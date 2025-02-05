# TMAP8 Field Species Migration syntax

The `[Physics/FieldMigration/ContinuousGalerkin/...]` syntax is used to create each `Physics` of
type [MultiSpeciesMigrationCG.md].

Multiple [MultiSpeciesMigrationCG.md] can be used to vary the numerical or modeling parameters in different spatial
regions of the model or for different species being trapped.
If using the same modeling parameters, multiple species may be specified within a single [MultiSpeciesMigrationCG.md].

!syntax list /Physics/FieldMigration/ContinuousGalerkin objects=False actions=True subsystems=False

!syntax list /Physics/FieldMigration/ContinuousGalerkin objects=True actions=False subsystems=False

!syntax list /Physics/FieldMigration/ContinuousGalerkin objects=False actions=False subsystems=True
