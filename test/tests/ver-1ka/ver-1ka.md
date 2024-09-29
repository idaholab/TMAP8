# ver-1ka

# Simple Volumetric Source

## General Case Description

This problem involves two enclosures connected by a diffusive membrane that follows Sieverts law for diffusion. Both enclosures contain hydrogen ($H_2$), deuterium ($T_2$), and hydrogen deuteride ($HT$). In the first enclosure, there is an initial inventory of only hydrogen ($H_2$) along with a constant volumetric source rate of deuterium ($T_2$). The second enclosure starts out empty.

## Case Set up

This verification problem is taken from [!cite](longhurst1992verification). 
The rise in pressure of $T_2$ molecules in the first enclosure can be monitored by using a non-flow type membrane between the two enclosures. Consequently, the rate of pressure increase can be expressed as:

\begin{equation}
\frac{dP_{T_2}}{dt} = \frac{S}{V} kT
\end{equation}

where $S$ represents the volumetric source rate, $V$ is the volume of the enclosure, $k$ is the Boltzmann constant, and $T$ is the temperature of the enclosure.

Comparison of the TMAP8 results and the analytical solution is shown in
[ver-1ka_comparison_time] as a function of time. The TMAP8 code predictions match very well with the analytical solution.

!media figures/ver-1ka_comparison_time.png
    style=width:50%;margin-bottom:2%
    id=ver-1ka_comparison_time
    caption=Comparison of $T_2$ partial pressure in an enclosure with no loss pathways as function of time calculated through TMAP8 and analytically

## Input files

!style halign=left
The input file for this case can be found at [/ver-1ka.i], which is different from the input file used as test in TMAP8. To limit the computational costs of the test cases, the tests run a version of the file with a coarser mesh and larger time steps. More information about the changes can be found in the test specification file for this case [/ver-1ka/tests].

!bibtex bibliography