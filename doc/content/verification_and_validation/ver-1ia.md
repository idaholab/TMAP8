# ver-1ia

# Species Equilibration Problem in Ratedep Conditions with Equal Starting Pressures

## General Case Description

This verification problem is taken from [!cite](ambrosek2008verification). When two species can react on a surface to form a third, it is possible to predict the rate at which equilibration between the species will occur. For example, the reaction between two isotopic species, A$_2$ and B$_2$, is described as

\begin{equation}
\label{eq:reaction}
\frac{1}{2} A_2 + \frac{1}{2} B_2 \rightleftharpoons AB,
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

Under ratedep condition, the conversion rate at the surface is higher than the rate in enclosure. We solve

\begin{equation}
\label{eq:equation_p_ab}
\frac{d P_{AB}}{dt} = \frac{S k T}{V} (2 K_r C_A C_B - K_d P_{AB}),
\end{equation}

where $t$ is the time, $S$ is the surface area, $k$ is the Boltzmann’s constant, $T$ is the temperature, $V$ is the volume in the enclosure, $K_r$ and $K_d$ are the recombination and dissociation coefficients, $C_A$ and $C_B$ are the concentration of A$_2$ and B$_2$ on the reactive surface, respectively. If diffusion is small, the almost constant numbers of A and B atoms in the gas imply that $C_A$ and $C_B$ should have an almost constant value regardless of the isotopic species composition. The production of $C_A$ and $C_B$ in equilibration is given by

\begin{equation}
\label{eq:equal_c_a_c_b}
C_A C_B = \frac{K_d}{2 K_r} P_{AB}^{eq}.
\end{equation}

This case uses equal starting pressures of $1e4$ Pa of H$_2$ and D$_2$ and no HD. $K_d$ was specified to be $1.858e24/\sqrt{T}$ atom/m$^2$/s/pa. $K_r$ was specified to be $5.88e-26$ m$^4$/atom/s. Temperature was 1000 K, the surface area for reaction was a 5 cm $\times$ 5 cm square, and the enclosure volume was 1 m$^3$.


## Analytical solution

[!cite](ambrosek2008verification) provides the analytical equation for the partial pressure of AB as

\begin{equation}
\label{eq:analytical_solution}
P_{AB}  = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0} (1 - \ \left( -\frac{S K_d k T}{V} t \right)).
\end{equation}

## Results

A comparison of the concentration of AB as a function of time is plotted in [ver-1ia_comparison_pressure]. The TMAP8 calculations are found to be in good agreement with the analytical solution, with root mean square percentage errors (RMSPE) of RMSPE = 0.13 %. The concentration of H$_2$ and D$_2$ as a function of time are also plotted in [ver-1ia_comparison_pressure].

!media comparison_ver-1ia.py
       image_name=ver-1ia_comparison_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1ia_comparison_pressure
       caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the solution in ratedep condition when A and B have equal pressures [!cite](ambrosek2008verification).

## Input files

!style halign=left
The input file for these cases can be found at [/ver-1ia.i], which is also used as tests in TMAP8 at [/ver-1ia/tests].

!bibtex bibliography
