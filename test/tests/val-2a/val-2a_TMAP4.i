nx_scale = 5

[Mesh]
  [cartesian_mesh_TMAP4]
    type = CartesianMeshGenerator
    dim = 1
    #     num
    dx = '${fparse 5 * ${units 4e-9 m -> mum}}  ${units 1e-8 m -> mum}  ${units 1e-7 m -> mum}
          ${units 1e-6 m -> mum}                ${units 1e-5 m -> mum}  ${fparse 10 * ${units 4.88e-5 m -> mum}}'
    ix = '${fparse 5 * ${nx_scale}}             ${nx_scale}             ${nx_scale}
          ${nx_scale}                           ${nx_scale}             ${fparse 10 * ${nx_scale}}'
  []
[]

[Functions]
  ################# TMAP4
  [Kd_left_func]
    type = ParsedFunction
    expression = '${dissociation_coefficient_parameter_enclos1} * (1 - 0.9999 * exp(-6e-5 * t))'
  []

  [Kr_left_func]
    type = ParsedFunction
    expression = '${recombination_coefficient_parameter_enclos1_TMAP4} * (1 - 0.9999 * exp(-6e-5 * t))'
  []

  [pressure_func]
    type = ParsedFunction
    expression = 'if(t<5820.0, ${pressure_high},
                  if(t<9056.0, ${pressure_low},
                  if(t<12062,  ${pressure_high},
                  if(t<14572,  ${pressure_low},
                  if(t<17678,  ${pressure_high}, ${pressure_low})))))'
  []

  [surface_flux_func]
    type = ParsedFunction
    expression = 'if(t<5820.0, ${flux_high},
                  if(t<9056.0, ${flux_low},
                  if(t<12062,  ${flux_high},
                  if(t<14572,  ${flux_low},
                  if(t<17678,  ${flux_high}, ${flux_low}))))) * 0.75'
  []

  [source_distribution]
    type = ParsedFunction
    symbol_names = 'width depth'
    symbol_values = '${units 2.4e-9 m -> mum} ${units 14e-9 m -> mum}'
    expression = '1.5 / ( width * sqrt(2 * pi) ) * exp(-0.5 * ((x - depth) / width) ^ 2)'
  []

  [concentration_source_norm_func]
    type = ParsedFunction
    symbol_names = 'source_distribution surface_flux_func'
    symbol_values = 'source_distribution surface_flux_func'
    expression = 'source_distribution * surface_flux_func'
  []

  [max_dt_size_func]
    type = ParsedFunction
    expression = 'if(t<5820.0-100, ${high_dt_max},
                  if(t<5820.0+100.0, ${low_dt_max},
                  if(t<9056.0-100, ${high_dt_max},
                  if(t<9056.0+100, ${low_dt_max},
                  if(t<12062-100,  ${high_dt_max},
                  if(t<12062+100,  ${low_dt_max},
                  if(t<14572-100,  ${high_dt_max},
                  if(t<14572+100,  ${low_dt_max},
                  if(t<17678-100,  ${high_dt_max},
                  if(t<17678+100,  ${low_dt_max}, ${high_dt_max}))))))))))'
  []
[]

[Outputs]
  file_base = 'val-2a_TMAP4_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
[]
