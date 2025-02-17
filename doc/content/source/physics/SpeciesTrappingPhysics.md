# Species Trapping Physics using a Continuous Galerkin Finite Element discretization / SpeciesTrappingPhysics

This [Physics](syntax/Physics/index.md) creates ordinary differential equations at every
node to represent the local trapping / releasing of species. It can be coupled with a
[SpeciesDiffusionReaction.md] `Physics` to model the influx/outflux of the species into a diffusing/migrating mobile species.

The ordinary differential equation solved at every node is:

!equation
\dfrac{\partial c_i}{\partial t} + \frac{\alpha_t}{N} C_t^e C_s - \alpha_r C_t = 0

where $c_i$ are the species of interest, $\alpha_t$ is the trapping rate coefficient, which has dimensions of
$1/time$, $N$ is the atomic number density of the host material, $C_t^e$ is the
concentration of empty trapping sites, and $C_s$ is the concentration of the
mobile species, $C_t$ is the concentration of trapped species, $\alpha_r$ is the releasing rate
coefficient, which may be a function of temperature.
See the respective kernels for the definition of the rate coefficients.

## Objects created

The equation(s) are created using the following nodal kernels:

- A [TimeDerivativeNodalKernel.md] for the time derivative of the concentration of each species being trapped, if simulating a transient. This term is not added if the [Executioner](syntax/Executioner/index.md) is not transient
- A [TrappingNodalKernel.md] for the trapping term
- A [ReleasingNodalKernel.md] for the releasing term

Additionally, the rate of release minus trapping of the species being trapped is added to the mobile concentration being
tracked using a [CoupledTimeDerivative.md] regular kernel.

No boundary conditions are created, the nodal kernels are created on the boundary nodes similarly to how they
are created in the nodes inside the volume.

## Interaction with ActionComponents

The `SpeciesTrappingPhysics` can be defined on a regular mesh or it can be defined by specifying the `physics` parameter of an [ActionComponent](syntax/ActionComponent/index.md) to include the name of the particular `SpeciesTrappingPhysics`. The name of the `Physics` can be found nested under `[Physics/SpeciesTrapping/<name>]`.

When specified on an `ActionComponent`, the block restriction of the component is added to the domain of definition of the `SpeciesTrappingPhysics`.
Certain parameters of the `SpeciesTrappingPhysics` can be specified on components that are specifically implemented to interact with the
`SpeciesTrappingPhysics`. For example, the [!param](/ActionComponents/Structure1D/species) and
[!param](/ActionComponents/Structure1D/species_initial_concentrations) parameters can be specified on a [Structure1D.md].
The `SpeciesTrappingPhysics` will then take care of defining the variable and its initial condition, on the subdomains of the `Structure1D`.

!syntax parameters /Physics/SpeciesTrapping/ContinuousGalerkin/SpeciesTrappingPhysics

!syntax inputs /Physics/SpeciesTrapping/ContinuousGalerkin/SpeciesTrappingPhysics

!syntax children /Physics/SpeciesTrapping/ContinuousGalerkin/SpeciesTrappingPhysics
