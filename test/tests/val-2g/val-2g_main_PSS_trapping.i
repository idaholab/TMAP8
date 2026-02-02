!include distribution_parameters.params

[StochasticTools]
[]

[Distributions]
  [detrapping_energy_1_ev]  # 1.24
    type = Normal
    mean = ${detrapping_energy_1_ev_ave} #1.25 # eV
    standard_deviation = ${detrapping_energy_1_ev_std} # 0.01
  []
  [trapping_site_fraction_1_expo] # -2.56
    type = Normal
    mean = ${trapping_site_fraction_1_expo_ave} #-2.55 # m^4/at/s
    standard_deviation = ${trapping_site_fraction_1_expo_std} #0.01
  []
  [trapping_rate_prefactor_expo] # 8.92
    type = Normal
    mean = ${trapping_rate_prefactor_expo_ave} #11 # m^4/at/s # Real
    standard_deviation = ${trapping_rate_prefactor_expo_std} #0.7 # 0.42 # 0.4
  []
  [release_rate_profactor_expo] # 17.90
    type = Normal
    mean = ${release_rate_profactor_expo_ave} #14 # m^4/at/s # Real
    standard_deviation = ${release_rate_profactor_expo_std} #1.3 # 0.78 # 0.4
  []
  [trapping_energy_ev] # 0.467
    type = Normal
    mean = ${trapping_energy_ev_ave} #4.7e-01 # eV
    standard_deviation = ${trapping_energy_ev_std} #0.005
  []
  [electron_concentration_initial_expo] # -1.61
    type = Normal
    mean = ${electron_concentration_initial_expo_ave} #-1.6 # m^4/at/s
    standard_deviation = ${electron_concentration_initial_expo_std} #0.01
  []
  [T2O_reaction_forward_value_expo] # -30.40
    type = Normal
    mean = ${T2O_reaction_forward_value_expo_ave} #-30.5 # m^4/at/s
    standard_deviation = ${T2O_reaction_forward_value_expo_std} #0.05
  []
  [T2_reaction_forward_value_expo] # 44.03
    type = Normal
    mean = ${T2_reaction_forward_value_expo_ave} #-44 # m^4/at/s
    standard_deviation = ${T2_reaction_forward_value_expo_std} #0.05
  []
  [diffusivity_OT_prefactor_m2s] # 1.9e-9
    type = Normal
    mean = ${diffusivity_OT_prefactor_m2s_ave} #2.449e-9 # m^2/s # Real
    standard_deviation = ${diffusivity_OT_prefactor_m2s_std} #0.2e-9
  []
  [diffusivity_OT_energy_ev] # 0.1216
    type = Normal
    mean = ${diffusivity_OT_energy_ev_ave} #0.23 # eV # Real
    standard_deviation = ${diffusivity_OT_energy_ev_std} #0.04
  []
  [diffusivity_V_O_prefactor_m2s] # 1.24e-7
    type = Normal
    mean = ${diffusivity_V_O_prefactor_m2s_ave} #1.021e-7 # m^2/s # Real
    standard_deviation = ${diffusivity_V_O_prefactor_m2s_std} #0.1e-7
  []
  [diffusivity_V_O_energy] # 100342.57
    type = Normal
    mean = ${diffusivity_V_O_energy_ave} #89216.77 # J/mol # Real
    standard_deviation = ${diffusivity_V_O_energy_std} #4e3 # 2.5e3 # 1e4
  []
  [diffusivity_e_prefactor_m2s] # 2.063e-2
    type = Normal
    mean = ${diffusivity_e_prefactor_m2s_ave} #2.05e-02 #  # m^2/s # Real
    standard_deviation = ${diffusivity_e_prefactor_m2s_std} #0.01e-2
  []
  [diffusivity_e_energy] # 95347.10
    type = Normal
    mean = ${diffusivity_e_energy_ave} # 103818.22 #  # J/mol # Real
    standard_deviation = ${diffusivity_e_energy_std} #3e3
  []
  [delta_H_T2O] # -156376.37
    type = Normal
    mean = ${delta_H_T2O_ave} #-79500 #  # J/mol # Real
    standard_deviation = ${delta_H_T2O_std} #2.6e4 # 1.6e4 # 1e4
  []
  [delta_S_T2O] # -137.38
    type = Normal
    mean = ${delta_S_T2O_ave} #-88.90 #  # J/mol/K # Real
    standard_deviation = ${delta_S_T2O_std} #17 # 10 # 8
  []
  [delta_H_T2] # -112177.03
    type = Normal
    mean = ${delta_H_T2_ave} #-115000 #  # J/mol # Real
    standard_deviation = ${delta_H_T2_std} #1e3
  []
  [delta_S_T2] # -36.99
    type = Normal
    mean = ${delta_S_T2_ave} #-38.90 #  # J/mol/K # Real
    standard_deviation = ${delta_S_T2_std} #1
  []
[]

[Samplers]
  [sample]
    type = ParallelSubsetSimulation
    distributions = 'detrapping_energy_1_ev trapping_site_fraction_1_expo trapping_rate_prefactor_expo release_rate_profactor_expo trapping_energy_ev electron_concentration_initial_expo T2O_reaction_forward_value_expo T2_reaction_forward_value_expo diffusivity_OT_prefactor_m2s diffusivity_OT_energy_ev diffusivity_V_O_prefactor_m2s diffusivity_V_O_energy diffusivity_e_prefactor_m2s diffusivity_e_energy delta_H_T2O delta_S_T2O delta_H_T2 delta_S_T2'
    execute_on = PRE_MULTIAPP_SETUP
    subset_probability = 0.1
    num_samplessub = 10 # 20
    num_subsets = 1
    output_reporter = 'constant/reporter_transfer:log_inverse_error:value'
    inputs_reporter = 'PSS_reporter/inputs'
    seed = 1012
  []
[]

[MultiApps]
  [sub]
    type = SamplerFullSolveMultiApp
    input_files = 'val-2g_trapping_initial_parameters.i'
    sampler = sample
    ignore_solve_not_converge = true
  []
[]

[Transfers]
  [reporter_transfer]
    type = SamplerReporterTransfer
    from_reporter = 'log_inverse_error/value'
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
    param_names = 'detrapping_energy_1_ev trapping_site_fraction_1_expo trapping_rate_prefactor_expo release_rate_profactor_expo trapping_energy_ev electron_concentration_initial_expo T2O_reaction_forward_value_expo T2_reaction_forward_value_expo diffusivity_OT_prefactor_m2s diffusivity_OT_energy_ev diffusivity_V_O_prefactor_m2s diffusivity_V_O_energy diffusivity_e_prefactor_m2s diffusivity_e_energy delta_H_T2O delta_S_T2O delta_H_T2 delta_S_T2'
  []
[]

[Reporters]
  [constant]
    type = StochasticReporter
  []
  [PSS_reporter]
    type = AdaptiveMonteCarloDecision
    output_value = constant/reporter_transfer:log_inverse_error:value
    inputs = 'inputs'
    sampler = sample
  []
[]

[Executioner]
  type = Transient
[]

[Outputs]
  file_base = 'val-2g_PSS/both_cases_trapping'
  [out]
    type = JSON
    execute_system_information_on = NONE
  []
[]
