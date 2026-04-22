# This input file defines one set of assumptions for the surface behavior in val-2k.
# It applies phenomenological D2 and D2O release flux conditions at both tungsten
# surfaces while the oxide is still represented only through effective surface behavior.

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
