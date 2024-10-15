nx_scale = 1



[Mesh]
  [cartesian_mesh_TMAP4]
    type = CartesianMeshGenerator
    dim = 1
    #     num
    dx = '${fparse 5 * 4e-3}        1e-2        1e-1        1e0         1e1         ${fparse 10 * 4.88e1}'
    ix = '${fparse 5 * ${nx_scale}} ${nx_scale} ${nx_scale} ${nx_scale} ${nx_scale} ${fparse 10 * ${nx_scale}}'
  []
[]

[BCs]
  # [left_balance]
  #   type = ADFunctionNeumannBC
  #   boundary = left
  #   variable = concentration
  #   function = 0
  # []
  [left_balance]
    type = EquilibriumBC
    Ko = '${fparse sqrt( ${dissociation_coefficient_parameter_enclos1} / ${recombination_coefficient_parameter_enclos1_TMAP4} )}'
    boundary = left
    enclosure_var = pressure_left
    temperature = ${Temperature}
    variable = concentration
    p = 0.5
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
    expression = 'if(t<6420.0, ${pressure_high},
                  if(t<9420.0, ${pressure_low},
                  if(t<12480,  ${pressure_high},
                  if(t<14940,  ${pressure_low},
                  if(t<18180,  ${pressure_high}, ${pressure_low})))))'
  []

  [surface_flux_func]
    type = ParsedFunction
    expression = 'if(t<6420.0, ${flux_high},
                  if(t<9420.0, ${flux_low},
                  if(t<12480,  ${flux_high},
                  if(t<14940,  ${flux_low},
                  if(t<18180,  ${flux_high}, ${flux_low}))))) * 0.75'
  []

  [concentration_source_func]
    type = ParsedFunction
    symbol_names = 'surface_flux_func pressure_func Kd_left_func Kr_left_func'
    symbol_values = 'surface_flux_func pressure_func Kd_left_func Kr_left_func'
    expression = 'if(x<8e-3,  0,
                  if(x<12e-3, sqrt((0.25 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func),
                  if(x<16e-3, sqrt((1.00 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func),
                  if(x<20e-3, sqrt((0.25 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func), 0))))'
  []
[]

[Outputs]
  # checkpoint = true
  file_base = 'val-2a_TMAP4_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
[]
