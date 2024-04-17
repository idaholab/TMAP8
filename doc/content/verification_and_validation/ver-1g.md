# ver-1g

# A Simple Forward Chemical Reaction

This verification problem is taken from [!cite](longhurst1992verification,ambrosek2008verification). A simple time-dependent chemical reaction given by:

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

For this verification exercise, three cases were considered: (a) the initial concentrations of A and B are equal, (b) the initial concentrations of A and B are different and use the TMAP4 verification case values, and (c) the initial concentrations of A and B are different and use the TMAP7 verification case values. The equal concentration case is the same in TMAP4 and TMAP7, and is used for verification of TMAP8 here. While both TMAP4 and TMAP7 verification cases ((b) and (c) respectively) have the same analytical solution, the different initial conditions produce different $C_{AB}$ values over time, and we replicate both results here.

For case (a), the initial pressures of A and B were 1 $\mu$Pa, and the reaction rate (K) is 4.14 x 10$^3$ $\mu$m$^3$ / atom$\cdot$s. For case (b) the initial pressure of A was same as in case (a) while the initial pressure of B is 0.1 $\mu$Pa as per TMAP4. For case (c) the initial pressure of A was same as in case (a) while the initial pressure of B is 0.5 $\mu$Pa. In all cases, the initial pressures of A and B are first converted to their initial concentrations $C_{A_o}$ and $C_{B_o}$ using the ideal gas law to be used in the TMAP8 simulations and analytical solutions. The initial concentration $C_{i_0}$ of component $i$ is

\begin{equation}
C_{i_0} = 10^{-18} \frac{P_{i_0} N_a}{R T},
\end{equation}

where $P_{i_0}$ is the initial pressure, $N_a$ is Avogardro's constant, $R$ is the gas constant (from  [PhysicalConstants](source/utils/PhysicalConstants.md)), and $T$ = 298.15 K (25$\deg$ C) is the temperature. The factor $10^{-18}$ converts the concentration from atoms/m$^3$ to atoms/$\mu$m$^3$.

A comparison of the concentration of AB as a function of time is plotted in [ver-1g_comparison_equal_conc] for case (a), and [ver-1g_comparison_diff_conc] for the cases (b) and (c), respectively. The TMAP8 calculations are found to be in good agreement with the analytical solution.

!media figures/ver-1g_comparison_equal_conc.png
    style=width:50%;margin-bottom:2%
    id=ver-1g_comparison_equal_conc
    caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the case when A and B have equal concentrations.

!media figures/ver-1g_comparison_diff_conc.png
    style=width:50%;margin-bottom:2%
    id=ver-1g_comparison_diff_conc
    caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the case when A and B have different concentrations. The plot shows comparisons for the initial conditions specified in both TMAP4 (case (b)) and TMAP7 (case (c)).

!bibtex bibliography
