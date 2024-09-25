k_b = '${units 1.380649e-23 J/K}' # Boltzmann constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)
T = '${units 1000 K}' # Temperature
V = '${units 1 m^3}' # Volume
S = '${units 25 cm^2 -> m^2}' # Area
p0_H2 = '${units 1e4 Pa}' # Initial pressure for H2
p0_D2 = '${units 1e4 Pa}' # Initial pressure for D2
end_time = '${units 6 s}'
K_r = '5.88e-26' # m^4/atom/s recombination rate for H2 or D2
K_d = '${fparse 1.858e24 / sqrt( ${T} )}' # at/m^2/s/pa dissociation rate for HD
K_s = '${fparse sqrt( ${K_d} / ${K_r} )}' # Sieverts' solubility

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
    # expression = '0.5e4'
  []
  [p_D2_kernel]
    type = ParsedAux
    variable = p_D2
    coupled_variables = 'p_HD'
    expression = '${p0_D2} - p_HD / 2'
    # expression = '0.5e4'
  []
  [c_H2_kernel]
    type = ParsedAux
    variable = c_H
    coupled_variables = 'p_H2'
    expression = '${K_s} * sqrt(p_H2)'
  []
  [c_D2_kernel]
    type = ParsedAux
    variable = c_D
    coupled_variables = 'p_D2'
    expression = '${K_s} * sqrt(p_D2)'
  []
[]

[Kernels]
  [timeDerivative_p_HD]
    type = CoefTimeDerivative
    variable = p_HD
    Coefficient = '${fparse ${V} / ${k_b} / ${T} / ${S}}'
  []
  [MatReaction_p_HD_recombination]
    type = ADMatReactionFlexible
    variable = p_HD
    vs = 'c_H c_D'
    coeff = '2'
    reaction_rate_name = '${K_r}'
  []
  [MatReaction_p_HD_dissociation]
    type = ADMatReactionFlexible
    variable = p_HD
    vs = 'p_HD'
    coeff = '-1'
    reaction_rate_name = '${K_d}'
  []
[]

[Materials]
  [K]
    type = ADParsedMaterial
    property_name = 'K'
    expression = '2' # units: micrometer^3.second/atom
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
  end_time = ${end_time}
  num_steps = 6000
  dt = .01
  n_startup_steps = 0
  automatic_scaling = true
[]

# [Executioner]
#   type = Transient
#   dt = .01
#   end_time = ${end_time}
#   solve_type = PJFNK
#   dtmin = .01
#   l_max_its = 30
#   nl_max_its = 5
#   petsc_options = '-snes_converged_reason -ksp_monitor_true_residual'
#   petsc_options_iname = '-pc_type -mat_mffd_err'
#   petsc_options_value = 'lu       1e-5'
#   scheme = 'bdf2'
# []

[Outputs]
  exodus = true
  csv = true
[]
