# Validation Problem #val-2k
# Validation case for deuterium release from self-irradiated tungsten with
# natural and artificial oxide layers based on:
# Kremer, K., Brucker, M., Jacob, W., Schwarz-Selinger, T. (2022)
# "Influence of thin surface oxide films on hydrogen isotope release from ion-irradiated tungsten"
#
# This companion stage adds a 10 nm oxygen-field oxide comparison alongside the
# thinner natural-oxide oxygen-field baseline.
# Included physics:
# - dimensionless deuterium diffusion with the same tungsten transport properties everywhere
# - dimensionless oxygen diffusion using the reported oxygen inventory and O-in-W transport kinetics
# - six scaled val-2f trap families introduced through SpeciesTrapping physics blocks and suppressed smoothly inside the oxide region with a sharp tanh profile
# - phenomenological D2 release on both surfaces and oxygen-gated D2O release on the front oxide surface
# Deferred to later stages:
# - explicit hydrogen-containing species
# - water formation
# - oxide reduction

oxide_thickness = '${units 10 nm -> mum}'
output_file_base = 'val-2k_10nm_oxide_out'
profile_output_file_base = 'val-2k_10nm_oxide_profile_initial_out'

!include parameters_val-2k_common.params
!include val-2k_base.i
