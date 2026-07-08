# PCC Multiscale Fuel-Cycle Example

## General Case Description

This example integrates a component-level proton-conducting-ceramic (PCC) membrane model into a
system-level tritium fuel-cycle model to examine the potential of PCC membranes as a tritium
extraction technology and as direct internal recycling (DIR) pathways. The two scales are coupled
directly using the MOOSE MultiApp system, with the fuel-cycle model serving as the main application
and the PCC membrane model serving as a sub-application. This coupling evaluates the impact of the
voltage-driven membrane performance predictions from the validated PCC membrane model
[!cite](yang2026elucidating) on fuel-cycle components, rather than treating membrane performance as
a fixed efficiency.

The tritium fuel-cycle configuration includes 11 subsystems based on the fuel-cycle example from
Meschini et al. reproduced in TMAP8 [!cite](meschini2023modeling,simon2026): the Breeding Blanket,
Tritium Extraction System, First Wall, Divertor, Heat Exchanger, Detritiation System, Vacuum Pump,
Fuel Clean-up, Isotope Separation System, Storage and Management, and the Tritium Permeation
Membrane. The baseline model represents each major component as a zero-dimensional inventory with
input and output flows, source terms, non-radioactive losses, and radioactive decay.

## Model Description

The time-dependent tritium retention in each component $i$ is represented by an ordinary
differential equation based on residence time [!cite](abdou2020physics,meschini2023modeling):

\begin{equation}
\label{eqn:pcc_multiscale_fuel_cycle}
\frac{dI_i}{dt} = \sum_{j\neq i}{\frac{I_j}{\tau_j}}  - \left(1+\epsilon_i\right)\frac{I_i}{\tau_i} - \lambda I_i + S_i,
\end{equation}

where $I_i$ and $\tau_i$ are the tritium inventory and residence time of component $i$, $\epsilon_i$
represents non-radioactive tritium losses, $\lambda$ is the radioactive decay constant, and $S_i$ is
the tritium source term.

The PCC membrane is incorporated into the two DIR loops, corresponding to the Vacuum Pump and Fuel
Clean-up systems, and into the Tritium Permeation Membrane. For the two DIR loops, component-scale
PCC membrane simulations are automatically performed during the fuel-cycle calculation. The
fuel-cycle model provides the upstream tritium partial pressure, and each component model returns the
recovered downstream tritium flow.

At each time step, the fuel cycle converts the tritium inventory stored as T$_2$ gas in the Vacuum
Pump and Fuel Clean-up components into an upstream partial pressure using the ideal-gas law,

\begin{equation}
\label{eqn:pcc_multiscale_pressure}
P_i = \frac{I_i}{M_{T_2}} \frac{R\,T_\text{feed}}{V_i},
\end{equation}

where $M_{T_2}$ is the molar mass of T$_2$, $T_\text{feed} = 773$ K is the assumed feed-gas
temperature, and $V_{VP} = 1600$ m$^3$ and $V_{FCU} = 100$ m$^3$ are the assumed upstream volumes
of the two DIR membrane modules. These volumes maintain upstream pressures on the order of 10 Pa due
to the low tritium partial pressure [!cite](li2024direct). The pressure is passed to the
component-level membrane model as its upstream boundary condition. Each membrane model solves the
voltage-driven transport problem at an applied voltage of 2 V and 773 K, and returns the recovered
steady tritium flux $J_i$ to storage. The membrane sub-applications reuse the hydrogen-calibrated
parameter set with isotope rescaling for tritium, with the tritium diffusivity scaled as
$D_T = D_H / \sqrt{3}$ [!cite](bonanos2015h).

The DIR fraction is computed from the membrane response rather than prescribed:

\begin{equation}
\label{eqn:pcc_multiscale_dir}
f_{\mathrm{DIR},i} = \frac{J_i}{I_i/\tau_i}.
\end{equation}

The active membrane areas are $4\times10^{-1}$ m$^2$ for the Vacuum Pump DIR loop and 1 m$^2$ for
the Fuel Clean-up DIR loop.

For the Tritium Permeation Membrane, the residence-time representation is updated from a
component-level PCC membrane release calculation rather than running another on-the-fly sub-app. A
standalone membrane calculation at an upstream T$_2$ pressure of 5 Pa gives the downstream tritium
release curve. The two-parameter residence time proposed by Yang et al. [!cite](yang2026multiscale)
is then used to fit the delay time $\tau_{11,0}$ and the release time constant $\tau_{11,1}$. With
an applied voltage of 2 V, the fitted values are $\tau_{11,0} = 14.88$ s and $\tau_{11,1} = 10.68$
s, which are significantly lower than the baseline residence time of 100 s.

!media fit_residence_time.py
       image_name=fit_residence_time.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=pcc_multiscale_residence_time
       caption=Two-parameter residence-time fit to downstream tritium release from the PCC membrane at 5 Pa upstream T$_2$ pressure.

## Multiscale Coupling

The coupling is implemented using the MultiApp and Transfer systems in MOOSE
[!cite](gaston2015physics,permann2020moose). The fuel-cycle model is the main application, while
each DIR loop is represented by an independent instance of the 1D PCC membrane model. The membrane
sub-applications are solved to steady state at each fuel-cycle time step and coupled back through
postprocessor transfers.

!listing test/tests/PCC_multiscale_example/dir_pcc_fuel_cycle.i link=false block=MultiApps

!listing test/tests/PCC_multiscale_example/dir_pcc_fuel_cycle.i link=false block=Transfers

The model is evaluated on a single-point mesh because all system-level fuel-cycle components are
treated as zero-dimensional inventories. Adaptive time stepping is used to resolve the pulsed
fueling cycle, and BDF2 is used for time integration. The full system-level calculation can be run
for two or more years, but the automated tests use input validation and compact reference data for
the documentation figures to avoid committing large generated output files.

## Results

The coupled model computes the upstream T$_2$ partial pressures feeding the two DIR membranes and
the resulting DIR recovery fractions. As tritium accumulates in the Vacuum Pump and Fuel Clean-up
components, the upstream pressure rises to the order of 10 Pa, with fluctuations from periodic
pulsing during the fuel cycle. Once the inventories build up, the voltage-driven membranes recover
nearly all tritium routed through both loops: the Vacuum Pump DIR fraction remains near 1.0, while
the Fuel Clean-up DIR fraction fluctuates between approximately 0.8 and 1.0.

!media plot_dir_fraction_pressure.py
       image_name=dir_pcc_dir_fraction_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=pcc_multiscale_dir_fraction_pressure
       caption=Upstream T$_2$ partial pressure and computed DIR recovery fraction for the PCC-enhanced Vacuum Pump and Fuel Clean-up membrane loops.

The PCC-enhanced fuel cycle reduces inventories in components connected to the DIR loops. In the
manuscript calculation, the Isotope Separation System inventory decreases by six orders of magnitude
relative to the baseline case, while the Fuel Clean-up system and Tritium Permeation Membrane
inventories are reduced by about one order of magnitude. The PCC-enhanced fuel cycle remains
self-sufficient with a startup inventory of 0.79 kg, approximately 30% lower than the 1.14 kg
required by the baseline configuration.

!media plot_inventory_comparison.py
       image_name=dir_pcc_inventory_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=pcc_multiscale_inventory_comparison
       caption=Inventory comparison between the baseline fuel-cycle model and the PCC-enhanced multiscale fuel-cycle model.

## Input Files

The main fuel-cycle input for the manuscript-style multiscale example is
[/PCC_multiscale_example/dir_pcc_fuel_cycle.i]. The component-level PCC membrane sub-application is
[/PCC_multiscale_example/dir_pcc_membrane_sub.i].

!listing test/tests/PCC_multiscale_example/dir_pcc_fuel_cycle.i link=false block=Variables

!listing test/tests/PCC_multiscale_example/dir_pcc_fuel_cycle.i link=false block=ScalarKernels

!listing test/tests/PCC_multiscale_example/dir_pcc_fuel_cycle.i link=false block=Postprocessors

!listing test/tests/PCC_multiscale_example/dir_pcc_fuel_cycle.i link=false block=Executioner

The shorter `fuel_cycle_PCC_membrane.i` and `pcc_membrane_sub.i` inputs in the same directory retain
a compact lock-step membrane-container coupling demonstration that is useful for checking the basic
pressure-to-flux bridge.

!alert note title=Full multiscale runs are intentionally manual
The full coupled fuel-cycle calculation solves two component-level PCC membrane sub-applications
during the system-level transient and can produce large CSV outputs. The automated tests validate
the input and regenerate the documentation figures from compact committed reference data.

!bibtex bibliography
