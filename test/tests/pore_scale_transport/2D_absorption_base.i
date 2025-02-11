# TMAP8 input file
# Written by Pierre-Clément Simon - Idaho National Laboratory
#
# Published with:
# P.-C. A. Simon, P. W. Humrickhouse, A. D. Lindsay,
# "Tritium Transport Modeling at the Pore Scale in Ceramic Breeder Materials Using TMAP8,"
# in IEEE Transactions on Plasma Science, 2022, doi: 10.1109/TPS.2022.3183525.
#
# Phase Field Model:   Isotropic bulk diffusion, pore surface reactions, isotropic pore diffusion
# Type:                Transient
# Phase structure:     Contains two phases: the bulk of a material, and the pores. An interface separates the two
# Physics:             tritium trapping and detrapping, surface reactions, diffusion
# Species variable:    tritium_s (Ts), tritium_trap (trapped T), tritium_2g (T2(g))
# Species AuxVariable: --
# Chemistry:           at the pore surface: (s) means in the solid, (g) means in gas form
#    Diatomic molecule dissolving at surface
#                                 T2(g) -> 2 T(s) rate K [T2] (1-theta)^2
#    Diatomic molecule combining at surface
#                                 2 T(s) -> T2(g) rate K [T]^2
#
# BCs:                 No flux for tritium and tritium_trap, zero at pore center for gaseous tritium in every form
#
#
# Info:
# - This input file uses the microstructure generated by 2D_microstructure_reader_smoothing_base.i
#   and performs tritium transport simulation on this microstructure.
# - Basic 2D non-dimensional input file for the transport of a solute in a microstructure with pores.
# - The goal of this input base and associated parameter files is to have the same simulation with different pore configurations
#   to show the effect of microstructure on tritium release.
#
#
# Once TMAP8 is installed and built (see instructions on the TMAP8 website), run with
# cd ~/projects/TMAP8/test/tests/pore_scale_transport/
# mpirun -np 8 ~/projects/TMAP8/tmap8-opt -i 2D_absorption_base.i pore_structure_open_absorption.params

# Scaling factors
scale_quantity = ${units 1e-18 moles}
scale_time = ${units 1 s}
scale_length = ${units 1 mum}
tritium_trap_scaling = 1e3 # (-)
tritium_s_scaling = 1e2 # (-)

# Conditions
tritium_2g_concentration = ${units 0.1121 mol/mum^3}

# Material properties
tritium_trap_0 = ${units 3.472805925e-18 mol/mum^3}
tritium_trap_0_scaled = ${fparse tritium_trap_0*scale_length^3/scale_quantity} # non-dimensional
available_sites_mult = 4.313540691 # (-) should be >1, otherwise there are fewer 'available sites' than 'trapping sites'
Diffusion_min = ${units 0 mum^2/s} # used as diffusion coefficients where I don't want the species to move (more stable than 0)
Diffusion_coefficient_Db_D0 = ${units 1649969.728 mum^2/s}
Diffusion_coefficient_D_pore_D0 = ${units 224767738.6 mum^2/s}
detrapping_rate_0 = ${units -4.065104516 1/s} # should be negative
trapping_rate_0 = ${units 8.333146645e+16 1/s/mol} # should be positive
reactionRateSurface_sXYg_ref_0 = ${units 1549103878000000.0 1/s/mol}
reactionRateSurface_gXYs_ref_0 = ${units 34.69205021 1/s}

[Mesh]
  file = ${input_name}
[]

[UserObjects]
  [initial_microstructure]
    type = SolutionUserObject
    mesh = ${input_name}
    timestep = LATEST
  []
[]

[Variables]
  [tritium_s]
    scaling = ${tritium_s_scaling}
  []
  [tritium_trap]
    scaling = ${tritium_trap_scaling}
  []
  [tritium_2g]
  []
[]

[ICs]
  [tritium_2g_ic]
    type = FunctionIC
    variable = tritium_2g
    function = 'gaseous_concentration_1_function_ic'
  []
[]

[Functions]
  [pore_position_func]
    type = SolutionFunction
    solution = initial_microstructure
    from_variable = gr0
  []
  [gaseous_concentration_1_function_ic]
    type = ParsedFunction
    symbol_names = 'len_pore  position_pore_int'
    symbol_values = '25   4521'
    expression = '${tritium_2g_concentration}*0.5*(1.0+tanh((sqrt(x*x+y*y)-position_pore_int)/(len_pore/2.2)))'
  []
[]

[BCs]
  [tritium_2g_sides_d] # Fix concentration on the sides
    type = DirichletBC
    variable = tritium_2g
    boundary = 'right top'
    value = ${tritium_2g_concentration}
  []
[]

[AuxVariables]
  [pore]
    initial_from_file_var = gr0
    initial_from_file_timestep = LATEST
  []
  # Used to prevent negative concentrations
  [bounds_dummy_tritium_s]
    order = FIRST
    family = LAGRANGE
  []
  [bounds_dummy_tritium_2g]
    order = FIRST
    family = LAGRANGE
  []
[]

[Bounds]
  # To prevent negative concentrations
  [tritium_s_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy_tritium_s
    bounded_variable = tritium_s
    bound_type = lower
    bound_value = 0.
  []
  [tritium_g_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy_tritium_2g
    bounded_variable = tritium_2g
    bound_type = lower
    bound_value = 0.
  []
[]

[Kernels]
  # ========================================== Time derivative for each variable
  [dtritium_sdt]
    type = TimeDerivative
    variable = 'tritium_s'
  []
  [dtritium_2gdt]
    type = TimeDerivative
    variable = 'tritium_2g'
  []
  [dtritium_trapdt]
    type = TimeDerivative
    variable = 'tritium_trap'
  []
  # ============================================================= Bulk diffusion
  [Diff_tritium]
    type = ADMatDiffusion
    variable = tritium_s
    diffusivity = D_tritium
  []
  # ============================================================= Pore diffusion
  [Diff_tritium2g]
    type = ADMatDiffusion
    variable = tritium_2g
    diffusivity = D_pore
  []
  # ================================================ Tritium trapping/detrapping
  [Trapping]
    type = CoupledTimeDerivative
    variable = tritium_s
    v = 'tritium_trap'
  []
  [Detrapping_trap]
    type = ADMatReaction
    variable = 'tritium_trap'
    reaction_rate = ${fparse scale_time * detrapping_rate_0} # from 1/s to non-dimensional
  []
  [Trapping_trap]
    type = ADMatCoupledDefectAnnihilation
    variable = 'tritium_trap'
    eq_concentration = ${tritium_trap_0_scaled}
    v = tritium_s
    annihilation_rate = ${fparse scale_time*scale_quantity/scale_length^3*trapping_rate_0} # from um^3/s/mol to non-dimensional
  []
  # ========================= Surface Reactions ================================
  # ======================================= Diatomic molecule dissolve at surface
  # T2(g) -> 2 T(s) rate K [T2] (1-theta) ======================================
  [Surface_Reaction_dissolution_tritium_2g] # T2(g) -> 2 T(s) rate -K*tritium_2g
    type = ADMatReactionFlexible
    variable = tritium_2g
    vs = 'tritium_2g'
    coeff = -1
    reaction_rate_name = ReactionRateSurface_gXYs
  []
  [Surface_Reaction_dissolution_tritium_2g_tritium_s] # T2(g) -> 2 T(s) rate 2*K*tritium_2g
    type = ADMatReactionFlexible
    variable = tritium_s
    vs = 'tritium_2g'
    coeff = 2
    reaction_rate_name = ReactionRateSurface_gXYs
  []
  # ======================================= Diatomic molecule combine at surface
  # 2 T(s) -> T2(g) rate K [T]^2 ===============================================
  [Surface_Reaction_release_tritium_s_tritium_2g] # 2 T(s) -> T2(g) rate -2*K*tritium_s^2
    type = ADMatReactionFlexible
    variable = tritium_s
    vs = 'tritium_s tritium_s'
    coeff = -2
    reaction_rate_name = ReactionRateSurface_sXYg
  []
  [Surface_Reaction_formation_tritium_2g] # 2 T(s) -> T2(g) rate K*tritium_s^2
    type = ADMatReactionFlexible
    variable = tritium_2g
    vs = 'tritium_s tritium_s'
    coeff = 1
    reaction_rate_name = ReactionRateSurface_sXYg
  []
[]

[AuxKernels]
  [pore_aux]
    type = FunctionAux
    variable = pore
    function = 'pore_position_func'
    execute_on = 'INITIAL'
  []
[]

[Materials]
  #===================================================== Interpolation functions
  [hsurfaceAD] # equal to 1 at pore surface, 0 elsewhere. The values of hsurface should be smaller than the ones for hmat or hpore to allow the diffusion of the species out of the surface
    type = ADDerivativeParsedMaterial
    coupled_variables = 'pore'
    expression = '16*(1-pore)^2*pore^2'
    property_name = 'hsurfaceAD'
  []
  [hmatAD] # equal to 1 in material, and 0 in pore.
    type = ADDerivativeParsedMaterial
    coupled_variables = 'pore'
    expression = '(1-pore)*(1-pore)'
    property_name = 'hmatAD'
  []
  [hporeAD] # equal to 1 in pore, and 1 in material. # notice that hpore overlaps a bit with hmat to prevent some agglomeration of chemicals on the edges of the surface.
    type = ADDerivativeParsedMaterial
    coupled_variables = 'pore'
    expression = 'pore*pore'
    property_name = 'hporeAD'
  []
  #================================================= Local species concentration
  [Tritium_ceramic]
    type = ADParsedMaterial
    property_name = 'tritium_ceramic'
    coupled_variables = 'tritium_s tritium_trap'
    expression = 'tritium_s+tritium_trap'
  []
  [Tritium_pore]
    type = ADParsedMaterial
    property_name = 'tritium_pore'
    coupled_variables = 'tritium_2g'
    expression = '2*tritium_2g'
  []
  [Tritium_total]
    type = ADParsedMaterial
    property_name = 'tritium_tot'
    coupled_variables = 'tritium_s tritium_trap tritium_2g'
    expression = 'tritium_s+tritium_trap+2*tritium_2g'
  []
  #=============================================== Occupied sites on the surface
  [theta]
    type = ADParsedMaterial
    property_name = 'theta'
    coupled_variables = 'tritium_s tritium_trap'
    expression = '(tritium_s + tritium_trap)/(${available_sites_mult}*${tritium_trap_0_scaled})'
  []
  #====================================================== Diffusion coefficients
  [Diffusion_coefficient_D] # from um^2/s to non-dimensional
    type = ADDerivativeParsedMaterial
    property_name = 'D_tritium'
    coupled_variables = 'pore'
    material_property_names = 'hmatAD(pore)'
    expression = '${scale_time}/${scale_length}^2*(hmatAD*${Diffusion_coefficient_Db_D0} + (1-hmatAD)*${Diffusion_min})'
    derivative_order = 2
  []
  [Diffusion_coefficient_D_pore] # from um^2/s to non-dimensional
    type = ADDerivativeParsedMaterial
    property_name = 'D_pore'
    material_property_names = 'hporeAD(pore)'
    expression = '${scale_time}/${scale_length}^2*(hporeAD*${Diffusion_coefficient_D_pore_D0} + (1-hporeAD)*${Diffusion_min})'
  []
  #============================================ Surface reaction rate of tritium
  [ReactionRateSurface_sXYg_ref] # from surface to gaseous for diatomic molecules # from um^3/s/mol to non-dimensional
    type = ADDerivativeParsedMaterial
    property_name = ReactionRateSurface_sXYg
    material_property_names = 'hsurfaceAD(pore)'
    expression = '${scale_time}*${scale_quantity}/${scale_length}^3*${reactionRateSurface_sXYg_ref_0}*hsurfaceAD'
  []
  [ReactionRateSurface_gXYs_ref] # from gaseous to surface for diatomic molecules # from 1/s to non-dimensional
    type = ADDerivativeParsedMaterial
    property_name = ReactionRateSurface_gXYs
    coupled_variables = 'pore tritium_s tritium_trap'
    material_property_names = 'hsurfaceAD(pore) theta(tritium_s,tritium_trap)'
    expression = '${scale_time}*${reactionRateSurface_gXYs_ref_0}*hsurfaceAD*(1-theta)^2'
  []
[]

[Postprocessors]
  [Tritium_amount_free]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_s
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Tritium_amount_trapped]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_trap
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Tritium_amount_ceramic]
    type = ADElementIntegralMaterialProperty
    mat_prop = tritium_ceramic
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Tritium2g_amount]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_2g
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Tritium_amount_pore]
    type = ADElementIntegralMaterialProperty
    mat_prop = tritium_pore
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Tritium_amount_total]
    type = ADElementIntegralMaterialProperty
    mat_prop = tritium_tot
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Surface_tot]
    type = ElementIntegralMaterialProperty
    mat_prop = 1
  []
  [dt]
    type = TimestepSize
  []
[]

[Preconditioning]
  [Newtonlu]
    type = SMP
    full = true
    solve_type = 'NEWTON'
    petsc_options_iname = '-pc_type -sub_pc_type -snes_type'
    petsc_options_value = 'asm      lu           vinewtonrsls' # This petsc option helps prevent negative concentrations'
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2

  nl_rel_tol = 1e-10
  end_time = 2000
  dtmax = 50
  nl_max_its = 14
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 12
    iteration_window = 1
    growth_factor = 1.2
    dt = 2.37e-7
    cutback_factor = 0.75
    cutback_factor_at_failure = 0.75
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    time_step_interval = 5
  []
  csv = true
  file_base = ${output_name}
[]
