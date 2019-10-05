l=10

[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = ${l}
  nx = ${l}
[]

[Variables]
  [u][]
  [lm][]
[]

[ICs]
  [u]
    type = FunctionIC
    variable = u
    function = '${l} - x'
  []
[]

[NodalKernels]
  [time]
    type = TimeDerivativeNodalKernel
    variable = u
  []
  [ffn]
    type = UserForcingFunctionNodalKernel
    variable = u
    function = '-1'
  []
  [lm_coupled_force]
    type = CoupledForceNodalKernel
    variable = u
    v = lm
  []
  [positive_constraint]
    type = RequirePositiveNCPNodalKernel
    variable = lm
    v = u
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
  num_steps = ${l}
  solve_type = NEWTON
  petsc_options = '-pc_svd_monitor'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'svd'
[]

[Outputs]
  exodus = true
[]

[Debug]
  show_var_residual_norms = true
[]
