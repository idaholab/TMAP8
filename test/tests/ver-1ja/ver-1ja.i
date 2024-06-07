# Verification Problem #1a from TMAP7 V&V document
# Radioactive Decay of Mobile Tritium in a Slab

# Case and model parameters (adapted from TMAP7)
tritium_concentration_initial = ${units 1.5e5 atoms/m3}
half_life = ${units 12.3232 years -> s}
decay_rate_constant = ${fparse 0.693/half_life_s} # 1/s

# Simulation parameters
end_time = ${units 100 years -> s}
dt_start = ${fparse end_time/250} # s

[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Variables]
  # tritium concentration in atoms/m^3
  [tritium_concentration]
    initial_condition = ${tritium_concentration_initial}
  []
  # helium concentration in atoms/m^3
  [helium_concentration]
  []
[]

[Kernels]
  # kernels for the tritium concentration equation
  [time_tritium]
    type = TimeDerivative
    variable = tritium_concentration
  []
  [decay_tritium]
    type = MatReaction
    variable = tritium_concentration
    v = tritium_concentration
    mob_name = '${fparse -decay_rate_constant}'
  []
  # kernels for the tritium concentration equation
  [time_helium]
    type = TimeDerivative
    variable = helium_concentration
  []
  [decay_helium]
    type = MatReaction
    variable = helium_concentration
    v = tritium_concentration
    mob_name = '${decay_rate_constant}'
  []
[]

[Postprocessors]
  # Average concentration of tritium in the sample in atoms/m^3
  [tritium_concentration]
    type = ElementAverageValue
    variable = tritium_concentration
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # Average concentration of helium in the sample in atoms/m^3
  [helium_concentration]
    type = ElementAverageValue
    variable = helium_concentration
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  dt = ${dt_start}
  end_time = ${end_time}
  solve_type = PJFNK
  scheme = 'bdf2'
  dtmin = 1
  l_max_its = 10
  nl_max_its = 5
  nl_rel_tol = 1e-07
  petsc_options = '-snes_converged_reason -ksp_monitor_true_residual'
  petsc_options_iname = '-pc_type -mat_mffd_err'
  petsc_options_value = 'lu       1e-5'
  line_search = 'bt'
[]

[Outputs]
  perf_graph = true
  csv = true
[]
