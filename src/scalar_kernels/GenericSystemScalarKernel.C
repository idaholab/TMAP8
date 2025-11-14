/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/
#include "GenericSystemScalarKernel.h"

// MOOSE includes
#include "Assembly.h"
#include "MooseVariableScalar.h"
#include "TMAP8Constants.h"

registerMooseObject("TMAP8App", GenericSystemScalarKernel);
registerMooseObject("TMAP8App", ADGenericSystemScalarKernel);

template <bool is_ad>
InputParameters
GenericSystemScalarKernelTempl<is_ad>::validParams()
{
  InputParameters params =
      is_ad ? ADScalarTimeDerivative::validParams() : ODETimeDerivative::validParams();
  params.addClassDescription("Implements a generic system component.");
  params.addParam<std::vector<VariableName>>("inputs", {}, "Variables which feed into this system");
  params.addParam<std::vector<VariableName>>("outputs", {}, "Variables this component feeds");
  // params.addParam<std::vector<MooseFunctorName>>(
  //     "input_fractions",
  //     std::vector<MooseFunctorName>({}),
  //     "Fraction of upstream variable coming into this system");
  // params.addParam<std::vector<MooseFunctorName>>(
  //     "output_fractions",
  //     std::vector<MooseFunctorName>({}),
  //     "Fraction of this variable which feeds into subsequent systems");
  params.addParam<MooseFunctorName>("decay_constant",
                                    PhysicalConstants::tritium_decay_const,
                                    "The decay constant of tritium (ln(2)/half-life)");
  params.addParam<bool>("steady_state",
                        false,
                        "Whether to apply a psuedo steady-state approximation (ignore dt term)");
  params.addParam<bool>(
      "is_implicit",
      false,
      "Whether an explicit (previous value calculation) or implicit (current value) is used");
  params.addParam<MooseFunctorName>("TBR", 0, "Tritium breeding ratio");
  params.addParam<MooseFunctorName>("burn_rate", 0, "Burn rate of tritium within this system");
  return params;
}

template <bool is_ad>
GenericSystemScalarKernelTempl<is_ad>::GenericSystemScalarKernelTempl(
    const InputParameters & parameters)
  : Base(parameters),
    _n_inputs(this->template getParam<std::vector<VariableName>>("inputs").size()),
    _input_vals(_n_inputs),
    _n_outputs(this->template getParam<std::vector<VariableName>>("outputs").size()),
    _output_vals(_n_outputs),
    _input_fractions(
        this->template getParam<std::vector<MooseFunctorName>>("input_fractions").size()),
    _output_fractions(
        this->template getParam<std::vector<MooseFunctorName>>("output_fractions").size()),
    _decay_constant(this->template getParam<Moose::Functor<GenericReal<is_ad>>>("decay_constant")),
    _pseudo_steady_state(this->template getParam<bool>("steady_state")),
    _is_implicit(this->template getParam<bool>("implicit_scheme")),
    _TBR(this->template getParam<Moose::Functor<GenericReal<is_ad>>>("TBR")),
    _burn_rate(this->template getParam<Moose::Functor<GenericReal<is_ad>>>("burn_rate"))
{
  mooseAssert(_n_inputs == _input_fractions.size(),
              "Input fractions must be defined with the same length as inputs.");
  mooseAssert(_n_outputs == _output_fractions.size(),
              "Output fractions must be defined with the same length as outputs.");
  for (size_t i = 0; i < _n_inputs; ++i)
  {
    //_input_variable_names[i] = coupledName("inputs", i);
    _input_vals[i] = &(ScalarCoupleable::coupledScalarValue("inputs", i));
    _input_fractions[i] = this->template getParam<std::vector<Moose::Functor<GenericReal<is_ad>>>>(
        "input_fractions")[i];
  }
  for (size_t i = 0; i < _n_outputs; ++i)
  {
    //_output_variable_names[i] = coupledName("outputs", i);
    _output_vals[i] = (this->template coupledScalarValue("outputs", i));
  }
}

template <bool is_ad>
GenericReal<is_ad>
GenericSystemScalarKernelTempl<is_ad>::computeQpResidual()
{
  GenericReal<is_ad> partial_residual = 0;
  const auto _qp = 0;
  const auto _state = _is_implicit ? Moose::currentState() : Moose::oldState();
  // for (unsigned int i = 0; i < _n_inputs; ++i)
  //{
  //   partial_residual += -_input_vals[i][_qp]; // * _input_fractions[i](_qp, _state);
  //}
  // for (unsigned int i = 0; i < _n_outputs; ++i)
  //{
  //  partial_residual += -_output_vals[i][_qp]; // * _output_fractions[i](_qp, _state);
  //}
  // partial_residual += _burn_rate;
  return partial_residual;
}

template class GenericSystemScalarKernelTempl<false>;
template class GenericSystemScalarKernelTempl<true>;
