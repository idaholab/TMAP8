[Mesh]
  type = GeneratedMesh
  dim = 2
[]

[Variables]
  [c_a]
  []
  [c_b]
  []
  [c_ab]
  []
[]

[ICs]
  [c_a_IC]
    type = ConstantIC
    variable = c_a
    value = 2.43e-4 # units: number of atoms / micrometer^3
  []
  [c_b_IC]
    type = ConstantIC
    variable = c_b
    value = 2.43e-4
  []
  [c_ab_IC]
    type = ConstantIC
    variable = c_ab
    value = 0
  []
[]

[Kernels]
  [timeDerivative_c_a]
    type = ADTimeDerivative
    variable = c_a
  []
  [timeDerivative_c_b]
    type = TimeDerivative
    variable = c_b
  []
  [timeDerivative_c_ab]
    type = TimeDerivative
    variable = c_ab
  []
  [MatReaction_b]
    type = ADMatReactionFlexible
    variable = c_b
    vs = 'c_a c_b'
    coeff = -1
    reaction_rate_name = K
  []
  [MatReaction_a]
    type = ADMatReactionFlexible
    variable = c_a
    vs = 'c_b c_a'
    coeff = -1
    reaction_rate_name = K
  []
  [MatReaction_ab]
    type = ADMatReactionFlexible
    variable = c_ab
    vs = 'c_b c_a'
    coeff = 1
    reaction_rate_name = K
  []
[]

[Materials]
  [K]
    type = ADParsedMaterial
    f_name = 'K'
    function = '4.14e3' # units: molecule.micrometer^3/atom.second
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
  [c_ab_neumann] # No flux on the sides
    type = NeumannBC
    variable = c_ab
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
  [conc_ab]
    type = ElementAverageValue
    variable = c_ab
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  nl_rel_tol = 1e-10

  solve_type = 'NEWTON'

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  start_time = 0.0
  end_time = 40
  num_steps = 60000
  dt = .2
  n_startup_steps = 0
[]

[Outputs]
  exodus = true
  csv = true
[]
