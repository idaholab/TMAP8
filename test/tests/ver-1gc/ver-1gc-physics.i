concentration_A_0 = '${units 2.415e14 at/m^3 -> at/mum^3}' # atoms/microns^3 initial concentration of species A
k_1 = 0.0125 # 1/s reaction rate for first reaction
k_2 = 0.0025 # 1/s reaction rate for second reaction
end_time = 1500 # s

[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Physics]
  [SpeciesDiffusionReaction]
    [all]
      species = 'c_A c_B c_C'
      initial_conditions_species = '${concentration_A_0} 0 0'
      diffusivity_matprops = '0 0 0'

      # Be careful to only enter the reaction once
      reacting_species      = 'c_A; c_B'
      product_species       = 'c_B; c_C'
      reaction_coefficients = 'K1 K2'
    []
  []
[]

# mK1, mK2 are used to flip the signs for the coefficient of reaction (production vs destruction)
[Materials]
  [K1]
    type = ADGenericConstantMaterial
    prop_names = 'K1 mK1'
    prop_values = '${k_1} -${k_1}'
  []
  [K2]
    type = ADGenericConstantMaterial
    prop_names = 'K2 mK2'
    prop_values = '${k_2} -${k_2}'
  []
[]

[Postprocessors]
  [concentration_A]
    type = ElementAverageValue
    variable = c_A
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [concentration_B]
    type = ElementAverageValue
    variable = c_B
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [concentration_C]
    type = ElementAverageValue
    variable = c_C
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  nl_rel_tol = 1e-11
  nl_abs_tol = 1e-50
  l_tol = 1e-10
  solve_type = 'NEWTON'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  end_time = ${end_time}
  dtmax = 50
  # Ensures the time steps taken are the same
  [TimeStepper]
    type = ExodusTimeSequenceStepper
    mesh = 'gold/ver-1gc_out.e'
  []
[]

[Outputs]
  exodus = true
  csv = true
[]
