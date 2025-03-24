Q = '${units 0.1 m^3/s}'
V = '${units 1 m^3}'
Q_by_V = '${fparse Q / V}'

# Initial pressures of Tritium and Deuterium in enclosures 1 and 2
P1_T = '${units 1.0 Pa}'
P2_T = '${units 0 Pa}'
P1_D = '${units 0 Pa}'
P2_D = '${units 1.0 Pa}'

simulation_time = '${units 40 s}'
time_step_size = '${units 0.1 s}'

[Mesh]
    type = GeneratedMesh
    dim = 1
[]

[Physics]
    [SpeciesDiffusionReaction]
        [all]
            species                    = '  P1_T    P2_T    P1_D    P2_D'
            initial_conditions_species = '${P1_T} ${P2_T} ${P1_D} ${P2_D}'

            # Be careful to only enter the reaction once
            # The ";" are separations between reactions
            reacting_species      = 'P1_T; P2_T; P1_D; P2_D'
            product_species       = 'P2_T; P1_T; P2_D; P1_D'
            reaction_coefficients = '${Q_by_V} ${Q_by_V} ${Q_by_V} ${Q_by_V}'
            # the duplicate P2 reaction is here to match the old input
        []
    []
[]

[Postprocessors]
    [P1_T_value]
        type = ElementAverageValue
        variable = P1_T
        execute_on = 'INITIAL TIMESTEP_END'
    []
    [P2_T_value]
        type = ElementAverageValue
        variable = P2_T
        execute_on = 'INITIAL TIMESTEP_END'
    []

    [P1_D_value]
        type = ElementAverageValue
        variable = P1_D
        execute_on = 'INITIAL TIMESTEP_END'
    []
    [P2_D_value]
        type = ElementAverageValue
        variable = P2_D
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
    end_time = ${simulation_time}
    dt = ${time_step_size}
[]

[Outputs]
    csv = true
[]
