# Verification Problem #1d from TMAP4/TMAP7 V&V document
# Permeation Problem with Trapping in Diffusion-limited Case
# No Soret effect, or solubility included.

# Modeling parameters
node_num = 200
thickness = '${units 1 m}'
end_time = ${units 3 s}
temperature = '${units 1000 K}'
diffusivity = ${units 1 m^2/s}

# Trapping parameters
density = '${units 3.1622e22 at/m^3}'
cl = '${units 3.1622e18 at/m^3}'
trapping_prefactor = ${units 1e15 1/s}
release_prefactor = ${units 1e13 1/s}
release_energy = ${units 100 K}
trapping_fraction = 0.1 # -

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${node_num}
  xmax = ${thickness}
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Variables]
  # mobile tritium variable
  [mobile]
  []
  # trapped tritium variable
  [trapped]
  []
[]

[Kernels]
  # kernel for mobile tritium
  [diff]
    type = MatDiffusion
    variable = mobile
    diffusivity = ${diffusivity}
    extra_vector_tags = ref
  []
  [time]
    type = TimeDerivative
    variable = mobile
    extra_vector_tags = ref
  []
  # kernel for trapped tritium
  [coupled_time]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped
    extra_vector_tags = ref
  []
[]

[NodalKernels]
  # kernel for trapped tritium in nodal sites
  [time]
    type = TimeDerivativeNodalKernel
    variable = trapped
  []
  [trapping]
    type = TrappingNodalKernel
    variable = trapped
    alpha_t = ${trapping_prefactor}
    N = '${fparse density / cl}'
    Ct0 = ${trapping_fraction}
    mobile_concentration = 'mobile'
    temperature = ${temperature}
    extra_vector_tags = ref
  []
  [release]
    type = ReleasingNodalKernel
    alpha_r = ${release_prefactor}
    temperature = ${temperature}
    detrapping_energy = ${release_energy}
    variable = trapped
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = mobile
    value = '${fparse cl / cl}'
    boundary = left
  []
  [right]
    type = DirichletBC
    variable = mobile
    value = 0
    boundary = right
  []
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'right'
    diffusivity = ${diffusivity}
    variable = mobile
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = ${cl}
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
  end_time = ${end_time}
  dt = .01
  dtmin = .01
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  verbose = true
  compute_scaling_once = false
[]

[Outputs]
  csv = true
  exodus = true
  [dof]
    type = DOFMap
    execute_on = initial
  []
  perf_graph = true
[]
