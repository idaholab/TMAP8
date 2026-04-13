# Validation Problem val-2j — Bayesian sub-app
# Tritium TDS from neutron-irradiated Li2TiO3 solid breeder
# This file is a parameterized version of val-2j.i for Bayesian optimization.
# It runs the full TDS simulation and computes a score (log(1/RMSPE)) by
# comparing the normalized release rate against the experimental TDS curve.

# ============ Optimizable Parameters (log-space for prefactors) ============
log10_alpha_t = '${fparse log10(4.2e8)}'    # ~8.623
epsilon_t_eV = 1.04    # eV
log10_alpha_r = '${fparse log10(4.1e6)}'    # ~6.613
epsilon_r_eV = 1.19    # eV
log10_D0 = '${fparse log10(6.9e-7)}'        # ~-6.161
E_d_eV = 1.07    # eV
log10_alpha_anneal = '${fparse log10(1.0e2)}'  # ~2.0
E_anneal_eV = 0.9    # eV

# ============ Derived Physical Parameters ============
alpha_t = '${fparse pow(10, log10_alpha_t)}'
epsilon_t = '${fparse epsilon_t_eV * 1.602176634e-19 / 1.380649e-23}'
alpha_r = '${fparse pow(10, log10_alpha_r)}'
epsilon_r = '${fparse epsilon_r_eV * 1.602176634e-19 / 1.380649e-23}'
D0_m2s = '${fparse pow(10, log10_D0)}'
D0 = '${fparse D0_m2s * 1e12}'  # m^2/s -> um^2/s
E_d = '${fparse E_d_eV * 1.602176634e-19 / 1.380649e-23}'
alpha_anneal = '${fparse pow(10, log10_alpha_anneal)}'
E_anneal = '${fparse E_anneal_eV * 1.602176634e-19 / 1.380649e-23}'


!include val-2j_base.i

# ============ Experimental data as PiecewiseLinear function of time ============
# Normalized experimental TDS data from experiment_data_sample_e.csv.
# Temperature converted to time via t = (T - 300) * 12 (heating rate 5 K/min).
# Release rate normalized by experimental maximum (7.1227 arb).
# Low-temperature constraint points (300-475 K) included with small values
# to penalize parameter sets that produce spurious early release peaks.
[Functions]
  [exp_norm_function]
    type = PiecewiseLinear
    x = '0.0000 2330.5605 2503.7649 2681.8139 2783.8513 2873.7583 2963.5903 3056.9524 3146.4463 3215.1347 3314.7686 3406.0652 3501.0797 3592.6016 3687.4284 3780.6779 3862.4355 3952.3801 4050.1361 4145.1507 4236.3346 4321.2093 4409.9146 4503.0514 4595.4370 4668.2189 4773.7114 4864.4447 4948.0424 5040.5783 5140.0244 5226.8519 5311.3135 5403.2485 5488.1232 5582.9124 5668.5757 5764.7920 5852.7087 5945.7328 6036.0905 6129.7906 6226.3074 6314.0738 7200.0000'
    y = '0.010000 0.016492 0.018341 0.021065 0.026622 0.031582 0.035917 0.040738 0.051156 0.058324 0.076327 0.094220 0.123516 0.154373 0.189813 0.232907 0.281031 0.341362 0.406823 0.473070 0.549178 0.634819 0.731485 0.832545 0.927719 0.999215 1.000000 0.935145 0.809671 0.660656 0.504463 0.384834 0.285067 0.209048 0.141917 0.093753 0.065004 0.047100 0.034107 0.027546 0.021025 0.015568 0.011213 0.010388 0.010000'
  []
[]

# ============ RMSPE computation using continuous comparison ============
# Instead of sampling at 22 discrete temperatures, compare simulation vs experiment
# at every timestep. The RMSPE with sim_max normalization is computed via the
# algebraic identity:
#   RMSPE² = sum(sim²)/(N·sim_max²) - 2·sum(sim·exp)/(N·sim_max) + sum(exp²)/N
# where sim = abs(release_rate), exp = exp_norm(t), and N = number of timesteps.
[Postprocessors]
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
  [exp_norm_pp]
    type = FunctionValuePostprocessor
    function = exp_norm_function
    execute_on = 'initial timestep_end'
  []

  # --- Three accumulation terms for deferred-normalization RMSPE ---
  [sim_sq]
    type = ParsedPostprocessor
    pp_names = 'abs_release_rate'
    expression = 'abs_release_rate^2'
    execute_on = 'initial timestep_end'
  []
  [sim_times_exp]
    type = ParsedPostprocessor
    pp_names = 'abs_release_rate exp_norm_pp'
    expression = 'abs_release_rate * exp_norm_pp'
    execute_on = 'initial timestep_end'
  []
  [exp_sq]
    type = ParsedPostprocessor
    pp_names = 'exp_norm_pp'
    expression = 'exp_norm_pp^2'
    execute_on = 'initial timestep_end'
  []

  # --- Cumulative sums ---
  [sum_sim_sq]
    type = CumulativeValuePostprocessor
    postprocessor = sim_sq
    execute_on = 'initial timestep_end'
  []
  [sum_sim_times_exp]
    type = CumulativeValuePostprocessor
    postprocessor = sim_times_exp
    execute_on = 'initial timestep_end'
  []
  [sum_exp_sq]
    type = CumulativeValuePostprocessor
    postprocessor = exp_sq
    execute_on = 'initial timestep_end'
  []
  [one]
    type = ParsedPostprocessor
    pp_names = 'abs_release_rate'
    expression = '1'
    execute_on = 'initial timestep_end'
  []
  [timestep_count]
    type = CumulativeValuePostprocessor
    postprocessor = one
    execute_on = 'initial timestep_end'
  []

  # --- Final RMSPE and log-inverse score ---
  [pp_RMSPE]
    type = ParsedPostprocessor
    pp_names = 'sum_sim_sq sum_sim_times_exp sum_exp_sq sim_max timestep_count'
    expression = 'sqrt(sum_sim_sq / (timestep_count * (sim_max + 1e-30)^2) - 2 * sum_sim_times_exp / (timestep_count * (sim_max + 1e-30)) + sum_exp_sq / timestep_count)'
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
