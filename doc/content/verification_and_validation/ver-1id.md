# ver-1id

# Species Equilibration Model in Surfdep Conditions with High Barrier Energy

## General Case Description

This verification problem is taken from [!cite](ambrosek2008verification) and builds on Equilibration Problem verified in [ver-1ia](ver-1ia.md), [ver-1ib](ver-1ib.md), and [ver-1ic](ver-1ic.md). The configuration and modeling parameters are the same as in [ver-1ic](ver-1ic.md), except that, in the current case, the reaction has a high barrier energy. The case is simulated in [/ver-1id.i].

The problem considers the reaction between two isotopic species, A$_2$ and B$_2$, on a surface in surfdep condition. The reaction is described as

\begin{equation}
\label{eq:reaction}
\frac{1}{2} A_2 + \frac{1}{2} B_2 \rightleftharpoons AB.
\end{equation}

and the partial pressure of A$_2$, B$_2$, and AB in equilibrium of the reaction is defined by

\begin{equation}
\label{eq:reaction_equilibrium_pressure}
\frac{P_{AB}}{\sqrt{P_{A_2}} \sqrt{P_{B_2}}} = K_{eq},
\end{equation}

where $P_i$ is the partial pressure of corresponding gas $i$, $K_{eq}$ is the equilibrium constant, and $K_{eq} = 2$ in this isotope reaction. Therefore, the partial pressure of AB in equilibrium is a constant value depends on initial partial pressure of A$_2$ and B$_2$:

\begin{equation}
\label{eq:p_AB_equilibrium}
P_{AB}^{eq} = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0}.
\end{equation}

Under surfdep condition, the conversion of A$_2$ and B$_2$ molecules to AB molecules requires several steps. First, homonuclear molecules in the gas must get to the surface. Next, they must dissociate. Then the individual surface atoms must migrate to sites where they encounter their conjugates. Here we assume there is a probability of unity of their combination once they find each other. Finally, the AB molecule must leave the surface and return to the gas. We solve

\begin{equation}
\label{eq:equation_p_ab}
\frac{d P_{AB}}{dt} = \frac{S k T \hat{K_d} \hat{K_b}}{V (\hat{K_r} + \hat{K_b})} ( C_A C_B 2 D_s \lambda \frac{\hat{K_r}}{\hat{K_d} \hat{K_b}} - P_{AB}),
\end{equation}

where $t$ is the time, $S$ is the surface area, $k$ is the Boltzmann’s constant, $T$ is the temperature, $V$ is the volume in the enclosure, $D_s$ is the surface diffusivity or mobility of the atomic species, and $\lambda$ is the lattice constant, $C_A$ and $C_B$ are the concentration of A$_2$ and B$_2$ on the reactive surface, respectively, $\hat{K_d}$, $\hat{K_r}$, and $\hat{K_b}$ are the release, deposition, and dissociation coefficients, respectively. The three coefficients is defined by

\begin{equation}
\label{eq:k_d_equation}
\hat{K_d} = \frac{1}{\sqrt{2 \pi M k T}} \exp \left( - \frac{E_x}{k T} \right),
\end{equation}

\begin{equation}
\label{eq:k_r_equation}
\hat{K_r} = \nu_0 \exp \left( \frac{E_c - E_x}{k T} \right),
\end{equation}

and

\begin{equation}
\label{eq:k_b_equation}
\hat{K_b} = \nu_0 \exp \left( - \frac{E_b}{k T} \right),
\end{equation}

where $M$ is the mass of species molecules, $\nu_0$ is the Debye frequency, $E_x$ is the adsorption barrier energy, $E_c$ is the surface binding energy, and $E_b$ is the dissociation activation energy. The production of $C_A$ and $C_B$ in equilibration is given by

\begin{equation}
\label{eq:equal_c_a_c_b}
C_A C_B = \frac{\hat{K_b} \hat{K_d}}{2 D_s \lambda \hat{K_r}} P_{AB}^{eq}.
\end{equation}

This case uses equal starting pressures of $1e4$ Pa of H$_2$ and D$_2$ and no HD. $E_x$, $E_c$, and $E_b$ were specified to be 0.20, -0.01, and 0.0 eV, respectively. $\nu_0$ was 8.4e12 m/s. Temperature was 1000 K, the surface area for reaction was a 5 cm $\times$ 5 cm square, and the enclosure volume was 1 m$^3$.

## Analytical solution

[!cite](ambrosek2008verification) provides the analytical equation for the partial pressure of AB as

\begin{equation}
\label{eq:analytical_solution}
P_{AB}  = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0} (1 - \exp(- \frac{t}{\tau})),
\end{equation}

where $\tau$ is defined by

\begin{equation}
\label{eq:tao}
\tau = \frac{V (\hat{K_r} + \hat{K_b})}{S k T \hat{K_d} \hat{K_b}}.
\end{equation}

## Results

A comparison of the concentration of AB as a function of time is plotted in [ver-1id_comparison_pressure]. The TMAP8 calculations are found to be in good agreement with the analytical solution, with root mean square percentage errors (RMSPE) of RMSPE =  0.19%. The concentration of H$_2$ and D$_2$ as a function of time are also plotted in [ver-1id_comparison_pressure].

!media comparison_ver-1id.py
       image_name=ver-1id_comparison_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1id_comparison_pressure
       caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the solution in surfdep condition with high barrier energy [!cite](ambrosek2008verification).

## Input files

!style halign=left
The input file for these cases can be found at [/ver-1id.i], which is also used as tests in TMAP8 at [/ver-1id/tests].

!bibtex bibliography
