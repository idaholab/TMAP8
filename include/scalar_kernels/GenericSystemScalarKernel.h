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
#include "MooseTypes.h"

template <bool is_ad>
class GenericSystemScalarKernelTempl
  : public std::conditional<is_ad, ADScalarTimeDerivative, ODETimeDerivative>::type
{
  using Base = typename std::conditional<is_ad, ADScalarTimeDerivative, ODETimeDerivative>::type;

public:
  GenericSystemScalarKernelTempl(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  virtual GenericReal<is_ad> computeQpResidual() final;
  size_t _n_inputs;
  std::vector<VariableName> _input_variable_names;
  std::vector<const VariableValue *> _input_vals;
  size_t _n_outputs;
  std::vector<VariableName> _output_variable_names;
  std::vector<const VariableValue *> _output_vals;
  std::vector<const Moose::Functor<GenericReal<is_ad>> *> _input_fractions;
  std::vector<const Moose::Functor<GenericReal<is_ad>> *> _output_fractions;
  const Moose::Functor<GenericReal<is_ad>> & _decay_constant;
  bool _pseudo_steady_state;
  bool _is_implicit;
  const Moose::Functor<GenericReal<is_ad>> & _TBR;
  const Moose::Functor<GenericReal<is_ad>> & _burn_rate;
};

typedef GenericSystemScalarKernelTempl<false> GenericSystemScalarKernel;
typedef GenericSystemScalarKernelTempl<true> ADGenericSystemScalarKernel;
