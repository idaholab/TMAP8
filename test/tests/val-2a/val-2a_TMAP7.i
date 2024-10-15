
nx_scale = 1

[Mesh]
  [cartesian_mesh_TMAP7]
    type = CartesianMeshGenerator
    dim = 1

    # #     0    1    2    3    4    5    6    7    8    9    num
    # dx = '1e-3 4e-3 4e-3 4e-3 4e-3 4e-3 1e-2 1e-1 1e-0 1e1
    #       5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1'
    # #     10        11        12        13        14        15        16        17        18

    #     num
    dx = '1e-3        ${fparse 5 * 4e-3}        1e-2        1e-1        1e0         1e1         ${fparse 9 * 5.4319e1}'
    ix = '${nx_scale} ${fparse 5 * ${nx_scale}} ${nx_scale} ${nx_scale} ${nx_scale} ${nx_scale} ${fparse 9 * ${nx_scale}}'
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
    Ko = '${fparse sqrt( ${dissociation_coefficient_parameter_enclos1} / ${recombination_coefficient_parameter_enclos1_TMAP7} )}'
    boundary = left
    enclosure_var = pressure_left
    temperature = ${Temperature}
    variable = concentration
    p = 0.5
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

  [concentration_source_func]
    type = ParsedFunction
    symbol_names = 'surface_flux_func pressure_func Kd_left_func Kr_left_func'
    symbol_values = 'surface_flux_func pressure_func Kd_left_func Kr_left_func'
    expression = 'if(x<5e-3,  0,
                  if(x<9e-3,  sqrt((0.15 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func),
                  if(x<13e-3, sqrt((0.70 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func),
                  if(x<17e-3, sqrt((0.15 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func), 0))))'
  []
[]

[Outputs]
  # checkpoint = true
  file_base = 'val-2a_TMAP7_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
[]
