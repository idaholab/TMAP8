# Verification Problem #1fb from TMAP4/TMAP7 V&V document
# Thermal transient in a slab whitout heat source

# Data used in TMAP4/TMAP7 case
length = '${units 4.0 m}'
initial_temperature = '${units 300 K}'
T_0 = '${units 300 K}'
T_1 = '${units 400 K}'
density = '${units 1 kg/m^3}'
specific_heat = '${units 10 J/kg/K}'
thermal_conductivity = '${units 10 W/m/K}'

[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = '${length}'
  nx = 20
[]

[Variables]
  # temperature parameter in the slab in K
  [temperature]
    initial_condition = '${initial_temperature}'
  []
[]

[Kernels]
  [heat]
    type = HeatConduction
    variable = temperature
  []
  [HeatTdot]
    type = HeatConductionTimeDerivative
    variable = temperature
  []
[]

[BCs]
  # The temerature on the right boundary of the slib is kept at 300 K
  [right_temp]
    type = DirichletBC
    boundary = right
    variable = temperature
    value = '${T_0}'
  []
  # The temerature on the right boundary of the slib is kept at 400 K
  [left_temp]
    type = DirichletBC
    boundary = left
    variable = temperature
    value = '${T_1}'
  []
[]

[Materials]
  # The diffusivity of the sample
  [diffusivity]
    type = GenericConstantMaterial
    prop_names = 'density  thermal_conductivity specific_heat'
    prop_values = '${density} ${thermal_conductivity} ${specific_heat}' # arbitrary values for diffusivity (=k/rho-Cp) to be 1.0
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
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  dt = 0.01
  end_time = 10
  automatic_scaling = true
[]

[VectorPostprocessors]
  # The temperature distribution on the sample at coresponding time
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${length} 0 0'
    num_points = 40
    sort_by = 'x'
    variable = temperature
    outputs = vector_postproc
  []
[]

[Outputs]
  exodus = true
  [vector_postproc]
    type = CSV
    sync_times = '0.1 0.5 1 5'
    sync_only = true
    file_base = 'ver-1fb_u_vs_x'
  []
[]
