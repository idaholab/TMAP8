# ver-1ic

# Species Equilibration Model in Surfdep Conditions with Low Barrier Energy

## General Case Description

This verification problem is taken from [!cite](ambrosek2008verification) and builds on [ver-1ia](ver-1ia.md). The configuration and modeling parameters are similar to [ver-1ia](ver-1ia.md), except that, in the current case, the reaction is in surfdep condition. The case is simulated in [/ver-1ic.i].

The problem considers the reaction between two isotopic species, A$_2$ and B$_2$, on a surface in surfdep condition. The reaction between AB, A$_2$, and B$_2$ is the same as in [ver-1ia](ver-1ia.md). Therefore, the partial pressure of AB in equilibrium is a constant value depends on the initial partial pressures of A$_2$ and B$_2$:

\begin{equation}
\label{eq:p_AB_equilibrium}
P_{AB}^{eq} = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0}.
\end{equation}

Under surfdep condition, there are again no assumptions about equilibrium except in the steady state. Then, the surface concentration of molecules is directly proportional to the gas over-pressure. We define the deposition, release, and dissociation coefficients on the surface by

\begin{equation}
\label{eq:k_d_equation}
\hat{K_d} = \frac{1}{\sqrt{2 \pi M k_b T}} \exp \left( - \frac{E_x}{k_b T} \right),
\end{equation}

\begin{equation}
\label{eq:k_r_equation}
\hat{K_r} = \nu_0 \exp \left( \frac{E_c - E_x}{k_b T} \right),
\end{equation}

and

\begin{equation}
\label{eq:k_b_equation}
\hat{K_b} = \nu_0 \exp \left( - \frac{E_b}{k_b T} \right),
\end{equation}

where $M$ is the mass of species molecules, $\nu_0$ is the Debye frequency, $E_x$ is the adsorption barrier energy, $E_c$ is the surface binding energy, and $E_b$ is the dissociation activation energy.

At steady-state, the flux to the surface will be balanced by the flux from the surface, and surface concentration will be related to the gas over-pressure by

\begin{equation}
\label{eq:Harry_equation}
C_m = P_m \frac{\hat{K_d}}{\hat{K_r}},
\end{equation}

where $C_m$ and $P_m$ are the surface concentration and enclosure pressure of gas $m$, respectively.

The conversion of A$_2$ and B$_2$ molecules to AB molecules requires several steps. First, homonuclear molecules in the gas must get to the surface. Next, they must dissociate. Then the individual surface atoms must migrate to sites where they encounter their conjugates. Here we assume there is a probability of unity of their combination once they find each other. Finally, the AB molecule must leave the surface and return to the gas. These behaviors are described as

\begin{equation}
\label{eq:surface_equation_1}
C_{AB} (\hat{K_r} + \hat{K_b}) = P_{AB} \hat{K_d} + C_A C_B (2 D_s \lambda ),
\end{equation}

\begin{equation}
\label{eq:surface_equation_2}
C_{A_2} (\hat{K_r} + \hat{K_b}) = P_{A_2} \hat{K_d} + C^2_A (D_s \lambda ),
\end{equation}

\begin{equation}
\label{eq:surface_equation_3}
C_{B_2} (\hat{K_r} + \hat{K_b}) = P_{B_2} \hat{K_d} + C^2_B (D_s \lambda ),
\end{equation}

\begin{equation}
\label{eq:surface_equation_4}
C_A (C_A + C_B) 2 D_s \lambda = (C_{AB} + 2 C_{A_2}) \hat{K_b},
\end{equation}

\begin{equation}
\label{eq:surface_equation_5}
C_B (C_A + C_B) 2 D_s \lambda = (C_{AB} + 2 C_{B_2}) \hat{K_b},
\end{equation}

where $D_s$ is the surface diffusivity or mobility of the atomic species and $\lambda$ is the lattice constant.

For the recombination step and dissociation step, we solve

\begin{equation}
\label{eq:equation_p_ab}
\frac{d P_{AB}}{dt} = \frac{S k_b T \hat{K_d} \hat{K_b}}{V (\hat{K_r} + \hat{K_b})} \left( C_A C_B 2 D_s \lambda \frac{\hat{K_r}}{\hat{K_d} \hat{K_b}} - P_{AB} \right),
\end{equation}

where $t$ is the time, $S$ is the surface area, $k_b$ is the Boltzmann’s constant, $T$ is the temperature, $V$ is the volume in the enclosure. The production of A$_2$ and B$_2$ in equilibration conditions is given by

\begin{equation}
\label{eq:equal_c_a_c_b}
C_A C_B = \frac{\hat{K_b} \hat{K_d}}{2 D_s \lambda \hat{K_r}} P_{AB}^{eq}.
\end{equation}

This case uses equal starting pressures of $1 \times 10^{4}$ Pa of A$_2$ and B$_2$ and no AB. $E_x$, $E_c$, and $E_b$ are specified to be 0.05, -0.01, and 0.0 eV, respectively, $\nu_0$ is $8.4 \times 10^{12}$ m/s, the temperature is 1000 K, the surface area for reaction is 0.05 m $\times$ 0.05 m square, and the enclosure volume is 1 m$^3$.


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

A comparison of the concentration of AB as a function of time is plotted in [ver-1ic_comparison_pressure]. The TMAP8 calculations are found to be in good agreement with the analytical solution, with a root mean square percentage error (RMSPE) of RMSPE =  0.93%. The concentrations of A$_2$ and B$_2$ as a function of time are also plotted in [ver-1ic_comparison_pressure].

!media comparison_ver-1ic.py
       image_name=ver-1ic_comparison_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1ic_comparison_pressure
       caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the solution in surfdep condition with low barrier energy [!citep](ambrosek2008verification).

## Input files

!style halign=left
The input file for this case can be found at [/ver-1ic.i], which is also used as tests in TMAP8 at [/ver-1ic/tests].

!bibtex bibliography
