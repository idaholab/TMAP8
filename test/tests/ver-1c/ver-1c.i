# Verification Problem #1c from TMAP4/TMAP7 V&V document
# Diffusion Problem with Partially Preloaded Slab
# No Soret effect, solubility, or trapping included.

# Locations for concentration comparison
# TMAP7 - 12, 0.25, h (10)
# TMAP4 - 12, 0,    h (10)

# Modeling parameters
node_num = 1e4
thickness = '${units 100 m}'
pre_load_thickness = '${units 10 m}'
pre_load_concentration = '${units 1 atom/m^3}'
end_time = '${units 100 s}'
diffusivity = '${units 1.0 m^2/s}'

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${node_num}
  xmax = ${thickness}
[]

[Variables]
  # mobile tritium variable
  [u]
  []
[]

[ICs]
  # Initial concentration with pre-load tritium
  [function]
    type = FunctionIC
    variable = u
    function = 'if(x<${pre_load_thickness},${pre_load_concentration},0)'
  []
[]

[BCs]
  [lhs]
    type = DirichletBC
    variable = u
    value = 0
    boundary = left
  []
[]

[Kernels]
  [diff]
    type = MatDiffusion
    variable = u
    diffusivity = ${diffusivity}
  []
  [time]
    type = TimeDerivative
    variable = u
  []
[]

[Postprocessors]
  [point0]
    type = PointValue
    variable = u
    point = '0 0 0'
  []
  [point0.25]
    type = PointValue
    variable = u
    point = '0.25 0 0'
  []
  [point10]
    type = PointValue
    variable = u
    point = '10.0 0 0'
  []
  [point12]
    type = PointValue
    variable = u
    point = '12 0 0'
  []
[]

[Executioner]
  type = Transient
  end_time = ${end_time}
  solve_type = NEWTON
  scheme = bdf2
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  l_tol = 1e-9
  timestep_tolerance = 1e-8
  dtmax = 2
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.001
    growth_factor = 1.25
    cutback_factor = 0.8
    optimal_iterations = 4
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
  []
  perf_graph = true
[]
