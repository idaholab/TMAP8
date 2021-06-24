# CoupledForceLM

!syntax description /Kernels/CoupledForceLM

## Overview

This object is equivalent to [CoupledForce.md] except it adds its residual both to
the primal equation on which the coupled force is being applied and to a Lagrange
Multiplier (LM) equation when an LM is present for enforcing non-negative
concentrations and we are trying to remove the saddle point due to no
on-diagonal dependence in the LM equation. See [LMKernel.md] for more details.

!syntax parameters /Kernels/CoupledForceLM

!syntax inputs /Kernels/CoupledForceLM

!syntax children /Kernels/CoupledForceLM
