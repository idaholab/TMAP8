# TMAP8 input file
# Written by Pierre-Clément Simon - Idaho National Laboratory
#
# Published with:
# P.-C. A. Simon, P. W. Humrickhouse, A. D. Lindsay,
# "Tritium Transport Modeling at the Pore Scale in Ceramic Breeder Materials Using TMAP8,"
# in IEEE Transactions on Plasma Science, 2022, doi: 10.1109/TPS.2022.3183525.
#
# Info:
# - This input file used to generate polycrystals for SiC.
# - This simulation predicts phase evolution based on a grain growth phase field model.
# - The pore and the ceramics represent two different phases and the initial conditions
#   are provided with a black and white picture, which is read by ImageFunction.
# - The simulation smoothens the interface between the two phases.
#
#
# Once TMAP8 is installed and built (see instructions on the TMAP8 website), run with
# cd ~/projects/TMAP8/test/tests/pore_scale_transport/
# mpirun -np 8 ~/projects/TMAP8/tmap8-opt -i 2D_microstructure_reader_smoothing_base.i pore_structure_open.params

# mesh information
num_nodes_x = ${fparse 2*120} # (-)
num_nodes_y = ${fparse 2*120} # (-)
domain_start_x = ${units 0 mum}
domain_start_y = ${units 0 mum}
domain_end_x = ${units 5425 mum}
domain_end_y = ${units 5425 mum}

# grain growth parameters (since the point of the simulation is only to get a smooth interface, the model parameters can be selected arbitrarily)
op_num = 2 # Number of grains
mobility_prefactor = 2.5e-6
GB_energy = 0.7
activation_energy = 0.23
temperature = ${units 700 K}
width_diffuse_GB = ${units 50 mum} # Width of the diffuse GB

# image function option
threshold_image_function = 255.5 # (-)

[Mesh]
  [gen]
    type = DistributedRectilinearMeshGenerator
    dim = 2
    nx = ${num_nodes_x}
    ny = ${num_nodes_y}
    xmin = ${domain_start_x}
    xmax = ${domain_end_x}
    ymin = ${domain_start_y}
    ymax = ${domain_end_y}
  []
[]

[GlobalParams]
  op_num = ${op_num}
  var_name_base = gr # Base name of grains
[]

[UserObjects]
  [grain_tracker]
    type = GrainTracker
    flood_entity_type = ELEMENTAL
    compute_halo_maps = true # For displaying HALO fields
  []
[]

[Functions]
  [image_func0]
    type = ImageFunction
    file = ${input_name}
    threshold = ${threshold_image_function}
    upper_value = 1
    lower_value = 0
  []
  [image_func1]
    type = ImageFunction
    file = ${input_name}
    threshold = ${threshold_image_function}
    upper_value = 0
    lower_value = 1
  []
[]

[ICs]
  [gr0_ic]
    type = FunctionIC
    function = image_func0
    variable = gr0
  []
  [gr1_ic]
    type = FunctionIC
    function = image_func1
    variable = gr1
  []
[]

[Variables]
  [PolycrystalVariables]
    # Custom action that created all of the phase variables and sets their initial condition
  []
[]

[AuxVariables]
  [bnds]
    # Variable used to visualize the interfaces in the simulation
  []
  [unique_grains]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [PolycrystalKernel]
    # Custom action creating all necessary kernels for phase evolution.  All input parameters are up in GlobalParams
  []
[]

[AuxKernels]
  [bnds_aux]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'initial timestep_end'
  []
  [unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    execute_on = timestep_end
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  []
[]

[Materials]
  [CuGrGr]
    type = GBEvolution
    GBmob0 = ${mobility_prefactor}
    GBenergy = ${GB_energy}
    Q = ${activation_energy}
    T = ${temperature}
    wGB = ${width_diffuse_GB}
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = '  hypre    boomeramg                   0.7'

  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 40
  nl_abs_tol = 1e-11
  nl_rel_tol = 1e-10

  [TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.9
    dt = 3e-2
    growth_factor = 1.1
    optimal_iterations = 7
  []
  dtmax = 25

  start_time = 0.0
  end_time = 100
[]

[Outputs]
  file_base = ${output_name}
  [exodus]
    type = Exodus
    execute_on = 'FINAL'
  []
[]
