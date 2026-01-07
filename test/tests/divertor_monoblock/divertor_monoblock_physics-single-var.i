### Nomenclatures
### C_mobile        mobile H concentration in "j" material, where j = CuCrZr, Cu, W
### C_trapped       trapped H concentration in "j" material, where j = CuCrZr, Cu, W
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

tungsten_atomic_density = ${units 6.338e28 m^-3}

!include mesh_base.i
!include outputs_base_single_var.i


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
            initial_temperature = ${units 300 K}

            thermal_conductivity = 'thermal_conductivity'
            specific_heat = 'specific_heat'

            heat_flux_boundaries = 'top'
            boundary_heat_fluxes = 'temp_flux_bc_func'
            fixed_temperature_boundaries = '2to1'
            boundary_temperatures = 'temp_inner_func'
        []
    []
    [Diffusion]
        [all]
            variable_name = 'C_mobile'
            diffusivity_matprop = diffusivity
            initial_condition = ${units 1.0e-20 m^-3}

            neumann_boundaries = 'top'
            boundary_fluxes = 'mobile_flux_bc_func'
        []
    []
    # TODO: modify the code to:
    # - use material properties for all the parameters
    # - use an element-based version of NodalKernels
    # then we wont need 3 Physics for Trapping
    [SpeciesTrapping]
        [all]
            species = 'C_trapped'
            mobile = 'C_mobile'
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
            species = 'C_trapped'
            mobile = 'C_mobile'
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
            species = 'C_trapped'
            mobile = 'C_mobile'
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

[Functions]
    ### Maximum mobile flux of 7.90e-13 at the top surface (1.0e-4 [m])
    ### 1.80e23/m^2-s = (5.0e23/m^2-s) *(1-0.999) = (7.90e-13)*(${tungsten_atomic_density})/(1.0e-4)  at steady state
    [mobile_flux_bc_func]
        type = ParsedFunction
        expression =   'if((t % 1600) < 100.0, 0.0      + 7.90e-13*(t % 1600)/100,
                        if((t % 1600) < 500.0, 7.90e-13,
                        if((t % 1600) < 600.0, 7.90e-13 - 7.90e-13*((t % 1600)-500)/100, 0.0)))'
    []
    ### Heat flux of 10MW/m^2 at steady state
    [temp_flux_bc_func]
        type = ParsedFunction
        expression =   'if((t % 1600) < 100.0, 0.0   + 1.0e7*(t % 1600)/100,
                        if((t % 1600) < 500.0, 1.0e7,
                        if((t % 1600) < 600.0, 1.0e7 - 1.0e7*((t % 1600)-500)/100, 0.0)))'
    []
    ### Maximum coolant temperature of 552K at steady state
    [temp_inner_func]
        type = ParsedFunction
        expression =   'if((t % 1600) < 100.0, 300.0 + (552-300)*(t % 1600)/100,
                        if((t % 1600) < 500.0, 552,
                        if((t % 1600) < 600.0, 552.0 - (552-300)*((t % 1600)-500)/100, 300)))'
    []
    [timestep_function]
        type = ParsedFunction
        expression = 'if((t % 1600) <   10.0,  20,
                      if((t % 1600) <   90.0,  40,
                      if((t % 1600) <  110.0,  20,
                      if((t % 1600) <  480.0,  40,
                      if((t % 1600) <  500.0,  20,
                      if((t % 1600) <  590.0,   4,
                      if((t % 1600) <  610.0,  20,
                      if((t % 1600) < 1500.0, 200,
                      if((t % 1600) < 1600.0,  40,  2)))))))))'
    []
[]

[Materials]
    ############################## Materials for W (block = 4)
    [diffusivity_W]
        type = ADParsedMaterial
        property_name = diffusivity
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
        type = ADGenericConstantMaterial
        prop_names = 'density'
        prop_values = '19300'                # [g/m^3]
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
        type = ADGenericConstantMaterial
        prop_names = 'density'
        prop_values = '8960.0'                # [g/m^3]
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
        type = ADGenericConstantMaterial
        prop_names = 'density specific_heat'
        prop_values = '8900.0 390.0'            # [g/m^3], [ W/m-K], [J/kg-K]
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

[Preconditioning]
    [smp]
        type = SMP
        full = true
    []
[]

[Executioner]
    type = Transient
    scheme = bdf2
    solve_type = NEWTON
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
    nl_rel_tol  = 1e-6 # 1e-8 works for 1 cycle
    nl_abs_tol  = 1e-7 # 1e-11 works for 1 cycle
    end_time = 8.0e4   # 50 ITER shots (3.0e4 s plasma, 2.0e4 SSP)
    automatic_scaling = true
    line_search = 'none'
    dtmin = 1e-4
    nl_max_its = 18
    [TimeStepper]
        type = IterationAdaptiveDT
        dt = 20
        optimal_iterations = 15
        iteration_window = 1
        growth_factor = 1.2
        cutback_factor = 0.8
        timestep_limiting_postprocessor = timestep_max_pp
    []
[]

[Postprocessors]
  # limit timestep
  [timestep_max_pp] # s
    type = FunctionValuePostprocessor
    function = timestep_function
  []
[]
