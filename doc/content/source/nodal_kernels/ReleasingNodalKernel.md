# ReleasingNodalKernel

!syntax description /NodalKernels/ReleasingNodalKernel

## Overview

This object implements a residual of the form

\begin{equation}
\alpha_r C_t
\end{equation}

where $C_t$ is the concentration of trapped species, and where $\alpha_r$ is the releasing rate
coefficient, which may be a function of temperature as shown below

\begin{equation}
\alpha_r = \alpha_{r0} \exp(-\epsilon / T)
\end{equation}

where both $\epsilon$, the trap energy, and $T$ are expressed in Kelvin.

!syntax parameters /NodalKernels/ReleasingNodalKernel

!syntax inputs /NodalKernels/ReleasingNodalKernel

!syntax children /NodalKernels/ReleasingNodalKernel
