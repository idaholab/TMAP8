# EnclosureSinkScalarKernel

!syntax description /ScalarKernels/EnclosureSinkScalarKernel

## Overview

This object implements the residual

\begin{equation}
\frac{\Gamma A}{V} \zeta
\end{equation}

where $\Gamma$ is the flux of the specie exiting the enclosure and entering the
structure, $A$ is the surface area of the structure contacting the enclosure,
$V$ is the enclosure volume, and $\zeta$ is a conversion factor from
concentration to pressure units. The units of the returned residual are
pressure/time.

!syntax parameters /ScalarKernels/EnclosureSinkScalarKernel

!syntax inputs /ScalarKernels/EnclosureSinkScalarKernel

!syntax children /ScalarKernels/EnclosureSinkScalarKernel
