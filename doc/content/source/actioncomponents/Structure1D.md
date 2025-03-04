# Structure1D

!syntax description /ActionComponents/Structure1D

This 1D [ActionComponent.md] represents a structure. A structure in TMAP8
is a volume in which tritium can migrate or be trapped.

## Interaction with common TMAP8 Physics

The [!param](/ActionComponents/Structure1D/physics) parameter of a `Structure1D` can be used
to define the [Physics](syntax/Physics/index.md) that should be active on the structure.
See more details on the [ComponentPhysicsInterface.md] page.

### Material properties

To vary the material properties used in each `Physics`, one can set the [!param](/ActionComponents/Structure1D/property_names) and [!param](/ActionComponents/Structure1D/property_values) parameters in the `Structure1D`.
See more details on the [ComponentMaterialPropertyInterface.md] page.

For a [SpeciesDiffusionReactionCG.md] `Physics` to be used you can define on
the `Structure1D`:

- the diffusivity material property, to be used in the [!param](/Physics/SpeciesDiffusionReaction/SpeciesDiffusionReactionCG/diffusivity_matprops) parameter
- reaction coefficients material properties for all reactions, to be used in the [!param](/Physics/SpeciesDiffusionReaction/SpeciesDiffusionReactionCG/reaction_coefficients) parameter

For a [MultiSpeciesDiffusionCG.md] `Physics` to be used you can define the:

- the diffusivity material property, to be used in the [!param](/Physics/SpeciesDiffusion/MultiSpeciesDiffusionCG/diffusivity_matprops) parameter

For a [SpeciesTrappingPhysics.md] to be used, you can define the:

- the trapping rate coefficient for each species, to be used in the [!param](/Physics/SpeciesTrapping/SpeciesTrappingPhysics/alpha_t) parameter
- the atomic number density of the host material, to be used in the [!param](/Physics/SpeciesTrapping/SpeciesTrappingPhysics/N) parameter
- fraction of host sites that can contribute to trapping, to be used in the [!param](/Physics/SpeciesTrapping/SpeciesTrappingPhysics/Ct0) parameter
- the release rate coefficient, to be used in the [!param](/Physics/SpeciesTrapping/SpeciesTrappingPhysics/alpha_r) parameter
- the trapping energy in units of Kelvin, to be used in the [!param](/Physics/SpeciesTrapping/SpeciesTrappingPhysics/detrapping_energy) parameter

### Boundary conditions

The `Structure1D` defines two boundaries by default: `left` and `right`.
Using the [!param](/ActionComponents/Structure1D/fixed_value_bc_boundaries),
[!param](/ActionComponents/Structure1D/fixed_value_bc_variables) and
[!param](/ActionComponents/Structure1D/fixed_value_bc_values) parameters of the `Structure1D`,
the `Physics` defined on this structure can set Dirichlet boundary conditions.

Using the [!param](/ActionComponents/Structure1D/flux_bc_boundaries),
[!param](/ActionComponents/Structure1D/flux_bc_variables) and
[!param](/ActionComponents/Structure1D/flux_bc_values) parameters of the `Structure1D`,
the `Physics` defined on this structure can set flux / Neumann boundary conditions.

See more details on the [ComponentBoundaryConditionInterface.md] page.

!syntax parameters /ActionComponents/Structure1D

!syntax inputs /ActionComponents/Structure1D

!syntax children /ActionComponents/Structure1D
