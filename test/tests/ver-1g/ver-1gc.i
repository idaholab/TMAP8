conc_to_pressure_factor = 0.00414078

[Mesh]
  type = GeneratedMesh
  dim = 2
[]

[Variables]
  [c_a]
    initial_condition = 2.415e-4 # units: number of atoms / micrometer^3
  []
  [c_b]
    initial_condition = 0.0
  []
  [c_c]
    initial_condition = 0.0
  []
[]

# [ICs]
#   [c_a_IC]
#     type = ConstantIC
#     variable = c_a
#     value = 2.43e-4 # units: number of atoms / micrometer^3
#   []
#   [c_b_IC]
#     type = ConstantIC
#     variable = c_b
#     value = 1.215e-4
#   []
#   [c_c_IC]
#     type = ConstantIC
#     variable = c_c
#     value = 0
#   []
# []

[Kernels]
  [timeDerivative_c_a]
    type = ADTimeDerivative
    variable = c_a
  []
  [timeDerivative_c_b]
    type = TimeDerivative
    variable = c_b
  []
  [timeDerivative_c_c]
    type = TimeDerivative
    variable = c_c
  []
  [MatReaction_b1]
    type = ADMatReactionFlexible
    variable = c_b
    vs = 'c_b'
    coeff = -1
    reaction_rate_name = K2
  []
  [MatReaction_b2]
    type = ADMatReactionFlexible
    variable = c_b
    vs = 'c_a'
    coeff = 1
    reaction_rate_name = K1
  []
  [MatReaction_a]
    type = ADMatReactionFlexible
    variable = c_a
    vs = 'c_a'
    coeff = -1
    reaction_rate_name = K1
  []
  [MatReaction_ab]
    type = ADMatReactionFlexible
    variable = c_c
    vs = 'c_b'
    coeff = 1
    reaction_rate_name = K2
  []
[]

[Materials]
  [K1]
    type = ADParsedMaterial
    f_name = 'K1'
    function = '1.25e-2' # units: molecule.micrometer^3/atom.second
  []
  [K2]
    type = ADParsedMaterial
    f_name = 'K2'
    function = '0.25e-2' # units: molecule.micrometer^3/atom.second
  []
[]

[BCs]
  [c_a_neumann] # No flux on the sides
    type = NeumannBC
    variable = c_a
    boundary = 'left right bottom top'
    value = 0
  []
  [c_b_neumann] # No flux on the sides
    type = NeumannBC
    variable = c_b
    boundary = 'left right bottom top'
    value = 0
  []
  [c_c_neumann] # No flux on the sides
    type = NeumannBC
    variable = c_c
    boundary = 'left right bottom top'
    value = 0
  []
[]

[Postprocessors]
  [conc_a]
    type = ElementAverageValue
    variable = c_a
  []
  [conc_b]
    type = ElementAverageValue
    variable = c_b
  []
  [conc_c]
    type = ElementAverageValue
    variable = c_c
  []
  [pressure_a]
    type = ScalePostprocessor
    value = conc_a
    scaling_factor = '${conc_to_pressure_factor}'
  []
  [pressure_b]
    type = ScalePostprocessor
    value = conc_b
    scaling_factor = '${conc_to_pressure_factor}'
  []
  [pressure_c]
    type = ScalePostprocessor
    value = conc_c
    scaling_factor = '${conc_to_pressure_factor}'
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-15

  solve_type = 'NEWTON'

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  start_time = 0.0
  end_time = 900 #40
  num_steps = 60000
  dt = 2.0
  n_startup_steps = 0
  # automatic_scaling = true
  # compute_scaling_once = false
  # off_diagonals_in_auto_scaling = true
  # resid_vs_jac_scaling_param = 0.5
[]

[Outputs]
  exodus = true
  csv = true
[]
