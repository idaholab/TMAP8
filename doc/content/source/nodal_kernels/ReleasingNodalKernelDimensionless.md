# ReleasingNodalKernelDimensionless

!syntax description /NodalKernels/ReleasingNodalKernelDimensionless

## Overview

`ReleasingNodalKernelDimensionless` is the dimensionless analogue of
[ReleasingNodalKernel](ReleasingNodalKernel.md). It applies the release source term
to a dimensionless trapped-species variable, $\hat{C}_t = C_t / C_{t,\mathrm{ref}}$
with $C_t$ the trapped-species variable and $C_{t,\mathrm{ref}}$ the characteristic trapped-species scale in the same unit as $C_t$.

This object implements the residual

\begin{equation}
\hat{k}_r \exp(-\epsilon / T) \hat{C}_t
\end{equation}

where $\hat{C}_t$ is the dimensionless trapped-species concentration, $\hat{k}_r$ is
the dimensionless release rate, $\epsilon$ is the detrapping activation energy in
Kelvin, and $T$ is the temperature in Kelvin.

Compared with [ReleasingNodalKernel](ReleasingNodalKernel.md), the form is the same
except that the trapped concentration variable is nondimensionalized and the rate
coefficient is provided directly as a dimensionless quantity.

!syntax parameters /NodalKernels/ReleasingNodalKernelDimensionless

!syntax inputs /NodalKernels/ReleasingNodalKernelDimensionless

!syntax children /NodalKernels/ReleasingNodalKernelDimensionless
