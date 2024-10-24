# val-2a

# Ion Implantation Experiment

## Test Description

This validation problem is taken from [!cite](anderl1985tritium). This paper describes an ion implantation experiment on a modified 316 stainless steel called Primary Candidate Alloy (PCA). This case is part of the validation suite of TMAP4 and TMAP7 as val-2a [!citep](longhurst1992verification,ambrosek2008verification). The PCA sample is a 0.5 mm thick disk with a diameter of 2.5 cm. It is exposed to a deuterium ion beam on the left side (also called the upstream side of the sample). The TRIM code [!citep](biersack1982stopping) was used in [!cite](longhurst1992verification,ambrosek2008verification) to determine that the average implantation depth for the ions is 11 nm $\pm$ 5.4 nm. Reemission data from the TRIM calculation shows that only 75 % of the incident flux remained in the metal and other 25 % is re-emitted.

One known non-physical feature in the modeling is that the cleanup of the upstream surface is modeled by a simple exponential in time rather than an integrated ion influence, which was interrupted twice during the actual experiment. The pressures upstream and downstream can be ignored and taken as zeros because these low pressures have trivial impact for final flux results [!citep](longhurst1992verification). The comparison between simulations results from TMAP8 and experimental data is reproduced in [val-2a_comparison_TMAP4].

The beam flux and the pressure on the upstream side of the sample during the experiment are presented in [val-2a_flux_and_pressure_TMAP4]. Other parameters are shown in [val-2a_set_up_values_TMAP4]. From TRIM, the peak flux from 8 nm to 12 nm is 0.25 $\times$ beam flux, the peak flux from 12 nm to 16 nm is 1.0 $\times$ beam flux, and peak beam flux from 16 nm to 20 nm is 0.25 $\times$ beam flux.

!table id=val-2a_flux_and_pressure_TMAP4 caption=Values of beam flux and pressure on the upstream side of the sample during the experiment [!citep](longhurst1992verification).
| time (s)      | Pressure (Pa)              | Beam flux (atom/m$^2$/s)     |
| ---------     | -------------------------- | ---------------------------- |
| 0 - 5820      | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 5820 - 9056   | 9$\times 10^{-6}$          | 0                            |
| 9056 - 12062  | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 12062 - 14572 | 9$\times 10^{-6}$          | 0                            |
| 14572 - 17678 | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 17678 - 20000 | 9$\times 10^{-6}$          | 0                            |

!alert warning title=Typo in [!cite](longhurst1992verification)
The times of starting and stopping the beam in [!cite](longhurst1992verification) are not accurate, TMAP8 uses the times from [!cite](anderl1985tritium) directly to get better fit on results.

!table id=val-2a_set_up_values_TMAP4 caption=Values of material properties.
| Parameter | Description                       | Value                                                       | Units                 |
| --------- | --------------------------------- | ----------------------------------------------------------- | --------------------- |
| $K_{d,l}$ | dissociation constant upstream     | 8.959 $\times 10^{18} (1-0.9999 \exp(-6 \times 10^{-5} t))$ | at/m$^2$/s/Pa$^{0.5}$ |
| $K_{d,r}$ | dissociation constant on downstream    | 1.7918$\times 10^{15}$                                      | at/m$^2$/s/Pa$^{0.5}$ |
| $K_{r,l}$ | recombination constant on upstream    | 1$\times 10^{-27} (1-0.9999 \exp(-6 \times 10^{-5} t))$     | m$^4$/at/s            |
| $K_{r,r}$ | recombination constant on downstream   | 2$\times 10^{-31}$                                          | m$^4$/at/s            |
| $D$       | deuterium diffusivity in PCA      | 3$\times 10^{-10}$                                          | m$^2$/2               |
| $d$       | diameter of PCA                   | 0.025                                                       | m                     |
| $l$       | thickness of PCA                  | 5$\times 10^{-4}$                                           | m                     |
| $T$       | temperature                       | 703                                                         | K                     |


!alert note title=This validation case replicate TMAP4 rather than TMAP7 due to inconsistent data. 
TMAP4 [!citep](longhurst1992verification) and TMAP7 [!citep](ambrosek2008verification) both replicate this validation case. However, they use different model parameters and configurations, and the experimental data presented in the experimental data in [!citep](ambrosek2008verification) for TMAP7 do not correspond to the data published in [!cite](anderl1985tritium). We therefore replicate only the data from TMAP4 in this TMAP8 validation case.

## Results

[val-2a_comparison_TMAP4] shows the comparison of the TMAP8 calculation and the experimental data from [!cite](anderl1985tritium). There is reasonable agreement between the TMAP predictions and the experimental data with a root mean square percentage error of RMSPE = 26.10 %. Note that the agreement could be improved by adjusting the model parameters. It is also possible to perform this optimization with [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html).
!media comparison_val-2a.py
       image_name=val-2a_comparison_TMAP4.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2a_comparison_TMAP4
       caption=Comparison of TMAP8 calculation with the experimental data on the downstream side of the sample. TMAP8 accurately replicate the experimental data. 

## Input files

!style halign=left
The input file for this case can be generated by combining the base file [/val-2a_base.i] with the case specific file [/val-2a_TMAP4.i]. These files are also used as test in TMAP8 at [/val-2a/tests].

!bibtex bibliography
