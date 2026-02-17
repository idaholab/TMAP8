### This input file is the complete input files for the divertor monoblock case using the physics
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

C_mobile_init = ${units 1.0e-20 m^-3}
C_trapping_init = ${units 1.0e-15 m^-3}

alpha_t = 2.75e11           # 1e15 # same for all materials
trapping_energy = 0 # same for all materials
alpha_r = 8.4e12            # 1.0e13  # same for all materials

detrapping_energy_W = 11604.6 # = 1.00 eV    E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 2
detrapping_energy_Cu = 5802.3  # = 0.50eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
detrapping_energy_CuCrZr = 5802.3  # = 0.50eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4

# H diffusivity in W
diffusivity_W_D0 = 2.4e-7
diffusivity_W_Ea = ${units 4525.8 K}
# H solubility in W = (1.87e24)/(${tungsten_atomic_density}) [#/m^3] // # H solubility in W = (1.87e24)/(${tungsten_atomic_density}) [#/m^3]
solubility_W_1_D0 = 2.95e-5
solubility_W_1_Ea = ${units 12069.0 K}
solubility_W_2_D0 = 4.95e-8
solubility_W_2_Ea = ${units 6614.6 K}
# H diffusivity in Cu
diffusivity_Cu_D0 = 6.60e-7
diffusivity_Cu_Ea = ${units 4525.8 K}
# H solubility in Cu = (3.14e24)/(${tungsten_atomic_density}) [#/m^3]
solubility_Cu_D0 = 4.95e-5
solubility_Cu_Ea = ${units 6614.6 K}
# H diffusivity in CuCrZr
diffusivity_CuCrZr_D0 = 3.90e-7
diffusivity_CuCrZr_Ea = ${units 4873.9 K}
#H solubility in CuCrZr = (4.28e23)/(${tungsten_atomic_density}) [#/m^3]
solubility_CuCrZr_D0 = 6.75e-6
solubility_CuCrZr_Ea = ${units 4525.8 K}

# include sections of the input file shared with other inputs
!include divertor_monoblock_common_base.i
!include divertor_monoblock_mesh_base.i
!include divertor_monoblock_outputs_base_single_var.i

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
        expression = '1.16e2 + 7.11e-2 * temperature - 6.58e-5 * temperature^2 + 3.24e-8 * temperature^3 -5.45e-12 * temperature^4'    # ~ 132[J/kg-K]
        outputs = all
    []
    [thermal_conductivity_W]
        type = ADParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'temperature'
        block = 4
        # expression = '-7.8e-9 * temperature^3 + 5.0e-5 * temperature^2 - 1.1e-1 * temperature + 1.8e2'    # ~ 173.0 [ W/m-K]   from R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038,
        expression = '2.41e2 - 2.90e-1 * temperature + 2.54e-4 * temperature^2 - 1.03e-7 * temperature^3 + 1.52e-11 * temperature^4'    # ~ 173.0 [ W/m-K]
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
        expression = '3.16e2 + 3.18e-1 * temperature - 3.49e-4 * temperature^2 + 1.66e-7 * temperature^3'    # ~ 384 [J/kg-K]
        outputs = all
    []
    [thermal_conductivity_Cu]
        type = ADParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'temperature'
        block = 3
        # expression = '-3.9e-8 * temperature^3 + 3.8e-5 * temperature^2 - 7.9e-2 * temperature + 4.0e2'    # ~ 401.0  [ W/m-K] from R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038,
        expression = '4.21e2 - 6.85e-2 * temperature'    # ~ 400.0 [ W/m-K]
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
        # expression = '5.3e-7 * temperature^3 - 6.5e-4 * temperature^2 + 2.6e-1 * temperature + 3.1e2'    # ~ 320.0  [ W/m-K] from R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038,
        expression = '3.87e2 - 1.28e-1 * temperature'    # ~ 349 [ W/m-K]
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
