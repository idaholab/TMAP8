# Verification Problem #1d from TMAP4/TMAP7 V&V document
# Permeation Problem with Trapping in Diffusion-limited Case using a Physics and Components syntax
# No Soret effect, or solubility included.

# Modeling parameters
node_num = 200
end_time = ${units 3 s}
thickness = '${units 1 m}'
temperature = '${units 1000 K}'
diffusivity = '${units 1 m^2/s}'

# Trapping parameters
density = '${units 3.1622e22 at/m^3}'
cl = '${units 3.1622e18 at/m^3}'
trapping_prefactor = ${units 1e15 1/s}
release_prefactor = ${units 1e13 1/s}
release_energy = ${units 100 K}
trapping_fraction = 0.1 # -
N = ${fparse density/cl}

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'trapped'
    species_initial_concentrations = '0'

    physics = 'mobile_diff trapped'

    # Material properties
    property_names = 'alpha_t trapping_energy    N  Ct0 trap_per_free alpha_r detrapping_energy diff'
    property_values = '${trapping_prefactor} 0   ${N} ${trapping_fraction} 1 ${release_prefactor} ${release_energy} ${diffusivity}'

    # Boundary conditions
    fixed_value_bc_variables = 'mobile'
    fixed_value_bc_boundaries = 'structure_left structure_right'
    fixed_value_bc_values = '${fparse cl / cl} 0'

    # Geometry
    nx = ${node_num}
    xmax = ${thickness}
    length_unit_scaling = 1
  []
[]

[Physics]
  [Diffusion]
    [mobile_diff]
      variable_name = 'mobile'
      diffusivity_matprop = 'diff'

      # Test differences are too large with default preconditioning
      preconditioning = 'defer'
    []
  []
  [SpeciesTrapping]
    [trapped]
      species = 'trapped'
      mobile = 'mobile'
      verbose = true

      # Trapping parameters are specified using functors on the structure component
      # Releasing parameters are specified using functors on the structure component
      temperature = 'temp'  # we can use component ICs to set the temperature on the component
    []
  []
[]

[AuxVariables]
  [temp]
    initial_condition = ${temperature}
  []
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'structure_right'
    diffusivity = ${diffusivity}
    variable = mobile
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = ${cl}
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient

  num_steps =  2
  end_time = ${end_time}
  dt = .01
  dtmin = .01
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
[]

[Outputs]
  csv = true
  exodus = true
  # Not present in the test we compare to
  hide = 'temp'
[]
