# ver-1g

# A Simple Chemical Reaction

This verification problem is taken from [!cite](longhurst1992verification). A simple time-dependent chemical reaction given by:

\begin{equation}
A + B \Rightarrow AB
\end{equation}

is modeled in a functional enclosure. The reaction rate, R, is positive if the species AB is being produced in the reaction and negative if it is being consumed. The forward rate coefficient, K, for the reaction has no spatial or time dependence. The reaction rate is:

\begin{equation}
R = K C_A C_B
\end{equation}

where $C_A$ and $C_B$ are the concentrations of A and B, respectively. The reaction rate in terms of the concentrations of the reactants and product is given as:

\begin{equation}
R = -\frac{d[C_A]}{dt} = -\frac{d[C_B]}{dt} = \frac{d[C_{AB}]}{dt} = K C_A C_B
\end{equation}

where $C_{AB}$ is the concentration of species AB. The analytical solution for the concentration of species AB as a function of time ($t$) is given as:

\begin{equation}
C_{AB} = C_{B_o} \frac{1 - exp{[K t (C_{B_o} - C_{A_o})]}}{1 - \frac{C_{B_o}}{C_{A_o}}exp{[K t (C_{B_o} - C_{A_o})]}}
\label{eq:conc_AB}
\end{equation}

where $C_{A_o}$ and $C_{B_o}$ are the initial concentrations of A and B, respectively. For the special case when $C_{A_o}$ and $C_{B_o}$ are equal, [eq:conc_AB] becomes:
\begin{equation}
C_{AB} = C_{A_o} - \frac{1}{\frac{1}{C_{A_o}} + Kt}
\end{equation}

For this verification exercise, two cases were considered: (a) the initial concentrations of A and B are equal and (b) the initial concentrations of A and B are different.

For case A, the initial concentrations of A and B were 2.43 x 10$^{-4}$ atoms / $\mu$m$^3$ (equivalent to 1 $\mu$Pa pressure assuming ideal gas law), and the reaction rate (K) is 4.14 x 10$^3$ $\mu$m$^3$ / atom$\cdot$s. For case B, the initial concentration of A was same as in case (a) while the initial concentration of B is 1.215 x 10$^{-4}$ atoms / $\mu$m$^3$.

A comparison of the concentration of AB as a function of time is plotted in [ver-1g_comparison_equal_conc] and [ver-1g_comparison_diff_conc] for the case A and case B, respectively. The TMAP8 calculations are found to be in good agreement with the analytical solution.

!media figures/ver-1g_comparison_equal_conc.png
    style=width:50%;margin-bottom:2%
    id=ver-1g_comparison_equal_conc
    caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the case when A and B have equal concentrations.

!media figures/ver-1g_comparison_diff_conc.png
    style=width:50%;margin-bottom:2%
    id=ver-1g_comparison_diff_conc
    caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the case when A and B have different concentrations.

!bibtex bibliography
