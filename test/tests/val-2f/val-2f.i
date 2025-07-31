# This input file provides the structure for the finite recombination case.

dpa_specified = 0.1
damage = '${units dpa_specified dpa}'

!include val-2f.params
!include val-2f_finite_recombination.params
!include val-2f_base.i

[BCs]
  [left_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_concentration_W
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface
  []
  [right_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_concentration_W
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface
  []
[]

[Functions]
  [max_dt_size_function]
    type = ParsedFunction
    expression = 'if(t<${fparse 5}, ${fparse 1e-2},
                  if(t<${fparse 8}, ${fparse 1e2},
                  if(t<${fparse 12}, ${fparse 1e-2},
                  if(t<${fparse 20}, ${fparse 1e2},
                  if(t<${fparse 35}, ${fparse 1e-2},
                  if(t<${fparse 450}, ${fparse 1e2},
                  if(t<${fparse 5000}, ${fparse 1e1},
                  if(t<${fparse 11000}, ${fparse 1e2},
                  if(t<${fparse 13000}, ${fparse 1e1},
                  if(t<${fparse charge_time + cooldown_duration + 4500}, ${fparse 1e2},
                  if(t<${fparse 313000}, ${fparse 1e2},
                  if(t<${fparse 315000}, ${fparse 1e1}, ${fparse 1e3}))))))))))))'
  []
[]

[Materials]
  [recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = 'Kr'
    functor_names = 'temperature_bc_func'
    functor_symbols = 'temperature'
    expression = '${recombination_coefficient} * exp(- ${recombination_energy} / ${kb_eV} / temperature)'
    output_properties = 'Kr'
  []
  [flux_recombination_surface]
    type = ADDerivativeParsedMaterial
    coupled_variables = 'deuterium_concentration_W'
    property_name = 'flux_recombination_surface'
    material_property_names = 'Kr'
    expression = '- 2 * Kr * deuterium_concentration_W ^ 2'
  []
[]

[Postprocessors]
  [flux_surface_left]
    type = ADSideAverageMaterialProperty
    boundary = 'left'
    property = flux_recombination_surface
    outputs = none
  []
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_left
    execute_on = 'initial nonlinear linear timestep_end'
  []
  [flux_surface_right]
    type = ADSideAverageMaterialProperty
    boundary = 'right'
    property = flux_recombination_surface
    outputs = none
  []
  [scaled_flux_surface_right]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_right
    execute_on = 'initial nonlinear linear timestep_end'
  []
  [total_flux]
    type = ParsedPostprocessor
    expression = 'scaled_flux_surface_left + scaled_flux_surface_right'
    pp_names = 'scaled_flux_surface_left scaled_flux_surface_right'
    execute_on = 'initial nonlinear linear timestep_end'
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_function
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
  []
[]
