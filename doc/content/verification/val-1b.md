# val-1b

# Diffusion Problem with Constant Source Boundary Condition

This validation problem is taken from [!cite](longhurst1992verification). Diffusion of tritium through a semi-infinite SiC layer is modeled with a constant
source located on one boundary. No solubility or traping is included. The
concentration as a function of time and position is given by:

\begin{equation}
C = C_o \; erfc \left(\frac{x}{2\sqrt{Dt}}\right)
\end{equation}

Comparison of the TMAP8 results and the analytical solution is shown in
[val-1b_comparison_time] as a function of time at
x = 0.2 mm. For simplicity, both the diffusion coefficient and the initial
concentration were set to unity. The TMAP8 code predictions match very well with
the analytical solution.

!media figures/val-1b_comparison_time.png
    style=width:50%;margin-bottom:2%
    id=val-1b_comparison_time
    caption=Comparison of concentration as function of time at x\=0.2m calculated
     through TMAP8 and analytically

As a second check, the concentration as a function of position at a given time
t = 25s, from TMAP8 was compared with the analytical solution as shown in
[val-1b_comparison_dist]. The predicted concentration profile from TMAP8 is in
good agreement with the analytical solution.

!media figures/val-1b_comparison_dist.png
    style=width:50%;margin-bottom:2%
    id=val-1b_comparison_dist
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

!media figures/val-1b_comparison_flux.png
    style=width:50%;margin-bottom:2%
    id=val-1b_comparison_flux
    caption=Comparison of flux as function of time at x\=0.5m calculated through
    TMAP8 and analytically

### Notes

The trapping test features some oscillations in the solution for whatever
reason. In order for the oscillations to not take over the simulation, it seems
that the ratio of the **inverse of the Fourier number** must be kept
sufficiently high, e.g. `h^2 / (D * dt)`. Included in this directory are three
`png` files that show the permeation for different `h` and `dt` values. They are
summarized below:

- `nx-80.png`: `nx = 80` and `dt = .0625`
- `nx-40.png`: `nx = 40` and `dt = .25`
- `nx-20.png`: `nx = 20` and `dt = 1`

The oscillations in the permeation graph go away with increasing fineness in the
mesh and in `dt`.

!bibtex bibliography
