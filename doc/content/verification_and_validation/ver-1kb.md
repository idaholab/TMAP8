# ver-1kb

# Henry’s Law Boundaries with No Volumetric Source

## General Case Description

Two enclosures are separated by a membrane that allows diffusion according to Henry’s law, with no volumetric source present. Enclosure 2 has twice the volume of Enclosure 1.

## Case Set Up

This verification problem is taken from [!cite](ambrosek2008verification).

Over time, the pressures of T$_2$, which diffuses across the membrane in accordance with Henry’s law, will gradually equilibrate between the two enclosures.

The diffusion process in each of the two enclosures can be described by the following equations:

\begin{equation}
\frac{\partial C_1}{\partial t} = \nabla D \nabla C_1
\end{equation}

\begin{equation}
\frac{\partial C_1}{\partial t} = D \nabla^2 C_1
\end{equation}

where $C_1$, $C_2$ represent the concentration fields in enclosures 1 and 2 respectively, and $D$ denotes the diffusivity.

The concentration in Enclosure 1 is related to the partial pressure and concentration in Enclosure 2 via the interface sorption law:

\begin{equation}
C_1 = K P_2^n = K \left( \frac{C_2 RT}{n} \right)
\end{equation}

where $R$ is the ideal gas constant in J/mol/K, $T$ is the temperature in K, $K$ is the solubility, and $n$ is the exponent of the sorption law. For the Henry’s law, $n=1$.

## Results

Two subcases are considered. In the first subcase, it is assumed that the pressures in the two enclosures are in equilibrium, implying $K = 1/RT$.
Consistent with the results from TMAP7, the pressure evolution in both enclosures is shown in [ver-1kb_comparison_time] as a function of time, confirming the equilibrium between the pressures in enclosures 1 and 2. The linear regression in [ver-1kb_comparison_concentration] demonstrates that the concentration values at the interface comply with the sorption law, with a proportionality coefficient consistent with the solubility value $K = \approx 2.4 \times 10^{-4}$. As shown in [ver-1kb_mass_conservation], mass is conserved between the two enclosures over time.

!media comparison_ver-1kb.py
       image_name=ver-1kb_comparison_time.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kb_comparison_time
       caption=Equilibration of species pressures under Henry’s law for $K=1/RT$.

!media comparison_ver-1kb.py
       image_name=ver-1kb_comparison_concentration.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kb_comparison_concentration
       caption=Concentration in enclosure 1 as a function of pressure in enclosure 2 at the interface for $K=1/RT$. Validation of the sorption law across the interface.

!media comparison_ver-1kb.py
       image_name=ver-1kb_mass_conservation.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kb_mass_conservation
       caption=Total mass conservation across both enclosures over time for $K=1/RT$.

In the second subcase, the sorption law with $K = 10/RT$ prevents the pressures in the two enclosures from reaching equilibrium. As illustrated in [ver-1kb_comparison_time_k10], the pressure jump maintains a ratio of $C_1/C_2 \approx 10$, which is consistent with the relationship $C_1 = K *RT * C_2$ for $K=10/RT$. The linear regression in [ver-1kb_comparison_concentration_k10] confirms that the concentration values at the interface adhere to the sorption law, with a proportionality coefficient aligned with the solubility value $K = \approx 2.4 \times 10^{-5}$. Additionally, [ver-1kb_mass_conservation_k10] verifies that mass is conserved between the two enclosures over time.

!media comparison_ver-1kb.py
       image_name=ver-1kb_comparison_time_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kb_comparison_time_k10
       caption=Pressures jump of species pressures under Henry’s law for $K=10/RT$.

!media comparison_ver-1kb.py
       image_name=ver-1kb_comparison_concentration_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kb_comparison_concentration_k10
       caption=Concentration in enclosure 1 as a function of pressure in enclosure 2 at the interface for $K=10/RT$. Validation of the sorption law across the interface.

!media comparison_ver-1kb.py
       image_name=ver-1kb_mass_conservation_k10.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kb_mass_conservation_k10
       caption=Total mass conservation across both enclosures over time for $K=10/RT$.

## Input files

!style halign=left
The input file for this case can be found at [/ver-1kb.i], which is also used as tests in TMAP8 at [/ver-1kb/tests].

!bibtex bibliography
