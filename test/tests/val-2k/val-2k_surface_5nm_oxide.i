# This input file defines the surface release assumptions for the explicit
# 5 nm oxide-layer case in val-2k. It applies D2 recombination flux conditions
# at the front oxide surface and the back tungsten surface.

[BCs]
  [left_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface
  []
  [right_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_mobile
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface
  []
[]
