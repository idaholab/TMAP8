# ver-1e

# Diffusion in a composite layer

## General Case Description

This verification problem is taken from [!cite](longhurst1992verification, ambrosek2008verification). In this problem, a composite structure of PyC and SiC is modeled with a constant concentration boundary condition of the free surface of PyC and zero concentration boundary condition on the free surface of the SiC.

## Analytical solution at steady state

The steady state solution for the PyC is given in [!cite](longhurst1992verification, ambrosek2008verification) as:

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

    $D_{SiC}$ = diffusivity in SiC (2.622 $\times$ 10$^{-11}$ m$^2$/sec)

## Analytical solution during transient

The analytical transient solution from Table 3, row 1 in [!cite](li2010analytical) for the concentration in the PyC and SiC side of the composite slab is given as:

\begin{equation}
\label{eqn:transient_PyC}
C = C_0 \left\{ \frac{(a-x) D_{SiC} + l D_{PyC}}{l D_{PyC} + a D_{SiC}} - 2 \sum_{n=1}^{\infty} B_m \sin\left(\lambda_n \frac{x}{a}\right) \exp\left(-D_{PyC} \frac{\lambda^2_n}{a^2} t \right) \right\}
\end{equation}

and

\begin{equation}
\label{eqn:transient_SiC}
C = C_0 \left\{ \frac{(l+a-x) D_{PyC}}{l D_{PyC} + a D_{SiC}} - 2 \sum_{n=1}^{\infty} B_m \frac{\sin(\lambda_n)}{\sin(k \lambda_n l/a)} \sin\left(k \lambda_n \frac{l+a-x}{a}\right) \exp\left(-D_{PyC} \frac{\lambda^2_n}{a^2} t \right) \right\}
\end{equation}

where

\begin{equation}
k = \sqrt{\frac{D_{PyC}}{D_{SiC}}},
\end{equation}

\begin{equation}
B_m = \frac{D_{PyC} l \sin^2(k \lambda_n l/a) (\cos(\lambda_n) - 1) + D_{SiC} \sin(k \lambda_n l/a) (k l \sin(\lambda_n) \cos(k \lambda_n l/a) - a \sin(k \lambda_n l/a))}{ \lambda_n (a D_{SiC} + l D_{PyC}) (\sin^2(k \lambda_n l/a) + l/a sin^2(\lambda_n))},
\end{equation}

and $\lambda_n$ are the roots of

\begin{equation}
\label{eqn:roots}
\frac{\sin(\lambda_n) \cos(k \lambda_n l/a)}{k} + \cos(\lambda_n) \sin(k \lambda_n l/a) = 0.
\end{equation}

!alert warning title=Typo in [!cite](ambrosek2008verification)
The expressions of the analytical solution for the transient case in TMAP4 ([!cite](longhurst1992verification)) and TMAP7 ([!cite](ambrosek2008verification)) are inconsistent with the results, which suggest typographical errors. Moreover, no reference is provided. For these reasons, we use a different analytical transient solution and roots of $\lambda$ for the concentration in PyC and SiC layer from [!cite](li2010analytical).

## Results

[ver-1e_comparison_dist] shows the comparison of the TMAP8 calculation and the analytical solution for concentration after steady-state is reached. The plots show the TMAP8 and analytical solution comparisons for both the TMAP4 case ($l$ = 63 $\mu$m) and the TMAP7 case ($l$ = 66 $\mu$m).

!media comparison_ver-1e.py
       image_name=ver-1e_comparison_dist.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1e_comparison_dist
       caption=Comparison of TMAP8 calculation with the analytical solution at steady state. Bold text next to the plot curves shows the root mean square percentage error (RMSPE) between the TMAP8 prediction and analytical solution for the TMAP4 and TMAP7 verification cases.

For transient solution comparisons, we select two different points: One in the PyC layer at $x = 32$ $\mu$m, and one in the SiC layer.
The concentration at these two points is calculated using TMAP8 and with the analytical equations ([eqn:transient_PyC] and [eqn:transient_SiC]).
[ver-1e_comparison_time_PyC] shows the comparison of the TMAP8 calculation against the analytical solution for this transient case in the PyC layer from 0 s to 1 s. Note that we only use the parameters from TMAP7 because the trivial difference between TMAP4 and TMAP7 in PyC layer.
[ver-1e_comparison_time] shows the comparison of the TMAP8 calculation against the analytical solution in the SiC layer. In the TMAP4 case, $x$ = 41 $\mu$m, and in the TMAP7 case, $x$ = 48.75 $\mu$m.
There is good agreement between TMAP8 and the analytical solution for both steady state as well as transient cases. In both cases, the root mean square percentage error (RMSPE) is under 0.2%.

!media comparison_ver-1e.py
       image_name=ver-1e_comparison_time_PyC.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1e_comparison_time_PyC
       caption=Comparison of TMAP8 calculation with the analytical solution at $x = 32$ $\mu$m in PyC layer. Bold text next to the plot curves shows the RMSPE for the match between the TMAP8 prediction and analytical solution for the TMAP4 and TMAP7 verification cases.

!media comparison_ver-1e.py
       image_name=ver-1e_comparison_time.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1e_comparison_time
       caption=Comparison of TMAP8 calculation with the analytical solution in SiC layer. The compared distances are $x$ = 41 $\mu$m in the TMAP4 case and $x$ = 48.75 $\mu$m in the TMAP7 case. Bold text next to the plot curves shows the RMSPE for the match between the TMAP8 prediction and analytical solution for the TMAP4 and TMAP7 verification cases.

The error is calculated between the TMAP8 and analytical solution values after $t$ = 0.2 s. This is in order to ignore the unphysical predictions of the analytical solution at very small times as shown in [ver-1e_comparison_time_zoomed], which is a close-up view of [ver-1e_comparison_time] close to the start of the simulation. The departure from physical results at low $t$ is due to the limited number of $\lambda_n$ values being used from [eqn:roots]. We use the $\lambda_n$ values from 0 to 100 in this case. The $\lambda_n$ values in larger range will only have limited improvement in the accuracy but increase the running time for the computation of the analytical solutions.

!media comparison_ver-1e.py
       image_name=ver-1e_comparison_time_closeup.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1e_comparison_time_zoomed
       caption=Zoomed-in view of comparison of TMAP8 calculation with the analytical solution for $t$ < 0.4 s. The analytical solution shows unphysical predictions close to $t$ = 0 s, whereas TMAP8's predictions are reasonable.

## Input files

!style halign=left
It is important to note that the input file used to reproduce these results and the input file used as test in TMAP8 are different. Indeed, the input file [/ver-1e.i] has a fine mesh and uses small time steps to accurately match the analytical solutions and reproduce the figures above. To limit the computational costs of the tests, however, the tests run a version of the file with a coarser mesh and larger time steps. More information about the changes can be found in the test specification file for this case [/ver-1e/tests].

!bibtex bibliography
