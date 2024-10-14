# ver-1id

# Species Equilibration Model in Surfdep Conditions with High Barrier Energy

## General Case Description

This verification problem is taken from [!cite](ambrosek2008verification) and builds on [ver-1ic](ver-1ic.md). The configuration and modeling parameters are the same as in [ver-1ic](ver-1ic.md), except that, in the current case, the reaction has a high barrier energy. The case is simulated in [/ver-1ic.i], but $E_x$ is set to 0.20 eV instead of 0.05 eV.

## Analytical solution

[!cite](ambrosek2008verification) provides the analytical equation for the partial pressure of AB as

\begin{equation}
\label{eq:analytical_solution}
P_{AB}  = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0} \left(1 - \exp \left(- \frac{t}{\tau}\right)\right),
\end{equation}

where $\tau$ is defined as

\begin{equation}
\label{eq:tau}
\tau = \frac{V (\hat{K_r} + \hat{K_b})}{S k_b T \hat{K_d} \hat{K_b}}.
\end{equation}

## Results

A comparison of the concentration of AB as a function of time is plotted in [ver-1id_comparison_pressure]. The TMAP8 calculations are found to be in good agreement with the analytical solution, with a root mean square percentage error (RMSPE) of RMSPE =  0.19%. The concentrations of A$_2$ and B$_2$ as a function of time are also plotted in [ver-1id_comparison_pressure].

!media comparison_ver-1id.py
       image_name=ver-1id_comparison_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1id_comparison_pressure
       caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the solution in surfdep condition with high barrier energy [!citep](ambrosek2008verification).

## Input files

!style halign=left
The input file for this case can be obtained by updating the adsorption barrier energy $E_x$ in [/ver-1ic.i], which is the approach used to create tests in TMAP8 at [/ver-1id/tests].

!bibtex bibliography
