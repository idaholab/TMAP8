# Validation Problem #2ed from TMAP7's V&V document
# Deuterium permeation through 0.05-mm Pd at 825 K.
# No Soret effect, or trapping included.

# Necessary physical and mdoel parameters (kb, R, temperature)
!include parameters_three_gases.params

# Solubility data used in TMAP7 case
solubility_exponent = 0.9297 # -
solubility_pre = '${units ${fparse 9.355e22 / 1e18} at/mum^3/Pa^0.9297}'
solubility_energy = '${units ${fparse 5918 * R} J/mol}'

# Modeling data used in current case
file_name = 'val-2ed_out'

!include val-2e_base_three_gases.i

[Kernels]
  # Gas flow kernels
  # Equation for D2 in enclosure upstream
  [MatReaction_upstream_D2_reaction]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'sqrt_PH2_sqrt_PD2_upstream'
    reaction_rate = -1
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_D2_re_reaction]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'HD_pressure_upstream'
    reaction_rate = 0.5
    extra_vector_tags = 'ref'
  []
  # Equation for H2 in enclosure upstream
  [MatReaction_upstream_H2_reaction]
    type = ADMatReaction
    variable = H2_pressure_upstream
    v = 'sqrt_PH2_sqrt_PD2_upstream'
    reaction_rate = -1
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_H2_re_reaction]
    type = ADMatReaction
    variable = H2_pressure_upstream
    v = 'HD_pressure_upstream'
    reaction_rate = 0.5
    extra_vector_tags = 'ref'
  []
  # Equation for HD in enclosure upstream
  [MatReaction_upstream_HD_reaction]
    type = ADMatReaction
    variable = HD_pressure_upstream
    v = 'sqrt_PH2_sqrt_PD2_upstream'
    reaction_rate = 2
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_HD_re_reaction]
    type = ADMatReaction
    variable = HD_pressure_upstream
    v = 'HD_pressure_upstream'
    reaction_rate = -1
    extra_vector_tags = 'ref'
  []
  # Membrane upstream
  [MatReaction_upstream_outflux_membrane_D]
    type = ADMatBodyForce
    variable = D2_pressure_upstream
    material_property = 'membrane_reaction_rate_right_D'
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_outflux_membrane_H]
    type = ADMatBodyForce
    variable = H2_pressure_upstream
    material_property = 'membrane_reaction_rate_right_H'
    extra_vector_tags = 'ref'
  []

  # Equation for D2 enclosure downstream
  [MatReaction_downstream_D2_reaction]
    type = ADMatReaction
    variable = D2_pressure_downstream
    v = 'sqrt_PH2_sqrt_PD2_downstream'
    reaction_rate = -1
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_D2_re_reaction]
    type = ADMatReaction
    variable = D2_pressure_downstream
    v = 'HD_pressure_downstream'
    reaction_rate = 0.5
    extra_vector_tags = 'ref'
  []
  # Equation for H2 enclosure downstream
  [MatReaction_downstream_H2_reaction]
    type = ADMatReaction
    variable = H2_pressure_downstream
    v = 'sqrt_PH2_sqrt_PD2_downstream'
    reaction_rate = -1
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_H2_re_reaction]
    type = ADMatReaction
    variable = H2_pressure_downstream
    v = 'HD_pressure_downstream'
    reaction_rate = 0.5
    extra_vector_tags = 'ref'
  []
  # Equation for HD enclosure downstream
  [MatReaction_downstream_HD_reaction]
    type = ADMatReaction
    variable = HD_pressure_downstream
    v = 'sqrt_PH2_sqrt_PD2_downstream'
    reaction_rate = 2
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_HD_re_reaction]
    type = ADMatReaction
    variable = HD_pressure_downstream
    v = 'HD_pressure_downstream'
    reaction_rate = -1
    extra_vector_tags = 'ref'
  []
  # Membrane downstream
  [MatReaction_downstream_influx_membrane_D]
    type = ADMatBodyForce
    variable = D2_pressure_downstream
    material_property = 'membrane_reaction_rate_left_D'
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_influx_membrane_H]
    type = ADMatBodyForce
    variable = H2_pressure_downstream
    material_property = 'membrane_reaction_rate_left_H'
    extra_vector_tags = 'ref'
  []
[]

[Materials]
  [membrane_reaction_rate_right_D]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_right_D'
    postprocessor_names = flux_surface_right_D
    expression = 'flux_surface_right_D * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}/2'
  []
  [membrane_reaction_rate_left_D]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_left_D'
    postprocessor_names = flux_surface_left_D
    expression = 'flux_surface_left_D * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}/2'
  []
  [membrane_reaction_rate_right_H]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_right_H'
    postprocessor_names = flux_surface_right_H
    expression = 'flux_surface_right_H * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}/2'
  []
  [membrane_reaction_rate_left_H]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_left_H'
    postprocessor_names = flux_surface_left_H
    expression = 'flux_surface_left_H * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}/2'
  []
[]

[BCs]
  # The surface of the slab in contact with the source is assumed to be in equilibrium with the source enclosure
  [right_diffusion_D]
    type = EquilibriumBC
    variable = D_concentration
    enclosure_var = D2_partial_pressure_upstream
    boundary = 'right'
    Ko = '${solubility_pre}'
    activation_energy = '${solubility_energy}'
    p = '${solubility_exponent}'
    temperature = ${temperature}
  []
  [left_diffusion_D]
    type = EquilibriumBC
    variable = D_concentration
    enclosure_var = D2_partial_pressure_downstream
    boundary = 'left'
    Ko = '${solubility_pre}'
    activation_energy = '${solubility_energy}'
    p = '${solubility_exponent}'
    temperature = ${temperature}
  []
  [right_diffusion_H]
    type = EquilibriumBC
    variable = H_concentration
    enclosure_var = H2_partial_pressure_upstream
    boundary = 'right'
    Ko = '${solubility_pre}'
    activation_energy = '${solubility_energy}'
    p = '${solubility_exponent}'
    temperature = ${temperature}
  []
  [left_diffusion_H]
    type = EquilibriumBC
    variable = H_concentration
    enclosure_var = H2_partial_pressure_downstream
    boundary = 'left'
    Ko = '${solubility_pre}'
    activation_energy = '${solubility_energy}'
    p = '${solubility_exponent}'
    temperature = ${temperature}
  []
[]
