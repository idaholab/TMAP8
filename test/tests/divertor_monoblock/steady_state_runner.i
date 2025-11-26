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

tungsten_atomic_density = ${units 6.338e28 m^-3}

[Controls/stochastic]                                                                              # Sends data to Stochastic
  type = SamplerReceiver
[]
[Mesh]                                                                                             # Begins the Mesh description block; the mesh spatially describes the problem, based on blocks (subdomains), meshes (geometries), nodes, etc..
    [ccmg]                                                                                         # name of the mesh
        type = ConcentricCircleMeshGenerator                                                       # type of mesh generator following parameters will be dependent on the type
        num_sectors = 12                                                                           # azimuthmal (angle) sections/divisions
        rings = '1 6 4 22'                                                                      # number of divisions/meshing between defined (next line) radii -> creates 4 (N+1) blocks (I don't know why this is made for radii and not azimuthmal sections)
        radii = '${units 6 mm -> m} ${units 7.5 mm -> m} ${units 8.5 mm -> m}'                     # radii deliminating different blocks/regions/mesh spacings (mesh generator denotes blocks by radii, this line defines 3 blocks)
        has_outer_square = on                                                                      # creates a square boundary for the problem, using the pitch (next line) as the width/height (4th block is generated here)
        pitch = ${units 28 mm -> m}                                                                # square width/height of problem
        portion = left_half                                                                        # only generate left (-14<x<0) portion of mesh
        preserve_volumes = false                                                                   # keep volume between radial mesh points constant
        smoothing_max_it = 3                                                                       # number of laplacian smoothing functions
    []
    [ssbsg1]                                                                                       # mesh name
        type = SideSetsBetweenSubdomainsGenerator                                                  # type of mesh generator, "creates a sideset composed of nodes located between two or more subdomains"
        input = ccmg                                                                               # mesh to modify
        primary_block = '4'     # W                                                                # specifies the 'block'(s) to draw a sidestep between
        paired_block = '3'      # Cu                                                               # specifies the 'block'(s) paired to the primary block
        new_boundary = '4to3'                                                                      # boundary name to create on the defined subdomain
    []
    [ssbsg2]                                                                                       # Creating subdomains for W, Cu, CuCrZr and H2O and their boundaries, working inwards
        type = SideSetsBetweenSubdomainsGenerator
        input = ssbsg1                                                                             # boundary between Cu and W, defines W subdomain
        primary_block = '3'     # Cu
        paired_block = '4'      # W
        new_boundary = '3to4'
    []
    [ssbsg3]
        type = SideSetsBetweenSubdomainsGenerator
        input = ssbsg2                                                                             # Boundary from Cu to CuCrZr, this and 2 define the CuCrZr subdomain
        primary_block = '3'     # Cu
        paired_block = '2'      # CuCrZr
        new_boundary = '3to2'
    []
    [ssbsg4]
        type = SideSetsBetweenSubdomainsGenerator                                                  # Boundary from CuCrZr to Cu
        input = ssbsg3
        primary_block = '2'     # CuCrZr
        paired_block = '3'      # Cu
        new_boundary = '2to3'
    []
    [ssbsg5]
        type = SideSetsBetweenSubdomainsGenerator                                                  # Boundary from Cu to H2O, this and 4 define the Cu subdomain
        input = ssbsg4
        primary_block = '2'     # CuCrZr
        paired_block = '1'      # H2O
        new_boundary = '2to1'
    []
    [bdg]
        type = BlockDeletionGenerator                                                              # H20 subdomain
        input = ssbsg5
        block = '1'             # H2O
    []
[]                                                                                                 # End MESH specifcations

[Problem]                                                                                          # Problem definition, i.e. the sucess criteria for the problem's time steps
    type = ReferenceResidualProblem                                                                # This type of problem checks for "convergence by comparing the residual to a different reference quantity. See https://mooseframework.inl.gov/source/problems/ReferenceResidualProblem.html
    extra_tag_vectors = 'ref'
    reference_vector = 'ref'
[]

[Variables]                                                                                        # Begin specifying variables; these are our dependent variables: what we are solving for.
    [temperature]                                                                                  # variable name
        order = FIRST                                                                              # order of the FE shape function used for this variable (Constant, 1st-4th) (shape of variable within a finite element (FE))
        family = LAGRANGE                                                                          # FE shape function family
        initial_condition = ${units 300 K}                                                         # Initial condition for this variable, and t=0. '${}' specifies units, to be replaced in code.
    []
    ######################### Variables for W (block = 4)
    [C_mobile_W]
        order = FIRST
        family = LAGRANGE
        initial_condition = ${units 1.0e-20 m^-3}
        block = 4                                                                                  # Specifying a block indicates which subdomain the variable is applicable to.
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
[]                                                                                                 # End main variables

[AuxVariables]                                                                                     # Define auxillary variables; these are NOT solved by the problem's defining PDE's (defined by the Kernels later). AuxKernels will be used to define the AuxVariables as functions of the known variables (solved for by the Kernels)
    [flux_y]
        order = FIRST
        family = MONOMIAL                                                                          # Product of powers of other variables
    []
    ############################## AuxVariables for W (block = 4)
    [Sc_C_mobile_W]
        block = 4                                                                                  # Specifying the subdomain the AuxVariable is applicable to
    []
    [Sc_C_trapped_W]
        block = 4
    []
    [C_total_W]
        block = 4
    []
    [Sc_C_total_W]
        block = 4
    []
    [S_empty_W]
        block = 4
    []
    [Sc_S_empty_W]
        block = 4
    []
    [S_trapped_W]
        block = 4
    []
    [Sc_S_trapped_W]
        block = 4
    []
    [S_total_W]
        block = 4
    []
    [Sc_S_total_W]
        block = 4
    []
    ############################## AuxVariables for Cu (block = 3)
    [Sc_C_mobile_Cu]
        block = 3
    []
    [Sc_C_trapped_Cu]
        block = 3
    []
    [C_total_Cu]
        block = 3
    []
    [Sc_C_total_Cu]
        block = 3
    []
    [S_empty_Cu]
        block = 3
    []
    [Sc_S_empty_Cu]
        block = 3
    []
    [S_trapped_Cu]
        block = 3
    []
    [Sc_S_trapped_Cu]
        block = 3
    []
    [S_total_Cu]
        block = 3
    []
    [Sc_S_total_Cu]
        block = 3
    []
    ############################## AuxVariables for CuCrZr (block = 2)
    [Sc_C_mobile_CuCrZr]
        block = 2
    []
    [Sc_C_trapped_CuCrZr]
        block = 2
    []
    [C_total_CuCrZr]
        block = 2
    []
    [Sc_C_total_CuCrZr]
        block = 2
    []
    [S_empty_CuCrZr]
        block = 2
    []
    [Sc_S_empty_CuCrZr]
        block = 2
    []
    [S_trapped_CuCrZr]
        block = 2
    []
    [Sc_S_trapped_CuCrZr]
        block = 2
    []
    [S_total_CuCrZr]
        block = 2
    []
    [Sc_S_total_CuCrZr]
        block = 2
    []
[]

[Kernels]                                                                                          # Begin Kernel Section. Kernels are a piece of physics, representing one or more operators in the weak form of a PDE, with all terms on the left side = 0, their sum is the residual.
    ############################## Kernels for W (block = 4)
    [diff_W]                                                                                       # Kernel name (user-specified)
        type = ADMatDiffusion                                                                      # Type of kernel (i.e. PDE)
        variable = C_mobile_W                                                                      # independent variable used by the kernel, number of independent variables, constants and other required and optional parameters are dependent on the exact kernel type used.
        diffusivity = diffusivity_W
        block = 4                                                                                  # Subdomain the kernel is applicable to.
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
        factor = 1e0
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
        factor = 1e0
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
        factor = 1e0
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

[AuxKernels]                                                                                       # Auxillary Kernels used to calculate AuxVariables from the solved variables
    ############################## AuxKernels for W (block = 4)
    [Scaled_mobile_W]                                                                              # user-specificed name
        variable = Sc_C_mobile_W                                                                   # Auxillary kernel operating on
        type = NormalizationAux                                                                    # type of AuxKernel
        normal_factor = ${tungsten_atomic_density}
        source_variable = C_mobile_W                                                               # Source variable used to calculate AuxVariable
    []
    [Scaled_trapped_W]
        variable = Sc_C_trapped_W
        type = NormalizationAux
        normal_factor = ${tungsten_atomic_density}
        source_variable = C_trapped_W
    []
    [total_W]
        variable = C_total_W
        type = ParsedAux
        expression = 'C_mobile_W + C_trapped_W'
        coupled_variables = 'C_mobile_W C_trapped_W'
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
        N = ${units 1.0e0 m^-3}       # = ${tungsten_atomic_density} #/m^3 (W lattice density)
        # Ct0 = ${units 1.0e-4 m^-3}   # E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 1
        Ct0 = ${units 1.0e-4 m^-3}    # E.A. Hodille et al 2021 Nucl. Fusion 61 1260033, trap 2
        trap_per_free = 1.0e0         # 1.0e1
        trapped_concentration_variables = C_trapped_W
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
        source_variable = C_trapped_W
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
        source_variable = C_mobile_Cu
    []
    [Scaled_trapped_Cu]
        variable = Sc_C_trapped_Cu
        type = NormalizationAux
        normal_factor = ${tungsten_atomic_density}
        source_variable = C_trapped_Cu
    []
    [total_Cu]
        variable = C_total_Cu
        type = ParsedAux
        expression = 'C_mobile_Cu + C_trapped_Cu'
        coupled_variables = 'C_mobile_Cu C_trapped_Cu'
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
        N = ${units 1.0e0 m^-3}     # = ${tungsten_atomic_density} #/m^3 (W lattice density)
        Ct0 = ${units 5.0e-5 m^-3}  # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
        trap_per_free = 1.0e0       # 1.0e1
        trapped_concentration_variables = C_trapped_Cu
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
        source_variable = C_trapped_Cu
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
        source_variable = C_mobile_CuCrZr
    []
    [Scaled_trapped_CuCrZr]
        variable = Sc_C_trapped_CuCrZr
        type = NormalizationAux
        normal_factor = ${tungsten_atomic_density}
        source_variable = C_trapped_CuCrZr
    []
    [total_CuCrZr]
        variable = C_total_CuCrZr
        type = ParsedAux
        expression = 'C_mobile_CuCrZr + C_trapped_CuCrZr'
        coupled_variables = 'C_mobile_CuCrZr C_trapped_CuCrZr'
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
        N = ${units 1.0e0 m^-3}     # = ${tungsten_atomic_density} #/m^3 (W lattice density)
        Ct0 = ${units 5.0e-5 m^-3}  # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
        # Ct0 = ${units 4.0e-2 m^-3} # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 5
        trap_per_free = 1.0e0       # 1.0e1
        trapped_concentration_variables = C_trapped_CuCrZr
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
        source_variable = C_trapped_CuCrZr
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
        diffusivity = diffusivity_W
        variable = flux_y
        diffusion_variable = C_mobile_W
        component = y
        block = 4
    []
    [flux_y_Cu]
        type = DiffusionFluxAux
        diffusivity = diffusivity_Cu
        variable = flux_y
        diffusion_variable = C_mobile_Cu
        component = y
        block = 3
    []
    [flux_y_CuCrZr]
        type = DiffusionFluxAux
        diffusivity = diffusivity_CuCrZr
        variable = flux_y
        diffusion_variable = C_mobile_CuCrZr
        component = y
        block = 2
    []
[]                                                                                                 # I.e., AuxVariables and AuxKernels are not necessary to complete the problem (I think?), but rather are convient output values to calculate during problem operation

[InterfaceKernels]                                                                                 # Specifying specific physis/equations for material interfaces.
    [tied_4to3]                                                                                    # Interface name (user-specified)
        type = ADPenaltyInterfaceDiffusion                                                         # Kernel type
        variable = C_mobile_W                                                                      # variable applicable to the interface
        neighbor_var = C_mobile_Cu                                                                 # corresponding variable on the other side of the interface
        penalty = 0.05                                                                             # proportionality between neighbor derivative and the difference in neighbor_var and var values. See: https://mooseframework.inl.gov/source/interfacekernels/PenaltyInterfaceDiffusion.html
        #  it will not converge with > 0.1, but it creates negative C_mobile _Cu with << 0.1
        # jump_prop_name = solubility_ratio_4to3
        jump_prop_name = solubility_ratio                                                          # material property used in variable jump
        boundary = '4to3'                                                                          # boundary to apply the interface condition to.
    []
    [tied_3to2]
        type = ADPenaltyInterfaceDiffusion
        variable = C_mobile_Cu
        neighbor_var = C_mobile_CuCrZr
        penalty = 0.05
        #  it will not converge with > 0.1, but it creates negative C_mobile _Cu with << 0.1
        # jump_prop_name = solubility_ratio_3to2
        jump_prop_name = solubility_ratio
        boundary = '3to2'
    []
[]

[NodalKernels]                                                                                     # Nodal Kernels are used to solve equations that specifically belong on a node.
    ############################## NodalKernels for W (block = 4)
    [time_W]
        type = TimeDerivativeNodalKernel                                                           # This kernel: forms the contribution to the residual and jacobian of the timer derivative term from an ODE being solves at ALL nodes: https://mooseframework.inl.gov/source/nodalkernels/TimeDerivativeNodalKernel.html
        variable = C_trapped_W                                                                     # variable the residual operates on
    []
    [trapping_W]
        type = TrappingNodalKernel                                                                 # Defines time dependent trapping rate
        variable = C_trapped_W                                                                     # variable operating on
        temperature = temperature
        alpha_t = 2.75e11      # 1e15                                                              # Trapping rate coefficient
        N = 1.0e0  # = (1e0) x (${tungsten_atomic_density} #/m^3)                                  # Host atom density
        # Ct0 = 1.0e-4                # E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 1
        Ct0 = 1.0e-4                # E.A. Hodille et al 2021 Nucl. Fusion 61 1260033, trap 2      # Host trapping fraction
        trap_per_free = 1.0e0       # 1.0e1                                                        # Estimate ratio of trapped to free species
        mobile_concentration = 'C_mobile_W'                                                        # Corresponding mobile species variable
        extra_vector_tags = ref
    []
    [release_W]
        type = ReleasingNodalKernel                                                                # Release rate of trapped species: https://mooseframework.inl.gov/TMAP8/source/nodal_kernels/ReleasingNodalKernel.html
        alpha_r = 8.4e12    # 1.0e13
        temperature = temperature
        # detrapping_energy = 9863.9    # = 0.85 eV E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 1
        detrapping_energy = 11604.6                                                                # Units of kelvin.
        # = 1.00 eV E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 2
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

[BCs]                                                                                              # Begin problem boundary conditions
    [C_mob_W_top_flux]                                                                             # User defined name
        type = NeumannBC                                                                   # PDE flux boundary condition: https://mooseframework.inl.gov/source/bcs/FunctionNeumannBC.html
        variable = C_mobile_W                                                                      # Applicable variable
        value = 7.90e-13
        boundary = 'top'                                                                           # boundary name to apply condition to
    []
    [mobile_tube]
        type = DirichletBC                                                                         # Constant boundary condition, specific value for the applicable variable at the specified boundary
        variable = C_mobile_CuCrZr                                                                 # controls tritium concentration at inner tube location (un-normalized concentration) -> exact units unknown
        value = 1.0e-18                                                                            # Value at boundary
        boundary = '2to1'
    []
    [temp_top]
        type = NeumannBC                                                                   # Applies to the variable, temperature, defined by the temp_flux_bc_func function.
        variable = temperature                                                                     # FunctionNeumannBC
        value = 1.0e7
        boundary = 'top'
    []
    [temp_tube]
        type = DirichletBC                                                                 # Constant BC, but the exact value is defined by a later function. 'Constant' is allowed to be spatially and temporally dependent: https://mooseframework.inl.gov/source/bcs/FunctionDirichletBC.html
        variable = temperature                                                                     # specifies inner tube temperature at the boundary: 2to1 (CuCrZr to H20)
        value = 552
        boundary = '2to1'
    []
[]
[Functions]                                                                                        # Specific physical relationship, allowed to be used by multiple objects
    [timestep_function]
        type = ParsedFunction
        expression = 'if(t<100, 25, 400)'
    []
[]
[Materials]                                                                                        # Material properties and relationships to apply to subdomains.
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
        prop_values = '19300'                # [g/m^3]
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
        prop_values = '8960.0'                # [g/m^3]
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
        prop_values = '8900.0 390.0'            # [g/m^3], [ W/m-K], [J/kg-K]
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

[Postprocessors]                                                                                   # Postprocessors compute single scalar values based on node results
#   ########################################################### Side Postprocessors !!! Added !!!
    [F_recombination]
        type = SideDiffusiveFluxAverage                                                            # Calculating average flux (integrated) over the specificed boundary
        boundary = 'top'
        diffusivity = 5.01e-24   # (3.01604928)/(6.02e23)/[gram(T)/m^2]
        # diffusivity = 5.508e-19   # (1.0e3)*(1.0e3)/(6.02e23)/(3.01604928) [gram(T)/m^2]
        variable = Sc_C_total_W
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [F_permeation] # Uses conversion factor, not really flux
        type = SideDiffusiveFluxAverage
        boundary = '2to1'
        diffusivity = 5.01e-24   # (3.01604928)/(6.02e23)/[gram(T)/m^2]
        # diffusivity = 5.508e-19   # (1.0e3)*(1.0e3)/(6.02e23)/(3.01604928) [gram(T)/m^2]
        variable = Sc_C_total_CuCrZr
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
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
    [coolant_heat_flux] # units of W/m2
        type = SideDiffusiveFluxAverage
        boundary = '2to1'
        diffusivity = thermal_conductivity_CuCrZr
        variable = temperature
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    ############################################################ Postprocessors for W (block = 4)
    [Int_C_mobile_W]
        type = ElementIntegralVariablePostprocessor                                                 # Compute the volume integral over a subdomain
        variable = C_mobile_W
        block = 4
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_mobile_W]
        type = ScalePostprocessor                                                                  # Scales some other PostProcessor by a real value
        value =  Int_C_mobile_W
        scaling_factor = 3.491e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
    []
    [Int_C_trapped_W]
        type = ElementIntegralVariablePostprocessor
        variable = C_trapped_W
        block = 4
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_trapped_W]
        type = ScalePostprocessor
        value = Int_C_trapped_W
        scaling_factor = 3.491e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
    []
    [Int_C_total_W]
        type = ElementIntegralVariablePostprocessor
        variable = C_total_W
        block = 4
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_total_W]
        type = ScalePostprocessor
        value = Int_C_total_W
        scaling_factor = 3.491e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
    []
    # ############################################################ Postprocessors for Cu (block = 3)
    [Int_C_mobile_Cu]
        type = ElementIntegralVariablePostprocessor
        variable = C_mobile_Cu
        block = 3
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_mobile_Cu]
        type = ScalePostprocessor
        value =  Int_C_mobile_Cu
        scaling_factor = 3.491e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [Int_C_trapped_Cu]
        type = ElementIntegralVariablePostprocessor
        variable = C_trapped_Cu
        block = 3
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_trapped_Cu]
        type = ScalePostprocessor
        value = Int_C_trapped_Cu
        scaling_factor = 3.44e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [Int_C_total_Cu]
        type = ElementIntegralVariablePostprocessor
        variable = C_total_Cu
        block = 3
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_total_Cu]
        type = ScalePostprocessor
        value = Int_C_total_Cu
        scaling_factor = 3.491e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    # ############################################################ Postprocessors for CuCrZr (block = 2)
    [Int_C_mobile_CuCrZr]
        type = ElementIntegralVariablePostprocessor
        variable = C_mobile_CuCrZr
        block = 2
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_mobile_CuCrZr]
        type = ScalePostprocessor
        value =  Int_C_mobile_CuCrZr
        scaling_factor = 3.491e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [Int_C_trapped_CuCrZr]
        type = ElementIntegralVariablePostprocessor
        variable = C_trapped_CuCrZr
        block = 2
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_trapped_CuCrZr]
        type = ScalePostprocessor
        value = Int_C_trapped_CuCrZr
        scaling_factor = 3.44e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [Int_C_total_CuCrZr]
        type = ElementIntegralVariablePostprocessor
        variable = C_total_CuCrZr
        block = 2
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [ScInt_C_total_CuCrZr]
        type = ScalePostprocessor
        value = Int_C_total_CuCrZr
        scaling_factor = 3.491e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    ############################################################ Postprocessors for others
    [dt]
        type = TimestepSize                                                                        # Reports timestep size
    []
    [temperature_top]                                                                              # Reports variable value at a specific point (x,y,z)
        type = PointValue
        variable = temperature
        point = '0 14.0e-3 0'
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [temperature_tube]
        type = PointValue
        variable = temperature
        point = '0 6.0e-3 0'
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    # limit timestep
    [timestep_max_pp] # s
        type = FunctionValuePostprocessor
        function = timestep_function
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [max_temperature_W] # !!! ADDED !!!
        type = ElementExtremeValue
        block = 4
        variable = 'temperature'
        value_type = max
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [max_temperature_Cu] # !!! ADDED !!!
        type = ElementExtremeValue
        block = 3
        variable = 'temperature'
        value_type = max
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [max_temperature_CuCrZr] # !!! ADDED !!!
        type = ElementExtremeValue
        block = 2
        variable = 'temperature'
        value_type = max
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [avg_temperature_W] # !!! ADDED !!!
        type = ElementAverageValue
        variable = temperature
        block = 4
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [avg_temperature_Cu] # !!! ADDED !!!
        type = ElementAverageValue
        variable = temperature
        block = 3
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [avg_temperature_CuCrZr] # !!! ADDED !!!
        type = ElementAverageValue
        variable = temperature
        block = 2
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [max_concentration_W] # !!! ADDED !!!
        type = ElementExtremeValue
        variable = 'C_total_W'
        value_type = max
        block = 4
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [max_concentration_Cu] # !!! ADDED !!!
        type = ElementExtremeValue
        variable = 'C_total_Cu'
        value_type = max
        block = 3
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [max_concentration_CuCrZr] # !!! ADDED !!!
        type = ElementExtremeValue
        variable = 'C_total_CuCrZr'
        value_type = max
        block = 2
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [area_W] # !!! ADDED !!!
        type = VolumePostprocessor
        block = 4
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [area_Cu] # !!! ADDED !!!
        type = VolumePostprocessor
        block = 3
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [area_CuCrZr] # !!! ADDED !!!
        type = VolumePostprocessor
        block = 2
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
    [total_retention] # !!! ADDED !!!
        type = SumPostprocessor
        values = 'ScInt_C_total_W ScInt_C_total_Cu ScInt_C_total_CuCrZr'
        execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
    []
[]

[Preconditioning]                                                                                  # https://mooseframework.inl.gov/syntax/Preconditioning/
    [smp]
        type = SMP
        full = true
    []
[]

[Executioner]                                                                                      # Solution parameters
    type = Transient
    scheme = bdf2
    solve_type = NEWTON
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
    nl_rel_tol  = 1e-2 # 1e-6                                                   # Relative independent parameter tolerance
    nl_abs_tol  = 1e-1 # 1e-7                                                 # Absolute tolerance
    end_time = 2.5e1   # 50 ITER shots (3.0e4 s plasma, 2.0e4 SSP)                                 # Total simulation time
    automatic_scaling = true
    line_search = 'none'
    dtmin = 1e-4                                                                                   # Minimum time step for convergence, time step size is reduced upon non-convergence, but dtmin is an absolute limit. Passing this will result in an error
    nl_max_its = 24                                                                                # Maximum number of iterations for convergence
    [TimeStepper]
        type = IterationAdaptiveDT
        dt = 20
        optimal_iterations = 15
        iteration_window = 1
        growth_factor = 2.0
        cutback_factor = 0.8
        timestep_limiting_postprocessor = timestep_max_pp
    []
[]

[Outputs]                                                                                          # Control outputs, include exodus and csv.
    execute_on = 'none'
[]

