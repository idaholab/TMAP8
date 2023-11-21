# ver-1c

# Diffusion Problem with Partially Preloaded Slab

This verification problem is taken from [!cite](longhurst1992verification). Diffusion of tritium through a semi-infinite SiC layer is modeled with an initial
loading of 1 atom/m{^3} in the first 10 m of a 2275-m slab. Diffusivity is unity
and no traping is included. The analytical solution is given by:

\begin{equation}
C = \frac{C_o}{2} \left( erf \left( \frac{h-x}{2} \sqrt{Dt} \right) + erf \left( \frac{h+x}{2\sqrt{Dt}}) \right) \right)
\end{equation}


where h is the thickness of the pre-loaded portion of the layer.

At the surface (x = 0) the concentration is given by:

\begin{equation}
C = \frac{C_o}{2} \; erf \left( \frac{h}{2\sqrt{Dt}} \right)
\end{equation}

while at x = h its value is described by

\begin{equation}
C = \frac{C_o}{2} \; erf \left( \frac{h}{\sqrt{Dt}} \right)
\end{equation}

A comparison of the mobile species concentration values at x = 0 m, 10 m and
12.5 m calculated through TMAP8 and analytically is shown in
[ver-1c_comparison_time]. The TMAP8 calculations are found to be in good agreement
with the analytical solution.

!media figures/ver-1c_comparison_time.png
    style=width:50%;margin-bottom:2%
    id=ver-1c_comparison_time
    caption=Comparison of concentration as function of time at x\=0 m, 10 m and 12 m
    calculated through TMAP8 and analytically

!bibtex bibliography
