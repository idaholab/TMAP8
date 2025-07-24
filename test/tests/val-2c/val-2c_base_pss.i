# This input files adds key blocks to the val-2c_base.i input files for the PSS study

## Conversion
lengthscale = 1e18 # ${units 1 m^3 -> mum^3}

times_measurement_HTO_start = 2440.415722 # s
times_measurement_HTO_end = 174765.6056 # s

times_measurement_T2_1 = 32003.54498 # s
times_measurement_T2_2 = 49281.50916 # s
times_measurement_T2_3 = 57804.64646 # s
times_measurement_T2_4 = 71561.68891 # s
time_measurement_T2 = 600 # s - assuming it takes 10 minutes to take the measurement
default_diff_value = 3 # value to be used as difference between modeling prediction and experimental data when experimental data is not available

[Functions]
  [experimental_data_hto] # time (s), concentrations (Ci/m^3)
    type = PiecewiseLinear
    data_file = gold/Experimental_data_HTO_concentration.csv
    scale_factor = 1
    format = columns
  []
  [experimental_data_t2] # time (s), concentrations (Ci/m^3)
    type = PiecewiseLinear
    data_file = gold/Experimental_data_T2_concentration.csv
    scale_factor = 1
    format = columns
  []
[]

[Postprocessors]
  [time]
    type = TimePostprocessor
    execution_order_group = -3
  []
  [concentration_hto_interp]
    type = FunctionValuePostprocessor
    function = experimental_data_hto
    time = time
    execution_order_group = -2
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [concentration_hto]
    type = ParsedPostprocessor
    pp_names = 'hto_enclosure_edge_concentration'
    expression = 'hto_enclosure_edge_concentration * ${fparse decay_rate_tritium / Curie * lengthscale}'
    execute_on = 'TIMESTEP_END'
  []
  [concentration_t2_interp]
    type = FunctionValuePostprocessor
    function = experimental_data_t2
    time = time
    execution_order_group = -2
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [concentration_t2]
    type = ParsedPostprocessor
    pp_names = 't2_enclosure_edge_concentration'
    expression = 't2_enclosure_edge_concentration * 2 * ${fparse decay_rate_tritium / Curie * lengthscale}'
    execute_on = 'TIMESTEP_END'
  []
  [diff_concentration_hto]
    type = ParsedPostprocessor
    pp_names = 'time concentration_hto_interp concentration_hto'
    expression = 'if((${times_measurement_HTO_1_start} <= time & time <= ${times_measurement_HTO_8_end}),
                  (log(concentration_hto_interp) - log(max(concentration_hto,1e-42)))^2*concentration_hto_interp*1e5, ${default_diff_value})' # the 1e-42 is to avoid the Inf at the first timesteps, which would make csvdiff fail
    execution_order_group = -1
    execute_on = 'TIMESTEP_END'
  []
  [diff_concentration_t2]
    type = ParsedPostprocessor
    pp_names = 'time concentration_t2_interp concentration_t2'
    expression = 'if((${fparse times_measurement_T2_1-time_measurement_T2/2} <= time & time <= ${fparse times_measurement_T2_1+time_measurement_T2/2})
                  |  (${fparse times_measurement_T2_2-time_measurement_T2/2} <= time & time <= ${fparse times_measurement_T2_2+time_measurement_T2/2})
                  |  (${fparse times_measurement_T2_3-time_measurement_T2/2} <= time & time <= ${fparse times_measurement_T2_3+time_measurement_T2/2})
                  |  (${fparse times_measurement_T2_4-time_measurement_T2/2} <= time & time <= ${fparse times_measurement_T2_4+time_measurement_T2/2}),
                  (log(concentration_t2_interp) - log(max(concentration_t2,1e-42)))^2, ${default_diff_value})' # the 1e-42 is to avoid the Inf at the first timesteps, which would make csvdiff fail
    execution_order_group = -1
    execute_on = 'TIMESTEP_END'
  []
  [objective1]
    type = ParsedPostprocessor
    pp_names = 'diff_concentration_hto diff_concentration_t2'
    expression = '(diff_concentration_hto^2+8000)/(30*diff_concentration_hto^4+400*diff_concentration_hto^2+1) + (diff_concentration_t2^2+45000)/(0.1*diff_concentration_t2^4+50*diff_concentration_t2^2+1)'
  []
  [objective]
    type = TimeIntegratedPostprocessor
    value = objective1
  []
[]

[Executioner]
  error_on_dtmin = false
[]

[Outputs]
  sync_times = '${fparse times_measurement_T2_1-time_measurement_T2/2} ${times_measurement_T2_1} ${fparse times_measurement_T2_1+time_measurement_T2/2}
                ${fparse times_measurement_T2_2-time_measurement_T2/2} ${times_measurement_T2_2} ${fparse times_measurement_T2_2+time_measurement_T2/2}
                ${fparse times_measurement_T2_3-time_measurement_T2/2} ${times_measurement_T2_3} ${fparse times_measurement_T2_3+time_measurement_T2/2}
                ${fparse times_measurement_T2_4-time_measurement_T2/2} ${times_measurement_T2_4} ${fparse times_measurement_T2_4+time_measurement_T2/2}'
[]
