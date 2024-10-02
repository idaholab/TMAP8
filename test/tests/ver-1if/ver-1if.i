k = '${units 1.380649e-23 J/K}' # Boltzmann constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)
T = '${units 1000 K}' # Temperature
V = '${units 1 m^3}' # Volume
S = '${units 25 cm^2 -> m^2}' # Area
p0_H2 = '${units 1e4 Pa}' # Initial pressure for H2
p0_D2 = '${units 1e5 Pa}' # Initial pressure for D2
# peq_HD = '${fparse 2 * ${p0_H2} * ${p0_D2} / ( ${p0_H2} + ${p0_D2} )}' # pressure in equilibration for HD
simulation_time = '${units 3 s}'
K_s = '${units 1.0e24 atom/m^3/pa^0.5}' # atom/m^3/pa^0.5 recombination rate for H2 or D2
K_d = '${fparse 1.858e24 / sqrt( ${T} )}' # at/m^2/s/pa dissociation rate for HD
K_r = '${fparse K_d / K_s / K_s}'

[Mesh]
  type = GeneratedMesh
  dim = 2
[]

[Variables]
  [p_HD]
    initial_condition = 0
  []
[]

[AuxVariables]
  [p_H2]
    initial_condition = ${p0_H2}
  []
  [p_D2]
    initial_condition = ${p0_D2}
  []
  [c_H]
  []
  [c_D]
  []
[]

[AuxKernels]
  [p_H2_kernel]
    type = ParsedAux
    variable = p_H2
    coupled_variables = 'p_HD'
    expression = '${p0_H2} - p_HD / 2'
  []
  [p_D2_kernel]
    type = ParsedAux
    variable = p_D2
    coupled_variables = 'p_HD'
    expression = '${p0_D2} - p_HD / 2'
  []
  [c_H_kernel]
    type = ParsedAux
    variable = c_H
    coupled_variables = 'p_H2'
    expression = '${K_s} * sqrt(p_H2)'
  []
  [c_D_kernel]
    type = ParsedAux
    variable = c_D
    coupled_variables = 'p_D2'
    expression = '${K_s} * sqrt(p_D2)'
  []
[]

[Kernels]
  [timeDerivative_p_HD]
    type = ADTimeDerivative
    variable = p_HD
  []
  [MatReaction_p_HD_recombination]
    type = ADMatReactionFlexible
    variable = p_HD
    vs = 'c_H c_D'
    coeff = '${fparse 2 * ${k} * ${T} * ${S} / ${V}}'
    reaction_rate_name = '${K_r}'
  []
  [MatReaction_p_HD_dissociation]
    type = ADMatReactionFlexible
    variable = p_HD
    vs = 'p_HD'
    coeff = '${fparse -1 * ${k} * ${T} * ${S} / ${V}}'
    reaction_rate_name = '${K_d}'
  []
[]

[BCs]
  [p_HD_neumann] # No flux on the sides
    type = NeumannBC
    variable = p_HD
    boundary = 'left right bottom top'
    value = 0
  []
[]

[Postprocessors]
  [pressure_H2]
    type = ElementAverageValue
    variable = p_H2
    execute_on = 'initial timestep_end'
  []
  [pressure_D2]
    type = ElementAverageValue
    variable = p_D2
    execute_on = 'initial timestep_end'
  []
  [pressure_HD]
    type = ElementAverageValue
    variable = p_HD
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

  start_time = 0.0
  end_time = ${simulation_time}
  num_steps = 6000
  dt = .01
  n_startup_steps = 0
  automatic_scaling = true
[]

[Outputs]
  exodus = true
  csv = true
[]
