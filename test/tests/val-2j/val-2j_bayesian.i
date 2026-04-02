# Validation Problem val-2j — Bayesian sub-app
# Tritium TDS from neutron-irradiated Li2TiO3 solid breeder
# This file is a parameterized version of val-2j.i for Bayesian optimization.
# It runs the full TDS simulation and computes a score (log(1/RMSPE)) by
# comparing the normalized release rate at 22 temperatures against experiment.

# ============ Optimizable Parameters (log-space for prefactors) ============
log10_alpha_t = '${fparse log10(4.2e8)}'    # ~8.623
epsilon_t_eV = 1.04    # eV
log10_alpha_r = '${fparse log10(4.1e6)}'    # ~6.613
epsilon_r_eV = 1.19    # eV
log10_D0 = '${fparse log10(6.9e-7)}'        # ~-6.161
E_d_eV = 1.07    # eV

# ============ Derived Physical Parameters ============
alpha_t = '${fparse pow(10, log10_alpha_t)}'
epsilon_t = '${fparse epsilon_t_eV * 1.602176634e-19 / 1.380649e-23}'
alpha_r = '${fparse pow(10, log10_alpha_r)}'
epsilon_r = '${fparse epsilon_r_eV * 1.602176634e-19 / 1.380649e-23}'
D0_m2s = '${fparse pow(10, log10_D0)}'
D0 = '${fparse D0_m2s * 1e12}'  # m^2/s -> um^2/s
E_d = '${fparse E_d_eV * 1.602176634e-19 / 1.380649e-23}'

# ============ Physical Constants ============
kB_J = '${units 1.380649e-23 J/K}'

# ============ Fixed Defect Annihilation Parameters (Eqs. 16-18) ============
alpha_anneal = '${units 1.0e2 1/s}'
E_anneal = '${fparse ${units 0.9 eV -> J} / ${kB_J}}'

!include val-2j_base.i

# ============ Pre-computed Normalized Experimental Values ============
# The Bayesian optimization objective function compares the simulated TDS release
# rate (normalized by its maximum) against experimental data at discrete temperature
# points. These values are pre-computed from the experimental CSV data
# (experiment_data_sample_e.csv) by normalizing the measured release rate by its
# maximum value (7.123 arb. units).
#
# Temperatures 525-825 K (every 25 K) cover the main TDS signal region where
# the experimental release rate is significant.
# Temperatures 300-500 K serve as low-temperature constraint points: the measured
# release is negligible in this range, so a small target value (0.01) penalizes
# parameter sets that produce spurious early release peaks.

# From Kobayashi et al. (2015) Sample E, normalized by max release (7.123)
exp_norm_525 = 0.022055
exp_norm_550 = 0.037797
exp_norm_575 = 0.073658
exp_norm_600 = 0.157138
exp_norm_625 = 0.306228
exp_norm_650 = 0.518851
exp_norm_675 = 0.829234
exp_norm_700 = 0.981209
exp_norm_725 = 0.567327
exp_norm_750 = 0.211734
exp_norm_775 = 0.059157
exp_norm_800 = 0.023630
exp_norm_825 = 0.010521

# Low-temperature constraint points (300-500 K) to penalize spurious early peaks
exp_norm_300 = 0.01
exp_norm_325 = 0.01
exp_norm_350 = 0.01
exp_norm_375 = 0.01
exp_norm_400 = 0.01
exp_norm_425 = 0.01
exp_norm_450 = 0.01
exp_norm_475 = 0.01
exp_norm_500 = 0.01

[Postprocessors]
  # --- Maximum release rate over entire simulation ---
  [abs_release_rate]
    type = ParsedPostprocessor
    pp_names = 'release_rate'
    expression = 'abs(release_rate)'
    execute_on = 'initial timestep_end'
  []
  [sim_max]
    type = TimeExtremeValue
    postprocessor = abs_release_rate
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # --- Release rate sampling at 22 temperatures (300-825 K, every 25 K) ---
  # Each pair: release_near_T (nonzero only within 2 K window) + release_at_T (peak capture)
  # 300-500 K: low-temperature constraint points to penalize spurious early peaks

  # T = 300 K
  [release_near_300]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 300), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_300]
    type = TimeExtremeValue
    postprocessor = release_near_300
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 325 K
  [release_near_325]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 325), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_325]
    type = TimeExtremeValue
    postprocessor = release_near_325
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 350 K
  [release_near_350]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 350), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_350]
    type = TimeExtremeValue
    postprocessor = release_near_350
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 375 K
  [release_near_375]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 375), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_375]
    type = TimeExtremeValue
    postprocessor = release_near_375
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 400 K
  [release_near_400]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 400), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_400]
    type = TimeExtremeValue
    postprocessor = release_near_400
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 425 K
  [release_near_425]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 425), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_425]
    type = TimeExtremeValue
    postprocessor = release_near_425
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 450 K
  [release_near_450]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 450), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_450]
    type = TimeExtremeValue
    postprocessor = release_near_450
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 475 K
  [release_near_475]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 475), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_475]
    type = TimeExtremeValue
    postprocessor = release_near_475
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 500 K
  [release_near_500]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 500), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_500]
    type = TimeExtremeValue
    postprocessor = release_near_500
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 525 K
  [release_near_525]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 525), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_525]
    type = TimeExtremeValue
    postprocessor = release_near_525
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 550 K
  [release_near_550]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 550), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_550]
    type = TimeExtremeValue
    postprocessor = release_near_550
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 575 K
  [release_near_575]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 575), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_575]
    type = TimeExtremeValue
    postprocessor = release_near_575
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 600 K
  [release_near_600]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 600), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_600]
    type = TimeExtremeValue
    postprocessor = release_near_600
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 625 K
  [release_near_625]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 625), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_625]
    type = TimeExtremeValue
    postprocessor = release_near_625
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 650 K
  [release_near_650]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 650), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_650]
    type = TimeExtremeValue
    postprocessor = release_near_650
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 675 K
  [release_near_675]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 675), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_675]
    type = TimeExtremeValue
    postprocessor = release_near_675
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 700 K
  [release_near_700]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 700), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_700]
    type = TimeExtremeValue
    postprocessor = release_near_700
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 725 K
  [release_near_725]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 725), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_725]
    type = TimeExtremeValue
    postprocessor = release_near_725
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 750 K
  [release_near_750]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 750), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_750]
    type = TimeExtremeValue
    postprocessor = release_near_750
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 775 K
  [release_near_775]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 775), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_775]
    type = TimeExtremeValue
    postprocessor = release_near_775
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 800 K
  [release_near_800]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 800), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_800]
    type = TimeExtremeValue
    postprocessor = release_near_800
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # T = 825 K
  [release_near_825]
    type = ParsedPostprocessor
    pp_names = 'temperature_pp abs_release_rate'
    expression = 'if(2 - abs(temperature_pp - 825), abs_release_rate, 0)'
    execute_on = 'initial timestep_end'
  []
  [release_at_825]
    type = TimeExtremeValue
    postprocessor = release_near_825
    value_type = max
    execute_on = 'initial timestep_end'
  []

  # --- Scoring: RMSPE of normalized release vs experiment ---
  [sum_error_sq]
    type = ParsedPostprocessor
    pp_names = 'release_at_300 release_at_325 release_at_350 release_at_375 release_at_400 release_at_425 release_at_450 release_at_475 release_at_500 release_at_525 release_at_550 release_at_575 release_at_600 release_at_625 release_at_650 release_at_675 release_at_700 release_at_725 release_at_750 release_at_775 release_at_800 release_at_825 sim_max'
    expression = '(release_at_300/(sim_max + 1e-30) - ${exp_norm_300})^2
      + (release_at_325/(sim_max + 1e-30) - ${exp_norm_325})^2
      + (release_at_350/(sim_max + 1e-30) - ${exp_norm_350})^2
      + (release_at_375/(sim_max + 1e-30) - ${exp_norm_375})^2
      + (release_at_400/(sim_max + 1e-30) - ${exp_norm_400})^2
      + (release_at_425/(sim_max + 1e-30) - ${exp_norm_425})^2
      + (release_at_450/(sim_max + 1e-30) - ${exp_norm_450})^2
      + (release_at_475/(sim_max + 1e-30) - ${exp_norm_475})^2
      + (release_at_500/(sim_max + 1e-30) - ${exp_norm_500})^2
      + (release_at_525/(sim_max + 1e-30) - ${exp_norm_525})^2
      + (release_at_550/(sim_max + 1e-30) - ${exp_norm_550})^2
      + (release_at_575/(sim_max + 1e-30) - ${exp_norm_575})^2
      + (release_at_600/(sim_max + 1e-30) - ${exp_norm_600})^2
      + (release_at_625/(sim_max + 1e-30) - ${exp_norm_625})^2
      + (release_at_650/(sim_max + 1e-30) - ${exp_norm_650})^2
      + (release_at_675/(sim_max + 1e-30) - ${exp_norm_675})^2
      + (release_at_700/(sim_max + 1e-30) - ${exp_norm_700})^2
      + (release_at_725/(sim_max + 1e-30) - ${exp_norm_725})^2
      + (release_at_750/(sim_max + 1e-30) - ${exp_norm_750})^2
      + (release_at_775/(sim_max + 1e-30) - ${exp_norm_775})^2
      + (release_at_800/(sim_max + 1e-30) - ${exp_norm_800})^2
      + (release_at_825/(sim_max + 1e-30) - ${exp_norm_825})^2'
    execute_on = 'timestep_end'
  []
  [pp_RMSPE]
    type = ParsedPostprocessor
    pp_names = 'sum_error_sq'
    expression = 'sqrt(sum_error_sq / 22)'
    execute_on = 'timestep_end'
  []
  [pp_log_inverse_error]
    type = ParsedPostprocessor
    pp_names = 'pp_RMSPE'
    expression = 'log(1 / (pp_RMSPE + 1e-30))'
    execute_on = 'timestep_end'
  []
[]

[Executioner]
  error_on_dtmin = false
[]

[Controls]
  [stochastic]
    type = SamplerReceiver
  []
[]

[Outputs]
  # Suppress outputs for speed during optimization
[]
