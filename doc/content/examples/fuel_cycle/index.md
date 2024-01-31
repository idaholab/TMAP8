# Fuel Cycle

This demonstration re-creates the tritium fuel cycle model described by [!cite](Abdou2021). First, we instantiate a mesh

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=Mesh

For our purposes this does nothing, but MOOSE requires a defined mesh as a placeholder to run the rest of the simulation.

Next, we need to define our system. Following the convention in [!cite](Abdou2021), we have 11 modeled systems, each with
their own ODE and tritium inventory:

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
\frac{dI_1}{dt} = \Lambda \dot{N}^{-} + (1-\eta_2)\frac{I_2}{\tau_2} - \frac{I_1}{\tau_1} - I_1\lambda
\end{equation}

\begin{equation}
\label{eqn:t2}
\frac{dI_2}{dt} = (1-f_{1-5})\frac{I_1}{\tau_1} - \frac{I_2}{\tau_2} - I_2\lambda
\end{equation}

\begin{equation}
\label{eqn:t3}
\frac{dI_3}{dt} = f_{p-3}\frac{\dot{N}^{-}}{\eta_f f_b} + f_{5-3}(1-f_{5-6})(1-f_{5-10})\frac{I_5}{\tau_5} + f_{6-3}(1-\eta_6)\frac{I_6}{\tau_6} - \frac{I_3}{\tau_3} - I_3\lambda
\end{equation}

\begin{equation}
\label{eqn:t4}
\frac{dI_4}{dt} = f_{p-4}\frac{\dot{N}^{-}}{\eta_f f_b} + (1-f_{5-3})(1-f_{5-6})(1-f_{5-10})\frac{I_5}{\tau_5} + (1-f_{6-3})(1-\eta_6)\frac{I_6}{\tau_6} - \frac{I_4}{\tau_4} - I_4\lambda
\end{equation}

\begin{equation}
\label{eqn:t5}
\frac{dI_5}{dt} = f_{1-5}\frac{I_1}{\tau_1}  + \frac{I_3}{\tau_3} + \frac{I_4}{\tau_4} - \frac{I_5}{\tau_5} - I_5\lambda
\end{equation}

\begin{equation}
\label{eqn:t6}
\frac{dI_6}{dt} = f_{5-6}(1-f_{5-10})\frac{I_5}{\tau_5} - \frac{I_6}{\tau_6} - I_6\lambda
\end{equation}

\begin{equation}
\label{eqn:t7}
\frac{dI_7}{dt} = (1-\eta_f f_b - f_{p-3} - f_{p-4})\frac{\dot{N}^{-}}{\eta_f f_b} - \frac{I_7}{\tau_7} - I_7\lambda
\end{equation}

\begin{equation}
\label{eqn:t8}
\frac{dI_8}{dt} = \frac{I_7}{\tau_7} - \frac{I_8}{\tau_8} - I_8\lambda
\end{equation}

\begin{equation}
\label{eqn:t9}
\frac{dI_9}{dt} = (1-f_{8-11})\frac{I_8}{\tau_8} + \frac{I_{10}}{\tau_{10}} + \eta_2 \frac{I_2}{\tau_2} + \eta_6 \frac{I_6}{\tau_6} - \frac{I_9}{\tau_9} - I_9\lambda
\end{equation}
\begin{equation}
\label{eqn:t10}
\frac{dI_{10}}{dt} = f_{5-10}\frac{I_5}{\tau_5} + f_{9-10}\frac{I_9}{\tau_9} - \frac{I_{10}}{\tau_{10}} - I_{10}\lambda
\end{equation}
\begin{equation}
\label{eqn:t11}
\frac{dI_{11}}{dt} = f_{8-11}\frac{I_8}{\tau_8} + (1-f_{9-10})\frac{I_9}{\tau_9} - \frac{\dot{N}^{-}}{\eta_f f_b} - I_{11}\lambda
\end{equation}

We instantiate the variables in the typical [`Variables`](/syntax/Variables) block, making sure to set the [!param](/Variables/family) attribute to `SCALAR` for each variable.
The default initial condition is zero.

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=Variables

Next we initiate the [`ScalarKernels`](/syntax/ScalarKernels) block. We can model the time-dependent terms with [`ODETimeDerivative`](/syntax/ScalarKernels/ODETimeDerivative) objects
and the other terms can be lumped in [`ParsedODEKernel`](/syntax/ScalarKernels/ParsedODEKernel) objects. We should have one [`ODETimeDerivative`](/syntax/ScalarKernels/ODETimeDerivative)
 and one (or more) [`ParsedODEKernel`](/syntax/ScalarKernels/ParsedODEKernel) object(s) per equation above. Internally, TMAP8 will sum the contributions of each object, so we need to
negate the [`ParsedODEKernel`](/syntax/ScalarKernels/ParsedODEKernel) equation from its representation above (move it to the left hand side). We use [`Postprocessors`](/syntax/Postprocessors)
to re-use the recurring variables

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=ScalarKernels

Finally, we define the [`Postprocessors`](/syntax/Postprocessors) and set their values to those referenced in [!cite](Abdou2021). Because the [`Postprocessors`](/syntax/Postprocessors) are
inputs, not outputs, we must be careful to properly set the [!param](/Postprocessors/ConstantPostprocessor/execute_on) parameter. We also gather the values of the different variables in
 separate [`Postprocessors`](/syntax/Postprocessors) and take their sum to obtain the total tritium inventory.

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=Postprocessors


Finally, we can set the [`Executioner`](/syntax/Executioner) block. In this case, we ask for a simple [`Transient`](/source/executioners/Transient.html) executioner with an exponentially growing
[`TimeStepper`](/syntax/Executioner/TimeStepper), [`IterationAdaptiveDT`](/source/timesteppers/IterationAdaptiveDT.html).

!listing test/tests/fuel-cycle/fuel_cycle.i link=false block=Executioner

With these blocks set, we can now run the simulation and track tritium inventory.

Implementing a high-fidelity model to replace the default values of specific postprocessors or to more accurately model
specific components is an exercise left for a later date.

### Comparing Results against literature

In order to compare against [!cite](Abdou2021), we need to make a few assumptions. First, we set the residence times and other parameters to the values listed in Tables 1-3
(the underlined if there are multiple options). Here we also assume that the "Fuel clean-up and isotope separation system" total residence time of 4 hours as specified in the
paper is broken down into 0.5 hour for the vacuum pump, 1.3 hours for the fuel clean-up system and another 2.2 hours for the isotope separation system.

Targeting the black lines of Figure 3, We also need to determine the appropriate reserve inventory $\frac{\dot{N}^-}{\eta_f f_b}t_r q$, which, given $q=0.25$ and
 $t_r=1\ \text{day}$ comes out to 127.5 kg. With this constraint, we can determine the relevant TBR to obtain a doubling time of 5 years, and iterating by hand, a value of 1.511145 yields a
doubling time of 5 years to three decimal places if `T_11_storage` is given an initial condition of 220.925 as shown in [!ref](assumptions).

Assumptions


!table id=assumptions caption=Assumptions and iterated conditions used for this example.
| Parameter | Value |
| --- | --- |
| `residence7` | 1800 s |
| `residence8` | 4680 s |
| `residence9` | 7920 s |
| `TBR` | 1.511145 |
| `T_11_storage` | 220.925 kg |



We compare our results with those from the black lines in [!cite](Abdou2021) Figure 3 in [!ref](comparison). The shaded regions are estimates of the values shown in the paper,
and the lines are the results from the model. There is fairly good agreement, though some of the individual inventories, in particular the
the isotope separation system, which is sensitive to the residence times assumed for the inner fuel cycle, is smaller than expected. This may be due to a different partitioning
of residence time between the systems than was assumed above.

!media examples/figures/fuel_cycle_abdou_03.png id=comparison caption=Tritium inventories of specific systems as a function of time. Shaded regions are best estimate of Figure 3 in [!cite](Abdou2021)
lines are model results.

!listing test/tests/fuel-cycle/fuel_cycle.i

!bibtex bibliography
