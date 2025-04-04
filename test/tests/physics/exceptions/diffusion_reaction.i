## This file is copied from ver-1g
# It is used to test exceptions and warnings from the SpeciesDiffusionReaction physics

R = 8.31446261815324 # Gas constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)
T = '${units 25 degC -> K}' # Temperature
Na = 6.02214076E23 # Avogadro's constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?na)

[Mesh]
  type = GeneratedMesh
  dim = 2
[]

[Physics]
  [SpeciesDiffusionReaction]
    [all]
      block = '0'
      species = 'c_a c_b c_ab'

      # Be careful to only enter the reaction once
      reacting_species = 'c_b'
      reacting_species_coefficients = '1'
      product_species = 'c_ab'
      product_species_coefficients = '1'
      reaction_coefficients = 'K' #'-1; -1; 1 1'
    []
  []
[]

[Materials]
  [K]
    type = ADParsedMaterial
    property_name = 'K'
    expression = '4.14e3' # units: molecule.micrometer^3/atom/second
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
  end_time = 40
  num_steps = 60000
  dt = .2
  n_startup_steps = 0
[]
