### Nomenclatures                                                                                  # Nelson S. Comments/Annotations
###
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
### ScInt_          Scaled and integrated                                                          # Nelson S. Comments/Annotations
### CHANGES ###
### 1. Added additional outputs for:
###    a. Average and maximum temperatures for all materials
###    b. Maximum tritium concentrations for all materials
###    c. Temperature and tritium flux along block boundaries
### 2. Converted to continous-pulse for reduced computation time
###    a. 1 Pulse = (500s)*(tritium flux) fluence
###    b.
temperature_top_val = 1.0e7
C_mob_W_top_flux_val = 7.90e-13
temperature_tube_val = 552

[Controls]
  [stochastic]
    # Sends data to Stochastic
    type = SamplerReceiver
  []
[]
### This input uses the `!include` feature to incorporate other input files
!include divertor_monoblock_explicit_base.i

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


# Geometry and design
num_sectors := 12
rings_CuCrZr := 6
rings_Cu := 4
rings_W := 22
Functions/mobile_flux_bc_function/expression := '${fparse C_mob_W_top_flux_val}'
Functions/temperature_flux_bc_function/expression := '${fparse temperature_top_val}'
Functions/temperature_inner_func/expression := '${fparse temperature_tube_val}'
Functions/timestep_function/expression := 'if(t<100, 25, 400)'
Executioner/nl_rel_tol := 1e-2
Executioner/nl_abs_tol := 1e-1
Executioner/end_time := 2.5e1
Executioner/nl_max_its := 24
Executioner/TimeStepper/growth_factor := 2.0
Postprocessors/F_recombination/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/F_permeation/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_mobile_W/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_trapped_W/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_total_W/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/Int_C_mobile_Cu/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
Postprocessors/ScInt_C_mobile_Cu/execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
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
Postprocessors/unused_parameters/expression := '${num_sectors} + ${rings_H2O} + ${rings_CuCrZr} + ${rings_Cu} + ${rings_W}
                  + ${temperature_coolant_max} + ${plasma_max_heat} + ${plasma_min_heat}
                  + ${plasma_max_flux} + ${plasma_min_flux}'
Variables/temperature/initial_condition= ${temperature_initial}
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
[]
[Outputs]
  # Control outputs, include exodus and csv.
  execute_on = 'none'
[]
