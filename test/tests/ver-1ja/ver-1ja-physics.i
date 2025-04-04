# Verification Problem #1ja from TMAP7 V&V document
# Radioactive Decay of Mobile Tritium in a Slab

# Case and model parameters (adapted from TMAP7)
tritium_concentration_initial = ${units 1.5e5 atoms/m3}
half_life = ${units 12.3232 year -> s}
decay_rate_constant = ${fparse 0.693/half_life} # 1/s

# Simulation parameters
end_time = ${units 100 year -> s}
dt_start = ${fparse end_time/250} # s

[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Physics]
  [SpeciesDiffusionReaction]
    [all]
      species                    = 'tritium_concentration helium_concentration'
      initial_conditions_species = '${tritium_concentration_initial} 0'

      reacting_species      = 'tritium_concentration'
      product_species       = 'helium_concentration'
      reaction_coefficients = '${decay_rate_constant}'
    []
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
  petsc_options = '-snes_converged_reason'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  perf_graph = true
  csv = true
[]
