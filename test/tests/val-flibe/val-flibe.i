endtime = 140000 # simulation end time

R = 8.31446261815324 # Gas constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)

T = '${units 550 degC -> K}' # temperature

p_bnd = 1210 # pressure

L_Ni = '${units 2 mm -> m}' # nickel thickness
L_salt = '${units 8.1 mm -> m}' # salt thickness

num_nodes = 200 # (-)

[Mesh]
  [whole_domain]
    type = GeneratedMeshGenerator
    xmin = 0
    xmax = '${fparse L_Ni + L_salt}'
    dim = 1
    nx = ${num_nodes}
  []
  [block_1]
    type = ParsedSubdomainMeshGenerator
    input = whole_domain
    combinatorial_geometry = 'x <= ${L_Ni}'
    block_id = 0
  []
  [block_2]
    type = ParsedSubdomainMeshGenerator
    input = block_1
    combinatorial_geometry = 'x > ${L_Ni}'
    block_id = 1
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = block_2
    primary_block = '0' # Ni
    paired_block = '1' # salt
    new_boundary = 'interface'
  []
  [interface_other_side]
    type = SideSetsBetweenSubdomainsGenerator
    input = interface
    primary_block = '1' # salt
    paired_block = '0' # Ni
    new_boundary = 'interface_other'
  []
[]

[Variables]
  [conc_Ni]
    initial_condition = 1.0e-0
    block = 0
  []
  [conc_salt]
    initial_condition = 1.0e-0
    block = 1
  []
[]

[AuxVariables]
  [enclosure_pressure]
    family = SCALAR
    initial_condition = ${p_bnd}
  []
  [flux_x]
    order = FIRST
    family = MONOMIAL
  []
[]

[Kernels]
  [diff_Ni]
    type = ADMatDiffusion
    variable = conc_Ni
    diffusivity = diffusivity_Ni
    block = 0
  []
  [diff_salt]
    type = ADMatDiffusion
    variable = conc_salt
    diffusivity = diffusivity_salt
    block = 1
  []
  [time_diff_Ni]
    type = TimeDerivative
    variable = conc_Ni
    block = 0
  []
  [time_diff_salt]
    type = TimeDerivative
    variable = conc_salt
    block = 1
  []
[]

[AuxKernels]
  [flux_x_Ni]
    type = DiffusionFluxAux
    diffusivity = diffusivity_Ni
    variable = flux_x
    diffusion_variable = conc_Ni
    component = x
    block = 0
  []
  [flux_x_salt]
    type = DiffusionFluxAux
    diffusivity = diffusivity_salt
    variable = flux_x
    diffusion_variable = conc_salt
    component = x
    block = 1
  []
[]

[BCs]
  [left_flux]
    type = EquilibriumBC
    Ko = 0.564
    activation_energy = 15800.0
    boundary = left
    enclosure_var = enclosure_pressure
    temperature = ${T}
    variable = conc_Ni
    p = 0.5
  []
  [interfaceBC]
    type = EquilibriumBC
    Ko = 0.151119063
    activation_energy = 0.0
    boundary = 'interface'
    enclosure_var = conc_Ni
    temperature = ${T}
    variable = conc_salt
    p = 2.0
  []
  [right_flux]
    type = ADDirichletBC
    boundary = right
    variable = conc_salt
    value = 0.0
  []
[]

[Functions]
  [diffusivity_Ni_func]
    type = ParsedFunction
    symbol_names = 'T'
    symbol_values = '${T}'
    expression = '0.0000007*exp(-39500/(${R}*T))'
  []

  [diffusivity_salt_func]
    type = ParsedFunction
    symbol_names = 'T'
    symbol_values = '${T}'
    expression = '0.00000093*exp(-42000/(${R}*T))'
  []

  [solubility_Ni_func]
    type = ParsedFunction
    symbol_names = 'T'
    symbol_values = '${T}'
    expression = '0.564 * exp(-15800/(${R}*T))'
  []

  [solubility_salt_func]
    type = ParsedFunction
    symbol_names = 'T'
    symbol_values = '${T}'
    expression = '0.079 * exp(-35000/(${R}*T))'
  []
[]

[Materials]
  [diff_solu]
    type = ADGenericFunctionMaterial
    prop_names = 'diffusivity_Ni diffusivity_salt solubility_Ni solubility_salt'
    prop_values = 'diffusivity_Ni_func diffusivity_salt_func solubility_Ni_func solubility_salt_func'
    outputs = all
  []
  [converter_to_regular]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_Ni diffusivity_salt'
    reg_props_out = 'diffusivity_Ni_nonAD diffusivity_salt_nonAD'
  []
[]

[Postprocessors]
  [avg_flux_right]
    type = SideDiffusiveFluxAverage
    variable = conc_salt
    boundary = right
    diffusivity = diffusivity_salt_nonAD
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  steady_state_detection = true
  steady_state_start_time = 40000
  steady_state_tolerance = 1e-9
  scheme = bdf2 # bdf2 # crank-nicolson # explicit-euler
  solve_type = NEWTON # LINEAR # JFNK # NEWTON
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  l_max_its = 10
  nl_max_its = 13
  nl_rel_tol = 1e-8 # nonlinear relative tolerance
  nl_abs_tol = 1e-20 #1e-30 # nonlinear absolute tolerance
  l_tol = 1e-5 # 1e-3 - 1e-5 # linear tolerance
  end_time = ${endtime}
  automatic_scaling = true
  line_search = none
  dtmax = 10.0
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-10
    optimal_iterations = 18 # 6-10 or 18
    growth_factor = 1.1
    cutback_factor = 0.5
  []
[]

[Outputs]
  execute_on = timestep_end
  exodus = true
  [csv]
    type = CSV
    file_base = 'val-flibe_1210_550'
    time_step_interval = 500
  []
[]

[Dampers]
  [limit_salt]
    type = BoundingValueElementDamper
    variable = conc_salt
    max_value = 1e42
    min_value = -0.01
    min_damping = 0.001
  []
  [limit_Ni]
    type = BoundingValueElementDamper
    variable = conc_Ni
    max_value = 1e42
    min_value = -0.01
    min_damping = 0.001
  []
[]
