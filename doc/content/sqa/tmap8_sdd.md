!template load file=sqa/app_sdd.md.template app=TMAP8App category=tmap8

!template! item key=introduction
Many of the phenomena related to tritium transport depend on the solutions of multiple
physics models, which can be described by partial differential equations that provide spatially and
temporally varying values of solution variables. These models for individual physics often depend on
each other. {{app}} relies on the MOOSE framework to solve these physics models, accounting for the
couplings that may occur between them. This document describes the system design of {{app}}.
!template-end!

!template! item key=system-scope
!include tmap8_srs.md start=system-scope-begin end=system-scope-finish
!template-end!

!template! item key=dependencies-and-limitations
{{app}} inherits the [software dependencies of the MOOSE framework](framework_sdd.md#dependencies-and-limitations),
with no additional dependencies.
!template-end!

!template! item key=design-stakeholders
Stakeholders for {{app}} include several of the funding sources including [!ac](DOE) and [!ac](INL).
However, Since {{app}} is an open-source project, several universities, companies, and foreign governments
have an interest in the development and maintenance of the {{app}} project.
!template-end!

!template! item key=system-design
{{app}} relies on MOOSE to solve the coupled physics models underlying tritium transport,
accounting for the couplings that may occur between them. The design of MOOSE is based on the concept
of modular code objects that define all of the aspects of the physics model. {{app}} follows this design,
providing code objects that define specific aspects of the solutions for its physics that derive from
the base classes defined by the MOOSE framework and the modules that it depends on.

{{app}} provides specialized `Kernel` classes that compute the contributions from the terms in the
partial differential equations for heat conduction, tritium diffusion, surface reactions, and other phenomena. It also provides
specialized `Material` classes that define the constitutive behavior of materials of interest for
diffusion, solubility, trapping, resolution, reactivity, permeation, and other physical properties. In addition, it provides miscellaneous `BC` and
`InterfaceKernel` classes to facilitate various aspects of these simulations, such as plasma exposure, surface reactions, transfer of species acros enclosures, among others. Much of the functionality
of {{app}} is provided by the MOOSE modules that it builds on.
!template-end!

!template! item key=system-structure
{{app}} relies on the MOOSE framework to provide the core functionality of solving multiphysics problems
using the finite element method. It also relies on the MOOSE modules for much of its core functionality.
A summary listing of the current modules required for complete TMAP8 operation are shown below:

- [Heat Transfer](heat_transfer/index.md)
- [Miscellaneous Module](misc/index.md)
- [Navier Stokes](navier_stokes/index.md)
- [Phase Field](phase_field/index.md)
- [Solid Mechanics](solid_mechanics/index.md)
- [Solid Properties](solid_properties/index.md)
- [Fluid Properties](fluid_properties/index.md)
- [Scalar Transport](scalar_transport/index.md)
- [Chemical Reactions](chemical_reactions/index.md)
- [Thermal Hydraulics](thermal_hydraulics/index.md)

The structure of {{app}} is based on defining C++ classes that derive from classes in the MOOSE framework
or modules that provide functionality that is specifically tailored to the structural degradation
problem. By using the interfaces defined in MOOSE base classes for these classes, {{app}} is able to
rely on MOOSE to execute these models at the appropriate times during the simulation and use their
results in the desired ways.
!template-end!

!syntax complete subsystems=False actions=False objects=False
!template-end!
