# Fuel Cycle Benchmarking

## General Case Description

This benchmarking case is taken from [!cite](meschini2023modeling) to simulate a tritium fuel cycle model using resident time method. The model uses a simplified approach by assigning residence times to simulate tritium flow through each system in a fusion power plant, avoiding complex and unfinished technical details. This approach helps understand the challenges and potential solutions for optimizing tritium inventory management and accelerating fusion energy development.

## Model Description

The fuel cycle model consists of 11 interconnected systems that handle tritium recycling in a fusion power plant as shown in [fuel_cycle_schematic]. Each system processes tritium differently:

<!-- The description for each systems from original paper -->

- Breeding Blanket (BB): Main tritium source through breeding reactions
- Tritium Extraction System (TES): Extracts bred tritium with efficiency η₂
- First Wall (FW): Collects tritium from plasma interactions
- Divertor (DIV): Handles unburned plasma exhaust
- Heat Exchanger (HX): Manages coolant-carried tritium
- Detritiation System (DS): Processes tritium from building atmosphere
- Vacuum Pump (VP): Pumps unburned fuel from plasma chamber
- Fuel Clean-up (FCU): Purifies recycled tritium
- Isotope Separation System (ISS): Separates hydrogen isotopes
- Storage and Management (SM): Maintains fuel inventory
- Tritium Separation Membrane (TS): Additional tritium recovery

!media figures/fuel_cycle_2023_schematic.jpg
       style=width:70%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=fuel_cycle_schematic
       caption=Schematic of the tritium fuel cycle model showing the main systems and tritium flow paths.

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
| Fueling System                         | 11 | -               | -         |
| Tritium Separation Membrane            | 12 | `T_11_membrane` | [eqn:t11] |

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


## Case and Model Parameters

We use the ScalarKernels in MOOSE to calculate the ODEs from 11 systems. All the model parameters are listed in [fuel_cycle_benchmark_table2]:

!table id=fuel_cycle_benchmark_table2=Values of material properties.
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

The model is validated by comparing TMAP8 simulation results with MatLab calculations from [!cite](meschini2023modeling) at first 10 days. [fuel_cycle_comparison] shows excellent agreement in the temporal evolution of tritium inventory across key systems, including breeding blanket, tritium extraction, vacuum pump, and storage systems. The close match validates our implementation using MOOSE's ScalarKernel system to solve the coupled ODEs that describe tritium transfer between systems.

!media comparison_fuel_cycle_benchmark.py
       image_name=fuel_cycle_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=fuel_cycle_comparison
       caption=Comparison of TMAP8 calculation with the MatLab data on the fuel cycle model.

## Input files

!style halign=left
The input file for this case can be found at [/fuel_cycle_benchmark/fuel_cycle.i]. The input file used for testing has fewer time steps to limit computational costs. More information about the changes can be found in the test specification file at [/fuel_cycle_benchmark/tests].

!bibtex bibliography
