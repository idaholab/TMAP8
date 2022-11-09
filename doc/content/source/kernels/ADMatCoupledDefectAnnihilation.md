# ADMatCoupledDefectAnnihilation

!syntax description /Kernels/ADMatCoupledDefectAnnihilation

## Overview

This kernel object adds to the residual a contribution from

\begin{equation}
\frac{dc}{dt} = \alpha K*(c_0-c)*v
\end{equation}

where $c$ and $v$ are species concentrations provided as nonlinear or coupled variables, $\alpha$ is a constant coefficient, $K$ is the annihilation rate defined as a material property, and $c_0$ is the equilibrium concentration of the species described by $c$. $\alpha$ can be used to scale up the annihilation rate, which could be used during a sensitivity analysis.

This kernel is particularly suited to model species trapping. For example, $c$ could describe the concentration of trapped atoms, $c_0$ the number of trapping sites, $v$ the concentration of free atoms, and $\alpha K$ could represent the trapping rate.

!syntax parameters /Kernels/ADMatCoupledDefectAnnihilation

!syntax inputs /Kernels/ADMatCoupledDefectAnnihilation

!syntax children /Kernels/ADMatCoupledDefectAnnihilation
