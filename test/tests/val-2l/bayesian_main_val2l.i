# val-2l: BCY20 hydrogen permeation under applied voltage.
# Unit system: length is converted to nm for the spatial solve, time is s,
# temperature is K, pressure is Pa, concentrations are atoms/nm^3,
# and fluxes reported by the membrane model are atoms/nm^2/s.

# Phase 7 - 14-parameter joint Bayesian optimization (500 C + 700 C).
# RMSPE uses global normalization: sqrt(sum_sq / 10) / mean_target_flux.
# Warm-started from Phase 2 R4 optimal (5 params) + Phase 1 optimal (2 params)
# + Phase 1/2 defaults (6 fixed params) + 0 for new electron_concentration_initial_energy.
# Both 500 C and 700 C simultaneously (10 voltage points).
# 5-core run (num_parallel_proposals=5, mpiexec -n 5), 40 steps per autorun round.
# max_procs_per_app=1 enables 5-way parallel execution with mpiexec -n 5.
# Target: RMSPE < 0.20 (score > log(5) approximately 1.609).

[StochasticTools]
[]

# Uniform distributions for 14 parameters (warm-start +/- physically motivated bounds)
[Distributions]
  [delta_H_T2O_dist]
    type = Uniform
    lower_bound = -165000
    upper_bound = -115000
  []
  [delta_S_T2O_dist]
    type = Uniform
    lower_bound = -168
    upper_bound = -100
  []
  [delta_H_T2_dist]
    type = Uniform
    lower_bound = -115000
    upper_bound = -50000
  []
  [delta_S_T2_dist]
    type = Uniform
    lower_bound = -38
    upper_bound = -30
  []
  [T2O_reaction_forward_energy_dist]
    type = Uniform
    lower_bound = -10000
    upper_bound = 15000
  []
  [T2O_reaction_forward_mol_exponent_dist]
    type = Uniform
    lower_bound = -13
    upper_bound = -6.5
  []
  [T2_reaction_forward_energy_dist]
    type = Uniform
    lower_bound = 5000
    upper_bound = 12000
  []
  [T2_reaction_forward_mol_exponent_dist]
    type = Uniform
    lower_bound = -4.5
    upper_bound = -2
  []
  [diffusivity_OT_energy_dist]
    type = Uniform
    lower_bound = -5000
    upper_bound = 70000
  []
  [diffusivity_OT_prefactor_exponent_dist]
    type = Uniform
    lower_bound = -14
    upper_bound = -5
  []
  [diffusivity_V_O_energy_dist]
    type = Uniform
    lower_bound = 50000
    upper_bound = 120000
  []
  [diffusivity_V_O_prefactor_exponent_dist]
    type = Uniform
    lower_bound = -6.5
    upper_bound = 0.6
  []
  [electron_concentration_initial_expo_dist]
    type = Uniform
    lower_bound = -4.5
    upper_bound = 0.5
  []
  [electron_concentration_initial_energy_dist]
    type = Uniform
    lower_bound = -20000
    upper_bound = 65000
  []
[]

# Acquisition function: Expected Improvement for optimization
[ParallelAcquisition]
  [expectedimprovement]
    type = ExpectedImprovement
    tuning = 1.0
  []
[]

[Samplers]
  [sample]
    type = GenericActiveLearningSampler
    distributions = 'delta_H_T2O_dist
                    delta_S_T2O_dist
                    delta_H_T2_dist
                    delta_S_T2_dist
                    T2O_reaction_forward_energy_dist
                    T2O_reaction_forward_mol_exponent_dist
                    T2_reaction_forward_energy_dist
                    T2_reaction_forward_mol_exponent_dist
                    diffusivity_OT_energy_dist
                    diffusivity_OT_prefactor_exponent_dist
                    diffusivity_V_O_energy_dist
                    diffusivity_V_O_prefactor_exponent_dist
                    electron_concentration_initial_expo_dist
                    electron_concentration_initial_energy_dist'
    sorted_indices = 'conditional/sorted_indices'
    num_parallel_proposals = 5 # must be >= MPI ranks to avoid GenericActiveLearner MPI deadlock
    num_tries = 50000
    seed = 2403
    # initial_values = '-163837 -156.4 -59289 -36.4 10620 -10.5945 14331 -3.56 9569.299999999999 -12.4266 76832.3 -2.3516 -2.5919 0'
    initial_values = '-162200.0 -166.7 -112177.032 -36.9926058 10000.0 -7 10000.0 -4 68480.23 -6 52083.55 -6 -4.1 0'
    max_procs_per_row = 1
    execute_on = PRE_MULTIAPP_SETUP
  []
[]

[MultiApps]
  [sub]
    type = SamplerFullSolveMultiApp
    input_files = 'val-2l.i'
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
    param_names = 'delta_H_T2O
                    delta_S_T2O
                    delta_H_T2
                    delta_S_T2
                    T2O_reaction_forward_energy
                    T2O_reaction_forward_mol_exponent
                    T2_reaction_forward_energy
                    T2_reaction_forward_mol_exponent
                    diffusivity_OT_energy
                    diffusivity_OT_prefactor_exponent
                    diffusivity_V_O_energy
                    diffusivity_V_O_prefactor_exponent
                    electron_concentration_initial_expo
                    electron_concentration_initial_energy'
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
    learning_rate = 0.025
    show_every_nth_iteration = 10
    batch_size = 100
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
    signal_variance = 1.0
    noise_variance = 1e-2 # 4.0
    length_factor = '10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 10.0 0.1 1.0 10.0 10.0 10.0' # '0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5'
  []
[]

[Executioner]
  type = Transient
  num_steps = 20
[]

[Outputs]
  file_base = 'bayesian_val2l_results/val-2l_bayesian_out'
  [out]
    type = JSON
    execute_system_information_on = NONE
  []
[]
