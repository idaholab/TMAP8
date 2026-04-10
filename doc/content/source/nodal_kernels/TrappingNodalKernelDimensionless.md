# TrappingNodalKernelDimensionless

!syntax description /NodalKernels/TrappingNodalKernelDimensionless

## Overview

`TrappingNodalKernelDimensionless` is the dimensionless analogue of
[TrappingNodalKernel](TrappingNodalKernel.md). It applies the trapping source term
to a dimensionless trapped-species variable, $\hat{C}_t = C_t / C_{t,\mathrm{ref}}$
with $C_t$ the trapped-species variable and $C_{t,\mathrm{ref}}$ the characteristic trapped-species scale in the same unit as $C_t$.

This object implements the residual

\begin{equation}
\hat{k}_t \exp(-\epsilon / T)
\left(
\frac{N C_{t0} - C_{t,\mathrm{ref}} \hat{C}_t - \sum_j C_{t,\mathrm{ref},j} \hat{C}_{t,j}}
{C_{t,\mathrm{ref}}}
\right)
\hat{C}_m
\end{equation}

where $\hat{k}_t$ is the dimensionless trapping rate, $\epsilon$ is the trapping
activation energy in Kelvin, $T$ is the temperature in Kelvin, $N$ is the atomic
number density of the host material, $C_{t0}$ is the fraction of host sites that can
trap the species, $\hat{C}_t$ is the dimensionless concentration of this trapped
species, $\hat{C}_{t,j}$ are optional competing trapped-species variables, and
$\hat{C}_m$ is the coupled mobile concentration variable.

The implementation computes the available trapping sites in physical units,

\begin{equation}
N C_{t0} - C_{t,\mathrm{ref}} \hat{C}_t - \sum_j C_{t,\mathrm{ref},j} \hat{C}_{t,j},
\end{equation}

and then divides by $C_{t,\mathrm{ref}}$ so that the residual is written for the
dimensionless unknown $\hat{C}_t$. Unlike [TrappingNodalKernel](TrappingNodalKernel.md),
this object does not use the `trap_per_free` scaling factor that the dimensional
kernel uses to convert between trapped-species and mobile-species concentration
scales. Here, the conversion is handled explicitly through
`trap_concentration_reference` ($C_{t,\mathrm{ref}}$) and `other_trap_concentration_references` ($C_{t,\mathrm{ref},j}$), so the
residual is expected to remain $O(\hat{k}_t)$ when the variables are scaled with
appropriate reference values.

!syntax parameters /NodalKernels/TrappingNodalKernelDimensionless

!syntax inputs /NodalKernels/TrappingNodalKernelDimensionless

!syntax children /NodalKernels/TrappingNodalKernelDimensionless
