# Verification Problem #1e from TMAP4/TMAP7 V&V document
# Permeation problem in a composite layer using a Physics and Components syntax
# No Soret effect, trapping, or solubility included.

# Numerical parameters
nx_num = 1000 # -
simulation_time = ${units 5000 s}

# Data used in TMAP4/TMAP7 case
T_PyC = ${units 33 mum -> m}
T_SiC = ${units 66 mum -> m}
D_ver = ${units 15.75 mum -> m}
Diffusivity_PyC = ${units 1.274e-7 m^2/s}
Diffusivity_SiC = ${units 2.622e-11 m^2/s}
length_PyC = ${units 33 mum -> m}
initial_concentration = ${units 50.7079 mol/m^3}

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'u'

    physics = 'diff'

    # Geometry
    nx = ${nx_num}
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
      boundary_values = '${initial_concentration} 0' # moles/m^3

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
    expression = 'if(x< ${length_PyC}, ${Diffusivity_PyC}, ${Diffusivity_SiC})'
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
  end_time = ${simulation_time}
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
    sync_times = ${simulation_time}
    sync_only = true
  []
[]
