# val-2l: BCY20 hydrogen permeation under applied voltage.
# Unit system: length is converted to nm for the spatial solve, time is s,
# temperature is K, pressure is Pa, concentrations are atoms/nm^3,
# and fluxes reported by the membrane model are atoms/nm^2/s.

# Level 2: voltage aggregator for the val-2l no-Joule membrane model.
# Level 2: Voltage aggregator for the val-2l real (H2+H2O) LEE2005 case
# Uses the optimized parameter set for the val-2l voltage validation.
# Runs Level 3 sub-apps at 10 voltage points (5@500C + 5@700C),
# collects recombination_flux_OT_dry_right from each,
# computes combined RMSPE.

# --- 14 optimized parameters used by the val-2l validation runs ---
delta_H_T2O = -1.54415211e+05
delta_S_T2O = -1.67187585e+02
delta_H_T2 = -5.46037663e+04
delta_S_T2 = -3.36929406e+01
T2O_reaction_forward_energy = -7.31595474e+03
T2O_reaction_forward_mol_exponent = -1.19792592e+01
T2_reaction_forward_energy = 5.13385478e+03
T2_reaction_forward_mol_exponent = -4.05998297e+00
diffusivity_OT_energy = 8.65880079e+03
diffusivity_OT_prefactor_exponent = -1.26000119e+01
diffusivity_V_O_energy = 5.87658926e+04
diffusivity_V_O_prefactor_exponent = -5.33084375e+00
electron_concentration_initial_expo = 4.94096686e-01
electron_concentration_initial_energy = 5.90846106e+04

# Experimental target flux values for recombination_flux_OT_dry_right
# NOTE: These must be in the same units as the simulation output.

# Physics parameters
molar_volume = '${units 2.24e4 cm^3/mol}'
N_A = '${units 6.022e23 at/mol}' # H2/mol

# 500C target data (rows 1,3,5,7,9 from Lee2005_500C gold files)
target_voltage_V0 = '${units 0.2528561064472667 V}'
target_voltage_V1 = '${units 0.88369488093245 V}'
target_voltage_V2 = '${units 1.3639034384890738 V}'
target_voltage_V3 = '${units 1.6671250787272887 V}'
target_voltage_V4 = '${units 1.963346966109397 V}'

target_flux_V0 = '${units ${fparse 0.6218274111675122 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}' # cm^3/min/cm^2 -> atoms/m^2/s
target_flux_V1 = '${units ${fparse 2.5568307216949897 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}' # cm^3/min/cm^2 -> atoms/m^2/s
target_flux_V2 = '${units ${fparse 6.716508497020525 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}' # cm^3/min/cm^2 -> atoms/m^2/s
target_flux_V3 = '${units ${fparse 9.532621428450163 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}' # cm^3/min/cm^2 -> atoms/m^2/s
target_flux_V4 = '${units ${fparse 13.414087567696043 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}' # cm^3/min/cm^2 -> atoms/m^2/s

# 700C target data (rows 1,3,5,7,9 from Lee2005_700C gold files)
target_voltage_V5 = '${units 0.03332748850295297 V}'
target_voltage_V6 = '${units 0.20215275729873194 V}'
target_voltage_V7 = '${units 0.4807120597447935 V}'
target_voltage_V8 = '${units 0.7303394518080452 V}'
target_voltage_V9 = '${units 1.0092335036304367 V}'

target_flux_V5 = '${units ${fparse 0.8159052568221696 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}'
target_flux_V6 = '${units ${fparse 3.1612566865319893 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}'
target_flux_V7 = '${units ${fparse 6.284704266664406 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}'
target_flux_V8 = '${units ${fparse 10.201125795813871 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}'
target_flux_V9 = '${units ${fparse 15.544671543984876 / molar_volume * N_A * 2 / 60 * 1e4} at/m^2/s}'

mean_target_flux = '${fparse (target_flux_V0 + target_flux_V1 + target_flux_V2 + target_flux_V3 + target_flux_V4 + target_flux_V5 + target_flux_V6 + target_flux_V7 + target_flux_V8 + target_flux_V9) / 10}'

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 1
  []
[]

[Problem]
  solve = false
  kernel_coverage_check = false
[]

[Executioner]
  type = Steady
[]

[MultiApps]
  [sub]
    type = FullSolveMultiApp
    input_files = 'val-2l_membrane.i'
    positions = '0 0 0  0 0 0  0 0 0  0 0 0  0 0 0  0 0 0  0 0 0  0 0 0  0 0 0  0 0 0'
    cli_args = 'V_current=${target_voltage_V0};target_flux=${target_flux_V0};delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V1};target_flux=${target_flux_V1};delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V2};target_flux=${target_flux_V2};delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V3};target_flux=${target_flux_V3};delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V4};target_flux=${target_flux_V4};delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V5};target_flux=${target_flux_V5};temperature_initial=973;delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V6};target_flux=${target_flux_V6};temperature_initial=973;delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V7};target_flux=${target_flux_V7};temperature_initial=973;delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V8};target_flux=${target_flux_V8};temperature_initial=973;delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false
               V_current=${target_voltage_V9};target_flux=${target_flux_V9};temperature_initial=973;delta_H_T2O=${delta_H_T2O};delta_S_T2O=${delta_S_T2O};delta_H_T2=${delta_H_T2};delta_S_T2=${delta_S_T2};T2O_reaction_forward_mol_exponent=${T2O_reaction_forward_mol_exponent};T2O_reaction_forward_energy=${T2O_reaction_forward_energy};T2_reaction_forward_mol_exponent=${T2_reaction_forward_mol_exponent};T2_reaction_forward_energy=${T2_reaction_forward_energy};diffusivity_OT_prefactor_exponent=${diffusivity_OT_prefactor_exponent};diffusivity_OT_energy=${diffusivity_OT_energy};diffusivity_V_O_prefactor_exponent=${diffusivity_V_O_prefactor_exponent};diffusivity_V_O_energy=${diffusivity_V_O_energy};electron_concentration_initial_expo=${electron_concentration_initial_expo};electron_concentration_initial_energy=${electron_concentration_initial_energy};Outputs/csv/enable=false'
    execute_on = 'INITIAL'
    max_procs_per_app = 1
    ignore_solve_not_converge = true
  []
[]

[Transfers]
  [get_error_sum]
    type = MultiAppPostprocessorTransfer
    from_multi_app = sub
    from_postprocessor = relative_error_sq
    to_postprocessor = combined_relative_error_sq
    reduction_type = sum
  []
[]

[Postprocessors]
  [combined_relative_error_sq]
    type = Receiver
  []
  [pp_RMSPE]
    type = ParsedPostprocessor
    pp_names = 'combined_relative_error_sq'
    expression = 'sqrt(combined_relative_error_sq / 10) / ${mean_target_flux}'
    execute_on = 'TIMESTEP_END'
  []
  [pp_log_inverse_error]
    type = ParsedPostprocessor
    pp_names = 'pp_RMSPE'
    expression = 'if(pp_RMSPE > 0, log(1 / pp_RMSPE), -5)'
    execute_on = 'TIMESTEP_END'
  []
[]

[Controls]
  [stochastic]
    type = SamplerReceiver
  []
[]

[Outputs]
  console = true
  csv = true
[]
