[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
[]

[Variables]
  [./c1]
  [../]
  [./c2]
  [../]
[]

[ICs]
  [c1_IC]
    type = ConstantIC
    variable = c1
    value = 1
  []
  [c2_IC]
    type = ConstantIC
    variable = c2
    value = 1
  []
[]

[Kernels]
  [./timeDerivative_c1]
    type     = ADTimeDerivative
    variable = c1
  [../]
  [./timeDerivative_c2]
    type     = TimeDerivative
    variable = c2
  [../]
  [./MatReaction]
    type     = ADMatReactionFlexible
    variable = c2
    vs = 'c1'
    coeff = 0.5
    mob_name = K
  [../]
[]

[Materials]
  [./K]
    type = ADParsedMaterial
    f_name = 'K'
    function = '10'
  [../]
[]

[BCs]
  [./c1_neumann] # No flux on the sides
    type = NeumannBC
    variable = c1
    boundary = 'left right bottom top'
    value = 0
  [../]
  [./c2_neumann] # No flux on the sides
    type = NeumannBC
    variable = c2
    boundary = 'left right bottom top'
    value = 0
  [../]
[]

[Executioner]
  type                 = Transient
  scheme               = bdf2
  nl_rel_tol           = 1e-10

  solve_type = 'PJFNK'

  petsc_options_iname  = '-pc_factor_levels -pc_factor_mat_ordering_type'
  petsc_options_value  = '20 rcm'

  start_time      = 0.0
  end_time        = 1.
  num_steps       = 60000
  dt              = .2
  n_startup_steps = 0
[]

[Outputs]
  exodus = true
[]
