# Verification Problem #1b from TMAP4/TMAP7 V&V document
# Tritium diffusion through SiC layer with constant source using a Physics and Components syntax
# No Soret effect, solubility, or trapping included.

# Modeling parameters
node_num = 5000
end_time = '${units 50 s}'
thickness = '${units 0.2 mm -> mum}' # 200 mum
diffusivity = '${units 1.0 mum^2/s}'
concentration_left = '${units 1 atom/mum^3}'

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'u'
    physics = 'multi-D'

    # Geometry
    nx = ${node_num}
    xmax = ${thickness}
    length_unit_scaling = 1
  []
[]

[Physics]
  [Diffusion]
    [multi-D]
      variable_name = 'u'
      diffusivity_matprop = ${diffusivity}

      dirichlet_boundaries = 'structure_left structure_right'
      boundary_values = '${concentration_left} 0'

      # Keep closer results to original inputs
      preconditioning = 'defer'
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
    diffusivity = ${diffusivity}
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
  end_time = ${end_time}
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
