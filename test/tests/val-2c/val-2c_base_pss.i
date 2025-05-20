# This input files adds key blocks to the val-2c_base.i input files for the PSS study

## Conversion
lengthscale = 1e18 # ${units 1 m^3 -> mum^3}

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
  []
  [concentration_hto]
    type = ParsedPostprocessor
    pp_names = 'hto_enclosure_edge_concentration'
    expression = 'hto_enclosure_edge_concentration * ${fparse decay_rate_tritium / Curie * lengthscale}'
  []
  [concentration_t2_interp]
    type = FunctionValuePostprocessor
    function = experimental_data_t2
    time = time
    execution_order_group = -2
  []
  [concentration_t2]
    type = ParsedPostprocessor
    pp_names = 't2_enclosure_edge_concentration'
    expression = 't2_enclosure_edge_concentration * ${fparse decay_rate_tritium / Curie * lengthscale}'
  []
  [diff_concentration_hto]
    type = ParsedPostprocessor # DifferencePostprocessor
    pp_names = 'concentration_hto_interp concentration_hto'
    expression = '(log(concentration_hto_interp) - log(concentration_hto))^2'
    execution_order_group = -1
    execute_on = 'TIMESTEP_END'
  []
  [diff_concentration_t2]
    type = ParsedPostprocessor # DifferencePostprocessor
    pp_names = 'concentration_t2_interp concentration_t2'
    expression = '(log(concentration_t2_interp) - log(concentration_t2))^2'
    execution_order_group = -1
    execute_on = 'TIMESTEP_END'
  []
  [objective1]
    type = ParsedPostprocessor # DifferencePostprocessor
    pp_names = 'diff_concentration_hto diff_concentration_t2'
    expression = '1/(diff_concentration_hto*5e3 + diff_concentration_t2)'
  []
  [objective]
    type = TimeIntegratedPostprocessor
    value = objective1
  []
[]

[Executioner]
  error_on_dtmin = false
[]
