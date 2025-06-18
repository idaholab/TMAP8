# This input file provides the structure for the infinite recombination case.

!include val-2f.params
!include val-2f_infinite_recombination.params
!include val-2f_base.i

[BCs]
  [left_concentration_sieverts]
    type = ADDirichletBC
    value = '${fparse 1e-10}'
    boundary = left
    variable = deuterium_concentration_W
  []
  [right_concentration_sieverts]
    type = ADDirichletBC
    value = '${fparse 1e-10}'
    boundary = right
    variable = deuterium_concentration_W
  []
[]

[Functions]
  [max_dt_size_function_inf]
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
                  if(t<${fparse 315000}, ${fparse 1e1}, ${fparse 1e3})))))))))))'
  []
[]

[Postprocessors]
  [flux_surface_left_sieverts]
    type = SideDiffusiveFluxAverage
    variable = deuterium_concentration_W
    boundary = 'left'
    diffusivity = 'diffusivity_W_nonAD'
    outputs = none
  []
  [scaled_flux_surface_left_sieverts]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2}}'
    value = flux_surface_left_sieverts
    execute_on = 'initial nonlinear linear timestep_end'
  []
  [flux_surface_right_sieverts]
    type = SideDiffusiveFluxAverage
    variable = deuterium_concentration_W
    boundary = 'right'
    diffusivity = 'diffusivity_W_nonAD'
    outputs = none
  []
  [scaled_flux_surface_right_sieverts]
    type = ScalePostprocessor
    scaling_factor = '${fparse 1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_right_sieverts
    execute_on = 'initial nonlinear linear timestep_end'
  []
  [total_flux]
    type = ParsedPostprocessor
    expression = 'scaled_flux_surface_left_sieverts + scaled_flux_surface_right_sieverts'
    pp_names = 'scaled_flux_surface_left_sieverts scaled_flux_surface_right_sieverts'
    execute_on = 'initial nonlinear linear timestep_end'
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_function_inf
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
  []
[]

[Outputs]
  file_base = 'val-2f_out_inf'
[]
