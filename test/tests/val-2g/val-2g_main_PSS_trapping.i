!include parameters_trapping_initial_distribution_PSS.params

[StochasticTools]
[]

[Distributions]
  [detrapping_energy_1_ev]
    type = Normal
    mean = ${detrapping_energy_1_ev_ave} # eV
    standard_deviation = ${detrapping_energy_1_ev_std}
  []
  [trapping_site_fraction_1_expo]
    type = Normal
    mean = ${trapping_site_fraction_1_expo_ave} # m^4/at/s
    standard_deviation = ${trapping_site_fraction_1_expo_std}
  []
  [trapping_rate_prefactor_expo]
    type = Normal
    mean = ${trapping_rate_prefactor_expo_ave} # m^4/at/s
    standard_deviation = ${trapping_rate_prefactor_expo_std}
  []
  [release_rate_profactor_expo]
    type = Normal
    mean = ${release_rate_profactor_expo_ave} # m^4/at/s
    standard_deviation = ${release_rate_profactor_expo_std}
  []
  [trapping_energy_ev]
    type = Normal
    mean = ${trapping_energy_ev_ave} # eV
    standard_deviation = ${trapping_energy_ev_std}
  []
  [electron_concentration_initial_expo]
    type = Normal
    mean = ${electron_concentration_initial_expo_ave} # m^4/at/s
    standard_deviation = ${electron_concentration_initial_expo_std}
  []
  [T2O_reaction_forward_value_expo]
    type = Normal
    mean = ${T2O_reaction_forward_value_expo_ave} # m^4/at/s
    standard_deviation = ${T2O_reaction_forward_value_expo_std}
  []
  [T2_reaction_forward_value_expo]
    type = Normal
    mean = ${T2_reaction_forward_value_expo_ave} # m^4/at/s
    standard_deviation = ${T2_reaction_forward_value_expo_std}
  []
  [diffusivity_OT_prefactor_m2s]
    type = Normal
    mean = ${diffusivity_OT_prefactor_m2s_ave} # m^2/s
    standard_deviation = ${diffusivity_OT_prefactor_m2s_std}
  []
  [diffusivity_OT_energy_ev]
    type = Normal
    mean = ${diffusivity_OT_energy_ev_ave} # eV
    standard_deviation = ${diffusivity_OT_energy_ev_std}
  []
  [diffusivity_V_O_prefactor_m2s]
    type = Normal
    mean = ${diffusivity_V_O_prefactor_m2s_ave} # m^2/s
    standard_deviation = ${diffusivity_V_O_prefactor_m2s_std}
  []
  [diffusivity_V_O_energy]
    type = Normal
    mean = ${diffusivity_V_O_energy_ave} # J/mol
    standard_deviation = ${diffusivity_V_O_energy_std}
  []
  [diffusivity_e_prefactor_m2s]
    type = Normal
    mean = ${diffusivity_e_prefactor_m2s_ave} # m^2/s
    standard_deviation = ${diffusivity_e_prefactor_m2s_std}
  []
  [diffusivity_e_energy]
    type = Normal
    mean = ${diffusivity_e_energy_ave} # J/mol
    standard_deviation = ${diffusivity_e_energy_std}
  []
  [delta_H_T2O]
    type = Normal
    mean = ${delta_H_T2O_ave} # J/mol
    standard_deviation = ${delta_H_T2O_std}
  []
  [delta_S_T2O]
    type = Normal
    mean = ${delta_S_T2O_ave} # J/mol/K
    standard_deviation = ${delta_S_T2O_std}
  []
  [delta_H_T2]
    type = Normal
    mean = ${delta_H_T2_ave} # J/mol
    standard_deviation = ${delta_H_T2_std}
  []
  [delta_S_T2]
    type = Normal
    mean = ${delta_S_T2_ave} # J/mol/K
    standard_deviation = ${delta_S_T2_std}
  []
[]

[Samplers]
  [sample]
    type = ParallelSubsetSimulation
    distributions = 'detrapping_energy_1_ev trapping_site_fraction_1_expo trapping_rate_prefactor_expo release_rate_profactor_expo trapping_energy_ev electron_concentration_initial_expo T2O_reaction_forward_value_expo T2_reaction_forward_value_expo diffusivity_OT_prefactor_m2s diffusivity_OT_energy_ev diffusivity_V_O_prefactor_m2s diffusivity_V_O_energy diffusivity_e_prefactor_m2s diffusivity_e_energy delta_H_T2O delta_S_T2O delta_H_T2 delta_S_T2'
    execute_on = PRE_MULTIAPP_SETUP
    subset_probability = 0.1
    num_samplessub = 10
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
