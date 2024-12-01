# ver-1c

# Diffusion Problem with Partially Preloaded Slab

This verification problem is taken from [!cite](longhurst1992verification,ambrosek2008verification). Diffusion of tritium through a semi-infinite SiC layer is modeled with an initial
loading of 1 atom/m$^3$ in the first 10 m of a 100 m slab. TMAP4 uses a slab length of 2275 m (the slab length is not specified in the TMAP7 document [!cite](ambrosek2008verification)); however, using a smaller slab length was found not to change the results. Additionally, the smaller domain size allows getting a finer simulation mesh for the same computational cost, which improves the agreement between the TMAP8 and analytical calculations.

Diffusivity is set to 1 m$^2$/s
and no trapping is included. The boundary condition on the left-hand side of the slab (at $x=0$ m) is different for the TMAP4 and TMAP7 cases. For TMAP4, an insulating boundary condition is assumed, and the analytical solution is given by [!citep](Carslaw1959conduction):

\begin{equation}
\label{eq:c_func_4}
C = \frac{C_0}{2} \left[ \text{erf}\left(\frac{h-x}{2\sqrt{Dt}}\right) +
\text{erf}\left(\frac{h+x}{2\sqrt{Dt}}\right)  \right]
\end{equation}

but for TMAP7, which specifies $C(x=0 \mathrm{\:m})=0$, the analytical solution is [!citep](Carslaw1959conduction)

\begin{equation}
\label{eq:c_func_7}
C = \frac{C_0}{2}\left[2\mathrm{erf}\left(\frac{x}{2\sqrt{Dt}}\right) - \mathrm{erf}\left(\frac{x-h}{2\sqrt{Dt}}\right) - \mathrm{erf}\left(\frac{x+h}{2\sqrt{Dt}}\right)\right]
\end{equation}

where $h=10$ m is the thickness of the pre-loaded portion of the layer, $C_0$ is the initial concentration in the pre-loaded section of the slab, erf is the error function, $x$ is the position along the slab, and $D$ is the diffusivity.

!alert warning title=Typo in [!cite](longhurst1992verification)
The value of $C$ found in [!cite](longhurst1992verification) has a typographical error, $\sqrt{Dt}$ should be at the denominator. [eq:c_func_4] follows the form of [!cite](Carslaw1959conduction).


!alert warning title=Typo in [!cite](longhurst1992verification)
The value of $C$ found in [!cite](longhurst1992verification) has a typographical error, $\sqrt{Dt}$ should be at the denominator. [eq:c_func_4] follows the form of [!cite](Carslaw1959conduction).
TMAP4 and TMAP7 verification cases are also evaluated at slightly different locations: TMAP4 verifies the mobile species concentration at three points:

1. a point at the free surface ($x = 0$ m)
2. a point at the end of the pre-loaded region ($x = 10$ m)
3. a point in the initially unloaded region ($x = 12$ m)


 The comparison of the values calculated with TMAP8 and analytically for the TMAP4 cases is shown in
[ver-1c_comparison_time_TMAP4]. TMAP7 verifies the mobile species concentration at similar points

1. a point near the free surface ($x = 0.25$ m), as the concentration at the surface is specified
2. a point at the end of the pre-loaded region ($x = 10$ m)
3. a point in the initially unloaded region ($x = 12$ m)



The comparison of the values calculated with TMAP8 and analytically for the TMAP7 cases is shown in
[ver-1c_comparison_time_TMAP7]. In all cases, the TMAP8 calculations are found to be in good agreement with the analytical solution.

!media comparison_ver-1c.py
       image_name=ver-1c_comparison_time_TMAP4.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1c_comparison_time_TMAP4
       caption=Comparison of concentration as a function of time at $x = 0$ m, 10 m, and 12 m
       calculated with TMAP8 and analytically (TMAP4 cases)

!media comparison_ver-1c.py
       image_name=ver-1c_comparison_time_TMAP7.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1c_comparison_time_TMAP7
       caption=Comparison of concentration as a function of time at $x = 0.25$ m, 10 m, and 12 m
       calculated with TMAP8 and analytically (TMAP7 cases)

## Input files

!style halign=left
The input file for this case can be found at [/ver-1c.i], which is also used as test in TMAP8 at [/ver-1c/tests]. The TMAP4 and TMAP7 verification tests use the same input file,
but different command line arguments for TMAP4.

!listing /test/tests/ver-1c/tests line=NeumannBC

and TMAP7

!listing /test/tests/ver-1c/tests line=DirichletBC

!bibtex bibliography
