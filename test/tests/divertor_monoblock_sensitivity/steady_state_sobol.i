[StochasticTools] # Designate as the Controller/Main Input
[]
[MultiApps] # Designate a subapp to control later
  [runner]
    type = SamplerFullSolveMultiApp
    sampler = sobol
    input_files = 'steady_state_runner.i'
    mode = batch-reset
    keep_full_output_history = True
  []
[]
[Controls] # Control inputs from Main->Subapp
  [cmdline]
    type = MultiAppSamplerControl
    multi_app = runner
    sampler = sobol
    param_names = """BCs/temp_top/value
                     BCs/C_mob_W_top_flux/value
                     BCs/temp_tube/value"""
  []
[]
[Distributions] # Define probability distributions of parameters for sampling
  [H_top]
    type = Uniform
    lower_bound =  9.5e6
    upper_bound = 10.5e6
  []
  [C_top]
    type = Uniform
    lower_bound = 7.505e-13
    upper_bound = 8.295e-13
  []
  [H_bot]
    type = Uniform
    lower_bound = 524.4
    upper_bound = 579.6
  []
[]
[Samplers] # Sampling methodology using the probability distributions above
  [hypercube_1]
    type = LatinHypercube
    distributions = 'H_top C_top H_bot'
    num_rows = 10 # N Samples
    seed = 1001
    execute_on = 'PRE_MULTIAPP_SETUP'
  []
  [hypercube_2]
    type = LatinHypercube
    distributions = 'H_top C_top H_bot'
    num_rows = 10 # N Samples
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
[Transfers] # Define values to extract from subapp
  [results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = sobol
    stochastic_reporter = results
    #execute_on = 'MULTIAPP_FIXED_POINT_END'
    from_reporter = """F_permeation/value
                       Scaled_Tritium_Flux/value
                       total_retention/value
                       coolant_heat_flux/value
                       max_temperature_W/value
                       max_temperature_Cu/value
                       max_temperature_CuCrZr/value"""
  []
  [matrix_results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = sobol
    stochastic_reporter = matrix
    from_reporter = """F_permeation/value
                       Scaled_Tritium_Flux/value
                       total_retention/value
                       coolant_heat_flux/value
                       max_temperature_W/value
                       max_temperature_Cu/value
                       max_temperature_CuCrZr/value"""
  []
[]
[Reporters]
  [results]
    type = StochasticReporter
    execute_on = 'FINAL' # INITIAL TIMESTEP_END MULTIAPP_FIXED_POINT_END
  []
  [stats]
    type = StatisticsReporter
    reporters = """results/results:F_permeation:value
                   results/results:Scaled_Tritium_Flux:value
                   results/results:total_retention:value
                   results/results:coolant_heat_flux:value
                   results/results:max_temperature_W:value
                   results/results:max_temperature_Cu:value
                   results/results:max_temperature_CuCrZr:value"""
    compute = 'mean stddev'
    ci_method = 'percentile'
    ci_levels = """0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50
                   0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95"""
    execute_on = 'FINAL'
  []
  [sobol]
    type = SobolReporter
    sampler = sobol
    reporters = """results/results:F_permeation:value
                   results/results:Scaled_Tritium_Flux:value
                   results/results:total_retention:value
                   results/results:coolant_heat_flux:value
                   results/results:max_temperature_W:value
                   results/results:max_temperature_Cu:value
                   results/results:max_temperature_CuCrZr:value"""
    ci_levels = """0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50
                   0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95"""
    execute_on = 'FINAL'
  []
  [matrix]
    type = StochasticMatrix
    sampler = sobol
    sampler_column_names = """BCs/temp_top/value
                              BCs/C_mob_W_top_flux/value
                              BCs/temp_tube/value"""
    execute_on = 'FINAL'
    parallel_type = ROOT
  []
[]
[Outputs]
  [out]
    type = JSON
    distributed = False
    execute_on = 'FINAL'
    execute_reporters_on = 'FINAL'
  []
[]
