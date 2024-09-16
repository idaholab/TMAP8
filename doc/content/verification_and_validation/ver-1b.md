# ver-1b

# Diffusion Problem with Constant Source Boundary Condition

This verification problem is taken from [!cite](longhurst1992verification). Diffusion of tritium through a semi-infinite SiC layer is modeled with a constant
source located on one boundary. No solubility or traping is included. The
concentration as a function of time and position is given by:

\begin{equation}
C = C_o \; erfc \left(\frac{x}{2\sqrt{Dt}}\right)
\end{equation}

Comparison of the TMAP8 results and the analytical solution is shown in
[ver-1b_comparison_time] as a function of time at
x = 0.2 mm. For simplicity, both the diffusion coefficient and the initial
concentration were set to unity. The TMAP8 code predictions match very well with
the analytical solution.

!media figures/ver-1b_comparison_time.png
    style=width:50%;margin-bottom:2%
    id=ver-1b_comparison_time
    caption=Comparison of concentration as function of time at x\=0.2m calculated
     through TMAP8 and analytically

As a second check, the concentration as a function of position at a given time
t = 25s, from TMAP8 was compared with the analytical solution as shown in
[ver-1b_comparison_dist]. The predicted concentration profile from TMAP8 is in
good agreement with the analytical solution.

!media figures/ver-1b_comparison_dist.png
    style=width:50%;margin-bottom:2%
    id=ver-1b_comparison_dist
    caption=Comparison of concentration as function of distance from the source
    at t\=25sec calculated through TMAP8 and analytically

Finally, the diffusive flux ($J$) was compared with the analytic solution where the
flux is proportional to the derivative of the concentration with respect to x and
is given by:

\begin{equation}
J = C_o \; \sqrt{\frac{D}{t\pi}} \; exp \left(\frac{x}{2\sqrt{Dt}}\right)
\end{equation}

The flux as given by Equation (?) is compared with values calculated by TMAP8 in
Table ?. The diffusivity, D, and the initial concentration, C$_o$, were both
taken as unity, and the distance, x, was taken as 0.5 in this comparison.
TMAP8 initially under predicts but the results match well subsequently. Comparison
results are shown in []

!media figures/ver-1b_comparison_flux.png
    style=width:50%;margin-bottom:2%
    id=ver-1b_comparison_flux
    caption=Comparison of flux as function of time at x\=0.5m calculated through
    TMAP8 and analytically


The oscillations in the permeation graph go away with increasing fineness in the
mesh and in `dt`.

## Input files

!style halign=left
The input file for this case can be found at [/ver-1b.i], which is different from the input file used as test in TMAP8. To limit the computational costs of the test cases, the tests run a version of the file with a coarser mesh and larger time steps. More information about the changes can be found in the test specification file for this case [/ver-1b/tests].

!bibtex bibliography
