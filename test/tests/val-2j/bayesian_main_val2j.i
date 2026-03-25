# Level 1: Bayesian optimization of 6 TDS parameters for val-2j
# Optimizes trapping/detrapping/diffusion parameters to minimize RMSPE
# between simulated and experimental TDS curves from Kobayashi et al. (2015).
# Uses Gaussian Process active learning with Expected Improvement acquisition.

[StochasticTools]
[]

[Distributions]
  [log10_alpha_t_dist]
    type = Uniform
    lower_bound = 7.0
    upper_bound = 10.0
  []
  [epsilon_t_eV_dist]
    type = Uniform
    lower_bound = 0.8
    upper_bound = 1.3
  []
  [log10_alpha_r_dist]
    type = Uniform
    lower_bound = 5.0
    upper_bound = 8.0
  []
  [epsilon_r_eV_dist]
    type = Uniform
    lower_bound = 0.9
    upper_bound = 1.5
  []
  [log10_D0_dist]
    type = Uniform
    lower_bound = -8.0
    upper_bound = -4.0
  []
  [E_d_eV_dist]
    type = Uniform
    lower_bound = 0.8
    upper_bound = 1.4
  []
[]

[ParallelAcquisition]
  [expectedimprovement]
    type = ExpectedImprovement
  []
[]

[Samplers]
  [sample]
    type = GenericActiveLearningSampler
    distributions = 'log10_alpha_t_dist epsilon_t_eV_dist log10_alpha_r_dist epsilon_r_eV_dist log10_D0_dist E_d_eV_dist'
    sorted_indices = 'conditional/sorted_indices'
    num_parallel_proposals = 5
    num_tries = 5000
    seed = 2401
    initial_values = '8.623 1.04 6.613 1.19 -6.161 1.07'
    max_procs_per_row = 1
    execute_on = PRE_MULTIAPP_SETUP
  []
[]

[MultiApps]
  [sub]
    type = SamplerFullSolveMultiApp
    input_files = 'val-2j_bayesian.i'
    sampler = sample
    mode = batch-reset
    max_procs_per_app = 1
    ignore_solve_not_converge = true
  []
[]

[Transfers]
  [reporter_transfer]
    type = SamplerReporterTransfer
    from_reporter = 'pp_log_inverse_error/value'
    stochastic_reporter = 'constant'
    from_multi_app = sub
    sampler = sample
  []
[]

[Controls]
  [cmdline]
    type = MultiAppSamplerControl
    multi_app = sub
    sampler = sample
    param_names = 'log10_alpha_t epsilon_t_eV log10_alpha_r epsilon_r_eV log10_D0 E_d_eV'
  []
[]

[Reporters]
  [constant]
    type = StochasticReporter
  []
  [conditional]
    type = GenericActiveLearner
    output_value = constant/reporter_transfer:pp_log_inverse_error:value
    sampler = sample
    al_gp = GP_al_trainer
    gp_evaluator = GP_eval
    acquisition = 'expectedimprovement'
    penalize_acquisition = true
  []
[]

[Trainers]
  [GP_al_trainer]
    type = ActiveLearningGaussianProcess
    covariance_function = 'covar'
    standardize_params = 'true'
    standardize_data = 'true'
    tune_parameters = 'covar:signal_variance covar:length_factor'
    num_iters = 1000
    learning_rate = 0.01
    show_every_nth_iteration = 0
  []
[]

[Surrogates]
  [GP_eval]
    type = GaussianProcessSurrogate
    trainer = GP_al_trainer
  []
[]

[Covariance]
  [covar]
    type = SquaredExponentialCovariance
    signal_variance = 4.0
    noise_variance = 1.0
    length_factor = '1.0 1.0 1.0 1.0 1.0 1.0'
  []
[]

[Executioner]
  type = Transient
  num_steps = 40
[]

[Outputs]
  file_base = 'bayesian_val2j_results/val2j_bayesian_6p'
  [out]
    type = JSON
    execute_system_information_on = NONE
  []
[]
