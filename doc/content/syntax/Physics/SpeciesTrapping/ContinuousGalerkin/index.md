# TMAP8 Field / Continuous Galerkin Species Trapping Physics syntax

The `[Physics/SpeciesTrapping/ContinuousGalerkin/...]` syntax is used to create each `Physics` of
type [FieldTrappingPhysics.md].

Multiple [FieldTrappingPhysics.md] can be used to vary the numerical or modeling parameters in different spatial
regions of the model or for different species being trapped.
If using the same modeling parameters, multiple species may be specified within a single [FieldTrappingPhysics.md].

!syntax list /Physics/SpeciesTrapping/ContinuousGalerkin objects=False actions=True subsystems=False

!syntax list /Physics/SpeciesTrapping/ContinuousGalerkin objects=True actions=False subsystems=False

!syntax list /Physics/SpeciesTrapping/ContinuousGalerkin objects=False actions=False subsystems=True
