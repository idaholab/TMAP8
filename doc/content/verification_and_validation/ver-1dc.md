# ver-1dc

# Permeation Problem with Multiple Trapping

## Test Description

This verification problem is taken from [!cite](ambrosek2008verification) and builds on the capabilities verified in [ver-1d](ver-1d.md). However, in the current case, there are three different types of traps. This case is simulated in [/ver-1dc.i].

This problem models permeation through a membrane with a constant source in which three trap populations are present. We solve the following equations

\begin{equation}
    \label{eqn:diffusion_mobile}
    \frac{dC_M}{dt} = \nabla D \nabla C_M - \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{dC_{T_i}}{dt} ,
\end{equation}
and, for $i=1$, $i=2$, and $i=3$:
\begin{equation}
    \label{eqn:trapped_rate}
    \frac{dC_{T_i}}{dt} = \alpha_t^i  \frac {C_{T_i}^{empty} C_M } {(N \cdot \text{trap\_per\_free})} - \alpha_r^i C_{T_i},
\end{equation}
and
\begin{equation}
    C_{T_i}^{empty} = (C_{{T_i}0} \cdot N - \text{trap\_per\_free} \cdot C_{T_i}  ) ,
\end{equation}
where $C_M$ is the concentrations of the mobile, $C_{T_i}$ is the trapped species in trap $i$, $D$ is the diffusivity of the mobile species, $\alpha_t^i$ and $\alpha_r^i$ are the trapping and release rate coefficients for trap $i$, $\text{trap\_per\_free}$ is a factor scaling $C_{T_i}$ to be closer to $C_M$ for better numerical convergence, $C_{{T_i}0}$ is the fraction of host sites $i$ that can contribute to trapping, $C_{T_i}^{empty}$ is the concentration of empty trapping sites, and $N$ is the host density.

The trapping parameter is defined by
\begin{equation}
  \label{eqn:zeta}
    \zeta = \frac{\lambda^2 \nu}{\rho D_0} \exp \left( \frac{E_d - \epsilon}{kT} \right) + \frac{c}{\rho},
\end{equation}

where

$\lambda$ = lattice parameter

$\nu$ = Debye frequency ($\approx$ $10^{13} \; s^{-1}$)

$\rho$ = trapping site fraction

$D_0$ = diffusivity pre-exponential

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
    J_p = \frac{C_0 D}{l} \left\{ 1 + 2 \sum_{m=1}^{\infty} \left[ (-1)^m \exp \left( -m^2 \frac{t}{2 \; \tau_{b_e}} \right) \right] \right\},
\end{equation}
where $C_0$ is the steady dissolved gas concentration at the upstream (x = 0) side, $l$ is the thickness of the slab, $D$ is the diffusivity of the gas through the material, and $\tau_{b_e}$, the breakthrough time, is defined as

\begin{equation}
\label{eqn:tau_be}
    \tau_{b_e} = \frac{l^2}{2 \; \pi^2 \; D_{eff}},
\end{equation}
where $D_{eff}$, the effective diffusivity, is defined as

\begin{equation}
\label{eqn:Deff}
    D_{eff} = \frac{D}{1 + \sum_{i=1}^3 1 / \zeta_i},
\end{equation}
where $\zeta_i$ is the trapping parameter of trap $i$.
The trapping parameters, $\zeta_i$, calculated from [eqn:zeta] for the three traps are 91.47930 $c/\rho$, 61.65009 $c/\rho$, 45.93069 $c/\rho$.

!alert warning title=Typo in [!cite](ambrosek2008verification)
The $\zeta_i$ values of the three traps from [!cite](ambrosek2008verification) have a typographical error: They are three orders of magnitude lower than the correct values. However, it does not impact the final analytical solution.

## Results and comparison against analytical solution

The analytical solution for the permeation transient is compared with TMAP8 results in [ver-1dc_comparison_diffusion]. The graphs for the theoretical flux and the calculated flux are in good agreement, with root mean square percentage errors (RMSPE) of RMSPE = 0.41 % for $t \geq 3$ s. The breakthrough time calculated from [eqn:tau_be] in analytical solution is 4.04 s, and the breakthrough time from TMAP8 is 4.12 s.

!media comparison_ver-1dc.py
       image_name=ver-1dc_comparison_diffusion.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1dc_comparison_diffusion
       caption=Comparison of TMAP8 calculation with the analytical solution for the permeation transient from [!cite](ambrosek2008verification).

## Further verification using the method of manufactured solution (MMS)

Although the flux and breakthrough time can be verified using analytical solutions as presented above, the [MMS](mms.md) approach is a powerful method to verify complex system of PDEs such as the one studied in this case.
Here, we apply the [MMS](mms.md) approach available in the [MOOSE framework](https://mooseframework.inl.gov) to verify TMAP8's predictions for ver-1dc.

Below, we (1) describe how to derive the weak form of the equation, which is necessary to apply the MMS, detail how we apply the MMS approach to this case, and (3) discuss the results.

### Derivation of the weak forms of the equations

#### Step 1: Define and rearrange the strong form of the equations

The strong form of the governing equations is provided in [eqn:diffusion_mobile] and [eqn:trapped_rate], and can be slightly rearranged as:

\begin{equation} \label{eqn:diffusion_mobile_step1}
    \frac{\partial C_M}{\partial t} - \nabla \cdot \left( D \nabla C_M \right) + \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t} = 0,
\end{equation}
and, for $i=1$, $i=2$, and $i=3$:
\begin{equation} \label{eqn:trapped_rate_step1}
    \frac{\partial C_{T_i}}{\partial t} - \alpha_t^i \frac{C_{T_i}^{\text{empty}} C_M}{N \cdot \text{trap\_per\_free}} + \alpha_r^i C_{T_i} = 0,
\end{equation}
respectively.

#### Step 2: Multiply every term by a test function

Multiply each term of the equations by an appropriate test function $\psi$ (or $\psi_i$ for $C_{T_i}$):

[eqn:diffusion_mobile_step1] becomes
\begin{equation} \label{eqn:diffusion_mobile_step2}
    \psi \frac{\partial C_M}{\partial t} - \psi \nabla \cdot \left( D \nabla C_M \right) + \psi \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t} = 0,
\end{equation}
and, for $i=1$, $i=2$, and $i=3$, [eqn:trapped_rate_step1] becomes
\begin{equation} \label{eqn:trapped_rate_step2}
    \psi_i \left( \frac{\partial C_{T_i}}{\partial t} - \alpha_t^i \frac{C_{T_i}^{\text{empty}} C_M}{N \cdot \text{trap\_per\_free}} + \alpha_r^i C_{T_i} \right) = 0.
\end{equation}

#### Step 3: Integrate over the domain $\Omega$

After integration over the domain, we obtain:

\begin{equation} \label{eqn:diffusion_mobile_step3}
    \int_\Omega \psi \frac{\partial C_M}{\partial t} \, d\Omega - \int_\Omega \psi \nabla \cdot \left( D \nabla C_M \right) \, d\Omega + \int_\Omega \psi \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t} \, d\Omega = 0,
\end{equation}

and, for $i=1$, $i=2$, and $i=3$,
\begin{equation} \label{eqn:trapped_rate_step3}
    \int_\Omega \psi_i \frac{\partial C_{T_i}}{\partial t} \, d\Omega - \int_\Omega \psi_i \alpha_t^i \frac{C_{T_i}^{\text{empty}} C_M}{N \cdot \text{trap\_per\_free}} \, d\Omega + \int_\Omega \psi_i \alpha_r^i C_{T_i} \, d\Omega = 0.
\end{equation}

#### Step 4: Integrate by parts and apply the divergence theorem

For the divergence term in [eqn:diffusion_mobile_step3], applying integration by parts and the divergence theorem provides
\begin{equation}
    \int_\Omega \psi \nabla \cdot \left( D \nabla C_M \right) \, d\Omega = - \int_\Omega \nabla \psi \cdot \left( D \nabla C_M \right) \, d\Omega + \oint\limits_{\partial \Omega} \psi \left( D \nabla C_M \right) \cdot \mathbf{n} \, d\partial \Omega,
\end{equation}
where $\partial \Omega$ is the boundary of the domain and $\mathbf{n}$ is the outward normal vector.

This update term is then substituted back into [eqn:diffusion_mobile_step3], which leads to:
\begin{equation} \label{eqn:diffusion_mobile_step4}
    \int_\Omega \psi \frac{\partial C_M}{\partial t} \, d\Omega + \int_\Omega \nabla \psi \cdot \left( D \nabla C_M \right) \, d\Omega - \oint\limits_{\partial \Omega} \psi \left( D \nabla C_M \right) \cdot \mathbf{n} \, d\partial \Omega + \int_\Omega \psi \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t} \, d\Omega = 0.
\end{equation}

Since no divergence terms exist in [eqn:trapped_rate_step3], no integration by parts is needed.

#### Step 5: Derive the final weak form in inner product notation

[eqn:diffusion_mobile_step4] and [eqn:trapped_rate_step3] can be expressed in inner product notation, where $\langle a, b \rangle = \int_\Omega a b \, d\Omega$:

[eqn:diffusion_mobile_step4] becomes
\begin{equation}
    \langle \psi, \frac{\partial C_M}{\partial t} \rangle + \langle \nabla \psi, D \nabla C_M \rangle - \langle \psi, \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t} \rangle + \int_{\partial \Omega} \psi \left( D \nabla C_M \right) \cdot \mathbf{n} \, d\Gamma = 0,
\end{equation}
and, for $i=1$, $i=2$, and $i=3$, [eqn:trapped_rate_step3] becomes
\begin{equation}
    \langle \psi_i, \frac{\partial C_{T_i}}{\partial t} \rangle - \langle \psi_i, \alpha_t^i \frac{C_{T_i}^{\text{empty}} C_M}{N \cdot \text{trap\_per\_free}} \rangle + \langle \psi_i, \alpha_r^i C_{T_i} \rangle = 0.
\end{equation}
These weak forms of the equations can now be used for finite element analysis and MMS.

### Application of the MMS

TBD

### Results

TBD

## Input files

The input file for this case can be found at [/ver-1dc.i] which is different from the input file used as test in TMAP8. To limit the computational costs of the test cases, the tests run a version of the file with a coarser mesh and less number of time steps. More information about the changes can be found in the test specification file for this case [/ver-1dc/tests].

!bibtex bibliography
