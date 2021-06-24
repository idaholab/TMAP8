# TimeDerivativeLM

!syntax description /Kernels/TimeDerivativeLM

## Overview

This object is equivalent to [TimeDerivative.md] except it adds its residual both to
the primal equation containing the time derivative and to a Lagrange
Multiplier (LM) equation when an LM is present for enforcing non-negative
concentrations and we are trying to remove the saddle point due to no
on-diagonal dependence in the LM equation. See [LMKernel.md] for more details.

!syntax parameters /Kernels/TimeDerivativeLM

!syntax inputs /Kernels/TimeDerivativeLM

!syntax children /Kernels/TimeDerivativeLM
