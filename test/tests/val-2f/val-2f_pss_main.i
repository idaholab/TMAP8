# This is the parallel subset simulation file for val-2f

!include val-2f_pss_main.params

# Outputs
file_base_output = val-2f_pss_results/val-2f_pss_main_out

sub_app_input = "val-2f_pss_sub.i"

[StochasticTools]
[]

[Distributions]
  [diffusion_W_preexponential_exp]
    type = Normal
    mean = ${mean_diffusion_W_preexponential_exp}
    standard_deviation = ${std_diffusion_W_preexponential_exp}
  []
  [diffusion_W_energy]
    type = Normal
    mean = ${mean_diffusion_W_energy}
    standard_deviation = ${std_diffusion_W_energy}
  []
  [recombination_preexponential_exp]
    type = Normal
    mean = ${mean_recombination_preexponential_exp}
    standard_deviation = ${std_recombination_preexponential_exp}
  []
  [recombination_energy]
    type = Normal
    mean = ${mean_recombination_energy}
    standard_deviation = ${std_recombination_energy}
  []
  [detrapping_prefactor]
    type = Normal
    mean = ${mean_detrapping_prefactor}
    standard_deviation = ${std_detrapping_prefactor}
  []
  [A0]
    type = Normal
    mean = ${mean_A0}
    standard_deviation = ${std_A0}
  []
  [detrapping_energy_1]
    type = Normal
    mean = ${mean_detrapping_energy_1}
    standard_deviation = ${std_detrapping_energy_1}
  []
  [K_1]
    type = Normal
    mean = ${mean_K_1}
    standard_deviation = ${std_K_1}
  []
  [nmax_1]
    type = Normal
    mean = ${mean_nmax_1}
    standard_deviation = ${std_nmax_1}
  []
  [Ea_1]
    type = Normal
    mean = ${mean_Ea_1}
    standard_deviation = ${std_Ea_1}
  []
  [detrapping_energy_2]
    type = Normal
    mean = ${mean_detrapping_energy_2}
    standard_deviation = ${std_detrapping_energy_2}
  []
  [K_2]
    type = Normal
    mean = ${mean_K_2}
    standard_deviation = ${std_K_2}
  []
  [nmax_2]
    type = Normal
    mean = ${mean_nmax_2}
    standard_deviation = ${std_nmax_2}
  []
  [Ea_2]
    type = Normal
    mean = ${mean_Ea_2}
    standard_deviation = ${std_Ea_2}
  []
  [detrapping_energy_3]
    type = Normal
    mean = ${mean_detrapping_energy_3}
    standard_deviation = ${std_detrapping_energy_3}
  []
  [K_3]
    type = Normal
    mean = ${mean_K_3}
    standard_deviation = ${std_K_3}
  []
  [nmax_3]
    type = Normal
    mean = ${mean_nmax_3}
    standard_deviation = ${std_nmax_3}
  []
  [Ea_3]
    type = Normal
    mean = ${mean_Ea_3}
    standard_deviation = ${std_Ea_3}
  []
  [detrapping_energy_4]
    type = Normal
    mean = ${mean_detrapping_energy_4}
    standard_deviation = ${std_detrapping_energy_4}
  []
  [K_4]
    type = Normal
    mean = ${mean_K_4}
    standard_deviation = ${std_K_4}
  []
  [nmax_4]
    type = Normal
    mean = ${mean_nmax_4}
    standard_deviation = ${std_nmax_4}
  []
  [Ea_4]
    type = Normal
    mean = ${mean_Ea_4}
    standard_deviation = ${std_Ea_4}
  []
  [detrapping_energy_5]
    type = Normal
    mean = ${mean_detrapping_energy_5}
    standard_deviation = ${std_detrapping_energy_5}
  []
  [K_5]
    type = Normal
    mean = ${mean_K_5}
    standard_deviation = ${std_K_5}
  []
  [nmax_5]
    type = Normal
    mean = ${mean_nmax_5}
    standard_deviation = ${std_nmax_5}
  []
  [detrapping_energy_intrinsic]
    type = Normal
    mean = ${mean_detrapping_energy_intrinsic}
    standard_deviation = ${std_detrapping_energy_intrinsic}
  []
  [trap_density_01dpa_intrinsic]
    type = Normal
    mean = ${mean_trap_density_01dpa_intrinsic}
    standard_deviation = ${std_trap_density_01dpa_intrinsic}
  []
[]

[Samplers]
  [sample]
    type = ParallelSubsetSimulation
    distributions = 'diffusion_W_preexponential_exp
                     diffusion_W_energy
                     recombination_preexponential_exp
                     recombination_energy
                     detrapping_prefactor
                     A0
                     detrapping_energy_1
                     K_1
                     nmax_1
                     Ea_1
                     detrapping_energy_2
                     K_2
                     nmax_2
                     Ea_2
                     detrapping_energy_3
                     K_3
                     nmax_3
                     Ea_3
                     detrapping_energy_4
                     K_4
                     nmax_4
                     Ea_4
                     detrapping_energy_5
                     K_5
                     nmax_5
                     detrapping_energy_intrinsic
                     trap_density_01dpa_intrinsic
                     '
    execute_on = 'PRE_MULTIAPP_SETUP'
    num_samplessub = ${num_samplessub}
    num_subsets = ${num_subsets}
    inputs_reporter = 'adaptive_MC/inputs'
    output_reporter = 'constant/reporter_transfer:objective:value'
    seed = 1012
  []
[]

[MultiApps]
  [sub]
    type = SamplerFullSolveMultiApp
    input_files = ${sub_app_input}
    sampler = sample
    ignore_solve_not_converge = true
  []
[]

[Transfers]
  [reporter_transfer]
    type = SamplerReporterTransfer
    from_reporter = 'objective/value'
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
    param_names = 'diffusion_W_preexponential_exp
                   diffusion_W_energy
                   recombination_preexponential_exp
                   recombination_energy
                   detrapping_prefactor
                   A0
                   detrapping_energy_1
                   K_1
                   nmax_1
                   Ea_1
                   detrapping_energy_2
                   K_2
                   nmax_2
                   Ea_2
                   detrapping_energy_3
                   K_3
                   nmax_3
                   Ea_3
                   detrapping_energy_4
                   K_4
                   nmax_4
                   Ea_4
                   detrapping_energy_5
                   K_5
                   nmax_5
                   detrapping_energy_intrinsic
                   trap_density_01dpa_intrinsic
                   '
  []
[]

[Reporters]
  [constant]
    type = StochasticReporter
  []
  [adaptive_MC]
    type = AdaptiveMonteCarloDecision
    output_value = constant/reporter_transfer:objective:value
    inputs = 'inputs'
    sampler = sample
  []
[]

[Executioner]
  type = Transient
[]

[Outputs]
  file_base = ${file_base_output}
  [out]
    type = JSON
  []
[]
