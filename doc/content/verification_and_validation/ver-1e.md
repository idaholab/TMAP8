# ver-1e

# Diffusion in a composite layer

## Test Description

This verification problem is taken from [!cite](longhurst1992verification, ambrosek2008verification). In this problem, a composite structure of PyC and SiC is modeled with a constant concentration boundary condition of the free surface of PyC and zero concentration boundary condition on the free surface of the SiC. The steady-state solution for the PyC is given as:

\begin{equation}
\label{eqn:steady_state_pyc}
    C = C_0 \left[1 + \frac{x}{l}  \left(\frac{a D_{PyC}}{a D_{PyC} + l D_{SiC}} - 1 \right) \right]
\end{equation}

while the concentration profile for the SiC layer is given as:

\begin{equation}
\label{eqn:steady_state_sic}
    C = C_0 \left(\frac{a+l-x}{l} \right) \left(\frac{a D_{PyC}}{a D_{PyC} + l D_{SiC}} \right)
\end{equation}

where

    $x$ = distance from free surface of PyC

    $a$ = thickness of the PyC layer (33 $\mu$m)

    $l$ = thickness of the SiC layer (63 $\mu$m in TMAP4 verification case, and 66 $\mu$m in TMAP7 verification case)

    $C_0$ = concentration at the PyC free surface (50.7079 moles/m$^3$)

    $D_{PyC}$ = diffusivity in PyC (1.274 $\times$ 10$^{-7}$ m$^2$/s)

    $D_{SiC}$ = diffusivity in SiC (2.622 $\times$ 10$^{-11}$ m$^2$/s)

The analytical transient solution for the concentration in the SiC side of the composite slab is given as:

\begin{equation}
\label{eqn:transient}
    C = C_0 \left\{ \frac{D_{PyC}(l-x)}{l D_{PyC} + a D_{SiC}} - 2 \sum_{n=1}^{\infty} \frac{\sin(a \lambda_n) \sin(k l \lambda_n) \sin \left[k (l-x) \lambda_n \right]}{\lambda_n \left[ a \sin^2(k l \lambda_n) + l \sin^2 (a \lambda_n) \right]} \exp(-D_{PyC} \lambda_n^2 t) \right\}
\end{equation}

where

$k$ = $\sqrt{\frac{D_{PyC}}{D_{SiC}}}$

and $\lambda_n$ are the roots of

\begin{equation}
\label{eqn:roots}
    \frac{1}{\tan(\lambda a)} + \frac{1}{k \; \tan(k l \lambda)} = 0.
\end{equation}

!alert warning title=Typo in [!cite](longhurst1992verification,ambrosek2008verification)
[eqn:roots] for the roots of $\lambda$ is different from the equations provided in [!cite](longhurst1992verification,ambrosek2008verification), as they both have typographical errors and give different analytical solutions from the one provided in the figures of these reports.

## Results

[ver-1e_comparison_dist] shows the comparison of the TMAP8 calculation and the analytical solution for concentration after steady-state is reached. The plots show the TMAP8 and analytical solution comparisons for both the TMAP4 case ($l = 63$ $\mu$m) and the TMAP7 case ($l = 66$ $\mu$m).

!media comparison_ver-1e.py
       image_name=ver-1e_comparison_dist.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1e_comparison_dist
       caption=Comparison of TMAP8 calculation with the analytical solution. Bold text next to the plot curves shows the root mean square percentage error (RMSPE) between the TMAP8 prediction and analytical solution for the TMAP4 and TMAP7 verification cases.

For transient solution comparison, the concentration at a point, which is $x$ $\mu$m away from the PyC-SiC interface into the SiC layer, is obtained using the TMAP code and analytically. [ver-1e_comparison_time] shows comparison of the TMAP calculation with the analytical solution for this transient case. In the TMAP4 case, $x$ = 8 $\mu$m, and in the TMAP7 case $x$ = 15.75 $\mu$m. There is good agreement between TMAP and the analytical solution for both steady state and transient cases. In both cases, the root mean square percentage error (RMSPE) is under 0.2 %.

!media comparison_ver-1e.py
       image_name=ver-1e_comparison_time.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1e_comparison_time
       caption=Comparison of TMAP8 calculation with the analytical solution. Bold text next to the plot curves shows the RMSPE for the match between the TMAP8 prediction and analytical solution for the TMAP4 and TMAP7 verification cases.

The error is calculated between the TMAP8 and analytical solution values after $t$ = 0.2 s. This is in order to ignore the unphysical predictions of the analytical solution at very small times as shown in [ver-1e_comparison_time_zoomed], which is a close-up view of [ver-1e_comparison_time] close to the start of the simulation.

!media comparison_ver-1e.py
       image_name=ver-1e_comparison_time_closeup.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1e_comparison_time_zoomed
       caption=Zoomed-in view of comparison of TMAP8 calculation with the analytical solution for $t$ < 1 s. The analytical solution shows unphysical predictions close to $t$ = 0 s, whereas TMAP8's predictions are reasonable.

## Input files

!style halign=left
It is important to note that the input file used to reproduce these results and the input file used as test in TMAP8 are different. Indeed, the input file [/ver-1e.i] has a fine mesh and uses small time steps to accurately match the analytical solutions and reproduce the figures above. To limit the computational costs of the tests, however, the tests run a version of the file with a coarser mesh and larger time steps. More information about the changes can be found in the test specification file for this case [/ver-1e/tests].

!bibtex bibliography
