# val-2a

# Diffusion Experiment in Beryllium

## Test Description

This validation problem is taken from [!cite](anderl1985tritium). He and co-workers conducted an ion implantation experiment on a modified 316 stainless steel called Primary Candidate Alloy (PCA). The PCA sample has 0.5 mm thick and has a diameter of 2.5 cm. It is exposed to an deuterium ion beam on the left side. The TRIM code ([!citep](biersack1982stopping)) is used to determine that the average implantation depth for the ions is 11 nm $\pm$ 5.4 nm. Reemission data from the TRIM calculation shows that only 75 % of the incident flux remained in the metal and other 25 % is re-emitted.

One known non-physical feature in the modeling is that the cleanup of the upstream surface was modeled by a simple exponential in time rather than an integrated ion influence which was interrupted twice during the actual experiment. The pressures upstream and downstream are proved to be inconsequential; they could have been taken as zero and obtained essentially the same results. The comparison between results from TMAP8 and experiment is reproduced in [val-2a_comparison_TMAP7] here.

!table id=val-2a_flux_and_pressure_TMAP7 caption=Values of beam flux and pressure on the left side during experiment.
| time (s)      | Pressure (Pa)              | Beam flux (atom/m$^2$/s)     |
| ---------     | -------------------------- | ---------------------------- |
| 0 - 5820      | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 5820 - 9060   | 9$\times 10^{-6}$          | 0                            |
| 9060 - 12160  | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 12160 - 14472 | 9$\times 10^{-6}$          | 0                            |
| 14472 - 17678 | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 17678 - 20000 | 9$\times 10^{-6}$          | 0                            |

!table id=val-2a_set_up_values_TMAP7 caption=Values of material properties.
| Parameter | Description                       | Value                                                           | Units                 |
| --------- | --------------------------------- | --------------------------------------------------------------- | --------------------- |
| $K_{d,l}$ | dissociation constant on left     | 8.959 $\times 10^{18} (1-0.999997 \exp(-1.2 \times 10^{-4} t))$ | at/m$^2$/s/Pa$^{0.5}$ |
| $K_{d,r}$ | dissociation constant on right    | 1.7918 $\times 10^{15}$                                         | at/m$^2$/s/Pa$^{0.5}$ |
| $K_{r,l}$ | recombination constant on left    | 7$\times 10^{-27} (1-0.999997 \exp(-1.2 \times 10^{-4} t))$     | m$^4$/at/s            |
| $K_{r,r}$ | recombination constant on right   | 2$\times 10^{-31}$                                              | m$^4$/at/s            |
| $D$       | deuterium diffusivity in PCA      | 3$\times 10^{-10}$                                              | m$^2$/2               |
| $d$       | diameter of PCA                   | 0.025                                                           | m                     |
| $l$       | thickness of PCA                  | 5$\times 10^{-4}$                                               | m                     |
| $T$       | temperature                       | 703                                                             | K                     |


!table id=val-2a_flux_and_pressure_TMAP4 caption=Values of beam flux and pressure on the left side during experiment.
| time (s)      | Pressure (Pa)              | Beam flux (atom/m$^2$/s)     |
| ---------     | -------------------------- | ---------------------------- |
| 0 - 6420      | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 6420 - 9420   | 9$\times 10^{-6}$          | 0                            |
| 9420 - 12480  | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 12480 - 14940 | 9$\times 10^{-6}$          | 0                            |
| 14940 - 18180 | 4$\times 10^{-5}$          | 4.9$\times 10^{19}$          |
| 18180 - 20000 | 9$\times 10^{-6}$          | 0                            |

!table id=val-2a_set_up_values_TMAP4 caption=Values of material properties.
| Parameter | Description                       | Value                                                       | Units                 |
| --------- | --------------------------------- | ----------------------------------------------------------- | --------------------- |
| $K_{d,l}$ | dissociation constant on left     | 8.959 $\times 10^{18} (1-0.9999 \exp(-6 \times 10^{-5} t))$ | at/m$^2$/s/Pa$^{0.5}$ |
| $K_{d,r}$ | dissociation constant on right    | 1.7918$\times 10^{15}$                                      | at/m$^2$/s/Pa$^{0.5}$ |
| $K_{r,l}$ | recombination constant on left    | 1$\times 10^{-27} (1-0.9999 \exp(-6 \times 10^{-5} t))$     | m$^4$/at/s            |
| $K_{r,r}$ | recombination constant on right   | 2$\times 10^{-31}$                                          | m$^4$/at/s            |
| $D$       | deuterium diffusivity in PCA      | 3$\times 10^{-10}$                                          | m$^2$/2               |
| $d$       | diameter of PCA                   | 0.025                                                       | m                     |
| $l$       | thickness of PCA                  | 5$\times 10^{-4}$                                           | m                     |
| $T$       | temperature                       | 703                                                         | K                     |

Due to the parameters from TMAP4 and TMAP7 are different, the case considers both situations. In TMAP7, the beam flux and the pressure on the left during the experiment are presented in [val-2a_flux_and_pressure_TMAP7]. Other parameters are shown in [val-2a_set_up_values_TMAP7]. From TRIM, the peak flux from 5 nm to 9 nm is 0.15 $\times$ beam flux, the peak flux from 9 nm to 13 nm is 0.70 $\times$ beam flux, and peak beam flux from 13 nm to 17 nm is 0.15 $\times$ beam flux. The permeation flux from the sample gives a good fit to the experimental data as shown in [val-2a_comparison_TMAP7]. In TMAP4, the beam flux and the pressure on the left during the experiment are presented in [val-2a_flux_and_pressure_TMAP4]. Other parameters are shown in [val-2a_set_up_values_TMAP4]. From TRIM, the peak flux from 8 nm to 12 nm is 0.25 $\times$ beam flux, the peak flux from 12 nm to 16 nm is 1.0 $\times$ beam flux, and peak beam flux from 16 nm to 20 nm is 0.25 $\times$ beam flux. The permeation flux from the sample gives a good fit to the experimental data as shown in [val-2a_comparison_TMAP4].


## Results

[val-2a_comparison_TMAP4] and [val-2a_comparison_TMAP7] shows the comparison of the TMAP8 calculation and the experimental data. There is reasonable agreement between the TMAP predictions and the experimental data with the root mean square percentage error of RMSPE = 29.91 % and RMSPE = 61.17 %, respectively. Note that the agreement could be improved by adjusting the model parameters. It is also possible to perform this optimization with [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html).

### Comparison based on data from TMAP4

!media comparison_val-2a.py
       image_name=val-2a_comparison_TMAP4.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2a_comparison_TMAP4
       caption=Comparison of TMAP8 calculation with the experimental data on right side with unit of atom/m$^2$/s

### Comparison based on data from TMAP7

!media comparison_val-2a.py
       image_name=val-2a_comparison_TMAP7.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2a_comparison_TMAP7
       caption=Comparison of TMAP8 calculation with the experimental data on right side with unit of atom/m$^2$/s

## Input files

!style halign=left
The input files for this case can be found at [/val-2a_base.i], [/val-2a_TMAP4.i], and [/val-2a_TMAP7.i], which are also used as test in TMAP8 at [/val-2a/tests].

!bibtex bibliography
