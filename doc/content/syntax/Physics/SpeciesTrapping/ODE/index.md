# TMAP8 ODE Species Trapping Physics syntax

The `[Physics/SpeciesTrapping/ODE/...]` syntax is used to create each `Physics` of
type [PointTrappingPhysics.md].

Multiple [PointTrappingPhysics.md] can be used to vary the numerical or modeling parameters at different points.
If using the same modeling parameters, multiple species may be specified within a single [PointTrappingPhysics.md].

!syntax list /Physics/SpeciesTrapping/ODE objects=False actions=True subsystems=False

!syntax list /Physics/SpeciesTrapping/ODE objects=True actions=False subsystems=False

!syntax list /Physics/SpeciesTrapping/ODE objects=False actions=False subsystems=True
