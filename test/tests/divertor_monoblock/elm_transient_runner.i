inter_pwr = 10e6
coolant_temp = 552
elm_value = 1147e6
elm_duration = 1.32e-3
W_cond_factor = 1.0
### This case was published in:
### M. Shimada, P.-C. A. Simon, C. T. Icenhour, and G. Singh, “Toward a high-fidelity
### tritium transport modeling for retention and permeation experiments,” Fusion
### Engineering and Design, Volume 203, 2024, 114438, ISSN 0920-3796,
### https://doi.org/10.1016/j.fusengdes.2024.114438.

### This input uses the `!include` feature to incorporate other input files
### Nomenclatures
### C_mobile_j      mobile H concentration in "j" material, where j = CuCrZr, Cu, W
### C_trapped_j     trapped H concentration in "j" material, where j = CuCrZr, Cu, W
### C_total_j       total H concentration in "j" material, where j = CuCrZr, Cu, W
###
### S_empty_j       empty site concentration in "j" material, where j = CuCrZr, Cu, W
### S_trapped_j     trapped site concentration in "j" material, where j = CuCrZr, Cu, W
### S_total_j       total site H concentration in "j" material, where j = CuCrZr, Cu, W
###
### F_permeation    permeation flux
### F_recombination recombination flux
###
### Sc_             Scaled
### Int_            Integrated
### ScInt_          Scaled and integrated

!include divertor_monoblock_explicit_base.i

Functions/mobile_flux_bc_function/expression := "if(t<2e2, (${inter_pwr}*7.9e-13/1e7),
if(t<(2e2+${elm_duration}*1/3),
(${inter_pwr}*7.9e-13/1e7)+(t-2e2)/(${elm_duration}*1/3)*((${elm_value}*7.9e-13/1e7)-(${inter_pwr}*7.9e-13/1e7)),
if(t<(2e2+(${elm_duration}*1/3)+(${elm_duration}*2/3)),
(${elm_value}*7.9e-13/1e7)-(t-2e2-(${elm_duration}*1/3))/(${elm_duration}*2/3)*((${elm_value}*7.9e-13/1e7)-(${inter_pwr}*7.9e-13/1e7)), (${inter_pwr}*7.9e-13/1e7))))" #TODO remove this"
Functions/temperature_inner_func/expression := "${coolant_temp}"
Executioner/petsc_options_iname := '-pc_type'
Executioner/petsc_options_value := 'lu'
Executioner/nl_rel_tol := 1e-5
Executioner/nl_abs_tol := 1e-6
Executioner/end_time := 2.01e2
Executioner/dtmin := 1e-6
Executioner/nl_max_its := 36
Executioner/TimeStepper/dt := 125
Executioner/TimeStepper/growth_factor := 2.0
[Executioner]
  [TimeStepper]
    time_t = '0 2e2 2.01e2'
    time_dt = '100 0.0001 100'
  []
  error_on_dtmin = False
[]
Postprocessors/F_recombination/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/F_permeation/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_mobile_W/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/ScInt_C_mobile_W/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_trapped_W/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_total_W/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_mobile_Cu/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_trapped_Cu/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/ScInt_C_trapped_Cu/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_total_Cu/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/ScInt_C_total_Cu/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_mobile_CuCrZr/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/ScInt_C_mobile_CuCrZr/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_trapped_CuCrZr/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/ScInt_C_trapped_CuCrZr/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_total_CuCrZr/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/ScInt_C_total_CuCrZr/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/temperature_top/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/temperature_tube/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/timestep_max_pp/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/unused_parameters/expression := '${plasma_max_flux} + ${plasma_min_flux} + ${temperature_initial} + ${temperature_coolant_max} + ${num_sectors}
 + ${rings_H2O} + ${rings_CuCrZr} + ${rings_Cu} + ${rings_W}'
[Postprocessors]
  [Tritium_SideFluxIntegral]
    type = SideDiffusiveFluxIntegral
    boundary = '2to1'
    diffusivity = diffusivity_CuCrZr_nonAD
    variable = Sc_C_total_CuCrZr
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [Scaled_Tritium_Flux]
    type = ParsedPostprocessor
    expression = '5.01e-24 * Tritium_SideFluxIntegral'
    pp_names = Tritium_SideFluxIntegral
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [coolant_heat_flux]
    # units of W/m2
    type = SideDiffusiveFluxAverage
    boundary = '2to1'
    diffusivity = thermal_conductivity_CuCrZr
    variable = temperature
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_temperature_W]
    type = ElementExtremeValue
    block = 4
    variable = 'temperature'
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_temperature_Cu]
    type = ElementExtremeValue
    block = 3
    variable = 'temperature'
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_temperature_CuCrZr]
    type = ElementExtremeValue
    block = 2
    variable = 'temperature'
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [avg_temperature_W]
    type = ElementAverageValue
    variable = temperature
    block = 4
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [avg_temperature_Cu]
    type = ElementAverageValue
    variable = temperature
    block = 3
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [avg_temperature_CuCrZr]
    type = ElementAverageValue
    variable = temperature
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_concentration_W]
    type = ElementExtremeValue
    variable = 'C_total_W'
    value_type = max
    block = 4
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_concentration_Cu]
    type = ElementExtremeValue
    variable = 'C_total_Cu'
    value_type = max
    block = 3
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_concentration_CuCrZr]
    type = ElementExtremeValue
    variable = 'C_total_CuCrZr'
    value_type = max
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [area_W]
    type = VolumePostprocessor
    block = 4
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [area_Cu]
    type = VolumePostprocessor
    block = 3
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [area_CuCrZr]
    type = VolumePostprocessor
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [total_retention]
    type = SumPostprocessor
    values = 'ScInt_C_total_W ScInt_C_total_Cu ScInt_C_total_CuCrZr'
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  ### TIME MAXIMA
  [time_max_T_W]
    type = TimeExtremeValue
    postprocessor = max_temperature_W
    output_type = extreme_value
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [time_max_T_Cu]
    type = TimeExtremeValue
    postprocessor = max_temperature_Cu
    output_type = extreme_value
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [time_max_T_CuCrZr]
    type = TimeExtremeValue
    postprocessor = max_temperature_CuCrZr
    output_type = extreme_value
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
[]

VectorPostprocessors/line/execute_on := 'NONE'
Materials/thermal_conductivity_W/expression := '${W_cond_factor}*(2.41e2 - 2.90e-1 * temperature + 2.54e-4 * temperature^2 - 1.03e-7 * temperature^3 + 1.52e-11 * temperature^4)'

[Outputs]
  execute_on = 'none'
[]


[ICs]
  [t_ic]
    type = FunctionIC
    function = temp_ss
    variable = temperature
  []
[]
