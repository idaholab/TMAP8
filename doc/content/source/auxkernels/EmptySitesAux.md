# EmptySitesAux

!syntax description /AuxKernels/EmptySitesAux

## Overview

This class calculates the concentration of empty trapping sites, $C_t^e$, as

\begin{equation}
C_t^e = C_{t,0} N - \sum_{s}{C_{t,s}}\ ,
\end{equation}
where $C_{t,0}$ is the fraction of host sites that can contribute to trapping (provided as a constant or a [Function](Functions/index.md)), $N$ is the atomic number density of the host material (atoms/volume), and $C_{t,s}$ is the concentration of trapped species of type $s$.

This calculation is similar to what is described in [TrappingNodalKernel](TrappingNodalKernel.md).

!syntax parameters /AuxKernels/EmptySitesAux

!syntax inputs /AuxKernels/EmptySitesAux

!syntax children /AuxKernels/EmptySitesAux
