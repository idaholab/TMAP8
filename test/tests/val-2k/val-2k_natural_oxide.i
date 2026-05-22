# Validation Problem val-2k
# Final natural-oxide wrapper for a validation case based on experimental data
# from Kremer et al. (2022):
# https://doi.org/10.1016/j.nme.2022.101137
# Unit system:
# - length: micrometers
# - time: seconds
# - concentration: atoms / micrometer^3
# - flux: atoms / micrometer^2 / second
# This wrapper sets the 1 nm front oxygen-field thickness used to represent the
# natural-oxide sample and includes the shared val-2k mesh, transport,
# trapping, and surface release model.

oxide_thickness = '${units 1 nm -> mum}'
output_file_base = 'val-2k_out'
profile_output_file_base = 'val-2k_profile_initial_out'

!include parameters_val-2k_common.params
!include val-2k_base.i
