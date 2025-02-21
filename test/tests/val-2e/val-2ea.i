# Validation Problem #2ea from TMAP7's V&V document
# Deuterium permeation through 0.05-mm Pd at 825 K.
# No Soret effect, or trapping included.

# Necessary physical and mdoel parameters (kb, R, temperature)
!include parameters_deuterium_gas.params

# Enclosure data used in TMAP7 case
pressure_enclosure1 = '${units 1e-6 Pa}'
pressure_initial = '${units 1e-6 Pa}'

# Modeling data used in current case
slab_thickness = '${units 5e-5 m -> mum}'
file_name = 'val-2ea_out'
simulation_time = '${units 1900 s}'

!include val-2e_base.i

# Diffusion data used in TMAP7 case
solubility_exponent = 0.9297 # -
solubility_pre = '${units ${fparse 1.511e23 / 1e18} at/mum^3/Pa^0.9297}'
solubility_energy = '${units ${fparse 5918 * R} J/mol}'

[Variables]
  [D2_pressure_upstream]
    initial_condition = '${pressure_initial}'
  []
  [D2_pressure_downstream]
    initial_condition = '${pressure_initial}'
  []
  [D_concentration]
    initial_condition = 0
  []
[]

[AuxVariables]
  [D2_pressure_enclosure1]
    initial_condition = '${pressure_enclosure1}'
  []
  [D2_pressure_enclosure4]
    initial_condition = '${pressure_enclosure4}'
  []
  [D2_pressure_enclosure5]
  []
[]

[AuxKernels]
  [D2_pressure_enclosure5_kernel]
    type = FunctionAux
    variable = D2_pressure_enclosure5
    function = D2_pressure_enclosure5_function
  []
[]

[Functions]
  [D2_pressure_enclosure5_function]
    type = ParsedFunction
    expression = 'if(t < 150, 1.20e-4,
                  if(t < 250, 2.41e-4,
                  if(t < 350, 6.06e-4,
                  if(t < 450, 1.30e-3,
                  if(t < 550, 2.53e-3,
                  if(t < 650, 7.08e-3,
                  if(t < 750, 1.45e-2,
                  if(t < 850, 2.63e-2,
                  if(t < 950, 6.51e-2,
                  if(t < 1050, 0.116,
                  if(t < 1150, 0.297,
                  if(t < 1250, 0.760,
                  if(t < 1350, 1.550,
                  if(t < 1900, 3.370, 3.370))))))))))))))'
  []
[]

[Kernels]
  # Gas flow kernels
  # Equation for enclosure upstream
  [MatReaction_upstream_D2_outflux_membrane]
    type = ADMatBodyForce
    variable = D2_pressure_upstream
    material_property = 'membrane_reaction_rate_right'
    extra_vector_tags = 'ref'
  []
  # Equation for enclosure downstream
  [MatReaction_downstream_D2_influx_membrane]
    type = ADMatBodyForce
    variable = D2_pressure_downstream
    material_property = 'membrane_reaction_rate_left'
    extra_vector_tags = 'ref'
  []
[]

[Materials]
  [membrane_reaction_rate_right]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_right'
    postprocessor_names = flux_surface_right_D
    expression = 'flux_surface_right_D * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor} / 2'
    outputs = 'exodus'
  []
  [membrane_reaction_rate_left]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_left'
    postprocessor_names = flux_surface_left_D
    expression = 'flux_surface_left_D * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor} / 2'
    outputs = 'exodus'
  []
  [converter_to_regular]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_D'
    reg_props_out = 'diffusivity_D_nonAD'
    outputs = none
  []
[]

[BCs]
  # The surface of the slab in contact with the source is assumed to be in equilibrium with the source enclosure
  [right_diffusion]
    type = EquilibriumBC
    variable = D_concentration
    enclosure_var = D2_pressure_upstream
    boundary = 'right'
    Ko = '${solubility_pre}'
    activation_energy = '${solubility_energy}'
    p = '${solubility_exponent}'
    temperature = ${temperature}
  []
  [left_diffusion]
    type = EquilibriumBC
    variable = D_concentration
    enclosure_var = D2_pressure_downstream
    boundary = 'left'
    Ko = '${solubility_pre}'
    activation_energy = '${solubility_energy}'
    p = '${solubility_exponent}'
    temperature = ${temperature}
  []
[]
