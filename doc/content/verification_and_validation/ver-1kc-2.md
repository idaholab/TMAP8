# ver-1kc-2

# Sieverts’ Law Boundaries with No Volumetric Source

## General Case Description

Two enclosures are separated by a membrane that allows diffusion according to Sieverts' law, with no volumetric source present. Enclosure 2 has twice the volume of Enclosure 1.

## Case Set Up

This verification problem is taken from [!cite](ambrosek2008verification).

Unlike the ver-1kc-1 case, which only considers tritium T$_2$, this setup describes a diffusion system in which tritium T$_2$, dihydrogen H$_2$ and tritium hybride HT are modeled across a one-dimensional domain split into two enclosures. The total system length is $2.5 \times 10^{-4}$ m, divided into 100 segments. The system operates at a constant temperature of 500 Kelvin. Initial tritium T$_2$ and dihydrogen H$_2$ pressures are specified as $10^{5}$ Pa for Enclosure 1 and $10^{-10}$ Pa for Enclosure 2. Initially, there is no tritium hybride HT in either enclosures.

The reaction between the species is described as follows

\begin{equation}
\text{H}_2 + \text{T}_2 \leftrightarrow 2\text{HT}
\end{equation}

The diffusion process for each species in the two enclosures can be expressed by

\begin{equation}
\frac{\partial C_1}{\partial t} = \nabla D \nabla C_1,
\end{equation}
and
\begin{equation}
\frac{\partial C_2}{\partial t} = \nabla D \nabla C_2,
\end{equation}

where $C_1$ and $C_2$ represent the concentration fields in enclosures 1 and 2 respectively, $t$ is the time, and $D$ denotes the diffusivity.

This case is similar to the [ver-1kb](ver-1kb.md) case, with the key difference being that sorption here follows Sieverts' law instead of Henry's law.
The concentration in Enclosure 1 is related to the partial pressure and concentration in Enclosure 2 via the interface sorption law:

\begin{equation}
C_1 = K P_2^n = K \left( C_2 RT \right)^n
\end{equation}

where $R$ is the ideal gas constant in J/mol/K, $T$ is the temperature in K, $K$ is the solubility, and $n$ is the exponent of the sorption law. For Sieverts' law, $n=0.5$.

## Results

We assume that $K = \frac{10}{\sqrt{RT}}$, which is expected to result in $C_1 = 10 \sqrt{C_2}$ at equilibrium.
As illustrated in [ver-1kc-2_comparison_time_k10], similarly to ver-1kc-1, T$_2$ and H$_2$ pressures reach equilibrium in both enclosures. What is new, however, is that HT is produced in both enclosures following the sorption law. The concentration ratios for T$_2$, H$_2$, and HT between enclosures 1 and 2, shown in [ver-1kc-2_concentration_ratio_T2_k10], [ver-1kc-2_concentration_ratio_H2_k10], and [ver-1kc-2_concentration_ratio_HT_k10], demonstrate that the results obtained with TMAP8 are consistent with the analytical results derived from the sorption law for $K \sqrt{RT} = 10$.

As shown in [ver-1kc-2_mass_conservation_k10], mass is conserved between the two enclosures over time for all species. The variation in mass is only $0.4$ % for T$_2$ and H$_2$. This variation in mass can be further minimized by refining the mesh, i.e., increasing the number of segments in the domain.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_comparison_time_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_comparison_time_k10
       caption=Evolution of species concentration over time governed by Sieverts' law with $K = \frac{10}{\sqrt{RT}}$.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_concentration_ratio_T2_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_concentration_ratio_T2_k10
       caption=Tritium concentrations ratio between enclosures 1 and 2 at the interface for $K = \frac{10}{\sqrt{RT}}$. This verifies TMAP8's ability to apply Sieverts' law across the interface.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_concentration_ratio_H2_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_concentration_ratio_H2_k10
       caption=Dihydrogen concentrations ratio between enclosures 1 and 2 at the interface for $K = \frac{10}{\sqrt{RT}}$. This verifies TMAP8's ability to apply Sieverts' law across the interface.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_concentration_ratio_HT_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_concentration_ratio_HT_k10
       caption=Tritium hybride concentrations ratio between enclosures 1 and 2 at the interface for $K = \frac{10}{\sqrt{RT}}$. This verifies TMAP8's ability to apply Sieverts' law across the interface.

!media comparison_ver-1kc-2.py
       image_name=ver-1kc-2_mass_conservation_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kc-2_mass_conservation_k10
       caption=Total mass conservation across both enclosures over time for $K = \frac{10}{\sqrt{RT}}$.

## Input files

!style halign=left
The input file for this case can be found at [/ver-1kc-2.i]. To limit the computational costs of the test cases, the tests run a version of the file with a coarser mesh and less number of time steps. More information about the changes can be found in the test specification file for this case [/ver-1kc-2/tests].

!bibtex bibliography
