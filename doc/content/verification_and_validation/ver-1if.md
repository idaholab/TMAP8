# ver-1if

# Species Equilibration Problem in Lawdep Condition with Unequal Starting Pressures

## General Case Description

This verification problem is taken from [!cite](ambrosek2008verification) and builds on Equilibration Problem verified in [ver-1ia](ver-1ia.md), [ver-1ib](ver-1ib.md), [ver-1ic](ver-1ic.md), [ver-1id](ver-1id.md), and [ver-1ie](ver-1ie.md). The configuration and modeling parameters are the same as in [ver-1ie](ver-1ie.md), except that, in the current case, the starting pressures for A$_2$ and B$_2$ are not equal. The case is simulated in [/ver-1ie.i], but the starting pressures of A$_2$ and B$_2$ are $1e4$ Pa and $1e5$ Pa, respectively, and there is no AB initially present.

## Analytical solution

Similar with [ver-1ie](ver-1ie.md), the governing equation becomes

\begin{equation}
\label{eq:equation_p_ab_final}
\frac{d P_{AB}}{dt} = \frac{S k_b T K_d}{V} (2 \sqrt{P^0_{A_2} - \frac{P_{AB}}{2}} \sqrt{P^0_{B_2} - \frac{P_{AB}}{2}} - P_{AB}).
\end{equation}

This is a non-linear function, the analytical solution is hard to calculate. [!cite](ambrosek2008verification) uses the solution from [ver-1ia](ver-1ia.md) with a different saturation time constant to compare with the numerical solution. The equation is defined by

\begin{equation}
\label{eq:analytical_solution}
P_{AB}  = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0} (1 - \exp(- \frac{t}{\tau})),
\end{equation}
where $\tau$ is the saturation time constant. The value of $\tau$ is selected as 0.123 because the shape of [eq:analytical_solution] is close to the shape of numerical solution.

## Results

A comparison of the concentration of AB as a function of time is plotted in [ver-1if_comparison_pressure]. The TMAP8 calculations are found to be in reasonable agreement with the solution from TMAP7, with a root mean square percentage error (RMSPE) of RMSPE =  13.56%. It makes sense for us because the solution from TMAP7 is not the real analytical solution. The concentration of A$_2$ and B$_2$ as a function of time are also plotted in [ver-1if_comparison_pressure].

!media comparison_ver-1if.py
       image_name=ver-1if_comparison_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1if_comparison_pressure
       caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the solution in lawdep condition when A$_2$ and B$_2$ have unequal pressures [!cite](ambrosek2008verification).

## Input files

!style halign=left
The input file for this case can be obtained by updating the initial pressure for B$_2$ in [/ver-1ie.i], which is the approach used to create tests in TMAP8 at [/ver-1if/tests].

!bibtex bibliography
