### This input file defines a sobol indice analysis of the monoblock input file to simulate a
### shutdown transient, with some simplifying assumptions that allow it
### to be run in a short amount of time.
### The physics input file is elm_transient_runner.i
### This file should be called directly by TMAP8, preferably with access to multiple cpus
### Output information including summary statistics can be found in a json file

# Define parameters in one spot for easier reading
peak_flux_value = ${units 20 MW/m^2 -> W/m^2}
peak_flux_std_deviation = ${units 1 MW/m^2 -> W/m^2}
peak_flux_duration_value = ${units 1 s}
peak_flux_duration_std_deviation = ${units 0.05 s}
coolant_temperature_value = ${units 552 K}
coolant_temperature_std_deviation = ${units 27.6 K}
tungsten_kth_prefactor_lower = 0.9
tungsten_kth_prefactor_upper = 1.0
N_samples = 10

[StochasticTools]
  # Designate as the Controller/Main Input
[]

[MultiApps]
  # Designate a subapp to control later
  [runner]
    type = SamplerFullSolveMultiApp
    sampler = sobol
    input_files = 'shutdown_transient_runner.i'
    mode = batch-reset
    keep_full_output_history = True
    ignore_solve_not_converge = True
  []
[]

[Controls]
  # Control inputs from Main->Subapp
  [cmdline]
    type = MultiAppSamplerControl
    multi_app = runner
    sampler = sobol
    param_names = "peak_value
                     peak_duration
                     coolant_temperature
                     W_cond_factor"
  []
[]

[Distributions]
  # Define probability distributions of parameters for sampling
  [P_val]
    type = Normal
    mean = ${peak_flux_value}
    standard_deviation = ${peak_flux_std_deviation}
  []
  [P_dur]
    type = Normal
    mean = ${peak_flux_duration_value}
    standard_deviation = ${peak_flux_duration_std_deviation}
  []
  [C_temperature]
    type = Normal
    mean = ${coolant_temperature_value}
    standard_deviation = ${coolant_temperature_std_deviation}
  []
  [W_cond]
    type = Uniform
    lower_bound = ${tungsten_kth_prefactor_lower}
    upper_bound = ${tungsten_kth_prefactor_upper}
  []
[]

[Samplers]
  # Sampling methodology using the probability distributions above
  [hypercube_1]
    type = LatinHypercube
    distributions = 'P_val P_dur C_temperature W_cond'
    num_rows = ${N_samples}
    seed = 1001
    execute_on = 'PRE_MULTIAPP_SETUP'
  []
  [hypercube_2]
    type = LatinHypercube
    distributions = 'P_val P_dur C_temperature W_cond'
    num_rows = ${N_samples}
    seed = 1002
    execute_on = 'PRE_MULTIAPP_SETUP'
  []
  [sobol]
    type = Sobol
    sampler_a = hypercube_1
    sampler_b = hypercube_2
    execute_on = 'PRE_MULTIAPP_SETUP'
  []
[]

[Transfers]
  # Define values to extract from subapp
  [results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = sobol
    stochastic_reporter = results
    #execute_on = 'MULTIAPP_FIXED_POINT_END'
    from_reporter = "F_permeation/value
                       Scaled_Tritium_Flux/value
                       total_retention/value
                       coolant_heat_flux/value
                       max_temperature_W/value
                       max_temperature_Cu/value
                       max_temperature_CuCrZr/value
                       time_max_T_W/value
                       time_max_T_Cu/value
                       time_max_T_CuCrZr/value"
  []
  [matrix_results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = sobol
    stochastic_reporter = matrix
    from_reporter = "F_permeation/value
                       Scaled_Tritium_Flux/value
                       total_retention/value
                       coolant_heat_flux/value
                       max_temperature_W/value
                       max_temperature_Cu/value
                       max_temperature_CuCrZr/value
                       time_max_T_W/value
                       time_max_T_Cu/value
                       time_max_T_CuCrZr/value"
  []
[]

[Reporters]
  [results]
    type = StochasticReporter
    execute_on = 'FINAL' # INITIAL TIMESTEP_END MULTIAPP_FIXED_POINT_END
  []
  [stats]
    type = StatisticsReporter
    reporters = "results/results:F_permeation:value
                   results/results:Scaled_Tritium_Flux:value
                   results/results:total_retention:value
                   results/results:coolant_heat_flux:value
                   results/results:max_temperature_W:value
                   results/results:max_temperature_Cu:value
                   results/results:max_temperature_CuCrZr:value
                   results/results:time_max_T_W:value
                   results/results:time_max_T_Cu:value
                   results/results:time_max_T_CuCrZr:value"
    compute = 'mean stddev'
    ci_method = 'percentile'
    ci_levels = "0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50
                   0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95"
    execute_on = 'FINAL'
  []
  [sobol]
    type = SobolReporter
    sampler = sobol
    reporters = "results/results:F_permeation:value
                   results/results:Scaled_Tritium_Flux:value
                   results/results:total_retention:value
                   results/results:coolant_heat_flux:value
                   results/results:max_temperature_W:value
                   results/results:max_temperature_Cu:value
                   results/results:max_temperature_CuCrZr:value
                   results/results:time_max_T_W:value
                   results/results:time_max_T_Cu:value
                   results/results:time_max_T_CuCrZr:value"
    ci_levels = "0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50
                   0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95"
    execute_on = 'FINAL'
  []
  [matrix]
    type = StochasticMatrix
    sampler = sobol
    sampler_column_names = "peak_value
                              peak_duration
                              coolant_temperature
                              W_cond_factor"
    execute_on = 'FINAL'
    parallel_type = ROOT
  []
[]

[Outputs]
  [out]
    type = JSON
    distributed = True
    execute_on = 'FINAL'
    execute_reporters_on = 'FINAL'
  []
[]
