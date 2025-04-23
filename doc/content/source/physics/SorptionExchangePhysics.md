# Species Solubility in 0D Structures / SorptionExchangePhysics

This [Physics](syntax/Physics/index.md) creates an ordinary differential equation to represent the local solubility / releasing of species
in a 0D enclosure, and mass exchange of that species at its boundaries. The 0D enclosure component is exchanging species with
a structure.

The ordinary differential equations solved for each species are:

!equation
\dfrac{\partial c_i}{\partial t} + \frac{\Gamma_i A}{V} \zeta = 0

where $c_i$ are the species of interest, $\Gamma_i$ is the flux of the specie $i$ exiting the enclosure and entering the
structure, $A$ is the surface area of the structure contacting the enclosure,
$V$ is the enclosure volume, and $\zeta$ is a conversion factor from
concentration to pressure units.
See the respective kernels for for information.

## Objects created

The species equation(s) on the 0D component (such as a [Enclosure0D.md]) are created using:

- A [ODETimeDerivative.md] for the time derivative of the concentration of each species being trapped, if simulating a transient. This term is not added if the [Executioner](syntax/Executioner/index.md) is not transient
- A [EnclosureSinkScalarKernel.md] for the trapping and releasing term

On the structures (such as a [Structure1D.md]) connected to the 0D component, an [EquilibriumBC.md] is created on their outer surface boundary.
This boundary condition applies to a variable being diffused/migrated on that structure if a [DiffusionPhysicsBase.md]-derived
`Physics` is defined on this structure.
This boundary condition connects the outgoing species flux 0D component with the incoming species flux on the boundary of the structure.

## Interaction with ActionComponents

The `SorptionExchangePhysics` can be defined on an [ActionComponent](syntax/ActionComponents/index.md) by specifying the `physics` parameter of that component to include the name of the particular `SorptionExchangePhysics`. The name of the `Physics` can be found nested under `[Physics/SorptionExchange/<name>]`.

Certain parameters of the `SorptionExchangePhysics` can be specified on components that are specifically implemented to interact with the
`SorptionExchangePhysics`. For example, the [!param](/ActionComponents/Enclosure0D/species) and
[!param](/ActionComponents/Enclosure0D/species_initial_pressures) parameters can be specified on a [Enclosure0D.md].
The `SorptionExchangePhysics` will then take care of defining the variable and its initial condition.

!syntax parameters /Physics/SorptionExchange/SorptionExchangePhysics

!syntax inputs /Physics/SorptionExchange/SorptionExchangePhysics

!syntax children /Physics/SorptionExchange/SorptionExchangePhysics
