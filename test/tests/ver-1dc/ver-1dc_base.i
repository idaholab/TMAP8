# This is the base input file for the ver-1dc case.
# This input file is meant to be included into the ver-1dc.i input file
# and into the ver-1dc_mms.i input file to be full.
# Its purpose is to centralize the capability common to the two cases
# within one file to minimize redundancy and ease maintenance.
# It is not meant to be run on its own.

# cl = 3.1622e18 # atom/m^3
# N = 3.1622e22 # atom/m^3
epsilon_1 = ${units 100 K}
epsilon_2 = ${units 500 K}
epsilon_3 = ${units 800 K}
temperature = ${units 1000 K}
# nx_num = 1000 # (-)
trapping_site_fraction_1 = 0.10 # (-)
trapping_site_fraction_2 = 0.15 # (-)
trapping_site_fraction_3 = 0.20 # (-)
# trapping_rate_coefficient = 1e15 # 1/s
# release_rate_coefficient = 1e13 # 1/s
diffusivity = 1 # m^2/s
# simulation_time = 60 # s
# time_interval_max = 0.3 # s

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${nx_num}
  xmax = 1
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Variables]
  [mobile]
  []
  [trapped_1]
  []
  [trapped_2]
  []
  [trapped_3]
  []
[]

[Kernels]
  [diff]
    type = Diffusion
    variable = mobile
    extra_vector_tags = ref
  []
  [time]
    type = TimeDerivative
    variable = mobile
    extra_vector_tags = ref
  []
  [coupled_time_1]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_1
    extra_vector_tags = ref
  []
  [coupled_time_2]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_2
    extra_vector_tags = ref
  []
  [coupled_time_3]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_3
    extra_vector_tags = ref
  []
[]


[NodalKernels]
  # For first traps
  [time_1]
    type = TimeDerivativeNodalKernel
    variable = trapped_1
  []
  [trapping_1]
    type = TrappingNodalKernel
    variable = trapped_1
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_1}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [release_1]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_1}'
    variable = trapped_1
  []
  # For second traps
  [time_2]
    type = TimeDerivativeNodalKernel
    variable = trapped_2
  []
  [trapping_2]
    type = TrappingNodalKernel
    variable = trapped_2
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_2}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [release_2]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_2}'
    variable = trapped_2
  []
  # For third traps
  [time_3]
    type = TimeDerivativeNodalKernel
    variable = trapped_3
  []
  [trapping_3]
    type = TrappingNodalKernel
    variable = trapped_3
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_3}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [release_3]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_3}'
    variable = trapped_3
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
  end_time = ${simulation_time}
  dtmax = ${time_interval_max}
  solve_type = NEWTON
  scheme = ${scheme}
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = 'none'
[]
