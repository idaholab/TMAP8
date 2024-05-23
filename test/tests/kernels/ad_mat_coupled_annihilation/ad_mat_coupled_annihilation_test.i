[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
[]

[Variables]
  [c_a]
  []
  [c_b]
  []
[]

[ICs]
  [c_a_IC]
    type = ConstantIC
    variable = c_a
    value = 1
  []
  [c_b_IC]
    type = ConstantIC
    variable = c_b
    value = 1
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
  [MatReaction]
    type = ADMatCoupledDefectAnnihilation
    variable = c_b
    eq_concentration = 0.9
    v = 'c_a'
    coeff = 0.5
    annihilation_rate = K
  []
[]

[Materials]
  [K]
    type = ADParsedMaterial
    property_name = 'K'
    expression = '10'
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
  end_time = 1.
  num_steps = 60000
  dt = .2
  n_startup_steps = 0
[]

[Outputs]
  exodus = true
[]
