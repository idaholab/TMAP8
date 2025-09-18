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
\begin{equation}  \label{eqn:trapping_empty}
    C_{T_i}^{empty} = C_{{T_i}0} \cdot N - \text{trap\_per\_free} \cdot C_{T_i} ,
\end{equation}
where $C_M$ is the concentrations of the mobile, $C_{T_i}$ is the trapped species in trap $i$, $D$ is the diffusivity of the mobile species, $\alpha_t^i$ and $\alpha_r^i$ are the trapping and release rate coefficients for trap $i$, $\text{trap\_per\_free}$ is a factor scaling $C_{T_i}$ to be closer to $C_M$ for better numerical convergence, $C_{{T_i}0}$ is the fraction of host sites $i$ that can contribute to trapping, $C_{T_i}^{empty}$ is the concentration of empty trapping sites, and $N$ is the host density.

The trapping parameter is defined by
\begin{equation}
  \label{eqn:zeta}
    \zeta = \frac{\lambda^2 \nu}{\rho D_0} \exp \left( \frac{E_d - \epsilon}{kT} \right) + \frac{c}{\rho},
\end{equation}

where

$\lambda$ = lattice parameter

$\nu$ = Debye frequency ($\approx$ $10^{13}$; s$^{-1}$)

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
where $C_0$ is the steady dissolved gas concentration at the upstream ($x =$ 0) side, $l$ is the thickness of the slab, $D$ is the diffusivity of the gas through the material, and $\tau_{b_e}$, the breakthrough time, is defined as

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

## Further verification using the method of manufactured solutions (MMS)

Although the flux and breakthrough time can be verified using analytical solutions as presented above, the [MMS](mms.md) approach is a powerful method to verify complex systems of PDEs such as the one studied in this case.
Here, we apply the [MMS](mms.md) approach available as a Python-based utility in the [MOOSE framework](https://mooseframework.inl.gov) to verify TMAP8's predictions for ver-1dc through spatial convergence.

Below, we (1) describe how to derive the weak form of the equation, which is necessary to apply the MMS,
(2) detail how we apply the MMS approach to this case, and
(3) discuss the results.

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
where $\partial \Omega$ is the boundary of the domain and $\mathbf{n}$ is the outward-facing normal vector.

This update term is then substituted back into [eqn:diffusion_mobile_step3], which leads to:
\begin{equation} \label{eqn:diffusion_mobile_step4}
    \int_\Omega \psi \frac{\partial C_M}{\partial t} \, d\Omega + \int_\Omega \nabla \psi \cdot \left( D \nabla C_M \right) \, d\Omega - \oint\limits_{\partial \Omega} \psi \left( D \nabla C_M \right) \cdot \mathbf{n} \, d\partial \Omega + \int_\Omega \psi \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t} \, d\Omega = 0.
\end{equation}

Since no divergence terms exist in [eqn:trapped_rate_step3], no integration by parts is needed.

#### Step 5: Derive the final weak form in inner product notation

[eqn:diffusion_mobile_step4] and [eqn:trapped_rate_step3] can be expressed in inner product notation, where $\langle a, b \rangle = \int_\Omega a b \, d\Omega$.

[eqn:diffusion_mobile_step4] becomes
\begin{equation}
    \langle \psi, \frac{\partial C_M}{\partial t} \rangle + \langle \nabla \psi, D \nabla C_M \rangle - \langle \psi, \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t} \rangle + \int_{\partial \Omega} \psi \left( D \nabla C_M \right) \cdot \mathbf{n} \, d\Gamma = 0,
\end{equation}
and, for $i=1$, $i=2$, and $i=3$, [eqn:trapped_rate_step3] becomes
\begin{equation}
    \langle \psi_i, \frac{\partial C_{T_i}}{\partial t} \rangle - \langle \psi_i, \alpha_t^i \frac{C_{T_i}^{\text{empty}} C_M}{N \cdot \text{trap\_per\_free}} \rangle + \langle \psi_i, \alpha_r^i C_{T_i} \rangle = 0.
\end{equation}
These weak forms of the equations can now be used for finite element analysis.

### Application of the MMS

A detailed and step by step description of the MMS approach is available on the [MOOSE MMS page](mms.md).
To perform a spatial convergence study with the MMS, we select a smoothly-varying sinusoidal spatial solution for the mobile and trapped species. In order to prevent temporal error from polluting the spatial error, we pick a temporal dependence that can be exactly represented by the time integrator we choose. In this MMS case, we use implicit or backwards Euler which is first-order accurate; consequently we choose a linear dependence on time. For our 1D case, this leads us to select the following MMS solution for the mobile species:

\begin{equation} \label{eqn:exact_solution_mobile_mms}
u(x,t) = \cos(x) t
\end{equation}

with $x$ the position along the 1D domain, and $t$ the time.
The trapping species concentrations are represented similarly with, for $i=1$, $i=2$, and $i=3$:

\begin{equation} \label{eqn:exact_solution_trapped_mms}
u_i(x,t) = \frac{ N u_{i,0}}{2} (t\cos(x) + 1)
\end{equation}

with $u_{i,0}$ the equivalent of $C_{{T_i}0}$ in [eqn:trapping_empty].

With the manufactured solutions selected, we generate forcing functions $f$ and $f_i$ by substituting the exact solutions into the strong-form PDEs, [eqn:diffusion_mobile_step1] and [eqn:trapped_rate_step1], leading to (assuming $\text{trap\_per\_free}=1$):

\begin{equation} \label{eqn:diffusion_mobile_mms}
    \frac{\partial u}{\partial t} - \nabla \cdot \left( D \nabla u \right) + \sum_{i=1}^{3} \frac{\partial u_i}{\partial t} - f = 0,
\end{equation}
and, for $i=1$, $i=2$, and $i=3$:
\begin{equation} \label{eqn:trapped_rate_mms}
    \frac{\partial u_i}{\partial t} - \alpha_t^i \frac{u_i^{\text{empty}} u}{N} + \alpha_r^i u_i - f_i = 0.
\end{equation}

$f$ and $f_i$ are therefore defined as:

\begin{equation} \label{eqn:diffusion_mobile_mms_forced}
    f = \cos(x) + Dt\cos(x) + \sum_{i=1}^{3} \frac{ N u_{i,0}}{2} \cos(x),
\end{equation}
and, for $i=1$, $i=2$, and $i=3$:
\begin{equation} \label{eqn:trapped_rate_mms_forced}
    f_i = \frac{u_{i,0}}{2} \left(N\cos(x) + \alpha_r^i N (t \cos(x) + 1) - \alpha_t^i t \cos(x) (-t\cos(x) + 1)\right).
\end{equation}

[eqn:diffusion_mobile_mms] and [eqn:trapped_rate_mms] now form a system of equations that can be solved and compared against the exact solutions defined in [eqn:exact_solution_mobile_mms] and [eqn:exact_solution_trapped_mms].

These forcing functions are then imposed in the TMAP8 input file using [BodyForce.md] and [UserForcingFunctionNodalKernel.md], respectively. Dirichlet boundary conditions for the mobile species are imposed using the selected exact/MMS solution. For the spatial discretization, we select first order Lagrange basis functions for the mobile concentration and for projecting the trapped species concentrations from nodes into element interiors for coupling in the trapped specie time derivative term in the mobile specie governing equation.

### Results

The results of the spatial convergence study using the MMS is shown in [ver-1dc_mms], with 10 levels of refinement.
The expected quadratic convergence rate of the $L_2$ error is observed, hence verifying the proper implementation of the diffusion and multi-trapping capabilities.

!media spatial_mms.py
       image_name=ver-1dc-mms-spatial.png
       id=ver-1dc_mms
       style=width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto
       caption=Spatial convergence for a diffusion-trapping-release problem modeled after the physics of ver-1dc using first order Lagrange basis functions. The expected quadratic convergence rate of the $L_2$ error is observed.

## Input files

This case contains several input files.
For the verification using the comparison against the analytical solutions, the input file can be found at [/ver-1dc.i].
For the verification using the MMS, the input file can be found at [/ver-1dc_mms.i].
The [ver-1dc/test.py] script runs the MMS test using [/ver-1dc_mms.i].
Note that both input files utilize the base input file [/ver-1dc_base.i], which contains all the objects that both verification approach share.
Using a base input file such as [/ver-1dc_base.i] reduces redundancy, eases maintenance, and ensures consistency between the two verification set ups.

Note that to limit the computational costs of the test cases, the tests run a version of [/ver-1dc.i] with a coarser mesh and fewer time steps.
More information about the changes can be found in the test specification file for this case [/ver-1dc/tests].

!bibtex bibliography
