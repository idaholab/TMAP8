# ver-1d

# Permeation Problem with Trapping

## Test Description

This verification problem is taken from [!cite](longhurst1992verification). It models permeation through a membrane with a constant source in which traps are operative. We solve the following equations

\begin{equation}
    \label{eqn:diffusion_mobile}
    \frac{dC_M}{dt} = - \nabla D \nabla C_M - \text{trap\_per\_free} \cdot \frac{dC_T}{dt},
\end{equation}
\begin{equation}
    \label{eqn:trapped_rate}
    \frac{dC_T}{dt} = \alpha_t  \frac {C_T^{empty} C_M } {(N \cdot \text{trap\_per\_free})} - \alpha_r C_T,
\end{equation}
and
\begin{equation}
    c_T^{empty} = (c_{T0} \cdot N - \text{trap\_per\_free} \cdot C_T  ) ,
\end{equation}
where $C_M$ and $C_T$ are the concentrations of the mobile and trapped species respectively, $D$ is the diffusivity of the mobile species, $\alpha_t$ and $\alpha_r$ are the trapping and release rate coefficients, $\text{trap\_per\_free}$ is a factor converting the magnitude of $C_T$ to be closer to $C_M$ for better numerical convergence, $c_{T0}$ is the fraction of host sites that can contribute to trapping, and $N$ is the host density.

The breakthrough time may have one of two limiting values depending on whether the trapping is in the effective diffusivity or strong-trapping regime. A trapping parameter is defined by:

\begin{equation}
  \label{eqn:zeta}
    \zeta = \frac{\lambda^2 \nu}{\rho D_o} exp \left( \frac{E_d - \epsilon}{kT} \right) + \frac{c}{\rho}
\end{equation}

where

$\lambda$ = lattice parameter

$\nu$ = Debye frequency ($\approx$ $10^{13} \; s^{-1}$)

$\rho$ = trapping site fraction

$D_o$ = diffusivity pre-exponential

$E_d$ = diffusion activation energy

$\epsilon$ = trap energy

$k$ = Boltzmann's constant

$T$ = temperature

$c$ = dissolved gas atom fraction

The discriminant for which regime is dominant is the ratio of $\zeta$ to c/$\rho$. If $\zeta$ $\gg$ c/$\rho$ then the effective diffusivity regime applies, and the permeation transient is identical to the standard diffusion transient but with the diffusivity replaced by an effective diffusivity.

\begin{equation}
\label{eqn:Deff}
    D_eff = \frac{D}{1 + \frac{1}{\zeta}}
\end{equation}

In this limit, the breakthrough time, defined as the intersection of the steepest tangent to the diffusion transient with the time axis, will be

\begin{equation}
\label{eqn:tau_be}
    \tau_{b_e} = \frac{l^2}{2 \; \pi^2 \; D_eff}
\end{equation}

where $l$ is the thickness of the slab and D is the diffusivity of the gas through the material. The permeation transient is then given by


\begin{equation}
\label{eqn:Jp}
    J_p = \frac{c_o D}{l} \Bigg\{ 1 + 2 \sum_{m=1}^{\infty} \left[ (-1)^m \exp \left( -m^2 \frac{t}{2 \; \tau_{b_e}} \right) \right] \Bigg\}
\end{equation}


[!cite](longhurst2005verification) where $\tau_{b_e}$ is defined in [eqn:tau_be]

In the deep-trapping limit, $\zeta$ $\approx$ c/$\rho$, and no permeation occurs until essentially all the traps have been filled. Then permeation rapidly turns on to its state value. The breakthrough time is given by

\begin{equation}
\label{eqn:tau_bd}
    \tau_{b_d} = \frac{l^2 \rho}{2 \; c_o \; D}
\end{equation}

where $c_o$ is the steady dissolved gas concentration at the upstream (x = 0) side.

Using TMAP8 we examine these two different regimes, one where diffusion is the rate-limiting step, and one where trapping is the rate-limiting step. The upstream-side starting concentration of 0.0001 atom fraction, a diffusivity of 1 $m^2$/s, a trapping site fraction of 0.1, $\lambda^2 = 10^{-15} \; m^2$, and a temperature of 1000 K is considered.


## Diffusion-limited

For the effective diffusivity limit, we selected $\epsilon/k = 100 K$ to give $\zeta = 91.47 c/\rho$. The comparison results are presented in [ver-1d_comparison_diffusion].

!media figures/ver-1d_comparison_diffusion.png
    style=width:50%;margin-bottom:2%
    id=ver-1d_comparison_diffusion
    caption=Permeation history of a slab subject to effective-diffusivity limit trapping.

## Trapping-limited

For the deep trapping limit we took $\epsilon/k = 10000 K$ to give $\zeta = 1.00454 c/\rho$.  The comparison results are presented in [ver-1d_comparison_trapping].

!media figures/ver-1d_comparison_trapping.png
    style=width:50%;margin-bottom:2%
    id=ver-1d_comparison_trapping
    caption=Permeation transient in a slab subject to strong trapping.




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
