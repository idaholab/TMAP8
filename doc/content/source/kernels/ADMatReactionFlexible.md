# ADMatReactionFlexible

!syntax description /Kernels/ADMatReactionFlexible

## Overview

This class adds to the residual a contribution from

\begin{equation}
\frac{dc_0}{dt} = \alpha K \prod_{i}{c_i}
\end{equation}

where $c_i$ are species concentrations provided as nonlinear or coupled variables, $\alpha$ is a constant coefficient, and $K$ is a material property.

!syntax parameters /Kernels/ADMatReactionFlexible

!syntax inputs /Kernels/ADMatReactionFlexible

!syntax children /Kernels/ADMatReactionFlexible
