//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "LMKernel.h"
#include "Assembly.h"
#include "MooseVariable.h"
#include "InputParameters.h"
#include "MooseArray.h"
#include "DualRealOps.h"
#include "SystemBase.h"

#include "libmesh/quadrature.h"

defineADValidParams(
    LMKernel,
    ADKernelValue,
    params.addRequiredCoupledVar("lm_variable", "The lagrange multiplier variable");
    params.addParam<Real>(
        "lm_sign",
        1.,
        "The sign to use in adding to the LM residual. This sign should be selected so that the "
        "diagonals for the LM block of the matrix are positive"););

template <ComputeStage compute_stage>
LMKernel<compute_stage>::LMKernel(const InputParameters & parameters)
  : ADKernelValue<compute_stage>(parameters),
    _lm_var(*this->getVar("lm_variable", 0)),
    _lm(adCoupledValue("lm_variable")),
    _lm_test(_lm_var.phi()),
    _lm_sign(getParam<Real>("lm_sign"))
{
}

template <ComputeStage compute_stage>
void
LMKernel<compute_stage>::computeResidual()
{
  std::vector<Real> strong_residuals(_qrule->n_points());

  precalculateResidual();

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    strong_residuals[_qp] = precomputeQpResidual() * _ad_JxW[_qp] * _ad_coord[_qp];

  // Primal residual
  prepareVectorTag(_assembly, _var.number());

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    for (_i = 0; _i < _test.size(); _i++)
      _local_re(_i) += _test[_i][_qp] * strong_residuals[_qp];

  accumulateTaggedLocalResidual();

  // LM residual
  prepareVectorTag(_assembly, _lm_var.number());

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    for (_i = 0; _i < _lm_test.size(); _i++)
      _local_re(_i) += _lm_sign * _lm_test[_i][_qp] * strong_residuals[_qp];

  accumulateTaggedLocalResidual();
}

template <>
void
LMKernel<JACOBIAN>::computeResidual()
{
}

template <ComputeStage compute_stage>
void
LMKernel<compute_stage>::computeJacobian()
{
  std::vector<DualReal> strong_residuals(_qrule->n_points());

  precalculateResidual();

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    strong_residuals[_qp] = precomputeQpResidual() * _ad_JxW[_qp] * _ad_coord[_qp];

  // Primal on-diagonal Jacobian
  prepareMatrixTag(_assembly, _var.number(), _var.number());

  size_t ad_offset = _var.number() * _sys.getMaxVarNDofsPerElem();

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    for (_i = 0; _i < _test.size(); _i++)
    {
      auto weak_residual = strong_residuals[_qp] * _test[_i][_qp];
      for (_j = 0; _j < _var.phiSize(); ++_j)
        _local_ke(_i, _j) += weak_residual.derivatives()[ad_offset + _j];
    }

  accumulateTaggedLocalMatrix();

  // LM on-diagonal Jacobian
  prepareMatrixTag(_assembly, _lm_var.number(), _lm_var.number());

  ad_offset = _lm_var.number() * _sys.getMaxVarNDofsPerElem();

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    for (_i = 0; _i < _lm_test.size(); _i++)
    {
      auto weak_residual = strong_residuals[_qp] * _lm_test[_i][_qp];
      for (_j = 0; _j < _lm_var.phiSize(); ++_j)
        _local_ke(_i, _j) += _lm_sign * weak_residual.derivatives()[ad_offset + _j];
    }

  accumulateTaggedLocalMatrix();
}

template <>
void
LMKernel<RESIDUAL>::computeJacobian()
{
}

template <ComputeStage compute_stage>
void
LMKernel<compute_stage>::computeADOffDiagJacobian()
{
  std::vector<DualReal> weak_primal_residuals(_test.size(), 0);
  std::vector<DualReal> weak_lm_residuals(_lm_test.size(), 0);

  precalculateResidual();
  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
  {
    auto value = precomputeQpResidual() * _ad_JxW[_qp] * _ad_coord[_qp];

    for (_i = 0; _i < _test.size(); ++_i)
      weak_primal_residuals[_i] += _test[_i][_qp] * value;
    for (_i = 0; _i < _lm_test.size(); ++_i)
      weak_lm_residuals[_i] += _lm_test[_i][_qp] * value;
  }

  auto & ce = _assembly.couplingEntries();
  for (const auto & it : ce)
  {
    MooseVariableFEBase & ivariable = *(it.first);
    MooseVariableFEBase & jvariable = *(it.second);

    unsigned int ivar = ivariable.number();
    unsigned int jvar = jvariable.number();

    const VariableTestValue * test_ptr;
    const std::vector<DualReal> * residuals;
    Real sign = 1;

    if (ivar == _var.number())
    {
      test_ptr = &_test;
      residuals = &weak_primal_residuals;
    }
    else if (ivar == _lm_var.number())
    {
      test_ptr = &_lm_test;
      residuals = &weak_lm_residuals;
      sign = -1;
    }
    else
      continue;

    const auto & test = *test_ptr;

    size_t ad_offset = jvar * _sys.getMaxVarNDofsPerElem();

    prepareMatrixTag(_assembly, ivar, jvar);

    mooseAssert(_local_ke.n() == jvariable.phiSize(),
                "The numbers of columns in the local Jacobian does not match the test space size "
                "of the coupled variable");

    if (ivar == _var.number())
      mooseAssert(_local_ke.m() == _test.size(),
                  "The numbers of rows in the local Jacobian does not match the test space size of "
                  "the primal variable");
    else
      mooseAssert(_local_ke.m() == _lm_test.size(),
                  "The numbers of rows in the local Jacobian does not match the test space size of "
                  "the lm variable");

    for (_i = 0; _i < test.size(); _i++)
      for (_j = 0; _j < jvariable.phiSize(); _j++)
        _local_ke(_i, _j) += sign * (*residuals)[_i].derivatives()[ad_offset + _j];

    accumulateTaggedLocalMatrix();
  }
}

template <>
void
LMKernel<RESIDUAL>::computeADOffDiagJacobian()
{
}

template class LMKernel<RESIDUAL>;
template class LMKernel<JACOBIAN>;
