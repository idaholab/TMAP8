# ver-1kb

# Henry’s Law Boundaries with No Volumetric Source 

## General Case Description

Two enclosures are separated by a membrane that allows diffusion according to Henry’s law, with no volumetric source present. Enclosure 2 has twice the volume of Enclosure 1.

## Case Set Up

This verification problem is taken from [!cite](ambrosek2008verification). 

Over time, the pressures of T$_2$, which diffuses across the membrane in accordance with Henry’s law, will gradually equilibrate between the two enclosures. 

The concentration in Enclosure 1 is related to the partial pressure and concentration in Enclosure 2 via the interface sorption law:

\begin{equation}
C_s = K P^n = K \left( \frac{C_g RT}{n} \right)
\end{equation}

where $R$ is the ideal gas constant in J/mol/K, $T$ is the temperature in K, $K$ is the solubility, and $n$ is the exponent of the sorption law. For the Henry’s law, $n=1$.


## Results

The TMAP8 pressure evolutions in the two enclosures are shown in [ver-1kb_comparison_time] as a function of time. 

!media comparison_ver-1kb.py 
       image_name=ver-1kb_comparison_time.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1kb_comparison_time
       caption=Equilibration of species pressures under Henry’s law as predicted by TMAP8.

## Input files

!style halign=left
The input file for this case can be found at [/ver-1kb.i], which is also used as tests in TMAP8 at [/ver-1kb/tests].

!bibtex bibliography