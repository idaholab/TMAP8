# ADMatCoupledDefectAnnihilation

!syntax description /Kernels/ADMatCoupledDefectAnnihilation

## Overview

This class adds to the residual a contribution from

\begin{equation}
\frac{dc}{dt} = \alpha K*(c_0-c)*v
\end{equation}

where $c$ and $v$ are species concentrations provided as nonlinear or coupled variables, $\alpha$ is a constant coefficient, and $K$ is the annihilation rate defined as a material property, and $c_0$ is the equilibrium oncentration of the species described by $c$. $\alpha$ can be used to scale up the annihilation rate, for sensitivity analysis for example.

!syntax parameters /Kernels/ADMatCoupledDefectAnnihilation

!syntax inputs /Kernels/ADMatCoupledDefectAnnihilation

!syntax children /Kernels/ADMatCoupledDefectAnnihilation
