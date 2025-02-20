# Base input file for Validation Problem #2ed 2ee
# Except for the blocks in val-2e_base.i
# Include [Variables], [AuxVariables], [AuxKernels], [Functions],
# [Kernels] for H2, HD, and H, [Materials] for H,
# [Postprocessors] for H2, HD, and H blocks

!include val-2e_base.i

[Variables]
  [D2_pressure_upstream]
    initial_condition = '${pressure_initial_enclosure2}'
  []
  [H2_pressure_upstream]
    initial_condition = '${pressure_initial_enclosure2_H2}'
  []
  [HD_pressure_upstream]
    initial_condition = '${pressure_initial_enclosure2}'
  []

  [D2_pressure_downstream]
    initial_condition = '${pressure_initial_enclosure3}'
  []
  [H2_pressure_downstream]
    initial_condition = '${pressure_initial_enclosure3}'
  []
  [HD_pressure_downstream]
    initial_condition = '${pressure_initial_enclosure3}'
  []

  [D_concentration]
    initial_condition = 0
  []
  [H_concentration]
    initial_condition = 0
  []
[]

[AuxVariables]
  [D2_pressure_enclosure1]
    initial_condition = '${pressure_enclosure1}'
  []
  [H2_pressure_enclosure1]
    initial_condition = '${pressure_enclosure1}'
  []
  [HD_pressure_enclosure1]
    initial_condition = '${pressure_enclosure1}'
  []
  [D2_pressure_enclosure4]
    initial_condition = '${pressure_enclosure4}'
  []
  [H2_pressure_enclosure4]
    initial_condition = '${pressure_enclosure4}'
  []
  [HD_pressure_enclosure4]
    initial_condition = '${pressure_enclosure4}'
  []
  [D2_pressure_enclosure5]
    initial_condition = 1.8421e-4
  []
  [H2_pressure_enclosure5]
    initial_condition = '${pressure_initial_enclosure2_H2}'
  []
  [HD_pressure_enclosure5]
    initial_condition = '${pressure_enclosure4}'
  []

  [D2_partial_pressure_upstream]
    initial_condition = '${fparse pressure_initial_enclosure2 + pressure_initial_enclosure2/2}'
  []
  [D2_partial_pressure_downstream]
    initial_condition = '${fparse pressure_initial_enclosure3 + pressure_initial_enclosure3/2}'
  []
  [H2_partial_pressure_upstream]
    initial_condition = '${fparse pressure_initial_enclosure2_H2 + pressure_initial_enclosure2/2}'
  []
  [H2_partial_pressure_downstream]
    initial_condition = '${fparse pressure_initial_enclosure3 + pressure_initial_enclosure3/2}'
  []

  [sqrt_PH2_sqrt_PD2_upstream]
  []
  [sqrt_PH2_sqrt_PD2_downstream]
  []

  [HD_pressure_upstream_reference]
  []
  [HD_pressure_downstream_reference]
  []
[]

[AuxKernels]
  [D2_pressure_enclosure5_kernel]
    type = FunctionAux
    variable = D2_pressure_enclosure5
    function = D2_pressure_enclosure5_function
  []
  [H2_pressure_enclosure5_kernel]
    type = FunctionAux
    variable = H2_pressure_enclosure5
    function = H2_pressure_enclosure5_function
  []

  [sqrt_PH2_sqrt_PD2_upstream_kernel]
    type = ParsedAux
    variable = sqrt_PH2_sqrt_PD2_upstream
    coupled_variables = 'D2_pressure_upstream H2_pressure_upstream'
    expression = 'sqrt(D2_pressure_upstream) * sqrt(H2_pressure_upstream)'
  []
  [sqrt_PH2_sqrt_PD2_downstream_kernel]
    type = ParsedAux
    variable = sqrt_PH2_sqrt_PD2_downstream
    coupled_variables = 'D2_pressure_downstream H2_pressure_downstream'
    expression = 'sqrt(D2_pressure_downstream) * sqrt(H2_pressure_downstream)'
  []

  [D2_partial_pressure_upstream_kernel]
    type = ParsedAux
    variable = D2_partial_pressure_upstream
    coupled_variables = 'D2_pressure_upstream HD_pressure_upstream'
    expression = 'D2_pressure_upstream + HD_pressure_upstream / 2'
  []
  [D2_partial_pressure_downstream_kernel]
    type = ParsedAux
    variable = D2_partial_pressure_downstream
    coupled_variables = 'D2_pressure_downstream HD_pressure_downstream'
    expression = 'D2_pressure_downstream + HD_pressure_downstream / 2'
  []
  [H2_partial_pressure_upstream_kernel]
    type = ParsedAux
    variable = H2_partial_pressure_upstream
    coupled_variables = 'H2_pressure_upstream HD_pressure_upstream'
    expression = 'H2_pressure_upstream + HD_pressure_upstream / 2'
  []
  [H2_partial_pressure_downstream_kernel]
    type = ParsedAux
    variable = H2_partial_pressure_downstream
    coupled_variables = 'H2_pressure_downstream HD_pressure_downstream'
    expression = 'H2_pressure_downstream + HD_pressure_downstream / 2'
  []

  [HD_pressure_upstream_reference_kernel]
    type = ParsedAux
    variable = HD_pressure_upstream_reference
    coupled_variables = 'D2_pressure_upstream H2_pressure_upstream'
    expression = '2 * sqrt(D2_pressure_upstream) * sqrt(H2_pressure_upstream)'
  []
  [HD_pressure_downstream_reference_kernel]
    type = ParsedAux
    variable = HD_pressure_downstream_reference
    coupled_variables = 'D2_pressure_downstream H2_pressure_downstream'
    expression = '2 * sqrt(D2_pressure_downstream) * sqrt(H2_pressure_downstream)'
  []
[]

[Functions]
  [D2_pressure_enclosure5_function]
    type = ParsedFunction
    expression = 'if(t < 150, 1.8421e-4,
                  if(t < 250, 1e-3,
                  if(t < 350, 3e-3,
                  if(t < 450, 0.009,
                  if(t < 550, 0.027,
                  if(t < 650, 0.081,
                  if(t < 750, 0.243,
                  if(t < ${simulation_time}, 0.729, 0.729))))))))'
  []
  [H2_pressure_enclosure5_function]
    type = ParsedFunction
    expression = '${pressure_initial_enclosure2_H2}' # Pa
  []
[]

[Kernels]
  # Gas flow kernels
  # Equation for D2 in enclosure upstream in val-2e_base.i
  # Equation for H2 in enclosure upstream
  [timeDerivative_upstream_H2]
    type = ADTimeDerivative
    variable = H2_pressure_upstream
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_H2_influx_5]
    type = ADMatReaction
    variable = H2_pressure_upstream
    v = 'H2_pressure_enclosure5'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_H2_influx_1]
    type = ADMatReaction
    variable = H2_pressure_upstream
    v = 'H2_pressure_enclosure1'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_H2_outflux_4]
    type = ADMatReaction
    variable = H2_pressure_upstream
    v = 'H2_pressure_upstream'
    reaction_rate = -${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  # Equation for HD in enclosure upstream
  [timeDerivative_upstream_HD]
    type = ADTimeDerivative
    variable = HD_pressure_upstream
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_HD_influx_5]
    type = ADMatReaction
    variable = HD_pressure_upstream
    v = 'HD_pressure_enclosure5'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_HD_influx_1]
    type = ADMatReaction
    variable = HD_pressure_upstream
    v = 'HD_pressure_enclosure1'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_HD_outflux_4]
    type = ADMatReaction
    variable = HD_pressure_upstream
    v = 'HD_pressure_upstream'
    reaction_rate = -${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []

  # Equation for D2 enclosure downstream in val-2e_base.i
  # Equation for H2 enclosure downstream
  [timeDerivative_downstream_H2]
    type = ADTimeDerivative
    variable = H2_pressure_downstream
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_H2_influx_1]
    type = ADMatReaction
    variable = H2_pressure_downstream
    v = 'H2_pressure_enclosure1'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_H2_outflux_4]
    type = ADMatReaction
    variable = H2_pressure_downstream
    v = 'H2_pressure_downstream'
    reaction_rate = -${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  # Equation for HD enclosure downstream
  [timeDerivative_downstream_HD]
    type = ADTimeDerivative
    variable = HD_pressure_downstream
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_HD_influx_1]
    type = ADMatReaction
    variable = HD_pressure_downstream
    v = 'HD_pressure_enclosure1'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_HD_outflux_4]
    type = ADMatReaction
    variable = HD_pressure_downstream
    v = 'HD_pressure_downstream'
    reaction_rate = -${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []

  # Diffusion kernels
  [timeDerivative_diffusion_H]
    type = ADTimeDerivative
    variable = H_concentration
    extra_vector_tags = 'ref'
  []
  [MatDiffusion_diffusion_H]
    type = ADMatDiffusion
    variable = H_concentration
    diffusivity = diffusivity_H
    extra_vector_tags = 'ref'
  []
[]

[Materials]
  [diffusivity_H]
    type = ADParsedMaterial
    property_name = 'diffusivity_H'
    expression = '${diffusivity_pre_H} * exp( - ${diffusivity_energy_H} / ${R} / ${temperature})'
  []
  [converter_to_regular]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_D diffusivity_H'
    reg_props_out = 'diffusivity_D_nonAD diffusivity_H_nonAD'
    outputs = none
  []
[]

[Postprocessors]
  # Pressure
  [pressure_upstream_H2]
    type = SideAverageValue
    variable = H2_pressure_upstream
    boundary = right
  []
  [pressure_downstream_H2]
    type = SideAverageValue
    variable = H2_pressure_downstream
    boundary = left
  []
  [pressure_upstream_HD]
    type = SideAverageValue
    variable = HD_pressure_upstream
    boundary = right
  []
  [pressure_upstream_HD_reference]
    type = SideAverageValue
    variable = HD_pressure_upstream_reference
    boundary = right
  []
  [pressure_downstream_HD]
    type = SideAverageValue
    variable = HD_pressure_downstream
    boundary = left
  []
  [pressure_downstream_HD_reference]
    type = SideAverageValue
    variable = HD_pressure_downstream_reference
    boundary = left
  []
  # Flux
  [flux_surface_right_H]
    type = SideDiffusiveFluxIntegral
    variable = H_concentration
    diffusivity = diffusivity_H_nonAD
    boundary = 'right'
    execute_on = 'initial timestep_end'
    outputs = 'console csv exodus'
  []
  [flux_surface_left_H]
    type = SideDiffusiveFluxIntegral
    variable = H_concentration
    diffusivity = diffusivity_H_nonAD
    boundary = 'left'
    execute_on = 'initial timestep_end'
    outputs = 'console csv exodus'
  []
[]
