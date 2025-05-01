## Run this file with one of three input files to simulate various verification cases
## a. equal_conc.i       -> TMAP4 and TMAP7 equal concentration case
## b. diff_conc_TMAP4.i  -> TMAP4 different concentration case
## c. diff_conc_TMAP7.i  -> TMAP7 different concentration case
## Example: ~/projects/TMAP8/tmap8-opt -i ver-1g.i equal_conc.i

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
      reacting_species = 'c_b c_a'
      product_species = 'c_ab'
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

[Outputs]
  exodus = true
  csv = true
[]
