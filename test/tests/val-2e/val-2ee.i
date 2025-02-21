# Validation Problem #2ee from TMAP7's V&V document
# Deuterium permeation through 0.05-mm Pd at 825 K.
# No Soret effect, or trapping included.

# Surface reaction data used in TMAP7 case
K_r_pre_D2 = '${units ${fparse 2.502e-24 / sqrt(4 * 870)} m^4/s -> mum^4/s}'
K_r_pre_H2 = '${units ${fparse 2.502e-24 / sqrt(2 * 870)} m^4/s -> mum^4/s}'
K_r_pre_HD = '${units ${fparse 2.502e-24 / sqrt(3 * 870)} m^4/s -> mum^4/s}'
K_r_energy = '${units ${fparse -11836 * 8.31446261815324} J/mol}'
K_d_D2 = '${units ${fparse 2.1897e22 / sqrt(4 * 870)} at/m^2/Pa -> at/mum^2/Pa}'
K_d_H2 = '${units ${fparse 2.1897e22 / sqrt(2 * 870)} at/m^2/Pa -> at/mum^2/Pa}'
K_d_HD = '${units ${fparse 2.1897e22 / sqrt(3 * 870)} at/m^2/Pa -> at/mum^2/Pa}'

# Modeling data used in current case
file_name = 'val-2ee_out'

!include val-2e_base_three_gases.i

[Kernels]
  # Gas flow kernels
  # Equation for D2 in enclosure upstream
  [MatReaction_upstream_D2_reaction]
    type = ADMatReactionFlexible
    variable = D2_pressure_upstream
    vs = 'D_concentration H_concentration'
    reaction_rate_name = 'K_r_HD'
    coeff = '${fparse -0.5 * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_D2_re_reaction]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'HD_pressure_upstream'
    reaction_rate = '${fparse 0.5 * K_d_HD * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  # Equation for H2 in enclosure upstream
  [MatReaction_upstream_H2_reaction]
    type = ADMatReactionFlexible
    variable = H2_pressure_upstream
    vs = 'D_concentration H_concentration'
    reaction_rate_name = 'K_r_HD'
    coeff = '${fparse -0.5 * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_H2_re_reaction]
    type = ADMatReaction
    variable = H2_pressure_upstream
    v = 'HD_pressure_upstream'
    reaction_rate = '${fparse 0.5 * K_d_HD * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  # Equation for HD in enclosure upstream
  [MatReaction_upstream_HD_reaction]
    type = ADMatReactionFlexible
    variable = HD_pressure_upstream
    vs = 'D_concentration H_concentration'
    reaction_rate_name = 'K_r_HD'
    coeff = '${fparse kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_HD_re_reaction]
    type = ADMatReaction
    variable = HD_pressure_upstream
    v = 'HD_pressure_upstream'
    reaction_rate = '${fparse - K_d_HD * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  # Membrane upstream
  [MatReaction_upstream_outflux_membrane_D2]
    type = ADMatBodyForce
    variable = D2_pressure_upstream
    material_property = 'membrane_reaction_rate_right_D2'
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_outflux_membrane_H2]
    type = ADMatBodyForce
    variable = H2_pressure_upstream
    material_property = 'membrane_reaction_rate_right_H2'
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_outflux_membrane_HD]
    type = ADMatBodyForce
    variable = HD_pressure_upstream
    material_property = 'membrane_reaction_rate_right_HD'
    extra_vector_tags = 'ref'
  []

  # Equation for D2 enclosure downstream
  [MatReaction_downstream_D2_reaction]
    type = ADMatReactionFlexible
    variable = D2_pressure_downstream
    vs = 'D_concentration H_concentration'
    reaction_rate_name = 'K_r_HD'
    coeff = '${fparse -0.5 * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_D2_re_reaction]
    type = ADMatReaction
    variable = D2_pressure_downstream
    v = 'HD_pressure_downstream'
    reaction_rate = '${fparse 0.5 * K_d_HD * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  # Equation for H2 enclosure downstream
  [MatReaction_downstream_H2_reaction]
    type = ADMatReactionFlexible
    variable = H2_pressure_downstream
    vs = 'D_concentration H_concentration'
    reaction_rate_name = 'K_r_HD'
    coeff = '${fparse -0.5 * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_H2_re_reaction]
    type = ADMatReaction
    variable = H2_pressure_downstream
    v = 'HD_pressure_downstream'
    reaction_rate = '${fparse 0.5 * K_d_HD * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  # Equation for HD enclosure downstream
  [MatReaction_downstream_HD_reaction]
    type = ADMatReactionFlexible
    variable = HD_pressure_downstream
    vs = 'D_concentration H_concentration'
    reaction_rate_name = 'K_r_HD'
    coeff = '${fparse kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_HD_re_reaction]
    type = ADMatReaction
    variable = HD_pressure_downstream
    v = 'HD_pressure_downstream'
    reaction_rate = '${fparse - K_d_HD * kb * temperature * surface_area / volume_enclosure}'
    extra_vector_tags = 'ref'
  []
  # Membrane downstream
  [MatReaction_downstream_influx_membrane_D2]
    type = ADMatBodyForce
    variable = D2_pressure_downstream
    material_property = 'membrane_reaction_rate_left_D2'
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_influx_membrane_H2]
    type = ADMatBodyForce
    variable = H2_pressure_downstream
    material_property = 'membrane_reaction_rate_left_H2'
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_influx_membrane_HD]
    type = ADMatBodyForce
    variable = HD_pressure_downstream
    material_property = 'membrane_reaction_rate_left_HD'
    extra_vector_tags = 'ref'
  []
[]

[Materials]
  [K_r_D2]
    type = ADParsedMaterial
    property_name = 'K_r_D2'
    expression = '${K_r_pre_D2} * exp( - ${K_r_energy} / ${R} / ${temperature})'
  []
  [K_r_H2]
    type = ADParsedMaterial
    property_name = 'K_r_H2'
    expression = '${K_r_pre_H2} * exp( - ${K_r_energy} / ${R} / ${temperature})'
  []
  [K_r_HD]
    type = ADParsedMaterial
    property_name = 'K_r_HD'
    expression = '${K_r_pre_HD} * exp( - ${K_r_energy} / ${R} / ${temperature})'
  []
  [membrane_reaction_rate_right_D2]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_right_D2'
    material_property_names = flux_on_right_D2
    expression = '-flux_on_right_D2 * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}'
  []
  [membrane_reaction_rate_left_D2]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_left_D2'
    material_property_names = flux_on_left_D2
    expression = '-flux_on_left_D2 * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}'
  []
  [membrane_reaction_rate_right_H2]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_right_H2'
    material_property_names = flux_on_right_H2
    expression = '-flux_on_right_H2 * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}'
  []
  [membrane_reaction_rate_left_H2]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_left_H2'
    material_property_names = flux_on_left_H2
    expression = '-flux_on_left_H2 * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}'
  []
  [membrane_reaction_rate_right_HD]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_right_HD'
    material_property_names = flux_on_right_HD
    expression = '-flux_on_right_HD * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}'
  []
  [membrane_reaction_rate_left_HD]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_left_HD'
    material_property_names = flux_on_left_HD
    expression = '-flux_on_left_HD * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}'
  []
  [flux_on_left_D]
    type = ADParsedMaterial
    coupled_variables = 'D_concentration H_concentration D2_pressure_downstream HD_pressure_downstream'
    property_name = 'flux_on_left_D'
    material_property_names = 'K_r_D2 K_r_HD'
    expression = '- 2 * K_r_D2 * D_concentration ^ 2 + 2 * ${K_d_D2} * D2_pressure_downstream - K_r_HD * D_concentration * H_concentration + ${K_d_HD} * HD_pressure_downstream'
    outputs = 'exodus'
  []
  [flux_on_right_D]
    type = ADParsedMaterial
    coupled_variables = 'D_concentration H_concentration D2_pressure_upstream HD_pressure_upstream'
    property_name = 'flux_on_right_D'
    material_property_names = 'K_r_D2 K_r_HD'
    expression = '- 2 * K_r_D2 * D_concentration ^ 2 + 2 * ${K_d_D2} * D2_pressure_upstream - K_r_HD * D_concentration * H_concentration + ${K_d_HD} * HD_pressure_upstream'
    outputs = 'exodus'
  []
  [flux_on_left_H]
    type = ADParsedMaterial
    coupled_variables = 'D_concentration H_concentration H2_pressure_downstream HD_pressure_downstream'
    property_name = 'flux_on_left_H'
    material_property_names = 'K_r_H2 K_r_HD'
    expression = '- 2 * K_r_H2 * H_concentration ^ 2 + 2 * ${K_d_H2} * H2_pressure_downstream - K_r_HD * D_concentration * H_concentration + ${K_d_HD} * HD_pressure_downstream'
    outputs = 'exodus'
  []
  [flux_on_right_H]
    type = ADParsedMaterial
    coupled_variables = 'D_concentration H_concentration H2_pressure_upstream HD_pressure_upstream'
    property_name = 'flux_on_right_H'
    material_property_names = 'K_r_H2 K_r_HD'
    expression = '- 2 * K_r_H2 * H_concentration ^ 2 + 2 * ${K_d_H2} * H2_pressure_upstream - K_r_HD * D_concentration * H_concentration + ${K_d_HD} * HD_pressure_upstream'
    outputs = 'exodus'
  []
  [flux_on_left_D2]
    type = ADParsedMaterial
    coupled_variables = 'D_concentration D2_pressure_downstream'
    property_name = 'flux_on_left_D2'
    material_property_names = 'K_r_D2'
    expression = '- K_r_D2 * D_concentration ^ 2 + ${K_d_D2} * D2_pressure_downstream'
    outputs = 'exodus'
  []
  [flux_on_left_HD]
    type = ADParsedMaterial
    coupled_variables = 'D_concentration H_concentration HD_pressure_downstream'
    property_name = 'flux_on_left_HD'
    material_property_names = 'K_r_HD'
    expression = '- K_r_HD * D_concentration * H_concentration + ${K_d_HD} * HD_pressure_downstream'
    outputs = 'exodus'
  []
  [flux_on_left_H2]
    type = ADParsedMaterial
    coupled_variables = 'H_concentration H2_pressure_downstream'
    property_name = 'flux_on_left_H2'
    material_property_names = 'K_r_H2'
    expression = '- K_r_H2 * H_concentration ^ 2 + ${K_d_H2} * H2_pressure_downstream'
    outputs = 'exodus'
  []
  [flux_on_right_D2]
    type = ADParsedMaterial
    coupled_variables = 'D_concentration D2_pressure_upstream'
    property_name = 'flux_on_right_D2'
    material_property_names = 'K_r_D2'
    expression = '- K_r_D2 * D_concentration ^ 2 + ${K_d_D2} * D2_pressure_upstream'
    outputs = 'exodus'
  []
  [flux_on_right_HD]
    type = ADParsedMaterial
    coupled_variables = 'D_concentration H_concentration HD_pressure_upstream'
    property_name = 'flux_on_right_HD'
    material_property_names = 'K_r_HD'
    expression = '- K_r_HD * D_concentration * H_concentration + ${K_d_HD} * HD_pressure_upstream'
    outputs = 'exodus'
  []
  [flux_on_right_H2]
    type = ADParsedMaterial
    coupled_variables = 'H_concentration H2_pressure_upstream'
    property_name = 'flux_on_right_H2'
    material_property_names = 'K_r_H2'
    expression = '- K_r_H2 * H_concentration ^ 2 + ${K_d_H2} * H2_pressure_upstream'
    outputs = 'exodus'
  []
[]

[BCs]
  # recombination BCs
  [left_diffusion_D]
    type = ADMatNeumannBC
    variable = D_concentration
    boundary = left
    value = 1
    boundary_material = flux_on_left_D
  []
  [right_diffusion_D]
    type = ADMatNeumannBC
    variable = D_concentration
    boundary = right
    value = 1
    boundary_material = flux_on_right_D
  []
  [left_diffusion_H]
    type = ADMatNeumannBC
    variable = H_concentration
    boundary = left
    value = 1
    boundary_material = flux_on_left_H
  []
  [right_diffusion_H]
    type = ADMatNeumannBC
    variable = H_concentration
    boundary = right
    value = 1
    boundary_material = flux_on_right_H
  []
[]

[Postprocessors]
  # Flux
  [dcdx_right_D]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_on_right_D
    outputs = 'console csv exodus'
  []
  [dcdx_left_D]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_left_D
    outputs = 'console csv exodus'
  []
  [dcdx_right_H]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_on_right_H
    outputs = 'console csv exodus'
  []
  [dcdx_left_H]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_left_H
    outputs = 'console csv exodus'
  []
  [flux_on_left_H2]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_left_H2
    outputs = 'console csv exodus'
  []
  [flux_on_left_D2]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_left_D2
    outputs = 'console csv exodus'
  []
  [flux_on_left_HD]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_left_HD
    outputs = 'console csv exodus'
  []
  [flux_on_right_H2]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_on_right_H2
    outputs = 'console csv exodus'
  []
  [flux_on_right_D2]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_on_right_D2
    outputs = 'console csv exodus'
  []
  [flux_on_right_HD]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_on_right_HD
    outputs = 'console csv exodus'
  []
[]
