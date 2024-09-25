# ver-1ib

# A Species Equilibration Model in Ratedep Conditions with Equal Starting Pressures

## General Case Description

<!-- All necessary equations -->
This verification problem is taken from [!cite](ambrosek2008verification). When two species can react on a surface to form a third, it is possible to predict the rate at which equilibration between the species will occur. For example, consider the reaction between two isotopic species:

\begin{equation}
\frac{1}{2} A_2 + \frac{1}{2} B_2 \rightleftharpoons AB.
\end{equation}

Under ratedep conditions, the conversion rate at the surface is higher than the rate in enclosure. The pressure of AB is described by

\begin{equation}
\frac{d P_{AB}}{dt} = \frac{S k T}{V} (2 K_r C_A C_B - K_d P_{AB}),
\end{equation}
where $P_{AB}$ is the pressure of AB, $C_A$ and $C_B$ are the concentration of $A_2$ and $B_2$ on the reactive surface respectively, S is the surface area, k is the Boltzmann’s constant, T is the temperature, V is the volume in the enclosure, K_r and K_d are the recombination and dissociation rate.

<!-- Detail parameters -->
This case uses equal starting pressures of $1e4$ Pa of $H_2$ and $D_2$ and no $HD$. $K_d$ was specified to be $1.858e24/\sqrt{T}$. Temperature was 1000 K, the surface area for reaction was a 5 cm $\times$ 5 cm square, and the enclosure volume was 1 m$^3$.


## Analytical solution
<!-- introduce the analytical equation and explain -->

The expression for the rate of formation of AB, when the conversion rate at the surface is high, is given in terms of starting molecular partial pressures of $A_2$ and $B_2$ as

\begin{equation}
P_{AB}  = \frac{2 P_{A_2}^0 P_{B_2}^0}{P_{A_2}^0 + P_{B_2}^0} (1 - exp(-\frac{S K_d k T}{V} t))
\end{equation}

<!-- Table for parameters -->
k Boltzmann’s constant
T temperature
S = surface area where reactions take place
V = volume of enclosure adjacent to the surface
The molecular deposition and dissociation rate is often given by

\begin{equation}
K_d  = \frac{1}{\sqrt{2 \pi M k T}}
\end{equation}



## Results

<!-- introduce the numerical result and compare the figures between analytical and results -->

A comparison of the concentration of AB as a function of time is plotted in [ver-1ib_comparison]. The TMAP8 calculations are found to be in good agreement with the analytical solution, with root mean square percentage errors (RMSPE) of RMSPE =  %. The concentration of $H_2$ and $D_2$ as a function of time are also plotted in [ver-1ib_comparison].

!media comparison_ver-1ib.py
       image_name=ver-1ib_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1ib_comparison
       caption=Comparison of concentration of AB as a function of time calculated through TMAP8 and analytically for the solution when A and B have equal pressures [!cite](ambrosek2008verification).

## Input files

!style halign=left
The input file for these cases can be found at [/ver-1ib.i], which is also used as tests in TMAP8 at [/ver-1ib/tests].

!bibtex bibliography
