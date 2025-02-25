# val-2a

# Ion Implantation Experiment

## Case Description

This validation problem is taken from [!cite](anderl1985tritium). This paper describes an ion implantation experiment on a modified 316 stainless steel called Primary Candidate Alloy (PCA). This case is part of the validation suite of TMAP4 and TMAP7 as val-2a [!citep](longhurst1992verification,ambrosek2008verification). The PCA sample is a 0.5 mm thick disk with a diameter of 2.5 cm. It is exposed to a deuterium ion beam on the left side (also called the upstream side of the sample). The TRIM code [!citep](biersack1982stopping) was used in [!cite](longhurst1992verification,ambrosek2008verification) to determine that the average implantation depth for the ions is 11 nm $\pm$ 5.4 nm. Reemission data from the TRIM calculation shows that only 75 % of the incident flux remained in the metal and other 25 % is re-emitted.

This model considers the diffusion in PCA and the recombination of deuterium on both sides. First, the diffusion of deuterium in PCA is described as:

\begin{equation} \label{eq:diffusion}
\frac{d C}{d t} = \nabla D \nabla C + S,
\end{equation}

where $C$ is the concentration of deuterium in PCA, $t$ is the time, $D$ is the diffusivity of deuterium in PCA, and $S$ is the source term in PCA due to the deuterium ion implantation.

Second, the deuterium recombines into gas on both sides of the PCA sample. By assuming that the recombination process is at steady state (which is not a necessary assumption in TMAP8, but appropriate in this case), it is described as the following surface flux:

\begin{equation} \label{eq:recombination}
J = 2 A (K_r C^2 - K_d P),
\end{equation}

where $J$ is the recombination flux out of the sample sides, $A$ is the area on the upstream or downstream side, $P$ is the pressure on the corresponding side, and $K_r$ and $K_d$ are the recombination and dissociation coefficients, respectively. The coefficient of 2 accounts for the fact that 2 deuterium atoms form one D$_2$ molecule.

The objective of this simulation is to determine the permeation flux on the downstream side and match the experimental data published in [!cite](anderl1985tritium) and reproduced in [val-2a_comparison].

## Model Description

In this case, TMAP8 simulates a one-dimensional domain to represent the deuterium implantation, diffusion, and recombination. Note that this case can easily be extended to a two- or three-dimensional case.

The source term in the model is described as a normal distribution instead of the piecewise function from TMAP4 [!citep](longhurst1992verification). The source term of deuterium from ion beam implantation is defined as:

\begin{equation} \label{eq:normal_distribution}
S = F \frac{1.5}{\sigma \sqrt{2 \pi}} \exp \left( - \frac{(x - \mu )^2}{2 \sigma^2} \right),
\end{equation}

where $F$ is the implantation flux provided in [val-2a_flux_and_pressure_TMAP4], $\sigma = 2.4 \times 10^{-9}$ m is the characteristic width of the normal distribution, and $\mu = 14 \times 10^{-9}$ m is the depth of the normal distribution from the upstream side. [eq:normal_distribution] uses the same factor of 1.5 from [!cite](longhurst1992verification) to better correspond to implantation of experiment from [!cite](anderl1985tritium). The comparison between the normal distribution from TMAP8 and piecewise function from TMAP4 is shown in [val-2a_normal_distribution]. The normal distribution has a similar distribution to the piecewise function, but the distribution profile is closer to the expected implantation profile.

!media comparison_val-2a.py
       image_name=val-2a_comparison_normal_distribution.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2a_normal_distribution
       caption= Comparison between the normal distribution from TMAP8 and piecewise function from TMAP4 for the source term due to deuterium ion beam implantation.

The pressures on the upstream and downstream sides are close to vacuum pressures, and have only little impact for the recombination on both sides [!citep](longhurst1992verification,ambrosek2008verification). Thus, TMAP8 ignores the impact of pressure on the boundary conditions to simplify the model. The recombination is described as a simplified version of [eq:recombination]:

\begin{equation} \label{eq:recombination_ignore_Pressure}
J = 2 A K_r C^2.
\end{equation}

## Case and Model Parameters

The beam flux on the upstream side of the sample during the experiment is presented in [val-2a_flux_and_pressure_TMAP4], and only 75% of the flux remains in the sample. Other case and model parameters used in TMAP8 are listed in [val-2a_set_up_values_TMAP4].

!table id=val-2a_flux_and_pressure_TMAP4 caption=Values of beam flux on the upstream side of the sample during the experiment [!citep](anderl1985tritium,longhurst1992verification).
| time (s)      | Beam flux $F$ (atom/m$^2$/s)   |
| ---------     | ---------------------------- |
| 0 - 5820      | 4.9$\times 10^{19}$          |
| 5820 - 9056   | 0                            |
| 9056 - 12062  | 4.9$\times 10^{19}$          |
| 12062 - 14572 | 0                            |
| 14572 - 17678 | 4.9$\times 10^{19}$          |
| 17678 - 20000 | 0                            |

!alert warning title=Typo in [!cite](longhurst1992verification)
The times listed in [!cite](longhurst1992verification) for TMAP8 for the start and end times of the beam are not accurate. Instead, TMAP8 uses the times directly from [!cite](anderl1985tritium) to better correspond to experimental conditions.

!table id=val-2a_set_up_values_TMAP4 caption=Values of material properties. Note that $K_d$ are currently not used in the input file since the upstream and downstream pressure do not noticeably influence the results.
| Parameter | Description                          | Value                                                       | Units                 | Reference                 |
| --------- | ------------------------------------ | ----------------------------------------------------------- | --------------------- | --------------------- |
| $K_{d,l}$ | upstream dissociation coefficient    | 8.959 $\times 10^{18} (1-0.9999 \exp(-6 \times 10^{-5} t))$ | at/m$^2$/s/Pa$^{0.5}$ | [!cite](longhurst1992verification) |
| $K_{d,r}$ | downstream dissociation coefficient  | 1.7918$\times 10^{15}$                                      | at/m$^2$/s/Pa$^{0.5}$ | [!cite](longhurst1992verification) |
| $K_{r,l}$ | upstream recombination coefficient   | 1$\times 10^{-27} (1-0.9999 \exp(-6 \times 10^{-5} t))$     | m$^4$/at/s            | Inspired from [!cite](longhurst1992verification) |
| $K_{r,r}$ | downstream recombination coefficient | 2$\times 10^{-31}$                                          | m$^4$/at/s            | [!cite](anderl1985tritium) |
| $P_{l}$   | upstream pressure                    | 0                                                           | Pa                    | [!cite](anderl1985tritium) |
| $P_{r}$   | downstream pressure                  | 0                                                           | Pa                    | [!cite](anderl1985tritium) |
| $D$       | deuterium diffusivity in PCA         | 3$\times 10^{-10}$                                          | m$^2$/s               | [!cite](anderl1985tritium) |
| $d$       | diameter of PCA                      | 0.025                                                       | m                     | [!cite](anderl1985tritium) |
| $l$       | thickness of PCA                     | 5$\times 10^{-4}$                                           | m                     | [!cite](anderl1985tritium) |
| $T$       | temperature                          | 703                                                         | K                     | [!cite](anderl1985tritium) |


!alert note title=This validation case replicates TMAP4 rather than TMAP7 due to inconsistent experiment results with [!cite](anderl1985tritium).
TMAP4 [!citep](longhurst1992verification) and TMAP7 [!citep](ambrosek2008verification) both replicate this validation case. However, they use different model parameters and configurations, and the experimental data presented in [!citep](ambrosek2008verification) for TMAP7 do not correspond to the data published in [!cite](anderl1985tritium). We therefore replicate only the data from TMAP4 and [!cite](anderl1985tritium) in this TMAP8 validation case.

!alert note title=The upstream recombination and dissociation coefficients as time-dependent exponentials.
Both TMAP4 [!citep](longhurst1992verification) and TMAP7 [!citep](ambrosek2008verification) describe the upstream recombination and dissociation coefficients as time-dependent exponentials rather than mechanistically capture the influence of ion irradiation on material performance. TMAP8 uses the same expressions.

## Results

[val-2a_comparison] shows the comparison of the TMAP8 calculation and the experimental data from [!cite](anderl1985tritium). There is reasonable agreement between the TMAP predictions and the experimental data with a root mean square percentage error of RMSPE = 25.95 %. Note that the agreement could be improved by adjusting the model parameters. It is also possible to perform this optimization with [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html).

!media comparison_val-2a.py
       image_name=val-2a_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2a_comparison
       caption=Comparison of TMAP8 calculation with the experimental data on the downstream side of the sample. TMAP8 accurately replicates the experimental data.

## Input files

!style halign=left
The input file for this case can be generated by [/val-2a.i]. The file are also used as test in TMAP8 at [/val-2a/tests].

!bibtex bibliography
