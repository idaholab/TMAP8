# ver-1c

# Diffusion Problem with Partially Preloaded Slab

This verification problem is taken from [!cite](longhurst1992verification,ambrosek2008verification). Diffusion of tritium through a semi-infinite SiC layer is modeled with an initial
loading of 1 atom/m$^3$ in the first 10 m of a 100 m slab. TMAP4 uses a slab length of 2275 m (the slab length is not specified in the TMAP7 document [!cite](ambrosek2008verification)), however using a smaller slab length was found to not change the results. Additionally, the smaller domain size allows getting a finer simulation mesh for the same computational cost, which improves the agreement between the TMAP8 and analytical calculations.

Diffusivity is set to 1 m$^2$/s
and no traping is included. The analytical solution is given by:

\begin{equation}
\label{eq:c_func}
C = \frac{C_0}{2} \left[ \text{erf}\bigg(\frac{h-x}{2\sqrt{Dt}}\bigg) +
\text{erf}\bigg(\frac{h+x}{2\sqrt{Dt}}\bigg)  \right]
\end{equation}

where $h=10$ m is the thickness of the pre-loaded portion of the layer.

!alert warning title=Typo in [!cite](longhurst1992verification,ambrosek2008verification)
[eq:c_func] for the value of $C$ is based on the expression from [!cite](longhurst1992verification), but the equation in [!cite](longhurst1992verification) has a typographical error and gives incorrect results ($\sqrt(Dt)$ should be at the denominator). The equation in [!cite](ambrosek2008verification) also has typographical errors, and adds an extra term to the equation that gives incorrect results.

TMAP4 and TMAP7 verification cases are slightly different: TMAP4 verifies the mobile species concentration at three points - (a) a point at the free surface (x = 0 m), (b) a point at the end of the pre-loaded region (x = 10 m), and (c) a point in the initially unloaded region (x = 12 m). The comparison of the values calculated with TMAP8 and analytically for the TMAP4 cases is shown in
[ver-1c_comparison_time_TMAP4]. TMAP7 verifies the mobile species concentration at the same points (b) and (c) as in the TMAP4 case, but performs the third comparison at (d) a point close to the free surface (x = 0.25 m). The comparison of the values calculated with TMAP8 and analytically for the TMAP7 cases is shown in
[ver-1c_comparison_time_TMAP7]. In all cases, the TMAP8 calculations are found to be in good agreement with the analytical solution.

!media figures/ver-1c_comparison_time_TMAP4.png
    style=width:50%;margin-bottom:2%
    id=ver-1c_comparison_time_TMAP4
    caption=Comparison of concentration as a function of time at x\=0 m, 10 m, and 12 m
    calculated with TMAP8 and analytically (TMAP4 cases)

!media figures/ver-1c_comparison_time_TMAP7.png
    style=width:50%;margin-bottom:2%
    id=ver-1c_comparison_time_TMAP7
    caption=Comparison of concentration as a function of time at x\=0.25 m, 10 m, and 12 m
    calculated with TMAP8 and analytically (TMAP7 cases)

!bibtex bibliography
