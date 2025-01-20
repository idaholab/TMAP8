# Fuel Cycle Benchmarking

## Case Description

This benchmarking case is taken from [!cite](meschini2023modeling) to simulate a fuel cycle model using resident time method. The model assign a resident time instead of complex techinical detail for each fuel cycle system in fuel energy plant. The model help us to understand the urgent difficulty in the development of fusion area in system-level. Lowering the tritium inventory

In the model, we have 11 systems to finish the tritium recycling in fuel cycle. The detail and corresponding ODE for each system are listed in below:

!table id=tritsystems caption=Systems and labels used in this example.
| System Name | System number | Tritium inventory variable| system equation |
| --- | --- | --- | --- |
| Breeding zone | 1 | `T_01_BZ` | [eqn:t1] |
| Tritium Extraction System | 2 | `T_02_TES` | [eqn:t2] |
| First Wall | 3 | `T_03_FW` | [eqn:t3] |
| Divertor | 4 | `T_04_DIV` | [eqn:t4] |
| Heat Exchanger | 5 | `T_05_HX` | [eqn:t5] |
| Coolant Purification System | 6 | `T_06_CPS` | [eqn:t6] |
| Vaccum Pump | 7 | `T_07_vacuum` | [eqn:t7] |
| Fuel Clean-up  | 8 | `T_08_FCU` | [eqn:t8] |
| Isotope Separation System | 9 | `T_09_ISS` | [eqn:t9] |
| Exhaust and Water Detritiation System | 10 | `T_10_exhaust` | [eqn:t10] |
| Storage and Management | 11 | `T_11_storage` | [eqn:t11] |



\begin{equation}
\label{eqn:t1}
\frac{dI_1}{dt} = \Lambda \dot{N}^{-} + (1-\eta_2)\frac{I_2}{\tau_2} - \frac{I_1}{\tau_1}- \frac{I_1\varepsilon_1}{\tau_1} - I_1\lambda
\end{equation}

\begin{equation}
\label{eqn:t2}
\frac{dI_2}{dt} = (1-f_{1-5})\frac{I_1}{\tau_1} - \frac{I_2}{\tau_2} - \frac{I_2\varepsilon_2}{\tau_2} - I_2\lambda
\end{equation}

\begin{equation}
\label{eqn:t3}
\frac{dI_3}{dt} = f_{p-3}\frac{\dot{N}^{-}}{\eta_f f_b} + f_{5-3}(1-f_{5-6})(1-f_{5-10})\frac{I_5}{\tau_5} + f_{6-3}(1-\eta_6)\frac{I_6}{\tau_6} - \frac{I_3}{\tau_3} - \frac{I_3\varepsilon_3}{\tau_3} - I_3\lambda
\end{equation}

\begin{equation}
\label{eqn:t4}
\frac{dI_4}{dt} = f_{p-4}\frac{\dot{N}^{-}}{\eta_f f_b} + (1-f_{5-3})(1-f_{5-6})(1-f_{5-10})\frac{I_5}{\tau_5} + (1-f_{6-3})(1-\eta_6)\frac{I_6}{\tau_6} - \frac{I_4}{\tau_4} - \frac{I_4\varepsilon_4}{\tau_4}  - I_4\lambda
\end{equation}

\begin{equation}
\label{eqn:t5}
\frac{dI_5}{dt} = f_{1-5}\frac{I_1}{\tau_1}  + \frac{I_3}{\tau_3} + \frac{I_4}{\tau_4} - \frac{I_5}{\tau_5} -\frac{I_5\varepsilon_5}{\tau_5} - I_5\lambda
\end{equation}

\begin{equation}
\label{eqn:t6}
\frac{dI_6}{dt} = f_{5-6}(1-f_{5-10})\frac{I_5}{\tau_5} - \frac{I_6}{\tau_6} - \frac{I_6\varepsilon_6}{\tau_6} - I_6\lambda
\end{equation}

\begin{equation}
\label{eqn:t7}
\frac{dI_7}{dt} = (1-\eta_f f_b - f_{p-3} - f_{p-4})\frac{\dot{N}^{-}}{\eta_f f_b} - \frac{I_7}{\tau_7} - \frac{I_7\varepsilon_7}{\tau_7} - I_7\lambda
\end{equation}

\begin{equation}
\label{eqn:t8}
\frac{dI_8}{dt} = \frac{I_7}{\tau_7} - \frac{I_8}{\tau_8} - \frac{I_8\varepsilon_8}{\tau_8} - I_8\lambda
\end{equation}

\begin{equation}
\label{eqn:t9}
\frac{dI_9}{dt} = (1-f_{8-11})\frac{I_8}{\tau_8} + \frac{I_{10}}{\tau_{10}} + \eta_2 \frac{I_2}{\tau_2} + \eta_6 \frac{I_6}{\tau_6} - \frac{I_9\varepsilon_9}{\tau_9} - \frac{I_9}{\tau_9} - I_9\lambda
\end{equation}
\begin{equation}
\label{eqn:t10}
\frac{dI_{10}}{dt} = f_{5-10}\frac{I_5}{\tau_5} + f_{9-10}\frac{I_9}{\tau_9} - \frac{I_{10}}{\tau_{10}} - \frac{I_{10}\varepsilon_{10}}{\tau_{10}} - I_{10}\lambda
\end{equation}
\begin{equation}
\label{eqn:t11}
\frac{dI_{11}}{dt} = f_{8-11}\frac{I_8}{\tau_8} + (1-f_{9-10})\frac{I_9}{\tau_9} - \frac{\dot{N}^{-}}{\eta_f f_b} - I_{11}\lambda
\end{equation}


## Model Description

We use the ScalarKernels to calculate the ODE from 11 systems.


## Case and Model Parameters

All the model parameters are listed in [fuel_cycle_benchmark_table2]:

!table id=fuel_cycle_benchmark_table2=Values of material properties. Note that parameters marked with * are currently not used in the input file.
| Parameter | Description                          | Value                                                       | Units                 | Reference                 |
| --------- | ------------------------------------ | ----------------------------------------------------------- | --------------------- | --------------------- |
| $k_b$     | Boltzmann constant                   | 1.380649 $\times 10^{-23}$                                  | J/K                   | [PhysicalConstants.h](https://physics.nist.gov/cgi-bin/cuu/Value?r) |
| $F$       | implantation flux                    | 1 $\times 10^{19}$                                          | at/m$^2$/s            | [!cite](hino1998hydrogen) |
| $D_{0,l}$ | maximum diffusivity coefficient when $x < 15 \times 10 ^ {-9}$ m | 4.1 $\times 10^{-7}$            | m$^2$/2               | [!cite](frauenfelder1969solution) |
| $D_{0,r}$ | maximum diffusivity coefficient when $x > 15 \times 10 ^ {-9}$ m | 4.1 $\times 10^{-6}$            | m$^2$/2               | [!cite](ambrosek2008verification) |
| $E_D$     | activity energy for diffusion        | 0.39                                                        | eV                    | [!cite](frauenfelder1969solution) |
| $C_0$     | initial concentration of tritium     | 1 $\times 10^{-10}$                                         | at/m$^3$              | [!cite](ambrosek2008verification) |
| $N$       | host density                         | 6.25 $\times 10^{28}$                                       | at/m$^3$              | [!cite](ambrosek2008verification) |
| $\chi^1_0$ | initial atom fraction in trap 1     | 0                                                           | -                     | [!cite](ambrosek2008verification) |
| $\chi^2_0$ | initial atom fraction in trap 2     | 4.4 $\times 10^{-10}$                                       | -                     | [!cite](ambrosek2008verification) |
| $\chi^3_0$ | initial atom fraction in trap 3     | 1.4 $\times 10^{-10}$                                       | -                     | [!cite](ambrosek2008verification) |
| $\epsilon_t$ | trapping energy for three traps   | 0.39 / k_b                                                  | K                     | [!cite](ambrosek2008verification) |
| $\epsilon_r^1$ | release energy for trap 1       | 1.20 / k_b                                                  | K                     | [!cite](ambrosek2008verification,haasz1999effect) |
| $\epsilon_r^2$ | release energy for trap 2       | 1.60 / k_b                                                  | K                     | [!cite](ambrosek2008verification,anderl1992deuterium) |
| $\epsilon_r^3$ | release energy for trap 3       | 3.10 / k_b                                                  | K                     | [!cite](ambrosek2008verification,frauenfelder1969solution) |
| $\chi^1$  | maximum atom fraction in trap 1      | 0.002156                                                    | -                     | [!cite](ambrosek2008verification) |
| $\chi^2$  | maximum atom fraction in trap 2      | 0.00175                                                     | -                     | Adjusted from [!cite](ambrosek2008verification) |
| $\chi^3$  | maximum atom fraction in trap 3      | 0.00200                                                     | -                     | [!cite](ambrosek2008verification) |
| $\alpha_{t0}$ | pre-factor of trapping rate coefficient | 9.1316 $\times 10^{12}$                              | 1/s                   | [!cite](ambrosek2008verification) |
| $\alpha_{r0}$ | pre-factor of release rate coefficient  | 8.4 $\times 10^{12}$                                 | 1/s                   | [!cite](ambrosek2008verification) |
| $A$       | * area of Tungsten sample              | 0.0025                                                      | m                     | [!cite](hino1998hydrogen) |
| $l$       | thickness of Tungsten sample         | 1 $\times 10^{-4}$                                          | m                     | [!cite](hino1998hydrogen) |
| $T_l$     | lowest temperature                   | 300                                                         | K                     | [!cite](hino1998hydrogen) |
| $T_h$     | highest temperature                  | 1273                                                        | K                     | [!cite](hino1998hydrogen) |
| $k_T$     | heating rate          | 50                                                          | K/min                 | [!cite](hino1998hydrogen) |


## Results


In this case, there is a general background drift on desorption flux due to an increasing source of atoms going into the gas phase as the heated region spread with time. Thus, we add a ramped signal peaking at 4.87 $\times 10^{17}$ H$_2$/m$^2$/s to the results of the TMAP8 during the thermal desorption.
[val-2d_comparison] shows the comparison of the TMAP8 calculation and the experimental data. There is reasonable agreement between the TMAP predictions and the experimental data with the root mean square percentage error of RMSPE = 32.81 %.
Note that the agreement could be improved by adjusting the model parameters and adding more potential traps. TMAP7 is limited to three traps, but TMAP8 can introduce an arbitrarily number of trapping populations. It is also possible to perform this optimization with [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html).

There are several reasons for the no exact fit with the data from [!cite](hino1998hydrogen): the most prominent one is the two-dimensionality of the experiment arising from beam non-uniformity and radial diffusion [!citep](anderl1992deuterium). The actual trap energies are probably a little lower than the ones indicated above if the time lag caused by two-dimensionality is significant. Exchange of hydrogen with chamber surfaces, particularly the sample support structure, may also be a factor.

One reason the measured signal falls off after $\approx$ 6300 s while the computed one remains steady is that the source of additional atoms in the experiment may be an expanding area that grow non-linearly, while the sample is being heated but stopped growing and thus stops emitting when the heating stops.

!media comparison_val-2d.py
       image_name=val-2d_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2d_comparison
       caption=Comparison of TMAP8 calculation with the experimental data on the upstream side of the sample.

## Input files

!style halign=left
The input file for this case can be found at [/fuel_cycle.i]. The input file is different from the input file used as test in TMAP8. To limit the computational costs of the test case, the test runs a version of the file with fewer time steps. More information about the changes can be found in the test specification file for this case, namely [/fuel_cycle_benchmark/tests].


!bibtex bibliography
