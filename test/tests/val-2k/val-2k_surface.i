# This input file defines the surface release assumptions for the oxygen-field
# val-2k cases. It applies phenomenological D2 release on both
# free surfaces and ties the D2O release channel to the evolving oxygen field.

[BCs]
  [left_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface_d2
  []
  [left_d2o_release_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface_d2o
  []
  [left_oxygen_release_flux]
    type = ADMatNeumannBC
    variable = oxygen
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface_oxygen
  []
  [right_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface_d2
  []
  [right_d2o_release_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface_d2o
  []
  [right_oxygen_release_flux]
    type = ADMatNeumannBC
    variable = oxygen
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface_oxygen
  []
[]
