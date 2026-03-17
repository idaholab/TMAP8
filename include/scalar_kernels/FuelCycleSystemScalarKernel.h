/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "ODETimeDerivative.h"
#include "ADScalarTimeDerivative.h"
#include "FunctorInterface.h"
#include "MooseTypes.h"

template <bool is_ad>
class FuelCycleSystemScalarKernelTempl
  : public std::conditional<is_ad, ADScalarTimeDerivative, ODETimeDerivative>::type,
    public FunctorInterface
{
  using Base = typename std::conditional<is_ad, ADScalarTimeDerivative, ODETimeDerivative>::type;

public:
  FuelCycleSystemScalarKernelTempl(const InputParameters & parameters);
  virtual bool isADObject() const override { return is_ad; };
  static InputParameters validParams();

protected:
  virtual GenericReal<is_ad> computeQpResidual() override;
  virtual Real computeQpJacobian();
  size_t _n_inputs;
  size_t _n_other_sources;
  size_t _n_other_sinks;
  std::vector<const VariableValue *> _input_vals;
  std::vector<const Moose::Functor<GenericReal<is_ad>> *> _input_fractions;
  const Moose::Functor<GenericReal<is_ad>> & _decay_constant;
  const Moose::Functor<GenericReal<is_ad>> & _residence_time;
  const Moose::Functor<GenericReal<is_ad>> & _leakage_rate;
  bool _pseudo_steady_state;
  bool _disable_residence_time;
  bool _is_implicit;
  const Moose::Functor<GenericReal<is_ad>> & _TBR;
  std::vector<const Moose::Functor<GenericReal<is_ad>> *> _other_sources;
  std::vector<const Moose::Functor<GenericReal<is_ad>> *> _other_sinks;
  const Moose::Functor<GenericReal<is_ad>> & _burn_rate;
};

typedef FuelCycleSystemScalarKernelTempl<false> FuelCycleSystemScalarKernel;
typedef FuelCycleSystemScalarKernelTempl<true> ADFuelCycleSystemScalarKernel;
