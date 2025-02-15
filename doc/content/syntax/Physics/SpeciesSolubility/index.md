# TMAP8 SpeciesSolubility Physics syntax

The `[Physics/SpeciesSolubility/...]` syntax is used to create each `Physics` of
type [SpeciesSolubilityPhysics.md].

Multiple [SpeciesSolubilityPhysics.md] can be used to vary the numerical or modeling parameters at different points.
If using the same modeling parameters, multiple species may be specified within a single [SpeciesSolubilityPhysics.md].

!syntax list /Physics/SpeciesTrapping/ODE objects=False actions=True subsystems=False

!syntax list /Physics/SpeciesTrapping/ODE objects=True actions=False subsystems=False

!syntax list /Physics/SpeciesTrapping/ODE objects=False actions=False subsystems=True
