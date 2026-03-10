# ver-1dd

# Permeation Problem without Trapping

## Test Description

This verification problem is taken from [!cite](ambrosek2008verification) and builds on the capabilities verified in [ver-1d](ver-1d.md) and [ver-1dc](ver-1dc.md). The configuration and modeling parameters are the same as in [ver-1d](ver-1d.md), except that, in the current case, there are no traps in the membrane. This case is simulated in [/ver-1dd.i].

This problem models permeation through a membrane with a constant source in which no trap presented. We solve

\begin{equation}
    \label{eqn:diffusion_mobile}
    \frac{dC_M}{dt} = \nabla \cdot D \nabla C_M ,
\end{equation}
where $C_M$ is the concentrations of the mobile, $D$ is the diffusivity of the mobile species, and $t$ is the time.

## Analytical solution

[!cite](ambrosek2008verification) provides the analytical equations for the permeation transient as

\begin{equation}
\label{eqn:Jp}
    J_p = \frac{C_0 D}{l} \left\{ 1 + 2 \sum_{m=1}^{\infty} \left[ (-1)^m \exp \left( -m^2 \frac{t}{2 \; \tau_{b_e}} \right) \right] \right\},
\end{equation}
where $C_0$ is the steady dissolved gas concentration at the upstream ($x = 0$) side, $l$ is the thickness of the slab, $D$ is the diffusivity of the mobile species through the material, and $\tau_{b_e}$, the breakthrough time, is defined as

\begin{equation}
\label{eqn:tau_be}
    \tau_{b_e} = \frac{l^2}{2 \; \pi^2 \; D_{eff}},
\end{equation}
where $D_{eff}$, the effective diffusivity, is equal to $D$ due to the absence of traps in the membrane.


## Results and comparison against analytical solution

The analytical solution for the permeation transient is compared with TMAP8 results in [ver-1dd_comparison_diffusion]. The graphs for the theoretical flux and the calculated flux are in good agreement, with root mean square percentage errors (RMSPE) of RMSPE = 0.14% for $t \geq 0.01$ s. The breakthrough time calculated from the analytical solution provided by [eqn:tau_be] is 0.05 s, and the breakthrough time from TMAP8 is 0.05 s, which matches.

!media comparison_ver-1dd.py
       image_name=ver-1dd_comparison_diffusion.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1dd_comparison_diffusion
       caption=Comparison of TMAP8 calculation with the analytical solution for the permeation transient without traps from [!cite](ambrosek2008verification).


## Input files

The input file for this case can be found at [/ver-1dd.i], which is also used as test in TMAP8 at [/ver-1dd/tests].

!bibtex bibliography
