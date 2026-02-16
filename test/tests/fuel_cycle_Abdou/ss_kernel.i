# This input file re-creates the deuterium-tritium fuel cycle model
# described by Abdou et al (2021).
# "Physics and technology considerations for the deuterium-tritium fuel cycle
#   and conditions for tritium fuel self sufficiency" M Abdou & M Riva & A Ying
#   & C Day & A Loarte & L R Baylor & P Humrickhouse & T F Fuerst & S Cho
#   Nucl. Fusion 61 (2021) https://doi.org/10.1088/1741-4326/abbf35

# Since this is a 0D simulation, the mesh is only a single point. If high-fidelity
# models of specific components are required, the scalar variables can be coupled to
# "Field" variables which can vary spatially across the mesh, or could be co-ordinated
# with sub-apps.

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
    TBR = TBR
    burn_rate = tritium_burn_rate
    residence_time = residence1
    leakage_rate = epsilon1
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
  [TBR] #According to the PhD Thesis referenced in the paper,
    # this is the required Tritium Breeding Ratio (TBR)
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = 1.9247
  []
  [epsilon1] #BZ
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = 0
  []
  [residence1] #BZ
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = 86400 #1 day, Abdou
    #value = 8640-86400 EXOTIC-6-7-8
  []
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
  # This postprocessor exists to sum up the tritium inventory
  #  across the entirety of the system
  [T_BZ]
    type = ScalarVariable
    variable = T_01_BZ
    execute_on = TIMESTEP_END
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  dtmin = 1
  end_time = 10
  [TimeStepper]
    type = IterationAdaptiveDT
    growth_factor = 1.4
    dt = 5
    #timestep_limiting_function = 'catch_five_year'
    #max_function_change = 0.5
    #force_step_every_function_point = true
  []
  solve_type = 'PJFNK'
  nl_rel_tol = 1e-08
  nl_abs_tol = 1e-14
[]
[Outputs]
  csv = true
  console = true
[]
