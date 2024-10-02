# ver-1ie

# Species Equilibration Problem in Lawdep Condition with Equal Starting Pressures

## General Case Description

<!-- All necessary equations -->
This verification problem is taken from [!cite](ambrosek2008verification) and builds on Equilibration Problem verified in [ver-1ia](ver-1ia.md), [ver-1ib](ver-1ib.md), [ver-1ic](ver-1ic.md), [ver-1id](ver-1id.md). The configuration and modeling parameters are the same as in [ver-1ia](ver-1ia.md), except that, in the current case, the reaction is in lawdep condition. The case is simulated in [/ver-1ie.i].

The problem considers the reaction between two isotopic species, $A_2$ and $B_2$, on a surface in lawdep condition. The reaction is described as

\begin{equation}
\label{eq:reaction}
\frac{1}{2} A_2 + \frac{1}{2} B_2 \rightleftharpoons AB,
\end{equation}

and the partial pressure of $A_2$, $B_2$, and $AB$ in equilibrium of the reaction is defined by

\begin{equation}
\label{eq:reaction_equilibrium_pressure}
\frac{P_{AB}}{\sqrt{P_{A_2}} \sqrt{P_{B_2}}} = K_{eq},
\end{equation}

where $P_i$ is the partial pressure of corresponding gas $i$, $K_{eq}$ is the equilibrium constant, and $K_{eq} = 2$ in this isotope reaction. Therefore, the partial pressure of $AB$ in equilibrium is a constant value depends on initial partial pressure of $A_2$ and $B_2$:

\begin{equation}
\label{eq:p_AB_equilibrium}
P_{AB}^{eq} = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0}.
\end{equation}

Under lawdep condition, we solve

\begin{equation}
\label{eq:equation_p_ab}
\frac{d P_{AB}}{dt} = \frac{S k T}{V} (2 K_r C_A C_B - K_d P_{AB}),
\end{equation}

where $t$ is the time, $S$ is the surface area, $k$ is the Boltzmann’s constant, $T$ is the temperature, $V$ is the volume in the enclosure, $K_r$ and $K_d$ are the recombination and dissociation coefficients, $C_A$ and $C_B$ are the concentration of $A_2$ and $B_2$ on the reactive surface, respectively. In lawdep diffusion boundary condition, the concentration of $A_2$ and $B_2$ are always fixed relative to the partial pressures in the gas over the surface. When heteronuclear species formation is involved, TMAP8 uses logic similar to that used in the ratedep and surfdep condition for the arrival rate of gas atoms to the surface. However, there are no barriers to adsorption or release, and conversion is assumed to take place instantaneously. Any gas that does not diffuse away is immediately released from the surface. Therefore, the concentration of $C_A$ and $C_B$ from Sieverts' law are given by

\begin{equation}
\label{eq:p_ca_relation}
C_A = K_s \sqrt{P_{A_2}},
\end{equation}

and

\begin{equation}
\label{eq:p_cb_relation}
C_B = K_s \sqrt{P_{B_2}},
\end{equation}

where $K_s$ is Sieverts’ solubility. Due to in the isotopic reaction, $K_s$ is the same for each homonuclear species. The relationship between $K_s$, $K_r$, and $K_d$ is given by

\begin{equation}
\label{eq:k_relation}
K_d = {K_s}^2 K_r.
\end{equation}

<!-- Detail parameters -->
This case uses equal starting pressures of $1e4$ Pa of $H_2$ and $D_2$ and no $HD$. $K_d$ was specified to be $1.858e24/\sqrt{T}$ atom/m$^2$/s/pa. $K_s$ was specified to be $1e24$ atom/m$^3$/Pa$^{0.5}$. Temperature was 1000 K, the surface area for reaction was a 5 cm $\times$ 5 cm square, and the enclosure volume was 1 m$^3$.


## Analytical solution

<!-- introduce the analytical equation and explain -->

After combining [eq:p_ca_relation] and [eq:p_cb_relation], [eq:equation_p_ab] becomes

\begin{equation}
\label{eq:equation_p_ab_final}
\frac{d P_{AB}}{dt} = \frac{S k T K_d}{V} (2 \sqrt{P^0_{A_2} - \frac{P_{AB}}{2}} \sqrt{P^0_{B_2} - \frac{P_{AB}}{2}} - P_{AB}).
\end{equation}

This is a non-linear function, but it has a special solution when $P^0_{A_2} = P^0_{B_2}$ in current case. Thus, the analytical solution for the partial pressure of $AB$ is given by

\begin{equation}
\label{eq:analytical_solution}
P_{AB}  = P_{A_2}^0 (1 - \exp \left( -\frac{ 2 S K_d k T}{V} t \right)).
\end{equation}

## Results

<!-- introduce the numerical result and compare the figures between analytical and results -->

A comparison of the concentration of $AB$ as a function of time is plotted in [ver-1ie_comparison_pressure]. The TMAP8 calculations are found to be in good agreement with the analytical solution, with root mean square percentage errors (RMSPE) of RMSPE =  0.36%. The concentration of $H_2$ and $D_2$ as a function of time are also plotted in [ver-1ie_comparison_pressure].

!media comparison_ver-1ie.py
       image_name=ver-1ie_comparison_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1ie_comparison_pressure
       caption=Comparison of concentration of $AB$ as a function of time calculated through TMAP8 and analytically for the solution in lawdep condition when $A_2$ and $B_2$ have equal pressures [!cite](ambrosek2008verification).

## Input files

!style halign=left
The input file for these cases can be found at [/ver-1ie.i], which is also used as tests in TMAP8 at [/ver-1ie/tests].

!bibtex bibliography
