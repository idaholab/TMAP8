
nx_scale = 5

[Mesh]
  [cartesian_mesh_TMAP7]
    type = CartesianMeshGenerator
    dim = 1
    #     num
    dx = '${units 1e-9 m -> mum}        ${fparse 5 * ${units 4e-9 m -> mum}}        ${units 1e-8 m -> mum}
          ${units 1e-7 m -> mum}        ${units 1e-6 m -> mum}                      ${units 1e-5 m -> mum}
          ${fparse 9 * ${units 5.4319e-5 m -> mum}}'
    ix = '${nx_scale}                  ${fparse 5 * ${nx_scale}}                  ${nx_scale}
          ${nx_scale}                  ${nx_scale}                                ${nx_scale}
          ${fparse 9 * ${nx_scale}}'
  []
[]

[Functions]
  ################## TMAP7
  [Kd_left_func]
    type = ParsedFunction
    expression = '${dissociation_coefficient_parameter_enclos1} * (1 - 0.999997 * exp(-1.2e-4 * t))'
  []

  [Kr_left_func]
    type = ParsedFunction
    expression = '${recombination_coefficient_parameter_enclos1_TMAP7} * (1 - 0.999997 * exp(-1.2e-4 * t))'
  []

  [Kr_left_time_dependent_func]
    type = ParsedFunction
    expression = '1 - 0.999997 * exp(-1.2e-4 * t)'
  []

  [pressure_func]
    type = ParsedFunction
    expression = 'if(t<5820.0, ${pressure_high},
                  if(t<9060.0, ${pressure_low},
                  if(t<12160,  ${pressure_high},
                  if(t<14472,  ${pressure_low},
                  if(t<17678,  ${pressure_high}, ${pressure_low})))))'
  []

  [surface_flux_func]
    type = ParsedFunction
    expression = 'if(t<5820.0, ${flux_high},
                  if(t<9060.0, ${flux_low},
                  if(t<12160,  ${flux_high},
                  if(t<14472,  ${flux_low},
                  if(t<17678,  ${flux_high}, ${flux_low}))))) * 0.75'
  []

  [source_distribution]
    type = ParsedFunction
    symbol_names = 'width depth'
    symbol_values = '${units 2.28e-9 m -> mum} ${units 11e-9 m -> mum}'
    expression = '1 / ( width * sqrt(2 * pi) ) * exp(-0.5 * ((x - depth) / width) ^ 2)'
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
                  if(t<9060.0-100, ${high_dt_max},
                  if(t<9060.0+100, ${low_dt_max},
                  if(t<12160-100,  ${high_dt_max},
                  if(t<12160+100,  ${low_dt_max},
                  if(t<14472-100,  ${high_dt_max},
                  if(t<14472+100,  ${low_dt_max},
                  if(t<17678-100,  ${high_dt_max},
                  if(t<17678+100,  ${low_dt_max}, ${high_dt_max}))))))))))'
  []
[]

[Outputs]
  file_base = 'val-2a_TMAP7_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
[]
