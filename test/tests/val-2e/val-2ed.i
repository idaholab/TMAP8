# Validation Problem #2ed from TMAP7's V&V document
# Deuterium permeation through 0.05-mm Pd at 825 K.
# No Soret effect, or trapping included.

# Physical Constants
# Note that we do NOT use the same number of digits as in TMAP7.
# This is to be consistent with PhysicalConstant.h
kb = '${units 1.380649e-23 J/K}' # Boltzmann constant
R = '${units 8.31446261815324 J/mol/K}' # Gas constant

# Enclosure data used in TMAP7 case
surface_area = '${units 1.8e-4 m^2 -> mum^2}'
temperature = '${units 870 K}'
pressure_enclosure1 = '${units 1e-7 Pa}'
pressure_enclosure4 = '${units 1e-10 Pa}'
pressure_initial_enclosure2 = '${units 1e-7 Pa}'
pressure_initial_enclosure2_H2 = '${units 0.063 Pa}'
pressure_initial_enclosure3 = '${units 1e-20 Pa}'
volume_enclosure = '${units 0.005 m^3 -> mum^3}'
flow_rate = '${units 0.1 m^3/s -> mum^3/s}'
flow_rate_by_V = '${fparse flow_rate / volume_enclosure}'

# Diffusion data used in TMAP7 case
diffusivity_pre_D = '${units 2.636e-4 m^2/s -> mum^2/s}'
diffusivity_energy_D = '${units ${fparse 1315.8 * R} J/mol}'
diffusivity_pre_H = '${units 3.728e-4 m^2/s -> mum^2/s}'
diffusivity_energy_H = '${units ${fparse 1315.8 * R} J/mol}'
# Diffusion data used in TMAP7 case
solubility_exponent = 0.9297 # -
solubility_pre = '${units ${fparse 9.355e22 / 1e18} at/mum^3/Pa^0.9297}'
solubility_energy = '${units ${fparse 5918 * R} J/mol}'

# Modeling data used in current case
slab_thickness = '${units 2.5e-5 m -> mum}'
num_node = 20 # -
concentration_to_pressure_conversion_factor = '${units ${fparse kb*temperature} Pa*m^3 -> Pa*mum^3}'
simulation_time = '${units 1000 s}'
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
