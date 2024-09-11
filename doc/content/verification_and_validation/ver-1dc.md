# ver-1dc

# Permeation Problem with Multiple Trapping

## Test Description

This verification problem is taken from [!cite](ambrosek2008verification) and builds on the capabilities verified in [ver-1d](ver-1d.md). However, in the current case, there are three different types of traps. This case is simulated in [/ver-1dc.i].

This problem models permeation through a membrane with a constant source in which three trap populations are present. We solve the following equations

\begin{equation}
    \label{eqn:diffusion_mobile}
    \frac{dC_M}{dt} = - \nabla D \nabla C_M - \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{dC_{T_i}}{dt} ,
\end{equation}
\begin{equation}
    \label{eqn:trapped_rate}
    \frac{dC_{T_i}}{dt} = \alpha_t^i  \frac {C_{T_i}^{empty} C_M } {(N \cdot \text{trap\_per\_free})} - \alpha_r^i C_{T_i},
\end{equation}
and
\begin{equation}
    C_{T_i}^{empty} = (C_{{T_i}0} \cdot N - \text{trap\_per\_free} \cdot C_{T_i}  ) ,
\end{equation}
where $C_M$ is the concentrations of the mobile, $C_{T_i}$ is the trapped species in trap $i$, $D$ is the diffusivity of the mobile species, $\alpha_t^i$ and $\alpha_r^i$ are the trapping and release rate coefficients for trap $i$, $\text{trap\_per\_free}$ is a factor scaling $C_{T_i}$ to be closer to $C_M$ for better numerical convergence, $C_{{T_i}0}$ is the fraction of host sites $i$ that can contribute to trapping, $C_{T_i}^{empty}$ is the concentration of empty trapping sites, and $N$ is the host density.

The breakthrough time is defined by
\begin{equation}
  \label{eqn:zeta}
    \zeta = \frac{\lambda^2 \nu}{\rho D_o} exp \left( \frac{E_d - \epsilon}{kT} \right) + \frac{c}{\rho},
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

and $c$ = dissolved gas atom fraction.
!alert note title=TMAP8 can accommodate an arbitrary number of trapping populations
This verification case was first introduced in [!cite](ambrosek2008verification) to highlight TMAP7's capability to model up to three different trapping populations, when TMAP4 was limited to one [!citep](longhurst1992verification). However, TMAP8 can accommodate an arbitrary number of trapping populations.

Three traps that are relatively weak are assumed to be active in a slab. The trapping site fraction of the three traps are 0.1, 0.15 and 0.20, respectively. The values of $\epsilon/k$ for the three traps are 100 K, 500 K, and 800 K, respectively. Other parameters are the same as the trap in the effective diffusivity limit in [ver-1d](ver-1d.md).

## Analytical solution

[!cite](ambrosek2008verification) provides the analytical equations for the permeation transient as

\begin{equation}
\label{eqn:Jp}
    J_p = \frac{c_o D}{l} \Bigg\{ 1 + 2 \sum_{m=1}^{\infty} \left[ (-1)^m \exp \left( -m^2 \frac{t}{2 \; \tau_{b_e}} \right) \right] \Bigg\},
\end{equation}
where $c_o$ is the steady dissolved gas concentration at the upstream (x = 0) side, $l$ is the thickness of the slab, $D$ is the diffusivity of the gas through the material, and $\tau_{b_e}$, the breakthrough time, is defined as

\begin{equation}
\label{eqn:tau_be}
    \tau_{b_e} = \frac{l^2}{2 \; \pi^2 \; D_{eff}},
\end{equation}
where $D_{eff}$, the effective diffusivity, is defined as

\begin{equation}
\label{eqn:Deff}
    D_{eff} = \frac{D}{1 + \sum_{i=1}^3 \frac{1}{\zeta_i}},
\end{equation}
where $\zeta_i$ is the trapping parameter of trap $i$.


## Results and comparison against analytical solution

The trapping parameters, $\zeta_i$, for the three traps are 91.47930 $c/\rho$, 61.65009 $c/\rho$, 45.93069 $c/\rho$.

!alert warning title=Typo in [!cite](ambrosek2008verification)
The $\zeta_i$ of the three traps from [!cite](ambrosek2008verification) have a typographical error, but it dos not impact the final analytical solution.

The analytical solution for the permeation transient is compared with TMAP8 results in [ver-1dc_comparison_diffusion]. The graphs for the theoretical flux and the calculated flux are in good agreement, with root mean square percentage errors (RMSPE) of RMSPE = 0.41 % when time $t \geq 3$ s.

!media comparison_ver-1dc.py
       image_name=ver-1dc_comparison_diffusion.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1dc_comparison_diffusion
       caption=Comparison of TMAP8 calculation with the analytical solution for the permeation transient from [!cite](ambrosek2008verification).


## Input files

The input file for this case can be found at [/ver-1dc.i].

!bibtex bibliography
