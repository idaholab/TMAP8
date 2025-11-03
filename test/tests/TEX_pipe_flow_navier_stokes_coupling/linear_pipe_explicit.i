#######################################################################
# Model Description 
# Vanadium Pipe Benchmark Model
# Created by Samuel Walker on Apr23-2025
#######################################################################


#######################################################################
# GEOMETRY and MESH
#######################################################################


#p_outlet = 1e5
Dh = 0.0234
#Vin = 0.465926 #2Kg/s
#Vin = 0.698889 #3Kg/s
Vin = 0.931852 #4Kg/s
Temp_fluid = 573.15
C_D = 1e-3
R_gas = 8.314
#D_H_f = 
#mu = 2.6
#rho = 1.0
advected_interp_method = 'upwind'

#T_initial = 450

#vanadium = '1'
#fluid  = '2'
#fuel  = '3'

#fuelair_matid = '1'
#steel_matid = '2'

[GlobalParams]
  rhie_chow_user_object = 'rc'
[]

[Mesh]

  # create a circle first with concentric layers (air, steel, air/fuel, steel)

  [circle]
    type = ConcentricCircleMeshGenerator
    radii            = '0.0117 0.0127'
    rings            = '4 4'
    num_sectors      = 6
    has_outer_square = false
    preserve_volumes = false
  []

  # turn the circle into a cylinder with the corresponding heights for each block
  # then assign new subdomains to be renamed later

  [extrude]
    type = MeshExtruderGenerator
    extrusion_vector    = '0 0 1'
    input               = circle
    #layer_thickness     = '1'
    #layer_subdivisions  = '100'
    num_layers = 100
    layers              = '0'
    #existing_subdomains = '${old_blocks}'
    #new_ids             = 'wall fluid'
    top_sideset         = 'outlet'
    bottom_sideset      = 'inlet'
  []

  # rename each of the 16 blocks to make them the correct block for material assignment

  [rename]
    type = RenameBlockGenerator
    input = extrude
    old_block = '1 2'
    new_block = 'fluid pipe'
  []
  [add_wall]
    type = SideSetsBetweenSubdomainsGenerator
    input = rename
    primary_block = 'fluid'
    paired_block = 'pipe'
    new_boundary = 'wall'
  []

  [fix_sideset]
    type = SideSetsAroundSubdomainGenerator
    input = add_wall
    new_boundary = 'fluid_outlet'
    block = 'fluid'
    #include_only_external∂_sides = 'true'
    normal = '0 0 1'
    #normals = '0.00898026 -0.00898026 1'
    #new_boundary = 'wall_outlet'
  []
  [fix_sideset_2]
    type = SideSetsAroundSubdomainGenerator
    input = fix_sideset
    new_boundary = 'fluid_inlet'
    block = 'fluid'
    include_only_external_sides = 'true'
    normal = '0 0 -0.01'
    #normals = '0.00898026 -0.00898026 1'
    #new_boundary = 'wall_outlet'
  []
  [fix_sideset_3]
    type = SideSetsAroundSubdomainGenerator
    input = fix_sideset_2
    new_boundary = 'solid_inlet'
    block = 'pipe'
    include_only_external_sides = 'true'
    normal = '0 0 -0.01'
    #normals = '0.00898026 -0.00898026 1'
    #new_boundary = 'wall_outlet'
  []
  [fix_sideset_4]
    type = SideSetsAroundSubdomainGenerator
    input = fix_sideset_3
    new_boundary = 'solid_outlet'
    block = 'pipe'
    #include_only_external∂_sides = 'true'
    normal = '0 0 1'
    #normals = '0.00898026 -0.00898026 1'
    #new_boundary = 'wall_outlet'
  []
  [delete_side_sets]
    type = BoundaryDeletionGenerator
    input = fix_sideset_4
    boundary_names = 'inlet outlet'
    #normals = '0.00898026 -0.00898026 1'
    #new_boundary = 'wall_outlet'
  []

[]

###################################
# TH
###################################

fluid_blocks = 'fluid'
solid_blocks = 'pipe'

[Problem]
  linear_sys_names = 'u_system v_system w_system pressure_system T_liq_system T_sol_system'
  previous_nl_solution_required = true
  kernel_coverage_check = false
  material_coverage_check = false
  fv_bcs_integrity_check = false
  boundary_restricted_elem_integrity_check = false
  #verbose_setup = true
[]

[UserObjects]
  [rc]
    type = RhieChowMassFlux
    u = vel_x
    v = vel_y
    w = vel_z
    pressure = pressure
    rho = 'rho'
    p_diffusion_kernel = p_diffusion
    block = ${fluid_blocks}
  []
[]

[Variables]
  #TH Variables
  [vel_x]
    type = MooseLinearVariableFVReal
    initial_condition = 0
    block = ${fluid_blocks}
    solver_sys = u_system
  []
  [vel_y]
    type = MooseLinearVariableFVReal
    initial_condition = 0
    block = ${fluid_blocks}
    solver_sys = v_system
  []
  [vel_z]
    type = MooseLinearVariableFVReal
    initial_condition = 0.8
    block = ${fluid_blocks}
    solver_sys = w_system
  []
  [pressure]
    type = MooseLinearVariableFVReal
    initial_condition = 0.2
    block = ${fluid_blocks}
    solver_sys = pressure_system
  []

  #Tritium Variables
  [T_liq]
    type = MooseLinearVariableFVReal
    #initial_condition = ${C_D}
    initial_condition = 0.0
    block = ${fluid_blocks}
    solver_sys = 'T_liq_system'
  []
  [T_sol]
    type = MooseLinearVariableFVReal
    #initial_condition = ${C_D}
    initial_condition = 0.0
    block = ${solid_blocks}
    solver_sys = 'T_sol_system'
  []

  # [Temp_fluid]
  #   type = INSFVEnergyVariable
  #   initial_condition = ${T_Salt_initial}
  #   block = ${fluid_blocks}
  # []
  # [T_solid]
  #   type = INSFVEnergyVariable
  #   initial_condition = ${T_Salt_initial}
  #   block = ${solid_blocks}
  # []
[]

# [FluidProperties]
#   [fluid_properties_obj]
#     type = LeadBismuthFluidProperties
#   []
# []

[LinearFVKernels]
  #Advection Kernels
  [u_advection_stress]
    type = LinearWCNSFVMomentumFlux
    variable = vel_x
    advected_interp_method = ${advected_interp_method}
    mu = 'mu'
    u = vel_x
    v = vel_y
    w = vel_z
    momentum_component = 'x'
    rhie_chow_user_object = 'rc'
    use_nonorthogonal_correction = false
  []
  [v_advection_stress]
    type = LinearWCNSFVMomentumFlux
    variable = vel_y
    advected_interp_method = ${advected_interp_method}
    mu = 'mu'
    u = vel_x
    v = vel_y
    w = vel_z
    momentum_component = 'y'
    rhie_chow_user_object = 'rc'
    use_nonorthogonal_correction = false
  []
  [w_advection_stress]
    type = LinearWCNSFVMomentumFlux
    variable = vel_z
    advected_interp_method = ${advected_interp_method}
    mu = 'mu'
    u = vel_x
    v = vel_y
    w = vel_z
    momentum_component = 'z'
    rhie_chow_user_object = 'rc'
    use_nonorthogonal_correction = false
  []

  #Cross Terms
  [u_pressure]
    type = LinearFVMomentumPressure
    variable = vel_x
    pressure = pressure
    momentum_component = 'x'
  []
  [v_pressure]
    type = LinearFVMomentumPressure
    variable = vel_y
    pressure = pressure
    momentum_component = 'y'
  []
  [w_pressure]
    type = LinearFVMomentumPressure
    variable = vel_z
    pressure = pressure
    momentum_component = 'z'
  []

  #Pressure Kernels
  [p_diffusion]
    type = LinearFVAnisotropicDiffusion
    variable = pressure
    diffusion_tensor = Ainv
    use_nonorthogonal_correction = false
  []
  [HbyA_divergence]
    type = LinearFVDivergence
    variable = pressure
    face_flux = HbyA
    force_boundary_execution = true
  []

  #Tritium Kernels 
  #T_liq Kernels
  [T_liq_advection]
    type = LinearFVScalarAdvection
    variable = T_liq
    #rhie_chow_user_object = rhie_chow_user_object
    #vel = 'vel_x_mat vel_y_mat'
    #vel = 'vel_x vel_y'
    #rho = ${rho}
    block = ${fluid_blocks}
  []
  [T_diffusion]
    type = LinearFVDiffusion
    diffusion_coeff = 'D_H_F'
    variable = T_liq
    block = ${fluid_blocks}
    use_nonorthogonal_correction = false
  []
  #T_solid Kernels - TMAP8 Here
  [T_sol_diffusion]
    type = LinearFVDiffusion
    diffusion_coeff = 'D_H_S'
    variable = T_sol
    #block = ${fluid_blocks}
    use_nonorthogonal_correction = false
  []
[]

[LinearFVBCs]
  #Inlet TH BCs
   [inlet-u]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'fluid_inlet'
    variable = vel_x
    functor = '0.0'
  []
  [inlet-v]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'fluid_inlet'
    variable = vel_y
    functor = '0.0'
  []
  [inlet-w]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'fluid_inlet'
    variable = vel_z
    functor = 'InletLaminar'
  []
  [walls-u]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'wall'
    variable = vel_x
    functor = 0.0
  []
  [walls-v]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'wall'
    variable = vel_y
    functor = 0.0
  []
  [walls-w]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'wall'
    variable = vel_z
    functor = 0.0
  []

  #Outlet TH BCs
  [outlet_p]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'fluid_outlet'
    variable = pressure
    functor = 1.2
  []
  [outlet_u]
    type = LinearFVAdvectionDiffusionOutflowBC
    variable = vel_x
    use_two_term_expansion = false
    boundary = 'fluid_outlet'
  []
  [outlet_v]
    type = LinearFVAdvectionDiffusionOutflowBC
    variable = vel_y
    use_two_term_expansion = false
    boundary = 'fluid_outlet'
  []
  [outlet_w]
    type = LinearFVAdvectionDiffusionOutflowBC
    variable = vel_z
    use_two_term_expansion = false
    boundary = 'fluid_outlet'
  []

  #Tritium BCs
  #T_liq inlet and outlets
  [T_liq_inlet]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'fluid_inlet'
    functor = ${C_D}
    #functor = 1e5
    variable = T_liq
    #block = ${fluid_blocks}
  []
  [T_liq_outlet]
    type = LinearFVAdvectionDiffusionOutflowBC
    boundary = 'fluid_outlet'
    #functor = 1e5
    variable = T_liq
    use_two_term_expansion = false
    #block = ${fluid_blocks}
  []

  #Mass Transfer at Interface. -TMPAP8 Here
  [T_sol_source]
    type = LinearFVConvectiveHeatTransferBC
    boundary = 'wall'
    T_fluid = T_liq
    T_solid = T_sol
    h = 1 # mass transfer exchange rate at interface - tune
    #functor = 1e5
    variable = T_sol
    #is_solid = true
    #block = ${fluid_blocks}
  []
  [T_liq_loss]
    type = LinearFVConvectiveHeatTransferBC
    boundary = 'wall'
    T_fluid = T_liq
    T_solid = T_sol
    h = 1
    #functor = 1e5
    variable = T_liq
    #is_solid = false
    #block = ${fluid_blocks}
  []

  #Solid Outlets from diffusion
  [T_sol_outer]
    type = LinearFVAdvectionDiffusionOutflowBC
    boundary = 'outer'
    #value = 0
    variable = T_sol
    use_two_term_expansion = false
    #block = ${fluid_blocks}
  []
  [T_sol_outer_2]
    type = LinearFVAdvectionDiffusionOutflowBC
    boundary = 'solid_outlet'
    #value = 0
    variable = T_sol
    use_two_term_expansion = false
    #block = ${fluid_blocks}
  []
  [T_sol_outer_3]
    type = LinearFVAdvectionDiffusionOutflowBC
    boundary = 'solid_inlet'
    #value = 0
    variable = T_sol
    use_two_term_expansion = false
    #block = ${fluid_blocks}
  []
[]

[FunctorMaterials]
  # [fluid_props_to_mat_props]
  #   type = GeneralFunctorFluidProps
  #   pressure = 'pressure'
  #   Temp_fluid = ${Temp_fluid}
  #   #Temp_fluid = 450
  #   speed = 'speed'
  #   characteristic_length = 1.0
  #   fp = fluid_properties_obj
  #   porosity = 1.0
  #   block = ${fluid_blocks}
  # []
  # [misc_mat_props]
  #   type = ADGenericFunctorMaterial
  #   prop_names = 'pipe_mat'
  #   prop_value = 1
  #   block = 'pipe'
  #   execute_on = 'INITIAL'
  # []
  [rho]
    type = ParsedFunctorMaterial  
    property_name = 'rho'
    expression = '10520-1.19051*${Temp_fluid}'
    block = 'fluid'
    #execute_on = 'Always'
  []
  [mu]
    type = ParsedFunctorMaterial  
    property_name = 'mu'
    expression = '0.187*10^-3*exp(1400/${Temp_fluid})+1*exp(-t/10)'
    block = 'fluid'
    #exe
  []
  [D_H_F]
    type = ParsedFunctorMaterial  
    property_name = 'D_H_F'
    expression = '4.03*10^-8*exp(-19500/(${R_gas}*${Temp_fluid}))'
    block = 'fluid'
    #exe
  []
  [D_H_S]
    type = ParsedFunctorMaterial  
    property_name = 'D_H_S'
    expression = '2.0*10^-8*exp(-4200/(${R_gas}*${Temp_fluid}))'
    block = 'pipe'
    #exe
  []
  # [rho]
  #   type = GenericFunctorMaterial
  #   prop_names = 'rho'
  #   prop_value = 'rho_calc'
  #   block = 'fluid'
  #   #execute_on = 'INITIAL'
  # []
  # [mu]
  #   type = GenericFunctorMaterial
  #   prop_names = 'mu'
  #   prop_value = 'mu_calc'
  #   block = 'fluid'
  #   #execute_on = 'INITIAL'
  # []
[]

[Functions]
  [InletLaminar]
    type = ParsedFunction
    symbol_names = 'R ubar'
    symbol_values = '${fparse Dh/2} ${Vin}'
    expression = 2.*ubar*(1.0-(y/R)^2.0-(x/R)^2)
  []
  [rho_calc]
    type = ParsedFunction
    symbol_names = 'T'
    symbol_values = '${Temp_fluid}'
    expression = 10520.35-1.19051*T
  []
  [mu_calc]
    type = ParsedFunction
    symbol_names = 'T'
    symbol_values = '${Temp_fluid}'
    expression = 0.187*10^-3*exp(1400/T)
  []
[]

[Executioner]
  type = PIMPLE
  momentum_l_abs_tol = 1e-13
  pressure_l_abs_tol = 1e-13
  #energy_l_abs_tol = 1e-13
  passive_scalar_l_abs_tol = 1e-13
  momentum_l_tol = 1e-13
  pressure_l_tol = 1e-13
  #energy_l_tol = 1e-12
  passive_scalar_l_tol = 1e-13
  rhie_chow_user_object = 'rc'
  momentum_systems = 'u_system v_system w_system'
  pressure_system = 'pressure_system'
  #energy_system = 'energy_system'
  passive_scalar_systems = 'T_liq_system T_sol_system'
  momentum_equation_relaxation = 0.8
  pressure_variable_relaxation = 0.3
  #energy_equation_relaxation = 0.9
  passive_scalar_equation_relaxation = '0.8 0.8'
  num_iterations = 100
  pressure_absolute_tolerance = 1e-11
  momentum_absolute_tolerance = 1e-11
  #energy_absolute_tolerance = 1e-11
  passive_scalar_absolute_tolerance = '1e-11 1e-11'
  momentum_petsc_options_iname = '-pc_type -pc_hypre_type'
  momentum_petsc_options_value = 'hypre boomeramg'
  pressure_petsc_options_iname = '-pc_type -pc_hypre_type'
  pressure_petsc_options_value = 'hypre boomeramg'
  #energy_petsc_options_iname = '-pc_type -pc_hypre_type'
  #energy_petsc_options_value = 'hypre boomeramg'
  passive_scalar_petsc_options_iname = '-pc_type -pc_hypre_type'
  passive_scalar_petsc_options_value = 'hypre boomeramg'
  print_fields = false
  continue_on_max_its = true

 [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    optimal_iterations = 10
    iteration_window = 2
    growth_factor = 2
    cutback_factor = 0.5
  []

  end_time = 1e10
  steady_state_detection = true
  steady_state_tolerance = 1e-12
[]

[Postprocessors]
  [flow_outlet]
    type = VolumetricFlowRate
    boundary = 'fluid_outlet'
    vel_x = vel_x
    vel_y = vel_y
    vel_z = vel_z
    advected_quantity = 1
  []
  [mass_flow_outlet]
    type = MassFluxWeightedFlowRate
    boundary = 'fluid_outlet'
    vel_x = vel_x
    vel_y = vel_y
    vel_z = vel_z
    density = 'rho'
    advected_quantity = 'rho'
  []
  [mdot_outlet]
    type = VolumetricFlowRate
    boundary = 'fluid_outlet'
    vel_x = vel_x
    vel_y = vel_y
    vel_z = vel_z
    #density = 'rho'
    advected_quantity = 'rho'
  []
  # [rho_check]
  #   type = ElementIntegralFunctorPostprocessor
  #   functor = 'rho'
  #   block = 'fluid'
  #   #pp_names = 'rho'
  #   #vel_x = vel_x
  #   #vel_y = vel_y
  #   #vel_z = vel_z
  #   #density = 'rho'
  #   #advected_quantity = 'rho'
  # []
  [T_liq_avg]
    type = ElementAverageValue
    variable = T_liq
    block = 'fluid'
    #pp_names = 'rho'
    #vel_x = vel_x
    #vel_y = vel_y
    #vel_z = vel_z
    #density = 'rho'
    #advected_quantity = 'rho'
  []
[]

[Outputs]
  csv = true
  exodus = true
[]
