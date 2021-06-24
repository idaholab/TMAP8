# BodyForceLM

!syntax description /Kernels/BodyForceLM

## Overview

This object is equivalent to [BodyForce.md] except it adds its residual both to
the primal equation on which the body force is being applied and to a Lagrange
Multiplier (LM) equation when an LM is present for enforcing non-negative
concentrations and we are trying to remove the saddle point due to no
on-diagonal dependence in the LM equation. See [LMKernel.md] for more details.

!syntax parameters /Kernels/BodyForceLM

!syntax inputs /Kernels/BodyForceLM

!syntax children /Kernels/BodyForceLM
