# ver-1ia

# A Species Equilibration Model in Ratedep Conditions with Equal Starting Pressures

## General Case Description

<!-- All necessary equations -->
This verification problem is taken from [!cite](ambrosek2008verification). When two species can react on a surface to form a third, it is possible to predict the rate at which equilibration between the species will occur. For example, consider the reaction between two isotopic species:

\begin{equation}
\label{eq:reaction}
\frac{1}{2} A_2 + \frac{1}{2} B_2 \rightleftharpoons AB.
\end{equation}

Under ratedep conditions, the conversion rate at the surface is higher than the rate in enclosure. The pressure of AB is described by

\begin{equation}
\label{eq:equation_p_ab}
\frac{d P_{AB}}{dt} = \frac{S k T}{V} (2 K_r C_A C_B - K_d P_{AB}),
\end{equation}
where $P_{AB}$ is the pressure of AB, $t$ is the time, $S$ is the surface area, $k$ is the Boltzmann’s constant, $T$ is the temperature, $V$ is the volume in the enclosure, $K_r$ and $K_d$ are the recombination and dissociation rate, $C_A$ and $C_B$ are the concentration of $A_2$ and $B_2$ on the reactive surface, respectively. If diffusion is small, the almost constant numbers of A and B atoms in the gas imply that $C_A$ and $C_B$ should have an almost constant value regardless of the isotopic species composition. The production of $C_A$ and $C_B$ in equilibration is given by

\begin{equation}
\label{eq:equal_c_a_c_b}
C_A C_B = \frac{K_d}{2 K_r} P_{AB}^{eq},
\end{equation}
where $P_{AB}^{eq}$ is the pressure of AB in equilibration, is defined as

\begin{equation}
\label{eq:equal_p_ab}
P_{AB}^{eq} = 2 \frac{P^0_{A_2} P^0_{B_2}}{(P^0_{A_2} + P^0_{B_2})},
\end{equation}
where $P^0_{A_2}$ and $P^0_{B_2}$ are the initial partial pressure of $A_2$ and $B_2$.

<!-- Detail parameters -->
This case uses equal starting pressures of $1e4$ Pa of $H_2$ and $D_2$ and no $HD$. $K_d$ was specified to be $1.858e24/\sqrt{T}$. $K_r$ was specified to be $5.88e-26$. Temperature was 1000 K, the surface area for reaction was a 5 cm $\times$ 5 cm square, and the enclosure volume was 1 m$^3$.


## Analytical solution

<!-- introduce the analytical equation and explain -->
[!cite](ambrosek2008verification) provides the analytical equation for the partial pressure of AB as

\begin{equation}
\label{eq:analytical_solution}
P_{AB}  = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0} (1 - exp(-\frac{S K_d k T}{V} t)) .
\end{equation}

## Results

<!-- introduce the numerical result and compare the figures between analytical and results -->

A comparison of the concentration of AB as a function of time is plotted in [ver-1ia_comparison_pressure]. The TMAP8 calculations are found to be in good agreement with the analytical solution, with root mean square percentage errors (RMSPE) of RMSPE = 0.13 %. The concentration of $H_2$ and $D_2$ as a function of time are also plotted in [ver-1ia_comparison_pressure].

!media comparison_ver-1ia.py
       image_name=ver-1ia_comparison_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1ia_comparison_pressure
       caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the solution when A and B have equal pressures [!cite](ambrosek2008verification).

Another simulation ignored the equilibration assumption in [eq:equal_c_a_c_b] is plotted in [ver-1ia_comparison_pressure_nonequal]. The concentration of A and B from Sieverts' law on the surface is defined as

\begin{equation}
\label{eq:equal_c_a}
C_A = K_s \sqrt{P_{A_2}},
\end{equation}

and

\begin{equation}
\label{eq:equal_c_b}
C_B = K_s \sqrt{P_{B_2}},
\end{equation}
where $K_s$ is the Sieverts’ solubility. The reaction simulation on surface without equilibration assumption is faster than the one in [ver-1ia_comparison_pressure]. Although the simulation cannot represent the current case, it still presents the flexibility and capability of TMAP8.

!media comparison_ver-1ia.py
       image_name=ver-1ia_comparison_pressure_nonequal.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1ia_comparison_pressure_nonequal
       caption=The concentration of AB as a function of time calculated through TMAP8 without the equilibration assumption when A and B have equal pressures [!cite](ambrosek2008verification).

## Input files

!style halign=left
The input file for these cases can be found at [/ver-1ia.i], which is also used as tests in TMAP8 at [/ver-1ia/tests].

!bibtex bibliography
