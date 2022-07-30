# val-1e

# Diffusion in a composite layer

# Depleting Source Problem

## Test Description

This verification problem is taken from [!cite](ambrosek2008verification). In this problem a composite structure of PyC and SiC is modeled with a constant concentration boundary condition of the free surface of PyC and zero concentration boundary condition on the free surface of the SiC. The steady state solution for the PyC is given as:

\begin{equation}
\label{eqn:steady_state_pyc}
    C = C_o \left[1 + \frac{x}{l}  \left(\frac{a D_{PyC}}{a D_{PyC} + l D_{SiC}} - 1 \right) \right]
\end{equation}

while the concentration profile for the SiC layer is given as:

\begin{equation}
\label{eqn:steady_state_sic}
    C = C_o \left(\frac{a+l-x}{l} \right) \left(\frac{a D_{PyC}}{a D_{PyC} + l D_{SiC}} \right)
\end{equation}

where

    $x$ = distance from free surface of PyC

    $a$ = thickness of the PyC layer (33 $\mu m$)

    $l$ = thickness of the SiC layer (66 $\mu m$)

    $C_o$ = concentration at the PyC free surface (50.7079 moles/m$^3$)

    $D_{PyC}$ = diffusivity in PyC (1.274 x 10$^{-7}$ m$^2$/sec)

    $D_{SiC}$ = diffusivity in SiC (2.622 x 10$^{-11}$ m$^2$/sec)

The analytical transient solution for the concentration in the SiC side of the composite slab is given as:

\begin{equation}
\label{eqn:transient}
    C = C_o \Bigg\{ \frac{D_{PyC}(l-x)}{l D_{PyC} + a D_{SiC}} - 2 \sum_{n=1}^{\infty} \frac{\sin(a \lambda_n) \sin(k l \lambda_n) \sin \left[k (l-x) \lambda_n \right]}{\lambda_n \left[ a \sin^2(k l \lambda_n) + l \sin^2 (a \lambda_n) \right]} \exp(-D_{PyC} \lambda_n^2 t) \Bigg\}
\end{equation}

where

$k$ = $\sqrt{\frac{D_{PyC}}{D_{SiC}}}$

and $\lambda_n$ are the roots of

$tan(\lambda a) + k \; tan(k l \lambda) = 0$


## Results

[ver-1e_comparison_dist] shows the comparison of the TMAP8 calculation and the analytical solution for concentration after steady-state is reached.

!media figures/ver-1e_comparison_dist.png
    style=width:50%;margin-bottom:2%
    id=ver-1e_comparison_dist
    caption=Comparison of TMAP8 calculation with the analytical solution

For transient solution comparison, the concentation at a point, which is 15.75 $\mu m$ away from the PyC-SiC interface into the SiC layer, is obtained using the TMAP code as well as analytically. [ver-1e_comparison_time] shows comparison of the TMAP calculation with the analytical solution for this transient case. There is good agreement between TMAP and the analytical solution for both steady state as well as transient cases.

!media figures/ver-1e_comparison_time.png
    style=width:50%;margin-bottom:2%
    id=ver-1e_comparison_time
    caption=Comparison of TMAP8 calculation with the analytical solution

!bibtex bibliography
