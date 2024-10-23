# ver-1jb

Two problems ([ver-1ja](ver-1ja.md) and ver-1jb) demonstrate tritium decay, though any other isotope could have been chosen.
The first ([ver-1ja](ver-1ja.md)) models simple decay of mobile species in a slab.
The second (ver-1jb) models decay of trapped atoms in a similar slab but with a distributed trap concentration.
This page presents ver-1jb.

# Radioactive Decay of Tritium in a Distributed Trap

## General Case Description

This verification case is an extension of[ver-1ja](ver-1ja.md), which tests the first order radioactive decay capabilities of TMAP8.
In ver-1jb, however, tritium decay is coupled with trapping, which was verified in several verification cases,
including [ver-1d](ver-1d.md).
As [ver-1ja](ver-1ja.md), ver-1jb is based on the case published in the TMAP7 V&V suite [!citep](ambrosek2008verification).
The model assumes pre-charging of an $l=1.5$ m long slab with tritium.
As opposed to [ver-1ja](ver-1ja.md), however, traps at $C_{trap} = 0.1$\% atom fraction
and $E=4.2$ eV trap energy are distributed in a normal distribution centered at the mid-plane of the slab and standard deviation of $l/4$.
The traps are initially filled to 50\% of trap concentration and the initial mobile atom concentration is set to $C_T^0 = 1$ atom/m$^3$.


The evolution of the mobile tritium, trapped tritium, and helium concentration, i.e., $C_M$, $C_T$, and C_{He}, respectively,
is governed by

\begin{equation}
    \label{eqn:diffusion_mobile}
    \frac{dC_M}{dt} = - \nabla D \nabla C_M - \text{trap\_per\_free} \cdot \left(\frac{dC_T}{dt} - k C_T \right) - k C_M,
\end{equation}
\begin{equation}
    \label{eqn:trapped_rate}
    \frac{dC_T}{dt} = \alpha_t  \frac {C_T^{empty} C_M } {(N \cdot \text{trap\_per\_free})} - \alpha_r C_T - k C_T,
\end{equation}
\begin{equation}
    \frac{d C_{He}}{dt} = k (C_M + C_T) ,
\end{equation}
where $t$ is the time in s, concentrations are in atoms/m$^3$, and $k= 0.693/t_{1/2}$ is the decay rate constant in 1/s.


The material properties are set to:

WARNING:
$ (1) Diffusivity for t
y=1.58e-4*exp(-308000.0/(8.314*temp)),end
$ (2) Trap release frequency
y=1.0e13*exp(-4.2/8.124e-5/temp),end
$ (3) Trapping frequency for t
y=2.096e15*exp(-308000.0/(8.314*temp)),end
temperature:
tempd=17*273.0












###### TBW
The tritium (T) is uniformly distributed over the thickness of the slab with an initial concentration of $C_T^0 = 1.5 \times 10^{5}$ atoms/m$^3$.
The tritium decays to $^3$He with a half-life of $t_{1/2} = 12.3232$ years.
The concentrations of the two species are calculated.

The evolution of the tritium and helium concentration, $C_T$ and C_{He}, respectively,
are governed by

\begin{equation}
    \label{eqn:diffusion_mobile}
    \frac{dC_M}{dt} = - \nabla D \nabla C_M - \text{trap\_per\_free} \cdot \left(\frac{dC_T}{dt} - k C_T \right) - k C_M,
\end{equation}
\begin{equation}
    \label{eqn:trapped_rate}
    \frac{dC_T}{dt} = \alpha_t  \frac {C_T^{empty} C_M } {(N \cdot \text{trap\_per\_free})} - \alpha_r C_T - k C_T,
\end{equation}
\begin{equation}
    \frac{d C_{He}}{dt} = k (C_M + C_T) ,
\end{equation}
where $t$ is the time in s, concentrations are in atoms/m$^3$, and $k= 0.693/t_{1/2}$ is the decay rate constant in 1/s.

!alert warning title=TMAP8 uses different model parameters than TMAP7
The initial tritium concentration in TMAP7 was defined as $C_T^0 = 1.5$ atoms/m$^3$. To use a more realistic values, TMAP8 uses $C_T^0 = 1.5 \times 10^{5}$ atoms/m$^3$.
Moreover, $k$ is defined as $k= 0.693/t_{1/2}=1.78199 \times 10^{-9} $ 1/s instead of $1.78241 \times 10^{-9} $ 1/s to be fully consistent with the half-life value (assuming 365.25 days in a year).

## Analytical Solution

###### TBW
The concentration of T in atoms/m$^3$, $C_T$, at any given time is given by

\begin{equation}
    C_T = C_T^0 \exp(-kt),
\end{equation}

where $T$ is the time in seconds, $C_T^0 = 1.5 \times 10^{5}$ atoms/m$^3$ is the initial concentration of tritium, and .
Applying a mass balance over the system, the concentration of helium in atoms/m$^3$, $C_{He}$, is given by
\begin{equation}
    C_{He} = C_T^0 \left[1- \exp(-kt) \right].
\end{equation}



### Results

[ver-1jb_results_1] shows the TMAP8 predictions and how they compare to the analytical solution
for the decay of tritium and associated growth of $^3$He in a distributed trap.
TMAP8 matches the analytical solution and can also provide the details of trapped and mobile tritium concentration

!media figures/ver-1jb_comparison_analytical_time_evolution.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=ver-1jb_results_1
    caption= Comparison of TMAP8 predictions against the analytical solution for the decay of tritium and associated growth of $^3$He in a distributed trap.

[ver-1jb_results_2] shows the depth profile of the initial trapped atoms of tritium, the final trapped atoms of
tritium after 45 years, and the distribution of $^3$He at the end of that time across the distributed trap as predicted by TMAP8.

Note that because of $^3$He is given a null diffusivity in this verification problem, the shape of the $^3$He does not broaden.
This could be easily implemented with existing TMAP8 diffusive capabilities, as was shown in many other TMAP8 cases,
including [ver-1d](ver-1d.md).

!media figures/ver-1jb_comparison_analytical_x_profile.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=ver-1jb_results_2
    caption= Concentration profiles of initially trapped tritium that decayed to $^3$He over 45 years.


### Input file

The input file for this case can be found at [/ver-1jb.i].

!bibtex bibliography
