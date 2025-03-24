k_b = '${units 1.380649e-23 J/K}' # Boltzmann constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)
T = '${units 1000 K}' # Temperature
V = '${units 1 m^3}' # Volume
S = '${units 25 cm^2 -> m^2}' # Area
p0_A2 = '${units 1e4 Pa}' # Initial pressure for A2
p0_B2 = '${units 1e4 Pa}' # Initial pressure for B2
peq_AB = '${units ${fparse 2 * ${p0_A2} * ${p0_B2} / ( ${p0_A2} + ${p0_B2} )} Pa}' # pressure in equilibration for AB
simulation_time = '${units 6 s}'
time_interval = '${units 0.01 s}'
K_r = '${units 5.88e-26 m^4/at/s}' # recombination rate for A2 or B2
K_d = '${units ${fparse 1.858e24 / sqrt( ${T} )} at/m^2/s/Pa}' # dissociation rate for AB

[Mesh]
  type = GeneratedMesh
  dim = 2
[]

[Physics]
  [SpeciesDiffusionReaction]
    [all]
      species = 'p_AB'

      # Be careful to only enter the reaction once
      reacting_species = 'c_A_dot_c_B; p_AB'
      product_species =  'p_AB; '
      reaction_coefficients = '${fparse 2 * ${k_b} * ${T} * ${S} / ${V} * ${K_r}} ${fparse ${k_b} * ${T} * ${S} / ${V} * ${K_d}}'
    []
  []
[]

[AuxVariables]
  [p_A2]
    initial_condition = ${p0_A2}
  []
  [p_B2]
    initial_condition = ${p0_B2}
  []
  [c_A_dot_c_B]
  []
[]

[AuxKernels]
  [p_A2_kernel]
    type = ParsedAux
    variable = p_A2
    coupled_variables = 'p_AB'
    expression = '${p0_A2} - p_AB / 2'
  []
  [p_B2_kernel]
    type = ParsedAux
    variable = p_B2
    coupled_variables = 'p_AB'
    expression = '${p0_B2} - p_AB / 2'
  []
  [c_A_dot_c_B_kernel]
    type = ParsedAux
    variable = c_A_dot_c_B
    expression = '${K_d} * ${peq_AB} / 2 / ${K_r}'
  []
[]

[Postprocessors]
  [pressure_A2]
    type = ElementAverageValue
    variable = p_A2
    execute_on = 'initial timestep_end'
  []
  [pressure_B2]
    type = ElementAverageValue
    variable = p_B2
    execute_on = 'initial timestep_end'
  []
  [pressure_AB]
    type = ElementAverageValue
    variable = p_AB
    execute_on = 'initial timestep_end'
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10

  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  end_time = ${simulation_time}
  dt = ${time_interval}
  automatic_scaling = true
[]

[Outputs]
  csv = true
[]
