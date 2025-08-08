T_PyC = ${units 33 mum -> m}
T_SiC = ${units 66 mum -> m}
D_ver = ${units 15.75 mum -> m}

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'u'

    physics = 'diff'

    # Geometry
    nx = 1000
    xmax = ${fparse ${T_PyC} + ${T_SiC} }
    length_unit_scaling = 1
  []
[]

[Physics]
  [Diffusion]
    [diff]
      variable_name = 'u'
      diffusivity_matprop = diffusivity_value

      dirichlet_boundaries = 'structure_left structure_right'
      boundary_values = '50.7079 0' # moles/m^3

      # Test differences are too large with default preconditioning
      preconditioning = 'defer'
    []
  []
[]

[Materials]
  [diff]
    type = ADGenericFunctionMaterial
    prop_names = diffusivity_value
    prop_values = diffusivity_value
  []
[]

[Functions]
  [diffusivity_value]
    type = ParsedFunction
    expression = 'if(x< ${units 33 mum -> m}, 1.274e-7, 2.622e-11)'
  []
[]

# Used while obtaining steady-state solution
#
[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${ActionComponents/structure/xmax} 0 0'
    num_points = ${ActionComponents/structure/nx}
    sort_by = 'x'
    variable = u
    outputs = vector_postproc
  []
[]

[Postprocessors]
  # Used to obtain varying concentration with time at a
  # point in SiC layer 'x' um from IPyC/SiC boundary
  # x = 8 um for TMAP4 verification case,
  # x = 15.75 um for TMAP7 verification case
  [conc_at_x]
    type = PointValue
    variable = u
    point = '${fparse ${T_PyC} + ${D_ver}} 0 0'
    outputs = 'csv'
  []
[]

[Executioner]
  type = Transient
  end_time = 5000
  dtmax = 10
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  scheme = 'bdf2'
  nl_rel_tol = 1e-50 # Make this really tight so that our absolute tolerance criterion is the one
  # we must meet
  nl_abs_tol = 1e-12
  abort_on_solve_fail = true
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-4
    optimal_iterations = 4
    growth_factor = 1.25
    cutback_factor = 0.8
  []
[]

[Outputs]
  [exodus]
    type = Exodus
  []
  [csv]
    type = CSV
  []
  [vector_postproc]
    type = CSV
    sync_times = 5000
    sync_only = true
  []
[]
