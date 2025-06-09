# TMAP8 Field Species Diffusion Migration syntax

The `[Physics/SpeciesDiffusionReaction/...]` syntax is used to create each `Physics` of
type [SpeciesDiffusionReactionCG.md].

Multiple [SpeciesDiffusionReactionCG.md] can be used to vary the numerical or modeling parameters in different spatial
regions of the model or for different species being trapped.
If using the same modeling parameters, multiple species may be specified within a single [SpeciesDiffusionReactionCG.md].

!syntax list /Physics/SpeciesDiffusionReaction objects=False actions=True subsystems=False

!syntax list /Physics/SpeciesDiffusionReaction objects=True actions=False subsystems=False

!syntax list /Physics/SpeciesDiffusionReaction objects=False actions=False subsystems=True
