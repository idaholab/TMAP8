# TMAP8 Field Species Diffusion syntax

The `[Physics/SpeciesDiffusion/...]` syntax is used to create each `Physics` of
type [MultiSpeciesDiffusionCG.md].

Multiple [MultiSpeciesDiffusionCG.md] can be used to vary the numerical or modeling parameters in different spatial
regions of the model or for different species being trapped.
If using the same modeling parameters, multiple species may be specified within a single [MultiSpeciesDiffusionCG.md].

!syntax list /Physics/SpeciesDiffusion objects=False actions=True subsystems=False

!syntax list /Physics/SpeciesDiffusion objects=True actions=False subsystems=False

!syntax list /Physics/SpeciesDiffusion objects=False actions=False subsystems=True
