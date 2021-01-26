/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "Kernel.h"

// Forward Declarations
class RequirePositiveNCP;

template <>
InputParameters validParams<RequirePositiveNCP>();

class RequirePositiveNCP : public Kernel
{
public:
  RequirePositiveNCP(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

private:
  const unsigned int _v_var;
  const VariableValue & _v;
  const Real _coef;
};
