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

# geometry and design
radius_coolant = ${units 6.0 mm -> m}
radius_CuCrZr = ${units 7.5 mm -> m}
radius_Cu = ${units 8.5 mm -> m}
block_size = ${units 28 mm -> m}
num_sectors = 36 # (-) defines mesh size

# operation conditions
temperature_initial = ${units 300.0 K}
temperature_coolant_max = ${units 552.0 K}
C_mobile_CuCrZr_DirichletBC_Coolant = 1.0e-18

# material properties
tungsten_atomic_density = ${units 6.338e28 m^-3}
density_W = 19300                # [g/m^3]
density_Cu = 8960.0               # [g/m^3]
density_CuCrZr = 8900.0 # [g/m^3]
specific_heat_CuCrZr = 390.0     # [ W/m-K], [J/kg-K]

plasma_ramp_time = 100.0 #s
plasma_ss_duration = 400.0 #s
plasma_cycle_time = 1600.0 #s (3.0e4 s plasma, 2.0e4 SSP)

plasma_ss_end = ${fparse plasma_ramp_time + plasma_ss_duration} #s
plasma_ramp_down_end = ${fparse plasma_ramp_time + plasma_ss_duration + plasma_ramp_time} #s

plasma_max_heat = 1.0e7 #W/m^2 # Heat flux of 10MW/m^2 at steady state
plasma_min_heat = 0.0 # W/m^2 # no flux while the pulse is off.

### Maximum mobile flux of 7.90e-13 at the top surface (1.0e-4 [m])
### 1.80e23/m^2-s = (5.0e23/m^2-s) *(1-0.999) = (7.90e-13)*(${tungsten_atomic_density})/(1.0e-4)  at steady state
plasma_max_flux = 7.90e-13
plasma_min_flux = 0.0

# include sections of the input file shared with other inputs
!include divertor_monoblock_mesh_base.i
!include divertor_monoblock_functions_plasma_exposure.i
!include divertor_monoblock_outputs_base.i
!include divertor_monoblock_executioner.i

[Problem]
    # TODO: add support for reference residual problem in Physics
    # type = ReferenceResidualProblem
    # extra_tag_vectors = 'ref'
    # reference_vector = 'ref'

    # Multi-system does not work with nodal kernels at the time
    # nl_sys_names = 'nl0 energy'
[]

[GlobalParams]
    species_scaling_factors = '1'
    # The heat conduction physics preconditioning does not apply well across the other physics
    preconditioning = 'defer'
[]

[Physics]
    [HeatConduction]
        [all]
            temperature_name = 'temperature'
            initial_temperature = ${units 300 K}
            # if using AD, increase the size of the factorization space in petsc options
            # using -mat_mumps_icntl_14 300 or use superlu_dist over mumps
            use_automatic_differentiation = false

            thermal_conductivity = 'thermal_conductivity'
            specific_heat = 'specific_heat'

            heat_flux_boundaries = 'top'
            boundary_heat_fluxes = 'temperature_flux_bc_function'
            fixed_temperature_boundaries = '2to1'
            boundary_temperatures = 'temperature_inner_func'
        []
    []
    [Diffusion]
        [W]
            variable_name = 'C_mobile_W'
            block = '4'
            diffusivity_matprop = diffusivity_W
            initial_condition = ${units 1.0e-20 m^-3}

            neumann_boundaries = 'top'
            boundary_fluxes = 'mobile_flux_bc_function'
        []
        [Cu]
            variable_name = 'C_mobile_Cu'
            block = '3'
            diffusivity_matprop = diffusivity_Cu
            initial_condition = ${units 5.0e-17 m^-3}
        []
        [CuCrZr]
            variable_name = 'C_mobile_CuCrZr'
            block = '2'
            diffusivity_matprop = diffusivity_CuCrZr
            initial_condition = ${units 1.0e-15 m^-3}

            dirichlet_boundaries ='2to1'
            boundary_values = '${C_mobile_CuCrZr_DirichletBC_Coolant}'
        []
    []
    [SpeciesTrapping]
        [W]
            species = 'C_trapped_W'
            mobile = 'C_mobile_W'
            block = '4'
            species_initial_concentrations = ${units 1.0e-15 m^-3}
            separate_variables_per_component = false

            temperature = temperature
            alpha_t = 2.75e11           # 1e15
            N = 1.0e0                   # = (1e0) x (${tungsten_atomic_density} #/m^3)
            Ct0 = 1.0e-4                # E.A. Hodille et al 2021 Nucl. Fusion 61 1260033, trap 2
            trap_per_free = 1.0e0       # 1.0e1
            trapping_energy = 0

            alpha_r = 8.4e12            # 1.0e13
            detrapping_energy = 11604.6 # = 1.00 eV    E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 2
        []
        [Cu]
            species = 'C_trapped_Cu'
            mobile = 'C_mobile_Cu'
            block = '3'
            species_initial_concentrations = ${units 1.0e-15 m^-3}
            separate_variables_per_component = false
            temperature = temperature

            alpha_t = 2.75e11           # 1e15
            N = 1.0e0                   # = ${tungsten_atomic_density} #/m^3 (W lattice density)
            Ct0 = 5.0e-5                # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
            trap_per_free = 1.0e0       # 1.0e1
            trapping_energy = 0

            alpha_r = 8.4e12            # 1.0e13
            detrapping_energy = 5802.3  # = 0.50eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
        []
        [CuCrZr]
            species = 'C_trapped_CuCrZr'
            mobile = 'C_mobile_CuCrZr'
            block = '2'
            species_initial_concentrations = ${units 1.0e-15 m^-3}
            separate_variables_per_component = false
            temperature = temperature

            alpha_t = 2.75e11           # 1e15
            N = 1.0e0                   # = ${tungsten_atomic_density} #/m^3 (W lattice density)
            Ct0 = 5.0e-5                # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
            trap_per_free = 1.0e0       # 1.0e1
            trapping_energy = 0

            alpha_r = 8.4e12            # 1.0e13
            detrapping_energy = 5802.3  # = 0.50eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
        []
    []
[]

[InterfaceKernels]
    [tied_4to3]
        type = ADPenaltyInterfaceDiffusion
        variable = C_mobile_W
        neighbor_var = C_mobile_Cu
        penalty = 0.05            #  it will not converge with > 0.1, but it creates negative C_mobile _Cu with << 0.1
        # jump_prop_name = solubility_ratio_4to3
        jump_prop_name = solubility_ratio
        boundary = '4to3'
    []
    [tied_3to2]
        type = ADPenaltyInterfaceDiffusion
        variable = C_mobile_Cu
        neighbor_var = C_mobile_CuCrZr
        penalty = 0.05            #  it will not converge with > 0.1, but it creates negative C_mobile _Cu with << 0.1
        # jump_prop_name = solubility_ratio_3to2
        jump_prop_name = solubility_ratio
        boundary = '3to2'
    []
[]


[Materials]
    ############################## Materials for W (block = 4)
    [diffusivity_W]
        type = ADParsedMaterial
        property_name = diffusivity_W
        coupled_variables = 'temperature'
        block = 4
        expression = '2.4e-7*exp(-4525.8/temperature)'    # H diffusivity in W
        outputs = all
    []
    [solubility_W]
        type = ADParsedMaterial
        property_name = solubility_W
        coupled_variables = 'temperature'
        block = 4
        # expression = '2.95e-5 *exp(-12069.0/temperature)'              # H solubility in W = (1.87e24)/(${tungsten_atomic_density}) [#/m^3]
        expression = '2.95e-5 *exp(-12069.0/temperature) + 4.95e-8 * exp(-6614.6/temperature)'    # H solubility in W = (1.87e24)/(${tungsten_atomic_density}) [#/m^3]
        outputs = all
    []
    [heat_transfer_W]
        type = GenericConstantMaterial
        prop_names = 'density'
        prop_values = '${density_W}'
        block = 4
    []
    [specific_heat_W]
        type = ParsedMaterial
        property_name = specific_heat
        coupled_variables = 'temperature'
        block = 4
        expression = '1.16e2 + 7.11e-2 * temperature - 6.58e-5 * temperature^2 + 3.24e-8 * temperature^3 -5.45e-12 * temperature^4'    # ~ 132[J/kg-K]
        outputs = all
    []
    [thermal_conductivity_W]
        type = ParsedMaterial
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
        property_name = diffusivity_Cu
        coupled_variables = 'temperature'
        block = 3
        expression = '6.60e-7*exp(-4525.8/temperature)'    # H diffusivity in Cu
        outputs = all
    []
    [solubility_Cu]
        type = ADParsedMaterial
        property_name = solubility_Cu
        coupled_variables = 'temperature'
        block = 3
        expression = '4.95e-5*exp(-6614.6/temperature)'    # H solubility in Cu = (3.14e24)/(${tungsten_atomic_density}) [#/m^3]
        outputs = all
    []
    [heat_transfer_Cu]
        type = GenericConstantMaterial
        prop_names = 'density'
        prop_values = '${density_Cu}'
        block = 3
    []
    [specific_heat_Cu]
        type = ParsedMaterial
        property_name = specific_heat
        coupled_variables = 'temperature'
        block = 3
        expression = '3.16e2 + 3.18e-1 * temperature - 3.49e-4 * temperature^2 + 1.66e-7 * temperature^3'    # ~ 384 [J/kg-K]
        outputs = all
    []
    [thermal_conductivity_Cu]
        type = ParsedMaterial
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
        property_name = diffusivity_CuCrZr
        coupled_variables = 'temperature'
        block = 2
        expression = '3.90e-7*exp(-4873.9/temperature)'    # H diffusivity in CuCrZr
        outputs = all
    []
    [solubility_CuCrZr]
        type = ADParsedMaterial
        property_name = solubility_CuCrZr
        coupled_variables = 'temperature'
        block = 2
        expression = '6.75e-6*exp(-4525.8/temperature)'    # H solubility in CuCrZr = (4.28e23)/(${tungsten_atomic_density}) [#/m^3]
        outputs = all
    []
    [heat_transfer_CuCrZr]
        type = GenericConstantMaterial
        prop_names = 'density specific_heat'
        prop_values = '${density_CuCrZr} ${specific_heat_CuCrZr}'
        block = 2
    []
    [thermal_conductivity_CuCrZr]
        type = ParsedMaterial
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
        concentration_primary = C_mobile_W
        concentration_secondary = C_mobile_Cu
    []
    [interface_jump_3to2]
        type = SolubilityRatioMaterial
        solubility_primary = solubility_Cu
        solubility_secondary = solubility_CuCrZr
        boundary = '3to2'
        concentration_primary = C_mobile_Cu
        concentration_secondary = C_mobile_CuCrZr
    []
[]
