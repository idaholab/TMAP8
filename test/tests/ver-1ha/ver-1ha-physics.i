P1 = '${units 1 Pa}'
R = '${units 8.31446261815324 J/K/mol}' # from PhysicalConstants
T = '${units 303 K}'
N_a = '${units 6.02214076e23 at/mol}' # from PhysicalConstants
Q = '${units 0.1 m^3/s }'
V2 = '${units 1 m^3}'
V3 = '${units 1 m^3}'
Q_by_V2 = '${fparse Q / V2}'
Q_by_V3 = '${fparse Q / V3}'

[Mesh]
    type = GeneratedMesh
    dim = 1
[]

[Physics]
    [SpeciesDiffusionReaction]
        [all]
            species = 'P2 P3'
            initial_conditions_species = '0 0'

            # Be careful to only enter the reaction once
            # The ";" are separations between reactions
            reacting_species      = 'P1; P2 ; P2; P2; P3'
            product_species       = 'P2;    ;   ; P3;   '
            reaction_coefficients = '${Q_by_V2} ${Q_by_V2} -${Q_by_V3} ${Q_by_V3} ${Q_by_V3}'
            # the duplicate P2 reaction is here to match the old input
        []
    []
[]

[AuxVariables]
    [P1]
        initial_condition = ${P1}
    []
[]

[Materials]
    [C2]
        type = ParsedMaterial
        coupled_variables = 'P2'
        property_name = 'C2'
        expression = 'P2*${N_a}/(${R}*${T})'
    []
    [C3]
        type = ParsedMaterial
        coupled_variables = 'P3'
        property_name = 'C3'
        expression = 'P3*${N_a}/(${R}*${T})'
    []
[]

[Postprocessors]
    [P2_value]
        type = ElementAverageValue
        variable = P2
        execute_on = 'INITIAL TIMESTEP_END'
    []
    [P3_value]
        type = ElementAverageValue
        variable = P3
        execute_on = 'INITIAL TIMESTEP_END'
    []
    [C2_value]
        type = ElementAverageMaterialProperty
        mat_prop = C2
        execute_on = 'INITIAL TIMESTEP_END'
    []
    [C3_value]
        type = ElementAverageMaterialProperty
        mat_prop = C3
        execute_on = 'INITIAL TIMESTEP_END'
    []
[]

[Executioner]
    type = Transient
    scheme = bdf2
    solve_type = 'NEWTON'
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
    automatic_scaling = true
    end_time = '${units 40 s}'
    dt = 0.1
[]

[Outputs]
    csv = true
[]
