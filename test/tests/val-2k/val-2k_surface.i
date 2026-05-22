# Validation Problem val-2k
# Shared surface release model for a validation case based on experimental data
# from Kremer et al. (2022):
# https://doi.org/10.1016/j.nme.2022.101137
# Unit system:
# - length: micrometers
# - time: seconds
# - concentration: atoms / micrometer^3
# - flux: atoms / micrometer^2 / second
# This file applies phenomenological D2 release on both free surfaces and ties
# the front-surface D2O release channel to the evolving oxygen field.

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
