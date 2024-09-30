k = '${units 1.380649e-23 J/K}' # Boltzmann constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)
T = '${units 1000 K}' # Temperature
V = '${units 1 m^3}' # Volume
S = '${units 25 cm^2 -> m^2}' # Area
p0_H2 = '${units 1e4 Pa}' # Initial pressure for H2
p0_D2 = '${units 1e4 Pa}' # Initial pressure for D2
peq_HD = '${fparse 2 * ${p0_H2} * ${p0_D2} / ( ${p0_H2} + ${p0_D2} )}' # pressure in equilibration for HD
end_time = '${units 10 s}'
E_x = '${units 0.2 eV -> J}'
E_c = '${units -0.01 eV -> J}'
E_b = '${units 0.00 eV -> J}'
nu = '${units 8.4e12 m/s}' # Debye frequency
M = '${fparse 2 * ${units 1.6605390666e-27 kg}}'
K_d = '${fparse 1 / sqrt(2 * pi * ${M} * ${k} * ${T}) * exp( - ${E_x} / ( ${k} * ${T} ) )}' # s / kg / m deposition rate
K_r = '${fparse ${nu} * exp(( ${E_c} - ${E_x} ) / ${k} / ${T})}' # m / s release rate
K_b = '${fparse ${nu} * exp( - E_b / ${k} / ${T} ) }' # m / s dissociation rate
D_s_lamda = '${fparse 5.3167e-7 * exp( -4529 / ${T} ) }' # m^4 / atom / s


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
  [c_H_dot_c_D]
  []
  [c_HD]
  []
  [p_H2]
    initial_condition = ${p0_H2}
  []
  [p_D2]
    initial_condition = ${p0_D2}
  []
[]

[AuxKernels]
  [c_H_dot_c_D_kernel]
    type = ParsedAux
    variable = c_H_dot_c_D
    # coupled_variables = 'p_HD c_H c_D'
    expression = ' ${peq_HD} * ${K_d} * ${K_b} / ${K_r} / 2 / ${D_s_lamda} '
  []
  [c_HD_kernel]
    type = ParsedAux
    variable = c_HD
    coupled_variables = 'p_HD c_H_dot_c_D'
    expression = ' (p_HD * ${K_d} + c_H_dot_c_D * 2 * ${D_s_lamda}) / ( ${K_r} + ${K_b} ) '
  []
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
[]

[Kernels]
  [timeDerivative_p_HD]
    type = ADTimeDerivative
    variable = p_HD
  []
  [MatReaction_p_HD_recombination]
    type = ADMatReactionFlexible
    variable = p_HD
    vs = 'c_H_dot_c_D'
    coeff = '${fparse 2 * ${S} * ${k} * ${T} / ${V} }'
    reaction_rate_name = '${D_s_lamda}'
  []
  [MatReaction_p_HD_dissociation]
    type = ADMatReactionFlexible
    variable = p_HD
    vs = 'c_HD'
    coeff = '${fparse - ${S} * ${k} * ${T} / ${V} }'
    reaction_rate_name = '${K_b}'
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
  nl_abs_tol = 1e-15

  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  start_time = 0.0
  end_time = ${end_time}
  num_steps = 6000
  dt = .1
  n_startup_steps = 0
  automatic_scaling = true
[]

[Outputs]
  exodus = true
  csv = true
[]
