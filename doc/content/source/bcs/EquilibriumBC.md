# EquilibriumBC

!syntax description /BCs/EquilibriumBC

## Overview

This class strongly enforces the Dirichlet boundary condition

\begin{equation}
C_i = KP_i^p
\end{equation}

where $C_i$, represented by the `variable` parameter, is the concentration of
specie $i$ in a diffusion structure, $P_i$ is the partial pressure of specie
$i$ in the gas phase in the enclosure adjacent to the diffusion structure, $K$
is a solubility constant, and $p$ is the exponent of the solution law.

!syntax parameters /BCs/EquilibriumBC

!syntax inputs /BCs/EquilibriumBC

!syntax children /BCs/EquilibriumBC
