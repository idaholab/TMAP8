[ActionComponents]
  [structure]
    type = Structure1D
    species = 'u'
    physics = 'multi-D'

    # Geometry
    nx = 5000
    xmax = 200
    length_unit_scaling = 1
  []
[]

[Physics]
  [Diffusion]
    [ContinuousGalerkin]
      [multi-D]
        variable_name = 'u'
        diffusivity_matprop = 1

        dirichlet_boundaries = 'structure_left structure_right'
        boundary_values = '1 0'
      []
    []
  []
[]

[AuxVariables]
  [flux_x]
    order = FIRST
    family = MONOMIAL
  []
[]

[AuxKernels]
  [flux_x]
    type = DiffusionFluxAux
    diffusivity = '${fparse 1.0}'
    variable = flux_x
    diffusion_variable = u
    component = x
  []
[]

[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '50 0 0'
    num_points = 51
    sort_by = 'x'
    variable = u
    outputs = 'vector_postproc'
  []
[]

[Postprocessors]
  [conc_point1]
    type = PointValue
    variable = u
    point = '.2 0 0'
    outputs = 'csv'
  []
  [flux_point2]
    type = PointValue
    variable = flux_x
    point = '.5 0 0'
    outputs = 'csv'
  []
[]

[Executioner]
  type = Transient
  end_time = 50
  dt = .1
  solve_type = NEWTON
  petsc_options_iname = '-pc_type '
  petsc_options_value = 'lu '
  scheme = 'bdf2'
[]

[Outputs]
  [exodus]
    type = Exodus
    file_base = 'ver-1b-component_out'
  []
  [csv]
    type = CSV
    time_step_interval = 10
  []
  [vector_postproc]
    type = CSV
    sync_times = '25'
    sync_only = true
  []
  perf_graph = true
[]
