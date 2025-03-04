# Species Migration Physics using a Continuous Galerking Discretization / SpeciesDiffusionReactionCG

This [Physics](syntax/Physics/index.md) creates a diffusion-reaction equation for every species specified.

!equation
\dfrac{\partial c_i}{\partial t} + \nabla \cdot k \nabla c_i - sum_j K_{ij} c_i c_j = 0

where $c_i$ are the species of interest, $k$ the diffusivity of species $i$,
and $c_j$ a species reacting with species $i$ with equilibrium constant $K_{ij}$.
See the respective kernels for more information.

## Objects created

The equation(s) are created using the following kernels:

- A [TimeDerivative.md] for the time derivative of the concentration of each species, if simulating a transient. This term is not added if the [Executioner](syntax/Executioner/index.md) is not transient
- A [MatDiffusion.md] kernel for the diffusive term if a diffusivity property is specified
- A [ADMatReactionFlexible.md] kernel for each reaction specified, for each reacting species specified

Dirichlet and Neumann boundary conditions can be created for the species. This functionality
is implemented in the parent [MultiSpeciesDiffusionCG.md] class.

## Interaction with ActionComponents

The `SpeciesDiffusionReactionCG` can be defined on a regular mesh, or it can be assigned to an [ActionComponent](syntax/ActionComponents/index.md)'s spatial domain by specifying its `physics` parameter to include the name of the particular `SpeciesDiffusionReactionCG`. The name of the `Physics` can be found nested under `[Physics/DiffusionReaction/<name>]`.

The `SpeciesDiffusionReactionCG` inherits from the `PhysicsComponentInterface`, which notably means that it can:

- create initial conditions defined on each component using the parameters from the [ComponentInitialConditionInterface.md]
- create boundary conditions defined on each component using the parameters from the [ComponentBoundaryConditionInterface.md]

!syntax parameters /Physics/SpeciesDiffusionReaction/SpeciesDiffusionReactionCG

!syntax inputs /Physics/SpeciesDiffusionReaction/SpeciesDiffusionReactionCG

!syntax children /Physics/SpeciesDiffusionReaction/SpeciesDiffusionReactionCG
