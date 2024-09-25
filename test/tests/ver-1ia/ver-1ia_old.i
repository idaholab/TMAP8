k_b = '1.380649e-23' # Boltzmann constant J/K (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)
T = '1000' # K Temperature
V = '1' # m^3 Volume
S = '0.0025' # m^2 Area
K_r = '5.88e-16' # at/m^3/Pa^0.5 recombination rate for H2 or D2
K_d = '${fparse 1.858e24 / ${T}^0.5}' # at.m^-2/s/pa dissociation rate for HD
K_s = '${fparse ${K_d}^0.5 / ${K_r}^0.5}' # Sieverts' solubility
p0_H2 = '${units 1e4 Pa}'
p0_D2 = '${units 1e4 Pa}'
end_time = 5 # s

[Mesh]
    type = GeneratedMesh
    dim = 2
[]

[ICs]
    # c_H2_IC = '${fparse ${K_s} * p0_H2^0.5 }'
    # c_D2_IC = '${fparse ${K_s} * p0_D2^0.5 }'
    # [ca_same_conc_IC]
    #     type = ConstantIC
    #     variable = c_H2
    #     value = '${c_H2_IC}'
    # []
    # [cb_same_conc_IC]
    #     type = ConstantIC
    #     variable = c_D2
    #     value = '${c_D2_IC}'
    # []
    # [p_H2_IC]
    #     type = ConstantIC
    #     value = p_H2
    #     variable = '${p0_H2}'
    # []
    # [p_D2_IC]
    #     type = ConstantIC
    #     value = p_D2
    #     variable = '${p0_D2}'
    # []
[]

[Variables]
    [p_H2]
        initial_condition = '${p0_H2}'
    []
    [p_D2]
        initial_condition = '${p0_D2}'
    []
    [p_HD]
        initial_condition = 0
    []
[]

[AuxVariables]
    [c_H2]
    []
    [c_D2]
    []
    [p_H2_sqrt]
    []
    [p_D2_sqrt]
    []
[]

[AuxKernels]
    [c_H2_kernel]
        type = ParsedAux
        variable = c_H2
        coupled_variables = 'p_H2'
        expression = '${K_s} * sqrt(p_H2)'
    []
    [c_D2_kernel]
        type = ParsedAux
        variable = c_D2
        coupled_variables = 'p_D2'
        expression = '${K_s} * sqrt(p_D2)'
    []
    [p_H2_sqrt_kernel]
        type = ParsedAux
        variable = p_H2_sqrt
        coupled_variables = 'p_H2'
        expression = 'sqrt(p_H2)'
    []
    [p_D2_sqrt_kernel]
        type = ParsedAux
        variable = p_D2_sqrt
        coupled_variables = 'p_D2'
        expression = 'sqrt(p_D2)'
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
        vs = 'c_H2 c_D2'
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

    [timeDerivative_p_H2]
        type = CoefTimeDerivative
        variable = p_H2
        Coefficient = '${fparse ${V} / ${k_b} / ${T} / ${S}}'
    []
    [MatReaction_p_H2_recombination]
        type = ADMatReactionFlexible
        variable = p_H2
        vs = 'c_H2 c_H2'
        coeff = '-1'
        reaction_rate_name = '${K_r}'
    []
    [MatReaction_p_H2_dissociation]
        type = ADMatReactionFlexible
        variable = p_H2
        vs = 'p_H2'
        coeff = '1'
        reaction_rate_name = '${K_d}'
    []

    [timeDerivative_p_D2]
        type = CoefTimeDerivative
        variable = p_D2
        Coefficient = '${fparse ${V} / ${k_b} / ${T} / ${S}}'
    []
    [MatReaction_p_D2_recombination]
        type = ADMatReactionFlexible
        variable = p_D2
        vs = 'c_D2 c_D2'
        coeff = '-1'
        reaction_rate_name = '${K_r}'
    []
    [MatReaction_p_D2_dissociation]
        type = ADMatReactionFlexible
        variable = p_D2
        vs = 'p_D2'
        coeff = '1'
        reaction_rate_name = '${K_d}'
    []

    # [timeDerivative_p_H2]
    #     type = ADTimeDerivative
    #     variable = p_H2
    # []
    # [timeDerivative_c_D2]
    #     type = TimeDerivative
    #     variable = p_D2
    # []
    # [timeDerivative_c_HD]
    #     type = TimeDerivative
    #     variable = p_HD
    # []
    # [MatReaction_D2]
    #     type = ADMatReactionFlexible
    #     variable = p_D2
    #     vs = 'p_H2_sqrt p_D2_sqrt'
    #     coeff = -0.5
    #     reaction_rate_name = K
    # []
    # [MatReaction_D2_rever]
    #     type = ADMatReactionFlexible
    #     variable = p_D2
    #     vs = 'p_HD'
    #     coeff = 0.5
    #     reaction_rate_name = 1
    # []
    # [MatReaction_H2]
    #     type = ADMatReactionFlexible
    #     variable = p_H2
    #     vs = 'p_H2_sqrt p_D2_sqrt'
    #     coeff = -0.5
    #     reaction_rate_name = K
    # []
    # [MatReaction_H2_rever]
    #     type = ADMatReactionFlexible
    #     variable = p_H2
    #     vs = 'p_HD'
    #     coeff = 0.5
    #     reaction_rate_name = 1
    # []
    # [MatReaction_HD]
    #     type = ADMatReactionFlexible
    #     variable = p_HD
    #     vs = 'p_H2_sqrt p_D2_sqrt'
    #     coeff = 1
    #     reaction_rate_name = K
    # []
    # [MatReaction_HD_rever]
    #     type = ADMatReactionFlexible
    #     variable = p_HD
    #     vs = 'p_HD'
    #     coeff = -1
    #     reaction_rate_name = 1
    # []
[]

[Materials]
    [K]
        type = ADParsedMaterial
        property_name = 'K'
        expression = '2' # units: micrometer^3.second/atom
    []
[]

[BCs]
    [c_H2_neumann] # No flux on the sides
        type = NeumannBC
        variable = p_H2
        boundary = 'left right bottom top'
        value = 0
    []
    [c_D2_neumann] # No flux on the sides
        type = NeumannBC
        variable = p_D2
        boundary = 'left right bottom top'
        value = 0
    []
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
    []
    [pressure_D2]
        type = ElementAverageValue
        variable = p_D2
    []
    [pressure_HD]
        type = ElementAverageValue
        variable = p_HD
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
    end_time = ${end_time}
    num_steps = 60000
    dt = .1
    n_startup_steps = 0
[]

[Outputs]
    exodus = true
    csv = true
[]
