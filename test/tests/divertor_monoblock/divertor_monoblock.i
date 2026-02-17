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

# operation conditions
temperature_initial = ${units 300.0 K}

C_mobile_CuCrZr_DirichletBC_Coolant = 1.0e-18

# material properties
tungsten_atomic_density = ${units 6.338e28 m^-3}
density_W = 19300                # [g/m^3]
density_Cu = 8960.0               # [g/m^3]
density_CuCrZr = 8900.0 # [g/m^3]
specific_heat_CuCrZr = 390.0     # [ W/m-K], [J/kg-K]

plasma_ramp_time = 100.0 #s
plasma_ss_duration = 400.0 #s
plasma_cycle_time = 1600.0 #s

plasma_ss_end = ${fparse plasma_ramp_time + plasma_ss_duration} #s
plasma_ramp_down_end = ${fparse plasma_ramp_time + plasma_ss_duration + plasma_ramp_time} #s

plasma_max_heat = 1.0e7 #W/m^2
plasma_min_heat = 0.0 # W/m^2 # no flux while the pulse is off.

### Maximum mobile flux of 7.90e-13 at the top surface (1.0e-4 [m])
### 1.80e23/m^2-s = (5.0e23/m^2-s) *(1-0.999) = (7.90e-13)*(${tungsten_atomic_density})/(1.0e-4)  at steady state
plasma_max_flux = 7.90e-13
plasma_min_flux = 0.0

# include sections of the input file shared with other inputs
!include divertor_monoblock_mesh_base.i
!include divertor_monoblock_functions_plasma_exposure.i
!include divertor_monoblock_outputs_base.i

[Problem]
    type = ReferenceResidualProblem
    extra_tag_vectors = 'ref'
    reference_vector = 'ref'
[]

[Variables]
    [temperature]
        order = FIRST
        family = LAGRANGE
        initial_condition = ${temperature_initial}
    []
    ######################### Variables for W (block = 4)
    [C_mobile_W]
        order = FIRST
        family = LAGRANGE
        initial_condition = ${units 1.0e-20 m^-3}
        block = 4
    []
    [C_trapped_W]
        order = FIRST
        family = LAGRANGE
        initial_condition = ${units 1.0e-15 m^-3}
        block = 4
    []
    ######################### Variables for Cu (block = 3)
    [C_mobile_Cu]
        order = FIRST
        family = LAGRANGE
        initial_condition = ${units 5.0e-17 m^-3}
        block = 3
    []
    [C_trapped_Cu]
        order = FIRST
        family = LAGRANGE
        initial_condition = ${units 1.0e-15 m^-3}
        block = 3
    []
    ######################### Variables for CuCrZr (block = 2)
    [C_mobile_CuCrZr]
        order = FIRST
        family = LAGRANGE
        initial_condition = ${units 1.0e-15 m^-3}
        block = 2
    []
    [C_trapped_CuCrZr]
        order = FIRST
        family = LAGRANGE
        initial_condition = ${units 1.0e-15 m^-3}
        block = 2
    []
[]

[Kernels]
    ############################## Kernels for W (block = 4)
    [diff_W]
        type = ADMatDiffusion
        variable = C_mobile_W
        diffusivity = diffusivity_W
        block = 4
        extra_vector_tags = ref
    []
    [time_diff_W]
        type = ADTimeDerivative
        variable = C_mobile_W
        block = 4
        extra_vector_tags = ref
    []
    [coupled_time_W]
        type = ScaledCoupledTimeDerivative
        variable = C_mobile_W
        v = C_trapped_W
        block = 4
        extra_vector_tags = ref
    []
    [heat_conduction_W]
        type = HeatConduction
        variable = temperature
        diffusion_coefficient = thermal_conductivity_W
        block = 4
        extra_vector_tags = ref
    []
    [time_heat_conduction_W]
        type = SpecificHeatConductionTimeDerivative
        variable = temperature
        specific_heat = specific_heat_W
        density = density_W
        block = 4
        extra_vector_tags = ref
    []
    ############################## Kernels for Cu (block = 3)
    [diff_Cu]
        type = ADMatDiffusion
        variable = C_mobile_Cu
        diffusivity = diffusivity_Cu
        block = 3
        extra_vector_tags = ref
    []
    [time_diff_Cu]
        type = ADTimeDerivative
        variable = C_mobile_Cu
        block = 3
        extra_vector_tags = ref
    []
    [coupled_time_Cu]
        type = ScaledCoupledTimeDerivative
        variable = C_mobile_Cu
        v = C_trapped_Cu
        block = 3
        extra_vector_tags = ref
    []
    [heat_conduction_Cu]
        type = HeatConduction
        variable = temperature
        diffusion_coefficient = thermal_conductivity_Cu
        block = 3
        extra_vector_tags = ref
    []
    [time_heat_conduction_Cu]
        type = SpecificHeatConductionTimeDerivative
        variable = temperature
        specific_heat = specific_heat_Cu
        density = density_Cu
        block = 3
        extra_vector_tags = ref
    []
    ############################## Kernels for CuCrZr (block = 2)
    [diff_CuCrZr]
        type = ADMatDiffusion
        variable = C_mobile_CuCrZr
        diffusivity = diffusivity_CuCrZr
        block = 2
        extra_vector_tags = ref
    []
    [time_diff_CuCrZr]
        type = ADTimeDerivative
        variable = C_mobile_CuCrZr
        block = 2
        extra_vector_tags = ref
    []
    [coupled_time_CuCrZr]
        type = ScaledCoupledTimeDerivative
        variable = C_mobile_CuCrZr
        v = C_trapped_CuCrZr
        block = 2
        extra_vector_tags = ref
    []
    [heat_conduction_CuCrZr]
        type = HeatConduction
        variable = temperature
        diffusion_coefficient = thermal_conductivity_CuCrZr
        block = 2
        extra_vector_tags = ref
    []
    [time_heat_conduction_CuCrZr]
        type = SpecificHeatConductionTimeDerivative
        variable = temperature
        specific_heat = specific_heat_CuCrZr
        density = density_CuCrZr
        block = 2
        extra_vector_tags = ref
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

[NodalKernels] ######################000000000000000 To be cleaned up
    ############################## NodalKernels for W (block = 4)
    [time_W]
        type = TimeDerivativeNodalKernel
        variable = C_trapped_W
    []
    [trapping_W]
        type = TrappingNodalKernel
        variable = C_trapped_W
        temperature = temperature
        alpha_t = 2.75e11      # 1e15
        N = 1.0e0  # = (1e0) x (${tungsten_atomic_density} #/m^3)
        # Ct0 = 1.0e-4                # E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 1
        Ct0 = 1.0e-4                # E.A. Hodille et al 2021 Nucl. Fusion 61 1260033, trap 2
        trap_per_free = 1.0e0       # 1.0e1
        mobile_concentration = 'C_mobile_W'
        extra_vector_tags = ref
    []
    [release_W]
        type = ReleasingNodalKernel
        alpha_r = 8.4e12    # 1.0e13
        temperature = temperature
        # detrapping_energy = 9863.9    # = 0.85 eV    E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 1
        detrapping_energy = 11604.6   # = 1.00 eV    E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 2
        variable = C_trapped_W
    []
    ############################## NodalKernels for Cu (block = 3)
    [time_Cu]
        type = TimeDerivativeNodalKernel
        variable = C_trapped_Cu
    []
    [trapping_Cu]
        type = TrappingNodalKernel
        variable = C_trapped_Cu
        temperature = temperature
        alpha_t = 2.75e11      # 1e15
        N = 1.0e0  # = ${tungsten_atomic_density} #/m^3 (W lattice density)
        Ct0 = 5.0e-5                # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
        trap_per_free = 1.0e0       # 1.0e1
        mobile_concentration = 'C_mobile_Cu'
        extra_vector_tags = ref
    []
    [release_Cu]
        type = ReleasingNodalKernel
        alpha_r = 8.4e12    # 1.0e13
        temperature = temperature
        detrapping_energy = 5802.3    # = 0.50eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
        variable = C_trapped_Cu
    []
    ############################## NodalKernels for CuCrZr (block = 2)
    [time_CuCrZr]
        type = TimeDerivativeNodalKernel
        variable = C_trapped_CuCrZr
    []
    [trapping_CuCrZr]
        type = TrappingNodalKernel
        variable = C_trapped_CuCrZr
        temperature = temperature
        alpha_t = 2.75e11      # 1e15
        N = 1.0e0  # = ${tungsten_atomic_density} #/m^3 (W lattice density)
        Ct0 = 5.0e-5                # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
        # Ct0 = 4.0e-2                # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 5
        trap_per_free = 1.0e0       # 1.0e1
        mobile_concentration = 'C_mobile_CuCrZr'
        extra_vector_tags = ref
    []
    [release_CuCrZr]
        type = ReleasingNodalKernel
        alpha_r = 8.4e12    # 1.0e13
        temperature = temperature
        detrapping_energy = 5802.3    # = 0.50eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
        # detrapping_energy = 9631.8   # = 0.83 eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 5
        variable = C_trapped_CuCrZr
    []
[]

[BCs]
    [C_mob_W_top_flux]
        type = FunctionNeumannBC
        variable = C_mobile_W
        boundary = 'top'
        function = mobile_flux_bc_function
    []
    [mobile_tube]
        type = DirichletBC
        variable = C_mobile_CuCrZr
        value = ${C_mobile_CuCrZr_DirichletBC_Coolant}
        boundary = '2to1'
    []
    [temp_top]
        type = FunctionNeumannBC
        variable = temperature
        boundary = 'top'
        function = temp_flux_bc_function
    []
    [temp_tube]
        type = FunctionDirichletBC
        variable = temperature
        boundary = '2to1'
        function = temp_inner_func
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
    [converter_to_regular_W]
        type = MaterialADConverter
        ad_props_in = 'diffusivity_W'
        reg_props_out = 'diffusivity_W_nonAD'
        block = 4
    []
    [heat_transfer_W]
        type = GenericConstantMaterial
        prop_names = 'density_W'
        prop_values = '${density_W}'
        block = 4
    []
    [specific_heat_W]
        type = ParsedMaterial
        property_name = specific_heat_W
        coupled_variables = 'temperature'
        block = 4
        expression = '1.16e2 + 7.11e-2 * temperature - 6.58e-5 * temperature^2 + 3.24e-8 * temperature^3 -5.45e-12 * temperature^4'    # ~ 132[J/kg-K]
        outputs = all
    []
    [thermal_conductivity_W]
        type = ParsedMaterial
        property_name = thermal_conductivity_W
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
    [converter_to_regular_Cu]
        type = MaterialADConverter
        ad_props_in = 'diffusivity_Cu'
        reg_props_out = 'diffusivity_Cu_nonAD'
        block = 3
    []
    [heat_transfer_Cu]
        type = GenericConstantMaterial
        prop_names = 'density_Cu'
        prop_values = '${density_Cu}'
        block = 3
    []
    [specific_heat_Cu]
        type = ParsedMaterial
        property_name = specific_heat_Cu
        coupled_variables = 'temperature'
        block = 3
        expression = '3.16e2 + 3.18e-1 * temperature - 3.49e-4 * temperature^2 + 1.66e-7 * temperature^3'    # ~ 384 [J/kg-K]
        outputs = all
    []
    [thermal_conductivity_Cu]
        type = ParsedMaterial
        property_name = thermal_conductivity_Cu
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
    [converter_to_regular_CuCrZr]
        type = MaterialADConverter
        ad_props_in = 'diffusivity_CuCrZr'
        reg_props_out = 'diffusivity_CuCrZr_nonAD'
        block = 2
    []
    [heat_transfer_CuCrZr]
        type = GenericConstantMaterial
        prop_names = 'density_CuCrZr specific_heat_CuCrZr'
        prop_values = '${density_CuCrZr} ${specific_heat_CuCrZr}'
        block = 2
    []
    [thermal_conductivity_CuCrZr]
        type = ParsedMaterial
        property_name = thermal_conductivity_CuCrZr
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
