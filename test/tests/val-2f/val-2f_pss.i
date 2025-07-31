# This input file adds key blocks to the val-2f_base.i input file for the PSS study
# It is included in the subfile val-2f_pss_sub.i

[Functions]
  [experimental_data] # temperature (J), deuterium loss rate (at/s)
    type = PiecewiseLinear
    data_file = gold/0.1_dpa.csv
    scale_factor = '${fparse 1/(12e-3 * 15e-3)}'
    format = columns
    x_title = 'Temperature (K)'
    y_title = 'Deuterium Loss Rate (at/s)'
  []
  [time_window]
    type = ParsedFunction
    expression = 'if(t<${fparse 302400+2616.132582}, 0, 1)'
  []
  [experimental_data_interp_last_exp_data]
    type = ParsedFunction
    expression = 'if(T<911.93484, a,
                                  ${fparse 9952613485/(911.93484-1000)} * (T - 1000))'
    symbol_names = 'a T'
    symbol_values = 'experimental_data_interp1 temperature'
  []
[]

[Postprocessors]
  [time]
    type = TimePostprocessor
  []

  [experimental_data_interp1]
    type = FunctionValuePostprocessor
    function = experimental_data
    time = temperature
    execute_on = 'initial timestep_end'
  []
  [experimental_data_interp]
    type = FunctionValuePostprocessor
    function = experimental_data_interp_last_exp_data
    time = temperature
    execute_on = 'initial timestep_end'
  []
  [time_window]
    type = FunctionValuePostprocessor
    function = time_window
    time = time
    execute_on = 'initial timestep_end'
  []
  [diff_desorption]
    type = ParsedPostprocessor
    pp_names = 'experimental_data_interp total_flux time_window'
    expression = '(experimental_data_interp - total_flux)^2 * time_window'
    execute_on = 'initial timestep_end'
  []
  [diff_desorption_integral]
    type = TimeIntegratedPostprocessor
    value = diff_desorption
  []
  [objective]
    type = ParsedPostprocessor
    pp_names = 'diff_desorption_integral'
    expression = '1/diff_desorption_integral'
  []
[]

[Executioner]
  error_on_dtmin = false
[]
