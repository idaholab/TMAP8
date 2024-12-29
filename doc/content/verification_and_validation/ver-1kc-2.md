# ver-1kc-2

# Sieverts’ Law Boundaries with Chemical Reactions and No Volumetric Source

## General Case Description

Two enclosures are separated by a membrane that allows diffusion according to Sieverts' law and chemical reactions, with no volumetric source present. Enclosure 2 has twice the volume of Enclosure 1.

## Case Set Up

This verification problem is taken from [!cite](ambrosek2008verification).

Unlike the (ver-1kc-1)[ver-1kc-1.md] case, which only considers tritium T$_2$, this setup describes a diffusion system in which tritium T$_2$, dihydrogen H$_2$ and HT are modeled across a one-dimensional domain split into two enclosures. The total system length is $2.5 \times 10^{-4}$ m, divided into 100 segments. The system operates at a constant temperature of 500 Kelvin. Initial tritium T$_2$ and dihydrogen H$_2$ pressures are specified as $10^{5}$ Pa for Enclosure 1 and $10^{-10}$ Pa for Enclosure 2. Initially, there is no HT in either enclosure.

The reaction between the species is described as follows

\begin{equation}
\text{H}_2 + \text{T}_2 \leftrightarrow 2\text{HT}
\end{equation}

The kinematic evolutions of the species are given by the following equations

\begin{equation}
\frac{d C_{\text{HT}}}{dt} = 2K_1 C_{\text{H}_2} C_{\text{T}_2} - K_2 C_{\text{HT}}^2
\end{equation}

\begin{equation}
\frac{d C_{\text{H}_2}}{dt} = -K_1 C_{\text{H}_2} C_{\text{T}_2} + \frac{1}{2} K_2 C_{\text{HT}}^2
\end{equation}

\begin{equation}
\frac{d C_{\text{T}_2}}{dt} = -K_1 c_{\text{H}_2} C_{\text{T}_2} + \frac{1}{2} K_2 C_{\text{HT}}^2
\end{equation}

where $K_1$ and $K_2$ represent the reaction rates for the forward and reverse reactions, respectively.

At equilibrium, the time derivatives are zero

\begin{equation}
2K_1 C_{\text{H}_2} C_{\text{T}_2} - K_2 C_{\text{HT}}^2 = 0
\end{equation}

From this, we can derive the same equilibrium condition as used in TMAP7:

\begin{equation}
P_{\text{HT}} = \eta \sqrt{P_{\text{H}_2} P_{\text{T}_2}}
\end{equation}

where the equilibrium constant $\eta$ is defined as

\begin{equation} \label{eq:eta}
\eta = \sqrt{\frac{2K_1}{K_2}}
\end{equation}

Similarly to TMAP7, the equilibrium constant $\eta$ has been set to a fixed value of $\eta = 2$.

The diffusion process for each species in the two enclosures can be expressed by

\begin{equation}
\frac{\partial C_1}{\partial t} = \nabla D \nabla C_1,
\end{equation}
and
\begin{equation}
\frac{\partial C_2}{\partial t} = \nabla D \nabla C_2,
\end{equation}

where $C_1$ and $C_2$ represent the concentration fields in enclosures 1 and 2 respectively, $t$ is the time, and $D$ denotes the diffusivity.
Note that the diffusivity may vary across different species and enclosures. However, in this case, it is assumed to be identical for all.

The concentration in Enclosure 1 is related to the partial pressure and concentration in Enclosure 2 via the interface sorption law:

\begin{equation}
C_1 = K P_2^n = K \left( C_2 RT \right)^n
\end{equation}

where $R$ is the ideal gas constant in J/mol/K, $T$ is the temperature in K, $K$ is the solubility, and $n$ is the exponent of the sorption law. For Sieverts' law, $n=0.5$.

## Results

We assume that $K = 10/\sqrt{RT}$, which is expected to result in $C_1 = 10 \sqrt{C_2}$ at equilibrium.
As illustrated in [ver-1kc-2_comparison_time_k10], similarly to ver-1kc-1, T$_2$ and H$_2$ pressures reach equilibrium in both enclosures. What is new, however, is that HT is produced in both enclosures following the sorption law.

Thus, it is crucial to ensure that the chemical equilibrium between HT, T$_2$ and H$_2$ is achieved. This can be verified in both enclosures by examining the ratio between $P_{\text{HT}}$ and $\sqrt{P_{\text{H}_2} P_{\text{T}_2}}$, which must equal $\eta=2$.
As shown in [ver-1kc-2_equilibrium_constant_k10], this ratio approaches $\eta=2$ for both enclosures, as observed in TMAP7. However, achieving this balance involves a compromise. On one hand, $K_1$ must be sufficiently large to ensure that the chemical kinetics in Enclosure 1 are significantly faster than other processes, such as diffusion and surface sorption. On the other hand, $K_2$ should not be excessively large, as this could hinder the diffusion of species into Enclosure 2, where no species are initially present.

The concentration ratios for T$_2$, H$_2$, and HT between enclosures 1 and 2, shown in [ver-1kc-2_concentration_ratio_T2_k10], [ver-1kc-2_concentration_ratio_H2_k10], and [ver-1kc-2_concentration_ratio_HT_k10], demonstrate that the results obtained with TMAP8 are consistent with the analytical results derived from the sorption law for $K \sqrt{RT} = 10$.

As shown in [ver-1kc-2_mass_conservation_k10], mass is conserved between the two enclosures over time for all species. The variation in mass is only $0.4$ % for T$_2$ and H$_2$. This variation in mass can be further minimized by refining the mesh, i.e., increasing the number of segments in the domain.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_comparison_time_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_comparison_time_k10
       caption=Evolution of species concentration over time governed by Sieverts' law with $K = 10/\sqrt{RT}$.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_equilibrium_constant_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_equilibrium_constant_k10
       caption=Equilibrium constant as a function of time.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_concentration_ratio_T2_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_concentration_ratio_T2_k10
       caption=T$_2$ concentration ratio between enclosures 1 and 2 at the interface for $K = 10/\sqrt{RT}$. This verifies TMAP8's ability to apply Sieverts' law across the interface.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_concentration_ratio_H2_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_concentration_ratio_H2_k10
       caption=H$_2$ concentration ratio between enclosures 1 and 2 at the interface for $K = 10/\sqrt{RT}$. This verifies TMAP8's ability to apply Sieverts' law across the interface.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_concentration_ratio_HT_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_concentration_ratio_HT_k10
       caption=HT concentration ratio between enclosures 1 and 2 at the interface for $K = 10/\sqrt{RT}$. This verifies TMAP8's ability to apply Sieverts' law across the interface.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_mass_conservation_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_mass_conservation_k10
       caption=Total mass conservation across both enclosures over time for $K = 10/\sqrt{RT}$.

## Input files

!style halign=left
The input file for this case can be found at [/ver-1kc-2.i].

!bibtex bibliography
