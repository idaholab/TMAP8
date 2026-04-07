# This test case is designed to test the functionality of a single "steady-state"
# scalar kernel, and ensure consistent results. The example was stripped from
# the fuel_cycle_Abdou test case and simplified.

residence_time = ${units 1 day -> s}
[Mesh]
  type = GeneratedMesh
  dim = 1
  xmin = 0
  xmax = 1
  nx = 1
[]

[Variables]
  [T_01_BZ]
    family = SCALAR
    initial_condition = 42
  []
[]

[ScalarKernels]
  [I1] # Breeding Zone
    type = FuelCycleSystemScalarKernel
    TBR = tritium_breeding_ratio
    burn_rate = tritium_burn_rate
    residence_time = ${residence_time}
    leakage_rate = 0
    variable = 'T_01_BZ'
    steady_state = true
    other_sinks = 'device_T_consumption'
  []
[]

# These postprocessors define the constants referenced in
# the equations above. The value of any of these constants
# could be informed by more detailed models (using sub-apps
# and transfers), but it is important that the postprocessor
# is evaluated before the executioner attempts to solve the
# ODE, which is not the default behavior.
[Postprocessors]
  [device_T_consumption]
    type = ParsedPostprocessor
    expression = 'tritium_burn_rate/tritium_burn_fraction/tritium_fueling_efficiency'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    pp_names = 'tritium_burn_rate tritium_burn_fraction tritium_fueling_efficiency'
  []
  [tritium_burn_fraction]
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = 0.0036
  []
  [tritium_burn_rate]
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = 5.3125e-6 # 0.459 kg/day
  []
  [tritium_fueling_efficiency]
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = 0.25
  []
  [tritium_breeding_ratio]
    type = ParsedPostprocessor
    constant_names = 't_d residence_time'
    constant_expressions = '${fparse  log(2)/388800000} ${residence_time}'
    pp_names = 'tritium_fueling_efficiency tritium_burn_fraction tritium_burn_rate'
    pp_symbols = 'tritium_fueling_efficiency tritium_burn_fraction tritium_burn_rate'
    expression = 't_d/tritium_burn_rate + 1/tritium_burn_rate/residence_time
                 + 1/(tritium_fueling_efficiency * tritium_burn_fraction)'
    execute_on =  'INITIAL TIMESTEP_BEGIN'
  []
  [T_BZ]
    type = ScalarVariable
    variable = T_01_BZ
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  dtmin = 1
  end_time = 3e7
  [TimeStepper]
    type = IterationAdaptiveDT
    growth_factor = 1.4
    dt = 50
  []
  solve_type = 'PJFNK'
  nl_rel_tol = 1e-13
  nl_abs_tol = 1e-19
[]
[Outputs]
  csv = true
  console = true
[]
