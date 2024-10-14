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

[Variables]
    [P1_T]
        initial_condition = ${P1_T}
    []
    [P2_T]
        initial_condition = ${P2_T}
    []

    [P1_D]
        initial_condition = ${P1_D}
    []
    [P2_D]
        initial_condition = ${P2_D}
    []
[]

[Kernels]
    # Equation for tritium in enclosure 1
    [timeDerivative_P1_T]
        type = ADTimeDerivative
        variable = P1_T
    []
    [enclosure1_T_outflux]
        type = ADMatReaction
        variable = P1_T
        v = P1_T
        reaction_rate = -${Q_by_V}
    []
    [enclosure1_T_influx]
        type = ADMatReaction
        variable = P1_T
        v = P2_T
        reaction_rate = ${Q_by_V}
    []

    # Equation for tritium in enclosure 2
    [timeDerivative_P2_T]
        type = ADTimeDerivative
        variable = P2_T
    []
    [enclosure2_T_outflux]
        type = ADMatReaction
        variable = P2_T
        v = P2_T
        reaction_rate = -${Q_by_V}
    []
    [enclosure2_T_influx]
        type = ADMatReaction
        variable = P2_T
        v = P1_T
        reaction_rate = ${Q_by_V}
    []

    # Equation for deuterium in enclosure 1
    [timeDerivative_P1_D]
        type = ADTimeDerivative
        variable = P1_D
    []
    [enclosure1_D_outflux]
        type = ADMatReaction
        variable = P1_D
        v = P1_D
        reaction_rate = -${Q_by_V}
    []
    [enclosure1_D_influx]
        type = ADMatReaction
        variable = P1_D
        v = P2_D
        reaction_rate = ${Q_by_V}
    []

    # Equation for deuterium in enclosure 2
    [timeDerivative_P2_D]
        type = ADTimeDerivative
        variable = P2_D
    []
    [enclosure2_D_outflux]
        type = ADMatReaction
        variable = P2_D
        v = P2_D
        reaction_rate = -${Q_by_V}
    []
    [enclosure2_D_influx]
        type = ADMatReaction
        variable = P2_D
        v = P1_D
        reaction_rate = ${Q_by_V}
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
