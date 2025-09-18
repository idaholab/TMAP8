# This is the parallel subset simulation file for val-2c

## Conversion
Curie = '${units 3.7e10 1/s}' # disintegrations/s - activity of one Curie
decay_rate_tritium = '${units 1.78199e-9 1/s/at}' # disintegrations/s/atoms
conversion_Ci_atom = '${units ${fparse decay_rate_tritium / Curie} 1/at}' # 1 tritium at = ~4.82e-20 Ci

## Material properties
diffusivity_elemental_tritium = '${units ${fparse 4.0e-12 * (1.0-0.1)} m^2/s -> mum^2/s}'
diffusivity_tritiated_water = '${units ${fparse 1.0e-14 * (1.0+0.4)} m^2/s -> mum^2/s}'
reaction_rate = '${units ${fparse 2.8 * 2.0e-10*conversion_Ci_atom} m^3/at/s -> mum^3/at/s}' # ~ 1.5* 9.62e-30 m^3/at/s, close to the 1.0e-29 m3/atoms/s in TMAP4
solubility_elemental_tritium = '${units 4.0e19 1/m^3/Pa -> 1/mum^3/Pa}' # molecules/microns^3/Pa = molecules*s^2/m^2/kg
solubility_tritiated_water = '${units 6.0e24 1/m^3/Pa -> 1/mum^3/Pa}' # molecules/microns^3/Pa = molecules*s^2/m^2/kg

## Numerical parameters
time_injection_T2_end = '${units 3 h -> s}'

## PSS parameters
num_samplessub = 1000 # should be higher for a full PSS study (~6000-10000)
num_subsets = 5 # should be higher for a full PSS study (~10)
subset_probability = 0.2 # should be closer to 0.1 for a full PSS study

## Outputs
file_base_output = val-2c_pss_results/val-2c_pss_main_out

sub_app_input = "val-2c_delay_pss.i"

[StochasticTools]
[]

[Distributions]
  [reaction_rate] # K^0
    type = Normal
    mean = ${reaction_rate}
    standard_deviation = '${fparse 5/100 * reaction_rate}' # 5% of mean
  []
  [diffusivity_elemental_tritium] # D^e
    type = Normal
    mean = ${diffusivity_elemental_tritium}
    standard_deviation = '${fparse 10/100 * diffusivity_elemental_tritium}' # 10% of mean
  []
  [diffusivity_tritiated_water] # D^w
    type = Normal
    mean = ${diffusivity_tritiated_water}
    standard_deviation = '${fparse 20/100 * diffusivity_tritiated_water}' # 20% of mean
  []
  [log_solubility_elemental_tritium] # KS^e
    type = Uniform
    lower_bound = '${fparse log(1e-4 * solubility_elemental_tritium)}'
    upper_bound = '${fparse log(1e-3 * solubility_elemental_tritium)}' # a preliminary study has shown that the calibrated value is much lower than the original value.
  []
  [log_solubility_tritiated_water] # KS^w
    type = Uniform
    lower_bound = '${fparse log(1e-4 * solubility_tritiated_water)}'
    upper_bound = '${fparse log(1e-3 * solubility_tritiated_water)}' # a preliminary study has shown that the calibrated value is much lower than the original value.
  []
  [time_injection_T2_end]
    type = Normal
    mean = ${time_injection_T2_end}
    standard_deviation = '${fparse 10/100 * time_injection_T2_end}' # 10% of mean
  []
[]

[Samplers]
  [sample]
    type = ParallelSubsetSimulation
    distributions = 'reaction_rate diffusivity_elemental_tritium diffusivity_tritiated_water log_solubility_elemental_tritium log_solubility_tritiated_water time_injection_T2_end'
    execute_on = 'PRE_MULTIAPP_SETUP'
    subset_probability = ${subset_probability}
    num_samplessub = ${num_samplessub}
    num_subsets = ${num_subsets}
    # num_parallel_chains = 5 # using multiple parallel chains helps with convergence
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
    param_names = 'reaction_rate diffusivity_elemental_tritium diffusivity_tritiated_water log_solubility_elemental_tritium log_solubility_tritiated_water time_injection_T2_end'
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
