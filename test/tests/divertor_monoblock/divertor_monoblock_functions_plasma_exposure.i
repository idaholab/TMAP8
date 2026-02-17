

[Functions]
    [t_in_cycle]
        type = ParsedFunction
        expression = 't % ${plasma_cycle_time}'
    []
    [plasma_time_function]
        type = ParsedFunction
        symbol_values = 't_in_cycle'
        symbol_names = 't_in_cycle'
        expression =   'if(t_in_cycle < ${plasma_ramp_time}, t_in_cycle/${plasma_ramp_time},
                        if(t_in_cycle < ${plasma_ss_end}, 1,
                        if(t_in_cycle < ${plasma_ramp_down_end}, 1 - (t_in_cycle-${plasma_ss_end})/${plasma_ramp_time}, 0.0)))'
    []
    [mobile_flux_bc_function]
        type = ParsedFunction
        symbol_values = 'plasma_time_function'
        symbol_names = 'time_function'
        expression = '(${plasma_max_flux} - ${plasma_min_flux}) * time_function + ${plasma_min_flux}'
    []
    ### Heat flux of 10MW/m^2 at steady state
    [temp_flux_bc_function]
        type = ParsedFunction
        symbol_values = 'plasma_time_function'
        symbol_names = 'time_function'
        expression = '(${plasma_max_heat} - ${plasma_min_heat}) * time_function + ${plasma_min_heat}'
    []
    ### Maximum coolant temperature of 552K at steady state
    [temp_inner_func]
        type = ParsedFunction
        symbol_values = 't_in_cycle'
        symbol_names = 't_in_cycle'
        expression =   'if(t_in_cycle < 100.0, ${temperature_initial} + (552-${temperature_initial})*t_in_cycle/100,
                        if(t_in_cycle < 500.0, 552,
                        if(t_in_cycle < 600.0, 552.0 - (552-${temperature_initial})*(t_in_cycle-500)/100, ${temperature_initial})))'
    []
    [timestep_function]
        type = ParsedFunction
        symbol_values = 't_in_cycle'
        symbol_names = 't_in_cycle'
        expression = 'if(t_in_cycle <   10.0,  20,
                      if(t_in_cycle <   90.0,  40,
                      if(t_in_cycle <  110.0,  20,
                      if(t_in_cycle <  480.0,  40,
                      if(t_in_cycle <  500.0,  20,
                      if(t_in_cycle <  590.0,   4,
                      if(t_in_cycle <  610.0,  20,
                      if(t_in_cycle < 1500.0, 200,
                      if(t_in_cycle < 1600.0,  40,  2)))))))))'
    []
[]
