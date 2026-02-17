[Functions]
    [t_in_cycle]
        type = ParsedFunction
        expression = 't % ${plasma_cycle_time}'
    []
    # pulse between 0 and 1 following the plasma operation
    [pulse_time_function]
        type = ParsedFunction
        symbol_values = 't_in_cycle'
        symbol_names = 't_in_cycle'
        expression =   'if(t_in_cycle < ${plasma_ramp_time}, t_in_cycle/${plasma_ramp_time},
                        if(t_in_cycle < ${plasma_ss_end}, 1,
                        if(t_in_cycle < ${plasma_ramp_down_end}, 1 - (t_in_cycle-${plasma_ss_end})/${plasma_ramp_time}, 0.0)))'
    []
    [mobile_flux_bc_function]
        type = ParsedFunction
        symbol_values = 'pulse_time_function'
        symbol_names = 'pulse_time_function'
        expression = '(${plasma_max_flux} - ${plasma_min_flux}) * pulse_time_function + ${plasma_min_flux}'
    []
    [temperature_flux_bc_function]
        type = ParsedFunction
        symbol_values = 'pulse_time_function'
        symbol_names = 'pulse_time_function'
        expression = '(${plasma_max_heat} - ${plasma_min_heat}) * pulse_time_function + ${plasma_min_heat}'
    []
    [temperature_inner_func]
        type = ParsedFunction
        symbol_values = 'pulse_time_function'
        symbol_names = 'pulse_time_function'
        expression = '(${temperature_coolant_max} - ${temperature_initial}) * pulse_time_function + ${temperature_initial}'
    []
    [timestep_function]
        type = ParsedFunction
        symbol_values = 't_in_cycle'
        symbol_names = 't_in_cycle'
        expression = 'if(t_in_cycle < ${fparse 0.1 * plasma_ramp_time}   ,  20,
                      if(t_in_cycle < ${fparse 0.9 * plasma_ramp_time}   ,  40,
                      if(t_in_cycle < ${fparse 1.1 * plasma_ramp_time}   ,  20,
                      if(t_in_cycle < ${fparse plasma_ss_end - 20}       ,  40,
                      if(t_in_cycle < ${plasma_ss_end}                   ,  20,
                      if(t_in_cycle < ${fparse plasma_ramp_down_end - 10},   4,
                      if(t_in_cycle < ${fparse plasma_ramp_down_end + 10},  20,
                      if(t_in_cycle < ${fparse plasma_cycle_time - 100}  , 200,
                      if(t_in_cycle < ${plasma_cycle_time}               ,  40,  2)))))))))'
    []
[]
