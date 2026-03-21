# This include defines the stage-1 surface release model for val-2k.
# It applies D2 recombination flux conditions at both tungsten surfaces while
# the oxide is still represented only through effective surface behavior.

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
