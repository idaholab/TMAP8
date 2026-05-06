# Validation Problem val-2k
# Final 10 nm oxide wrapper for a validation case based on experimental data
# from Kremer et al. (2022):
# https://doi.org/10.1016/j.nme.2022.101137
# Unit system:
# - length: micrometers
# - time: seconds
# - concentration: atoms / micrometer^3
# - flux: atoms / micrometer^2 / second
# This wrapper sets the 10 nm front oxygen-field thickness and output names,
# then includes the shared val-2k mesh, transport, trapping, and surface
# release model.

oxide_thickness = '${units 10 nm -> mum}'
output_file_base = 'val-2k_10nm_oxide_out'
profile_output_file_base = 'profiles/val-2k_10nm_oxide_profile_initial_out'

!include parameters_val-2k_common.params
!include val-2k_base.i
