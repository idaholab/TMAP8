# This input file defines the surface release assumptions for the explicit
# 5 nm oxide-layer case in val-2k. It applies phenomenological D2 and D2O
# release flux conditions at the front oxide surface and the back tungsten surface.

[BCs]
  [left_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface
  []
  [left_d2o_release_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface_d2o
  []
  [right_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface
  []
  [right_d2o_release_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface_d2o
  []
[]
