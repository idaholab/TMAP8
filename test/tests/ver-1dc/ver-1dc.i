# Verification Problem #1dc from TMAP7 V&V document
# Permeation Problem with Three Trapping sites
# No Soret effect or solubility included.
# It leverages ver-1dc_base.i to form a complete input file.

# Modeling parameters
nx_num = 1000 # (-)
simulation_time = ${units 60 s}
time_interval_max = ${units 0.3 s}
time_step = ${units 1e-6 s}
scheme = BDF2

# Trapping parameters
cl = ${units 3.1622e18 atom/m^3}
N = ${units 3.1622e22 atom/m^3}
trapping_rate_coefficient = ${units 1e15 1/s}
release_rate_coefficient = ${units 1e13 1/s}

!include ver-1dc_base.i

[AuxVariables]
  [empty_sites_1]
  []
  [scaled_empty_sites_1]
  []
  [empty_sites_2]
  []
  [scaled_empty_sites_2]
  []
  [empty_sites_3]
  []
  [scaled_empty_sites_3]
  []
  [trapped_sites_1]
  []
  [trapped_sites_2]
  []
  [trapped_sites_3]
  []
  [total_sites]
  []
[]

[AuxKernels]
  [empty_sites_1]
    variable = empty_sites_1
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_1}'
    trapped_concentration_variables = trapped_1
  []
  [scaled_empty_1]
    variable = scaled_empty_sites_1
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_1
  []
  [empty_sites_2]
    variable = empty_sites_2
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_2}'
    trapped_concentration_variables = trapped_2
  []
  [scaled_empty_2]
    variable = scaled_empty_sites_2
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_2
  []
  [empty_sites_3]
    variable = empty_sites_3
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_3}'
    trapped_concentration_variables = trapped_3
  []
  [scaled_empty_3]
    variable = scaled_empty_sites_3
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_3
  []
  [trapped_sites_1]
    variable = trapped_sites_1
    type = NormalizationAux
    source_variable = trapped_1
  []
  [trapped_sites_2]
    variable = trapped_sites_2
    type = NormalizationAux
    source_variable = trapped_2
  []
  [trapped_sites_3]
    variable = trapped_sites_3
    type = NormalizationAux
    source_variable = trapped_3
  []
  [total_sites]
    variable = total_sites
    type = ParsedAux
    expression = 'trapped_sites_1 + trapped_sites_2 + trapped_sites_3 + empty_sites_1 + empty_sites_2 + empty_sites_3'
    coupled_variables = 'trapped_sites_1 trapped_sites_2 trapped_sites_3 empty_sites_1 empty_sites_2 empty_sites_3'
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = mobile
    value = '${fparse cl / cl}'
    boundary = left
  []
  [right]
    type = DirichletBC
    variable = mobile
    value = 0
    boundary = right
  []
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'right'
    diffusivity = '${diffusivity}'
    variable = mobile
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = '${cl}'
  []
[]

[Executioner]
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${time_step}
    optimal_iterations = 9
    growth_factor = 1.1
    cutback_factor = 0.909
  []
[]

[Outputs]
  exodus = true
  csv = true
  [dof]
    type = DOFMap
    execute_on = initial
  []
  perf_graph = true
[]
