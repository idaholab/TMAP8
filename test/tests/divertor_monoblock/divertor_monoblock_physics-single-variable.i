### This input file is the complete input file for the divertor monoblock case using the physics
### syntax with a single variable across materials.
### This input uses the `!include` feature to incorporate other input files

### Nomenclatures
### C_mobile        mobile H concentration
### C_trapped       trapped H concentration
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

C_mobile_init = 1.0e-20 # at.fraction

# Include sections of the input file shared with other inputs
!include divertor_monoblock_common_base.i
!include divertor_monoblock_mesh_base.i
!include divertor_monoblock_output_base.i

[AuxKernels]
  ############################## AuxKernels for W (block = 4)
  [Scaled_mobile_W]
    variable = Sc_C_mobile_W
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_mobile
  []
  [Scaled_trapped_W]
    variable = Sc_C_trapped_W
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_trapped
  []
  [total_W]
    variable = C_total_W
    type = ParsedAux
    expression = 'C_mobile + C_trapped'
    coupled_variables = 'C_mobile C_trapped'
  []
  [Scaled_total_W]
    variable = Sc_C_total_W
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_total_W
  []
  [empty_sites_W]
    variable = S_empty_W
    type = EmptySitesAux
    N = ${N_W}
    Ct0 = ${Ct0_W}
    trap_per_free = ${trap_per_free_W}
    trapped_concentration_variables = C_trapped
  []
  [scaled_empty_W]
    variable = Sc_S_empty_W
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_empty_W
  []
  [trapped_sites_W]
    variable = S_trapped_W
    type = NormalizationAux
    normal_factor = 1e0
    source_variable = C_trapped
  []
  [scaled_trapped_W]
    variable = Sc_S_trapped_W
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_trapped_W
  []
  [total_sites_W]
    variable = S_total_W
    type = ParsedAux
    expression = 'S_trapped_W + S_empty_W'
    coupled_variables = 'S_trapped_W S_empty_W'
  []
  [scaled_total_W]
    variable = Sc_S_total_W
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_total_W
  []
  ############################## AuxKernels for Cu (block = 3)
  [Scaled_mobile_Cu]
    variable = Sc_C_mobile_Cu
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_mobile
  []
  [Scaled_trapped_Cu]
    variable = Sc_C_trapped_Cu
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_trapped
  []
  [total_Cu]
    variable = C_total_Cu
    type = ParsedAux
    expression = 'C_mobile + C_trapped'
    coupled_variables = 'C_mobile C_trapped'
  []
  [Scaled_total_Cu]
    variable = Sc_C_total_Cu
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_total_Cu
  []
  [empty_sites_Cu]
    variable = S_empty_Cu
    type = EmptySitesAux
    N = ${N_Cu}
    Ct0 = ${Ct0_Cu}
    trap_per_free = ${trap_per_free_Cu}
    trapped_concentration_variables = C_trapped
  []
  [scaled_empty_Cu]
    variable = Sc_S_empty_Cu
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_empty_Cu
  []
  [trapped_sites_Cu]
    variable = S_trapped_Cu
    type = NormalizationAux
    normal_factor = 1e0
    source_variable = C_trapped
  []
  [scaled_trapped_Cu]
    variable = Sc_S_trapped_Cu
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_trapped_Cu
  []
  [total_sites_Cu]
    variable = S_total_Cu
    type = ParsedAux
    expression = 'S_trapped_Cu + S_empty_Cu'
    coupled_variables = 'S_trapped_Cu S_empty_Cu'
  []
  [scaled_total_Cu]
    variable = Sc_S_total_Cu
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_total_Cu
  []
  ############################## AuxKernels for CuCrZr (block = 2)
  [Scaled_mobile_CuCrZr]
    variable = Sc_C_mobile_CuCrZr
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_mobile
  []
  [Scaled_trapped_CuCrZr]
    variable = Sc_C_trapped_CuCrZr
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_trapped
  []
  [total_CuCrZr]
    variable = C_total_CuCrZr
    type = ParsedAux
    expression = 'C_mobile + C_trapped'
    coupled_variables = 'C_mobile C_trapped'
  []
  [Scaled_total_CuCrZr]
    variable = Sc_C_total_CuCrZr
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = C_total_CuCrZr
  []
  [empty_sites_CuCrZr]
    variable = S_empty_CuCrZr
    type = EmptySitesAux
    N = ${N_CuCrZr}
    Ct0 = ${Ct0_CuCrZr}
    trap_per_free = ${trap_per_free_CuCrZr}
    trapped_concentration_variables = C_trapped
  []
  [scaled_empty_CuCrZr]
    variable = Sc_S_empty_CuCrZr
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_empty_CuCrZr
  []
  [trapped_sites_CuCrZr]
    variable = S_trapped_CuCrZr
    type = NormalizationAux
    normal_factor = 1e0
    source_variable = C_trapped
  []
  [scaled_trapped_CuCrZr]
    variable = Sc_S_trapped_CuCrZr
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_trapped_CuCrZr
  []
  [total_sites_CuCrZr]
    variable = S_total_CuCrZr
    type = ParsedAux
    expression = 'S_trapped_CuCrZr + S_empty_CuCrZr'
    coupled_variables = 'S_trapped_CuCrZr S_empty_CuCrZr'
  []
  [scaled_total_CuCrZr]
    variable = Sc_S_total_CuCrZr
    type = NormalizationAux
    normal_factor = ${tungsten_atomic_density}
    source_variable = S_total_CuCrZr
  []
  [flux_y_W]
    type = DiffusionFluxAux
    diffusivity = diffusivity
    variable = flux_y
    diffusion_variable = C_mobile
    component = y
    block = 4
  []
  [flux_y_Cu]
    type = DiffusionFluxAux
    diffusivity = diffusivity
    variable = flux_y
    diffusion_variable = C_mobile
    component = y
    block = 3
  []
  [flux_y_CuCrZr]
    type = DiffusionFluxAux
    diffusivity = diffusivity
    variable = flux_y
    diffusion_variable = C_mobile
    component = y
    block = 2
  []
[]

[Postprocessors]
  ############################################################ Postprocessors for W (block = 4)
  [F_recombination]
    type = SideDiffusiveFluxAverage
    boundary = 'top'
    diffusivity = ${diffusivity_fixed}
    variable = Sc_C_total_W
  []
  [F_permeation]
    type = SideDiffusiveFluxAverage
    boundary = '2to1'
    diffusivity = ${diffusivity_fixed}
    variable = Sc_C_total_CuCrZr
  []

  [Int_C_mobile_W]
    type = ElementIntegralVariablePostprocessor
    variable = C_mobile
    block = 4
  []
  [ScInt_C_mobile_W]
    type = ScalePostprocessor
    value = Int_C_mobile_W
    scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_W]
    type = ElementIntegralVariablePostprocessor
    variable = C_trapped
    block = 4
  []
  [ScInt_C_trapped_W]
    type = ScalePostprocessor
    value = Int_C_trapped_W
    scaling_factor = ${scaling_factor}
  []
  [Int_C_total_W]
    type = ElementIntegralVariablePostprocessor
    variable = C_total_W
    block = 4
  []
  [ScInt_C_total_W]
    type = ScalePostprocessor
    value = Int_C_total_W
    scaling_factor = ${scaling_factor}
  []
  # ############################################################ Postprocessors for Cu (block = 3)
  [Int_C_mobile_Cu]
    type = ElementIntegralVariablePostprocessor
    variable = C_mobile
    block = 3
  []
  [ScInt_C_mobile_Cu]
    type = ScalePostprocessor
    value = Int_C_mobile_Cu
    scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_Cu]
    type = ElementIntegralVariablePostprocessor
    variable = C_trapped
    block = 3
  []
  [ScInt_C_trapped_Cu]
    type = ScalePostprocessor
    value = Int_C_trapped_Cu
    scaling_factor = ${scaling_factor_2}
  []
  [Int_C_total_Cu]
    type = ElementIntegralVariablePostprocessor
    variable = C_total_Cu
    block = 3
  []
  [ScInt_C_total_Cu]
    type = ScalePostprocessor
    value = Int_C_total_Cu
    scaling_factor = ${scaling_factor}
  []
  # ############################################################ Postprocessors for CuCrZr (block = 2)
  [Int_C_mobile_CuCrZr]
    type = ElementIntegralVariablePostprocessor
    variable = C_mobile
    block = 2
  []
  [ScInt_C_mobile_CuCrZr]
    type = ScalePostprocessor
    value = Int_C_mobile_CuCrZr
    scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_CuCrZr]
    type = ElementIntegralVariablePostprocessor
    variable = C_trapped
    block = 2
  []
  [ScInt_C_trapped_CuCrZr]
    type = ScalePostprocessor
    value = Int_C_trapped_CuCrZr
    scaling_factor = ${scaling_factor_2}
  []
  [Int_C_total_CuCrZr]
    type = ElementIntegralVariablePostprocessor
    variable = C_total_CuCrZr
    block = 2
  []
  [ScInt_C_total_CuCrZr]
    type = ScalePostprocessor
    value = Int_C_total_CuCrZr
    scaling_factor = ${scaling_factor}
  []
  ############################################################ Postprocessors for others
  [dt]
    type = TimestepSize
  []
  [temperature_top]
    type = PointValue
    variable = temperature
    point = '0 ${fparse block_size / 2} 0'
  []
  [temperature_tube]
    type = PointValue
    variable = temperature
    point = '0 ${radius_coolant} 0'
  []
  # limit timestep
  [timestep_max_pp]
    # s
    type = FunctionValuePostprocessor
    function = timestep_function
  []
[]

[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 ${fparse block_size / 2} 0'
    end_point = '0 ${radius_coolant} 0'
    num_points = 100
    sort_by = 'y'
    variable = 'C_total_W C_total_Cu C_total_CuCrZr C_mobile C_trapped flux_y temperature'
    execute_on = timestep_end
  []
[]
[GlobalParams]
  species_scaling_factors = '1'
  # The heat conduction physics preconditioning does not apply well across the other physics
  preconditioning = 'defer'
[]

# Define the variable outside of the Physics to prevent the Physics from defining it
# with a block restriction
[Variables]
  [C_trapped]
  []
[]

[Physics]
  [HeatConduction]
    [all]
      temperature_name = 'temperature'
      initial_temperature = ${temperature_initial}

      thermal_conductivity = 'thermal_conductivity'
      specific_heat = 'specific_heat'

      heat_flux_boundaries = 'top'
      boundary_heat_fluxes = 'temperature_flux_bc_function'
      fixed_temperature_boundaries = '2to1'
      boundary_temperatures = 'temperature_inner_func'
    []
  []
  [Diffusion]
    [all]
      variable_name = 'C_mobile'
      diffusivity_matprop = diffusivity
      initial_condition = ${C_mobile_init}

      neumann_boundaries = 'top'
      boundary_fluxes = 'mobile_flux_bc_function'
    []
  []
  [SpeciesTrapping]
    [all]
      species = 'C_trapped'
      mobile = 'C_mobile'
      block = '4'
      species_initial_concentrations = ${C_trapping_init}
      separate_variables_per_component = false

      temperature = temperature
      alpha_t = ${alpha_t}
      N = ${N_W}
      Ct0 = ${Ct0_W}
      trap_per_free = ${trap_per_free_W}
      trapping_energy = ${trapping_energy}

      alpha_r = ${alpha_r}
      detrapping_energy = ${detrapping_energy_W}
    []
    [Cu]
      species = 'C_trapped'
      mobile = 'C_mobile'
      block = '3'
      species_initial_concentrations = ${C_trapping_init}
      separate_variables_per_component = false
      temperature = temperature

      alpha_t = ${alpha_t}
      N = ${N_Cu}
      Ct0 = ${Ct0_Cu}
      trap_per_free = ${trap_per_free_Cu}
      trapping_energy = ${trapping_energy}

      alpha_r = ${alpha_r}
      detrapping_energy = ${detrapping_energy_Cu}
    []
    [CuCrZr]
      species = 'C_trapped'
      mobile = 'C_mobile'
      block = '2'
      species_initial_concentrations = ${C_trapping_init}
      separate_variables_per_component = false
      temperature = temperature

      alpha_t = ${alpha_t}
      N = ${N_CuCrZr}
      Ct0 = ${Ct0_CuCrZr}
      trap_per_free = ${trap_per_free_CuCrZr}
      trapping_energy = ${trapping_energy}

      alpha_r = ${alpha_r}
      detrapping_energy = ${detrapping_energy_CuCrZr}
    []
  []
[]

[Materials]
  ############################## Materials for W (block = 4)
  [diffusivity_W]
    type = ADParsedMaterial
    property_name = diffusivity
    coupled_variables = 'temperature'
    block = 4
    expression = '${diffusivity_W_D0}*exp(-${diffusivity_W_Ea}/temperature)'
    outputs = all
  []
  [solubility_W]
    type = ADParsedMaterial
    property_name = solubility_W
    coupled_variables = 'temperature'
    block = 4
    expression = '${solubility_W_1_D0}*exp(-${solubility_W_1_Ea}/temperature) + ${solubility_W_2_D0}*exp(-${solubility_W_2_Ea}/temperature)'
    outputs = all
  []
  [heat_transfer_W]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '${density_W}'
    block = 4
  []
  [specific_heat_W]
    type = ADParsedMaterial
    property_name = specific_heat
    coupled_variables = 'temperature'
    block = 4
    expression = '1.16e2 + 7.11e-2 * temperature - 6.58e-5 * temperature^2 + 3.24e-8 * temperature^3 -5.45e-12 * temperature^4' # [J/kg-K]
    outputs = all
  []
  [thermal_conductivity_W]
    type = ADParsedMaterial
    property_name = thermal_conductivity
    coupled_variables = 'temperature'
    block = 4
    expression = '2.41e2 - 2.90e-1 * temperature + 2.54e-4 * temperature^2 - 1.03e-7 * temperature^3 + 1.52e-11 * temperature^4' # [W/m-K]
    outputs = all
  []
  ############################## Materials for Cu (block = 3)
  [diffusivity_Cu]
    type = ADParsedMaterial
    property_name = diffusivity
    coupled_variables = 'temperature'
    block = 3
    expression = '${diffusivity_Cu_D0}*exp(-${diffusivity_Cu_Ea}/temperature)'
    outputs = all
  []
  [solubility_Cu]
    type = ADParsedMaterial
    property_name = solubility_Cu
    coupled_variables = 'temperature'
    block = 3
    expression = '${solubility_Cu_D0}*exp(-${solubility_Cu_Ea}/temperature)'
    outputs = all
  []
  [heat_transfer_Cu]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '${density_Cu}'
    block = 3
  []
  [specific_heat_Cu]
    type = ADParsedMaterial
    property_name = specific_heat
    coupled_variables = 'temperature'
    block = 3
    expression = '3.16e2 + 3.18e-1 * temperature - 3.49e-4 * temperature^2 + 1.66e-7 * temperature^3' # [J/kg-K]
    outputs = all
  []
  [thermal_conductivity_Cu]
    type = ADParsedMaterial
    property_name = thermal_conductivity
    coupled_variables = 'temperature'
    block = 3
    # expression = '-3.9e-8 * temperature^3 + 3.8e-5 * temperature^2 - 7.9e-2 * temperature + 4.0e2'    # ~ 401.0  [ W/m-K] from R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038,
    expression = '4.21e2 - 6.85e-2 * temperature' # [W/m-K]
    outputs = all
  []
  ############################## Materials for CuCrZr (block = 2)
  [diffusivity_CuCrZr]
    type = ADParsedMaterial
    property_name = diffusivity
    coupled_variables = 'temperature'
    block = 2
    expression = '${diffusivity_CuCrZr_D0}*exp(-${diffusivity_CuCrZr_Ea}/temperature)'
    outputs = all
  []
  [solubility_CuCrZr]
    type = ADParsedMaterial
    property_name = solubility_CuCrZr
    coupled_variables = 'temperature'
    block = 2
    expression = '${solubility_CuCrZr_D0}*exp(-${solubility_CuCrZr_Ea}/temperature)'
    outputs = all
  []
  [heat_transfer_CuCrZr]
    type = ADGenericConstantMaterial
    prop_names = 'density specific_heat'
    prop_values = '${density_CuCrZr} ${specific_heat_CuCrZr}'
    block = 2
  []
  [thermal_conductivity_CuCrZr]
    type = ADParsedMaterial
    property_name = thermal_conductivity
    coupled_variables = 'temperature'
    block = 2
    expression = '3.87e2 - 1.28e-1 * temperature' # [W/m-K]
    outputs = all
  []
  ############################## Materials for others
  [interface_jump_4to3]
    type = SolubilityRatioMaterial
    solubility_primary = solubility_W
    solubility_secondary = solubility_Cu
    boundary = '4to3'
    concentration_primary = C_mobile
    concentration_secondary = C_mobile
  []
  [interface_jump_3to2]
    type = SolubilityRatioMaterial
    solubility_primary = solubility_Cu
    solubility_secondary = solubility_CuCrZr
    boundary = '3to2'
    concentration_primary = C_mobile
    concentration_secondary = C_mobile
  []
[]
