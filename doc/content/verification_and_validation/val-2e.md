# val-2ea

# Co-permeation of H$_2$ and D$_2$ through Pd

## Case Description

This validation problem is taken from [!cite](kizu2001co).
This paper describes the permeation experiments in which H$_2$ and D$_2$ permeate through thin Pd membranes either separately or together.
This case is part of the validation suite of TMAP7 as val-2e [!citep](ambrosek2008verification).

The experimental equipment has two vacuum chambers separated by a Pd membrane.
The membrane area is 1.8 $\times 10^{-4}$ m$^2$ and has thicknesses of either 0.025 mm or 0.05 mm, depending on the test.
Copper gaskets hold the membrane in place. Gas can only move from one chamber to the other by diffusing through the membrane.
The membrane's temperature is controlled between 820 and 870 K using an electric heater and a thermocouple.
Gas is supplied to one chamber (the upstream chamber) from regulated bottles at different compositions and pressures.
he base pressure on both upstream and downstream chambers is maintained below 1 $\times 10^{-6}$ Pa using turbomolecular and rotary pumps.
Pressure is measured by an ion gage on each side, and downstream gas composition is measured with a quadrupole mass spectrometer.
Flow rates through the membrane are determined by pressure increases in the downstream chamber at a fixed pumping rate of 0.1 m$^3$/s.

The structure of the equipment is shown in [val-2e_equipment_schematic].
Enclosure 1 is the source of background pressure to the experimental system.
Enclosure 4 is the vacuum pumping system that provides a sink for all system flows.
Enclosure 5 is the gas feed to the upstream experimental chamber, Enclosure 2.
The pressures in Enclosure 1, 4, and 5 are hold a constant or a functional value while the pressures in enclosure 2 and 3 are varied according to the flow and diffusion.
Depending on the experiment, the feed pressure of H$_2$ is 0, 0.14, or 0.063 Pa.
Combined with the evacuation to enclosure 4, this provides the upstream H$_2$ pressure for permeation.
The D$_2$ pressure is a stepped function of time, one step corresponding to each of the data points in the data plots from [!cite](kizu2001co).
Steps are arbitrarily set at 100 s, but equilibrium is achieved in times much shorter than that. Effectively no HD is fed into the upstream experimental chamber, in keeping with the experimental setup given by [!cite](kizu2001co).
Rather, with either solution-law or recombination limited-boundary conditions for diffusion, HD is formed in accordance with the laws of chemical equilibrium.
Likewise in the downstream chamber, enclosure 3, HD is formed together with H$_2$ and D$_2$ in chemical equilibrium from diffusing H and D.

!media figures/val-2e_equipment_schematic.png
        style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
        id=val-2e_equipment_schematic
        caption=Schematic of the modeled enclosures for val-2e.

The first three test cases are permeation tests of D$_2$ alone through membranes of each thickness.
For the 0.025 membrane, tests are conducted at both 825 K and 865 K whereas the 0.05 mm membrane is tested only at 825 K.
[] shows the experimental data for deuterium permeation flux versus upstream D2 pressure. We run corresponding simulations for the three test cases separately, to calibrate the permeability of the membranes for hydrogen isotopes in TMAP8 model.

The next two test cases are co-permeation of H$_2$ and D$_2$ through membrane of 0.025 mm at 870 K.
We separately compare the experimental permeation flux with two simulations using two lawdep and ratedep boundary condition on the membrane.


## Model Description

In first three cases, TMAP8 simulates a one-dimensional domain to represent the deuterium diffusion and gas flowing in enclosure.
Note that this case can easily be extended to a two- or three-dimensional case.

This model considers the diffusion of deuterium on both sides of Pd membrane.
First, the diffusion of deuterium in membrane is described as:

\begin{equation} \label{eq:diffusion}
\frac{d C_i}{d t} = \nabla D_i \nabla C_i,
\end{equation}

where $C_i$ is the concentration of hydrogen isotope $i$ in membrane,
$i$ represents hydrogen isotope H or D,
$t$ is the time,
$D_i$ is the diffusivity of hydrogen isotope $i$.

The flow of gas into enclosures 2 and 3 can be given by

\begin{equation} \label{eq:dt_P2}
\frac{P_{Ij}}{dt} = \frac{Q (P_{I,j-1}-P_{Ij})}{V_j},
\end{equation}

where $Q$ is the volumetric flow rate of always 0.1 m$^3$/s,
$V_j$ is the volume of current enclosure $j$, $P_{I,j-1}$ and $P_{I,j}$ are the pressure of gas molecules $I$ in the previous enclosure and current enclosure, gas molecules $I$ represents H$_2$, or D$_2$, or HD.

The hydrogen isotope recombines into gas on both sides of the membrane.
By assuming that the recombination process is at steady state, the concentrations on both sides are describe by

\begin{equation} \label{eq:seivert_concentration}
C_i = K_s P_{Ij}^{n},
\end{equation}

where $K_s$ is the solubility of hydrogen isotope in membrane, and $n$ is the exponent for the relation of pressure and concentration.

The co-permeation simulation with lawdep uses the same sievert boundary condition,
whereas, the simulation with ratedep uses the recombination boundary condition, which is described as

\begin{equation} \label{eq:recombination}
J_{ij} = 2 A (K_r C_i^2 - K_d P_{Ij}),
\end{equation}

where $J_{ij}$ is the recombination flux of hydrogen isotope $i$ out of the sample sides in enclosure $j$,
$A$ is the area on the upstream or downstream side,
and $K_r$ and $K_d$ are the recombination and dissociation coefficients, respectively.
The coefficient of 2 accounts for the fact that 2 atoms form one isotope molecule.

The two co-permeation simulations also include the chemical reactions on upstream and downstream enclosure.
The reaction rates for H$_2$, D$_2$, and HD are described by

\begin{equation} \label{eq:chemical_reaction_lawdep}
\frac{- 2 d P_{H_2}}{dt} = \frac{- 2 d P_{D_2}}{dt} = \frac{d P_{HD}}{dt} = 2 P_{H_2}^{0.5} P_{D_2}^{0.5}
\end{equation}

for lawdep boundary condition and

\begin{equation} \label{eq:chemical_reaction_ratedep}
\frac{- 2 d P_{H_2}}{dt} = \frac{- 2 d P_{D_2}}{dt} = \frac{d P_{HD}}{dt} = \frac{k_b T A}{V} (K_r C_H C_D - K_d P_{HD}),
\end{equation}

for ratedep boundary condition,
where $k_b$ is the Boltzmann’s constant,
$A$ is the surface area of the membrane,
$T$ are the temperature.

## Case and Model Parameters

The pressure history of deuterium on the enclosure 5 for first three simulations (val-2ea, val-2eb, and val-2ec) is presented in [val-2e_abc_pressure_history], as shown in [val-2e_comparison_pressure_history]. The initial pressures on other enclosures are presented in [val-2e_abc_pressure_initial].

!table id=val-2e_abc_pressure_history caption=Values of deuterium pressure on enclosure 5 during simulations val-2ea, val-2eb, and val-2ec [!citep](ambrosek2008verification).
| time (s)      | Pressure $P_{D_2,5}$ (Pa)      |
| ---------     | ---------------------------- |
| 0 - 150       | 1.2 $\times 10^{-4}$         |
| 150 - 250     | 2.41 $\times 10^{-4}$        |
| 250 - 350     | 6.06 $\times 10^{-4}$        |
| 350 - 450     | 1.3 $\times 10^{-3}$         |
| 450 - 550     | 2.53 $\times 10^{-3}$        |
| 550 - 650     | 7.08 $\times 10^{-3}$        |
| 650 - 750     | 1.45 $\times 10^{-2}$        |
| 750 - 850     | 2.63 $\times 10^{-2}$        |
| 850 - 950     | 6.51 $\times 10^{-2}$        |
| 950 - 1050    | 1.16 $\times 10^{-1}$        |
| 1050 - 1150   | 2.97 $\times 10^{-1}$        |
| 1150 - 1250   | 7.6 $\times 10^{-1}$         |
| 1250 - 1350   | 1.55                         |
| 1350 - 1900   | 3.37                         |

!media comparison_val-2e.py
       image_name=val-2e_comparison_pressure_history.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2e_comparison_pressure_history
       caption= The pressure history of D$_2$ in enclosure 5 for simulations val-2ea, val-2eb, and val-2ec.

!table id=val-2e_abc_pressure_initial caption=Values of deuterium pressure during simulations val-2ea, val-2eb, and val-2ec [!citep](ambrosek2008verification).
| Parameter | Description                          | Value                                                       | Units                 |
| --------- | ------------------------------------ | ----------------------------------------------------------- | --------------------- |
| $P_{D_2,1}$ | Deuterium pressure in enclosure 1    | 1 $\times 10^{-6}$                                          | Pa                    |
| $P_{D_2,2}$ | Deuterium pressure in enclosure 2    | 1 $\times 10^{-6}$                                          | Pa                    |
| $P_{D_2,3}$ | Deuterium pressure in enclosure 3    | 1 $\times 10^{-6}$                                          | Pa                    |
| $P_{D_2,4}$ | Deuterium pressure in enclosure 4    | 1 $\times 10^{-10}$                                         | Pa                    |

The pressure history of D$_2$ on the enclosure 5 for next two simulations (val-2ed and val-2ee) is presented in [val-2e_de_pressure_history], as shown in [val-2e_comparison_mixture_pressure_history]. The initial pressures on other enclosures are presented in [val-2e_de_pressure_initial].

!table id=val-2e_de_pressure_history caption=Values of deuterium pressure on enclosure 5 during simulations val-2ed and val-2ee [!citep](ambrosek2008verification).
| time (s)      | Pressure $P_{D_2,5}$ (Pa)      |
| ---------     | ---------------------------- |
| 0 - 150       | 1.8421 $\times 10^{-4}$      |
| 150 - 250     | 1 $\times 10^{-3}$           |
| 250 - 350     | 3 $\times 10^{-3}$           |
| 350 - 450     | 9 $\times 10^{-3}$           |
| 450 - 550     | 2.7 $\times 10^{-2}$         |
| 550 - 650     | 8.1 $\times 10^{-2}$         |
| 650 - 750     | 2.43 $\times 10^{-1}$        |
| 750 - 1000    | 7.29 $\times 10^{-1}$        |

!media comparison_val-2e.py
       image_name=val-2e_comparison_mixture_pressure_history.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2e_comparison_mixture_pressure_history
       caption= The pressure history of D$_2$ in enclosure 5 for simulations val-2ed and val-2ee.

!table id=val-2e_de_pressure_initial caption=Values of pressure of H$_2$, D$_2$, and HD during simulations val-2ed and val-2ee [!citep](ambrosek2008verification).
| Parameter   | Description                          | Value                                                    | Units                 |
| ----------- | ------------------------------------ | -------------------------------------------------------- | --------------------- |
| $P_{D_2,1}$ | D$_2$ pressure in enclosure 1        | 1 $\times 10^{-7}$                                       | Pa                    |
| $P_{H_2,1}$ | H$_2$ pressure in enclosure 1        | 1 $\times 10^{-7}$                                       | Pa                    |
| $P_{HD,1}$  | HD pressure in enclosure 1           | 1 $\times 10^{-7}$                                       | Pa                    |
| $P_{D_2,2}$ | initial D$_2$ pressure in enclosure 2 | 1 $\times 10^{-7}$                                      | Pa                    |
| $P_{H_2,2}$ | initial H$_2$ pressure in enclosure 2 | 6.3 $\times 10^{-2}$                                    | Pa                    |
| $P_{HD,2}$  | initial HD pressure in enclosure 2   | 1 $\times 10^{-7}$                                       | Pa                    |
| $P_{D_2,3}$ | initial D$_2$ pressure in enclosure 3 | 1 $\times 10^{-20}$                                     | Pa                    |
| $P_{H_2,3}$ | initial H$_2$ pressure in enclosure 3 | 1 $\times 10^{-20}$                                     | Pa                    |
| $P_{HD,3}$  | initial HD pressure in enclosure 3   | 1 $\times 10^{-20}$                                      | Pa                    |
| $P_{D_2,4}$ | D$_2$ pressure in enclosure 4        | 1 $\times 10^{-10}$                                      | Pa                    |
| $P_{H_2,4}$ | H$_2$ pressure in enclosure 4        | 1 $\times 10^{-10}$                                      | Pa                    |
| $P_{HD,4}$  | HD pressure in enclosure 4           | 1 $\times 10^{-10}$                                      | Pa                    |
| $P_{H_2,5}$ | H$_2$ pressure in enclosure 4        | 6.3 $\times 10^{-2}$                                     | Pa                    |
| $P_{HD,5}$  | HD pressure in enclosure 4           | 1 $\times 10^{-10}$                                      | Pa                    |


!alert note title=Updates of times and initial pressures in val-2ee to be consistent with val-2ed.
In [!cite](ambrosek2008verification), the times and initial pressures in val-2ee are different from these values in val-2ed. However, we use the same values from val-2ed in val-2ee for consistency. The trivial difference on times and initial pressures will not impact the final results.

Other case and model parameters used in TMAP8 are listed in [val-2e_parameters]:


!table id=val-2e_parameters caption=Values of material properties.
| Parameter | Description                          | Value                                                       | Units                 | Reference                 |
| --------- | ------------------------------------ | ----------------------------------------------------------- | --------------------- | --------------------- |
| $k_b$     | Boltzmann constant                   | 1.380649 $\times 10^{-23}$                                  | J/K                   | [PhysicalConstants.h](https://physics.nist.gov/cgi-bin/cuu/Value?r) |
| $R$       | Gas constant                         | 8.31446261815324                                            | J/mol/K               | [PhysicalConstants.h](https://physics.nist.gov/cgi-bin/cuu/Value?r) |
| $A$ | surface area  | 1.8$\times 10^{-4}$                                      | m$^2$ | [!cite](kizu2001co) |
| $V$ | enclosure volume   | 0.005     | m$^3$            | [!cite](kizu2001co) |
| $T_1$ | temperature in val-2ea and val-2eb | 825                                          | K            | [!cite](kizu2001co) |
| $T_2$ | temperature in val-2ec | 865                                          | K            | [!cite](kizu2001co) |
| $T_3$ | temperature in val-2ed and val-2ee | 870                                          | K            | [!cite](kizu2001co) |
| $Q$   | flow rate in all enclosures         | 0.1                       | m$^3$/s                   | [!cite](ambrosek2008verification) |
| $L_1$ | thinckness of membrane in val-2ea     | 5$\times 10^{-5}$         | m                    | [!cite](kizu2001co) |
| $L_2$ | thinckness of membrane in val-2eb, val-2ec, val-2ed, val-2ee | 2.5$\times 10^{-5}$ | m          | [!cite](kizu2001co) |
| $D_H$ | hydrogen diffusivity in membrane         | 3.728$\times 10^{-4} \exp(-1315.8/T)$        | m$^2$/s              | [!cite](katz1960permeability) |
| $D_D$ | deuterium diffusivity in membrane         | 2.636$\times 10^{-4} \exp(-1315.8/T)$        | m$^2$/s              | [!cite](ambrosek2008verification) |
| $K_{s,1}$ | solubility of hydrogen isotope in val-2ea, val-2eb, val-2ec  | 1.511$\times 10^{23} \exp(-5918/T)$        | atom/m$^3$/Pa$^{0.9297}$  | [!cite](ambrosek2008verification) |
| $K_{s,2}$ | solubility of hydrogen isotope in val-2ed, val-2ee  | 9.355$\times 10^{22} \exp(-5918/T)$        | atom/m$^3$/Pa$^{0.9297}$  | [!cite](ambrosek2008verification) |
| $n$ | exponent for the relation of pressure and concentration | 0.9297         | -                     | [!cite](kizu2001co) |
| $K_{r,D_2}$ | D$_2$ recombination coefficient | 2.502$\times 10^{-24} / \sqrt(4T) \exp(11836/T)$        | m$^4$/s              | [!cite](ambrosek2008verification) |
| $K_{r,H_2}$ | H$_2$ recombination coefficient | 2.502$\times 10^{-24} / \sqrt(2T) \exp(11836/T)$        | m$^4$/s              | [!cite](ambrosek2008verification) |
| $K_{r,HD}$ | HD recombination coefficient | 2.502$\times 10^{-24} / \sqrt(3T) \exp(11836/T)$        | m$^4$/s              | [!cite](ambrosek2008verification) |
| $K_{d,D_2}$ | D$_2$ dissociation coefficient | 2.1897$\times 10^{22} / \sqrt(4T)$     | molecular/m$^2$/Pa              | [!cite](ambrosek2008verification) |
| $K_{d,H_2}$ | H$_2$ dissociation coefficient | 2.1897$\times 10^{22} / \sqrt(2T)$     | molecular/m$^2$/Pa              | [!cite](ambrosek2008verification) |
| $K_{d,HD}$ | HD dissociation coefficient | 2.1897$\times 10^{22} / \sqrt(3T)$     | molecular/m$^2$/Pa              | [!cite](ambrosek2008verification) |

## Results

[val-2e_comparison_diffusion] shows the comparison of the TMAP8 calculation and the experimental data from [!cite](kizu2001co), including simulations val-2ea, val-2eb, and val-2ec. There are reasonable agreements between the TMAP predictions and the experimental data with root mean square percentage errors of RMSPE = 22.17 %, 23.68 %, and 23.21 % for val-2ea, val-2eb, and val-2ec.
[val-2e_comparison_mixture_diffusion] shows the comparison of the D$_2$, H$_2$, and HD flux versus effective D$_2$ pressure on the upstream side of the membrane from TMAP8 calculation using lawdep condition and the experimental data. The effective D$_2$ pressure is calculated using $P_{D_2} + 0.5 P_{HD}$. There is not a good agreement except for H$_2$ at low pressure, and D$_2$ at high pressure. Which is similar to the results from TMAP7. The root mean square percentage errors are RMSPE = 66.07 %, 49.18 %, 119.67 %, 22.96 % for H$_2$, D$_2$, HD, and the summation of all gas.
[val-2e_comparison_mixture_diffusion_recombination] shows the comparison of the D$_2$, H$_2$, and HD flux versus effective D$_2$ pressure on the upstream side of the membrane from TMAP8 calculation using ratedep condition and the experimental data. There are reasonable agreement between the TMAP predictions and the experimental data with root mean square percentage errors of RMSPE = 14.14 %, 58.53  %, 85.22 %, 59.57  % for H$_2$, D$_2$, HD, and the summation of all gas.
Note that the agreement could be improved by adjusting the model parameters. It is also possible to perform this optimization with [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html).

!media comparison_val-2e.py
       image_name=val-2e_comparison_diffusion.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2e_comparison_diffusion
       caption= Comparison of the D$_2$ flux versus D$_2$ pressure on the upstream side of the membrane from TMAP8 calculation and the experimental data.

!media comparison_val-2e.py
       image_name=val-2e_comparison_mixture_diffusion.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2e_comparison_mixture_diffusion
       caption= Comparison of the D$_2$, H$_2$, and HD flux versus effective D$_2$ pressure on the upstream side of the membrane from TMAP8 calculation using lawdep condition and the experimental data.

!media comparison_val-2e.py
       image_name=val-2e_comparison_mixture_diffusion_recombination.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2e_comparison_mixture_diffusion_recombination
       caption= Comparison of the D$_2$, H$_2$, and HD flux versus effective D$_2$ pressure on the upstream side of the membrane from TMAP8 calculation using ratedep condition and the experimental data.

## Input files

!style halign=left
The input file for this case can be generated by [/val-2ea.i], [/val-2ed.i], and [/val-2ee.i]. The file are also used as test in TMAP8 at [/val-2e/tests].

!bibtex bibliography
