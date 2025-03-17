# Fuel Cycle Benchmarking from [!cite](meschini2023modeling)

## General Case Description

In this case, TMAP8 reproduces the fuel cycle model from [!cite](meschini2023modeling), which consitutes a benchmark
The model uses a simplified approach by assigning residence times to simulate tritium flow through each system in a fusion power plant, avoiding the complex, high-fidelity description of the fuel cycle. This approach helps minimize computational cost and understand the challenges and potential solutions for optimizing tritium inventory management and accelerating fusion energy development.
To increase the fidelity of the simulation, TMAP8 enables performing component level simulation in parallel to provide model parameters in the fuel cycle using the multi-app system.

This case represents an update from the [previous fuel cycle model](examples/fuel_cycle/index.md), which reproduced the model from [!cite](Abdou2021).

## Model Description

The fuel cycle model consists of 11 interconnected systems that handle tritium recycling in a fusion power plant, as shown in Fig. 1 from [!cite](meschini2023modeling). Each system processes tritium differently:

- Breeding Blanket (BB): Generates tritium through breeding reactions with lithium using neutrons from fusion reactions in vacuum chamber. This is the main tritium source for sustaining the fusion reaction.

- Tritium Extraction System (TES): Processes and extracts tritium from the breeding blanket with an extraction efficiency $\eta_2$. The extracted tritium is directed to the tritium permeation membrane while unextracted tritium flows to the heat exchanger.

- First Wall (FW): Interface between plasma and breeding blanket that collects implanted tritium from plasma interactions.

- Divertor (DIV): Collects unburned plasma exhaust and tritium through direct plasma implantation. Similar to the first wall, it experiences tritium permeation to the breeding blanket and receives tritium from heat exchanger leaks.

- Heat Exchanger (HX): Manages coolant-carried tritium from TES and redistributes it to BB, FW, DIV, and detritiation systems. This component plays a crucial role in tritium redistribution throughout the system.

- Detritiation System (DS): Processes tritium from building atmosphere and receives input from both heat exchanger leaks and ISS. It acts as an environmental safety system by capturing and processing tritium that escapes into the facility atmosphere.

- Vacuum Pump (vacuum): Extracts unburned fuel and fusion productions from the plasma chamber. A portion of the pumped tritium goes to direct internal recycling while the rest is sent for processing through the fuel cleanup system.

- Fuel Clean-up (FCU): Seperates hydrogen isotopes from exhaust gas. The hydrogen isotopes is then sent to the isotope separation system for further processing.

- Isotope Separation System (ISS): Separates and purifies hydrogen isotopes from various input streams. It receives tritium from both FCU and DS, processing it for either storage or recycling through DS.

- Storage and Management (storage): Maintains and manages the fuel inventory, receiving purified tritium from ISS and supplying fuel for plasma operation. It serves as the main tritium repository for the fuel cycle.

- Fueling System (FS): Injects fresh fuel into the vacuum chamber for plasma operation. While not directly modeled in the tritium inventory calculations, its function is represented through an outflux term in the storage and management system equations equal to the tritium fueling rate.

- Tritium Permeation Membrane (membrane): Provides additional tritium recovery from the TES output stream with high efficiency, helping to minimize losses and maximize tritium recovery for fuel cycle sustainability.

The label and corresponding equation for each systems are shown in [tritium_systems].

!table id=tritium_systems caption=Systems and labels used in this example.
| System Name | System number | Tritium inventory variable| system equation |
| --- | --- | --- | --- |
| Breeding Blanket                       | 1  | `T_01_BB`       | [eqn:t1] |
| Tritium Extraction System              | 2  | `T_02_TES`      | [eqn:t2] |
| First Wall                             | 3  | `T_03_FW`       | [eqn:t3] |
| Divertor                               | 4  | `T_04_DIV`      | [eqn:t4] |
| Heat Exchanger                         | 5  | `T_05_HX`       | [eqn:t5] |
| Detritiation System                    | 6  | `T_06_DS`       | [eqn:t6] |
| Vaccum Pump                            | 7  | `T_07_vacuum`   | [eqn:t7] |
| Fuel Clean-up                          | 8  | `T_08_FCU`      | [eqn:t8] |
| Isotope Separation System              | 9  | `T_09_ISS`      | [eqn:t9] |
| Storage and Management                 | 10 | `T_10_storage`  | [eqn:t10] |
| Tritium Permeation Membrane            | 11 | `T_11_membrane` | [eqn:t11] |

!alert note title=The fuel cycle of Tritium in Fueling System is ignored
Fueling system only injects fresh fuel in the vacuum chamber and is not modeled in the fuel cycle to simplify the model. Instead, an outflux equal to the tritium fueling rate is added to the equation describing the storage and management system.

\begin{equation}
\label{eqn:t1}
\frac{dI_1}{dt} = TBR \cdot \dot{N}_{T,burn} + \frac{I_3}{\tau_3} + \frac{I_4}{\tau_4} + f_{5-1} \frac{I_5}{\tau_5} - \frac{I_1}{\tau_1}- \frac{I_1\varepsilon_1}{\tau_1} - I_1\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t2}
\frac{dI_2}{dt} = \frac{I_1}{\tau_1} - \frac{I_2}{\tau_2} - \frac{I_2\varepsilon_2}{\tau_2} - I_2\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t3}
\frac{dI_3}{dt} = f_{p-3} \frac{ \dot{N}_{T,burn} }{TBE} + f_{5-3}\frac{I_5}{\tau_5} - \frac{I_3}{\tau_3} - \frac{I_3\varepsilon_3}{\tau_3} - I_3\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t4}
\frac{dI_4}{dt} = f_{p-4}\frac{\dot{N}_{T,burn}}{TBE} + f_{5-4}\frac{I_5}{\tau_5} - \frac{I_4}{\tau_4} - \frac{I_4\varepsilon_4}{\tau_4}  - I_4\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t5}
\frac{dI_5}{dt} = (1 - \eta_2)\frac{I_2}{\tau_2} - \frac{I_5}{\tau_5} -\frac{I_5\varepsilon_5}{\tau_5} - I_5\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t6}
\frac{dI_6}{dt} = f_{5-6}\frac{I_5}{\tau_5} + f_{9-6}\frac{I_9}{\tau_9} - \frac{I_6}{\tau_6} - \frac{I_6\varepsilon_6}{\tau_6} - I_6\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t7}
\frac{dI_7}{dt} = (1- TBE - f_{p-3} - f_{p-4}) \frac{\dot{N}_{T,burn}}{TBE} - \frac{I_7}{\tau_7} - \frac{I_7\varepsilon_7}{\tau_7} - I_7\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t8}
\frac{dI_8}{dt} = (1 - f_{DIR}) \frac{I_7}{\tau_7} - \frac{I_8}{\tau_8} - \frac{I_8\varepsilon_8}{\tau_8} - I_8\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t9}
\frac{dI_9}{dt} =  \frac{I_6}{\tau_6} + \frac{I_8}{\tau_8} - \frac{I_9\varepsilon_9}{\tau_9} - \frac{I_9}{\tau_9} - I_9\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t10}
\frac{dI_{10}}{dt} = (1 - f_{9-6}) \frac{I_9}{\tau_9} + f_{DIR} \frac{I_7}{\tau_7} + \frac{I_{11}}{\tau_{11}} - \frac{\dot{N}_{T,burn}}{TBE} - I_{10}\lambda ,
\end{equation}

\begin{equation}
\label{eqn:t11}
\frac{dI_{11}}{dt} = \eta_2 \frac{I_2}{\tau_2} - \frac{I_{11}}{\tau_{11}} - \frac{I_{11}\varepsilon_{11}}{\tau_{11}} - I_{11}\lambda ,
\end{equation}

where $TBE$, the tritium burn efficiency, is defined as:

\begin{equation}
\label{eqn:TBE}
TBE = \eta_f f_b
\end{equation}

Compared to the [previous fuel cycle model](examples/fuel_cycle/index.md), this model from [!cite](meschini2023modeling) includes both direct internal recycling in the Vacuum Pump and Fuel Clean-up systems. This direct internal recycling introduces an additional shortcut between the storage system and exhaust gas, reducing the tritium inventory in the fuel cycle. In addition, Tritium Permeation System can separate tritium from gas mixture extracted from Breeding Blanket, enhancing the tritium recycling process. Except for these component updates, this model uses $TBE$ to represent the production of fueling efficiency and burn fraction as described in [!cite](Abdou2021). The definition of $TBE$ is more suitable for explaining the fueling process in a fusion reaction under equilibrium conditions.


## Case and Model Parameters

We use the ScalarKernels in MOOSE to calculate the ODEs from 11 systems. All the model parameters are listed in [fuel_cycle_benchmark_table2]:

!table id=fuel_cycle_benchmark_table2 caption=Values of material properties.
| Parameter | Description                          | Value                                                       | Units                 |
| --------- | ------------------------------------ | ----------------------------------------------------------- | --------------------- |
| TBR       | Tritium breeding ratio               | 1.067                                                       | -                     |
| TBE       | Tritium burn efficiency in plasma    | 0.025                                                       | -                     |
| AF        | Availability factor                  | 0.75                                                        | -                     |
| $\varepsilon_i$ | Fraction of tritium lost from non-radioactive phenomena in the $i$th component | 1e-4 except for FW and DIV system            | -               |
| $\eta_f$  | Fueling efficiency                   | 0.25                                                        | -                     |
| $f_b$     | Tritium burn fraction in the plasma  | 0.10                                                        | -                     |
| $\eta_2$  | Tritium extraction efficiency        | 0.7                                                         | -                     |
| $f_{DIR}$ | Direct internal recycling fraction   | 0.5                                                         | -                     |
| $I_i$     | Tritium inventory in the $i$th component | -                                                       | kg                    |
| $\dot{N}_{T,burn}$ | Tritium burn rate           | 8.99e-7                                                     | -                     |
| $\lambda$ | Tritium decay rate                   | 1.73e-9                                                     | s$^{-1}$              |
| $t$       | time                                 | -                                                           | s                     |
| $\tau_i$  | Tritium residence time in the $i$th component | 4500 in $\tau_1$, 86400 in $\tau_2$, 1000 in $\tau_3$, $\tau_4$, $\tau_5$, 3600 in $\tau_6$, 600 in $\tau_7$, 585 in $\tau_8$, 22815 in $\tau_9$, 100 in $\tau_11$ | s                     |

## Results

The model is benchmarked by comparing TMAP8 simulation results with MatLab calculations from [!cite](meschini2023modeling) during the first 20 days. [fuel_cycle_comparison] shows excellent agreement in the temporal evolution of tritium inventory across key systems, including breeding blanket, tritium extraction, vacuum pump, and storage systems. The close match properly benchmarks our implementation in TMAP8 using MOOSE's ScalarKernel system to solve the coupled ODEs describing tritium transfer between systems.

!media comparison_fuel_cycle_benchmark.py
       image_name=fuel_cycle_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=fuel_cycle_comparison
       caption=Comparison of TMAP8 calculation with the data of fuel cycle model from [!cite](meschini2023modeling).

!alert note title=The comparison only considers first 20 days.
The csv file from [!cite](meschini2023modeling) for a three-year simulation has a large storage size due to the short time intervals used. To reduce storage costs, we only compare the TMAP8 simulation results with MatLab calculations from [!cite](meschini2023modeling) for the first 20 days.

## Input files

!style halign=left
The input file for this case can be found at [/fuel_cycle_benchmark/fuel_cycle.i]. As same as the [previous fuel cycle model](examples/fuel_cycle/index.md), we initialize the tritium mass for all systems with 0 kg except for tritium in storage system with `initial_inventory` of 1.14 kg.

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=Variables

In [`ScalarKernels`](/syntax/ScalarKernels) block, all the ODEs from 11 systems in [tritium_systems] are built using [`ODETimeDerivative`](/syntax/ScalarKernels/ODETimeDerivative) and [`ParsedODEKernel`](/syntax/ScalarKernels/ParsedODEKernel) objects.

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=ScalarKernels

In [`Functions`](/syntax/Functions) block, we create functions to simulate the period influenced by the availability factor and ensures the time interval is shorter than this period. However, the input file used for testing considers an averaged tritium breeding ratio instead of a period to increase the time interval and reduce computational costs. During testing, the simulation uses the period to represent the availability factor before `accuracy_time` and switches to using the averaged value after `accuracy_time`. More information about the changes can be found in the test specification file at [/fuel_cycle_benchmark/tests].

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=Functions

In [`Postprocessors`](/syntax/Postprocessors) block, we initialize all necessary parameters related to the input flow, output flow, radiation, and source term for each system.

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=Postprocessors

In [`UserObjects`](/syntax/UserObjects) block, we define `Terminator` to stop the simulation once running out of the tritium in storage system ot total tritium. Then, we use a [`Transient`](/source/executioners/Transient.html) executioner to solve the fuel cycle model in [`Executioner`](/syntax/Executioner) block.

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=UserObjects

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=Executioner

!bibtex bibliography
