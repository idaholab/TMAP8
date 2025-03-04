# TMAP8 SorptionExchange Physics syntax

The `[Physics/SorptionExchange/...]` syntax is used to create each `Physics` of
type [SorptionExchangePhysics.md].

Multiple [SorptionExchangePhysics.md] can be used to vary the numerical or modeling parameters at different points.
If using the same modeling parameters, multiple species may be specified within a single [SorptionExchangePhysics.md].

!syntax list /Physics/SorptionExchange objects=False actions=True subsystems=False

!syntax list /Physics/SorptionExchange objects=True actions=False subsystems=False

!syntax list /Physics/SorptionExchange objects=False actions=False subsystems=True
