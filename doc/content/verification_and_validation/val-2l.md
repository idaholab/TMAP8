# val-2l

# Hydrogen Permeation Through a BCY20 Proton-Conducting Ceramic Membrane Under Applied Voltage

## Case Description

This validation case compares a TMAP8 component-scale proton-conducting ceramic (PCC) membrane model against hydrogen permeation measurements from Lee et al. [!citep](lee2005thin). The experiments measured hydrogen flux through a BaCe$_{0.8}$Y$_{0.2}$O$_{3-\delta}$ (BCY20) membrane under applied voltages at 773 K and 973 K. Because hydrogen and tritium share similar transport mechanisms in PCC membranes, these data provide a suitable validation benchmark. Hydrogen diffusivity exceeds tritium diffusivity by a factor of $\sqrt{3}$ due to isotope mass scaling [!citep](lee1986protonic,mukundan1999tritium).

The validation includes the voltage-driven transport model, a Bayesian optimization driver using MOOSE Stochastic Tools, and a Joule-heating extension of the membrane model.

!media figures/val-2l_pcc_voltage_transport_schematic.png
    style=width:40%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2l_transport_schematic
    caption=Schematic for hydrogen-isotope transport in a PCC membrane. $Q$ represents hydrogen isotopes, and $O$ represents oxygen.

## Model Description

The hydrogen transport model is based on the PCC model from [!cite](yang2026elucidating), extended to include Nernst-Planck migration under an applied voltage and Joule heating. Hydrogen transport depends on diffusion in the material and on surface dissociation and recombination reactions.

The surface chemical reactions using Kroger-Vink notation are

\begin{equation}
H_2O + V_O^{\cdot\cdot} + O_O^x \rightleftharpoons 2OH_O^{\cdot},
\end{equation}

and

\begin{equation}
H_2 + 2 O_O^x \rightleftharpoons 2OH_O^{\cdot} + 2 e^{\prime}.
\end{equation}

The hydrogen transport in the PCC membrane is governed by

\begin{equation}
\frac{\partial C^H}{\partial t} = \nabla \cdot D^H \nabla C^H + \frac{\partial}{\partial x}\left( \frac{C^H D^H F}{RT} \frac{\partial \phi}{\partial x} \right),
\end{equation}

where $C^H$ is the concentration of mobile hydrogen, $D^H$ is the hydrogen diffusivity, and $\phi$ is the electric potential. Oxygen vacancies are also affected by the applied voltage,

\begin{equation}
\frac{\partial C^{V_O}}{\partial t} = \nabla \cdot D^{V_O} \nabla C^{V_O} + \frac{\partial}{\partial x} \left(\frac{2 C^{V_O} D^{V_O} F}{RT} \frac{\partial \phi}{\partial x} \right),
\end{equation}

where the factor of 2 represents the charge number of $V_O^{\cdot\cdot}$. Since ionic transport is the dominant contribution to the current density in BaCeO$_3$-based proton conductors under hydrogen environments [!citep](iwahara1988proton,holz2020analysis), electron diffusion is neglected. The electron concentration is treated as a temperature-dependent constant that affects the surface reaction balance.

To account for Joule heating caused by ionic current through the membrane under applied voltage, the Joule-heating model couples the heat equation to the species transport equations:

\begin{equation}
\rho c_p \frac{\partial T}{\partial t} = \nabla \cdot (\kappa \nabla T) + \dot{q}_J,
\end{equation}

with the volumetric heating source

\begin{equation}
\dot{q}_J = \sigma_{\mathrm{ion}} |\nabla \phi|^2.
\end{equation}

The ionic conductivity is computed from the Nernst-Einstein relation,

\begin{equation}
\sigma_{\mathrm{ion}} = \frac{F^2}{RT} \sum_i z_i^2 D_i C_i,
\end{equation}

where the sum includes the hydroxyl group and oxygen vacancy contributions. Fixed-temperature boundary conditions are applied at both membrane surfaces, consistent with furnace-controlled experimental conditions.

## Case and Model Parameters

The simulations use a one-dimensional 10 $\mu$m membrane with 300 elements. The upstream hydrogen pressure is $8.11 \times 10^4$ Pa, and the water partial pressure is $3.04 \times 10^3$ Pa, matching Lee et al. [!citep](lee2005thin). The membrane density is 6.154 g/cm$^3$. For the Joule-heating model, the thermal conductivity is 1.05 W/(m K), based on dense BaCeO$_3$ measurements [!citep](tenevich2023mechanical), and the specific heat capacity is 120 J/(mol K), based on high-temperature calorimetry for BaCeO$_3$ [!citep](yamanaka2003thermophysical).

!table id=val-2l_parameters caption=Experimental conditions and selected model parameters for the BCY20 membrane validation model.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $T$ | temperature | 773 and 973 | K | [!cite](lee2005thin) |
| $l$ | membrane thickness | 10 | $\mu$m | [!cite](lee2005thin) |
| $\rho$ | membrane density | 6.154 | g/cm$^3$ | [!cite](lee2005thin) |
| $P_{H_2}$ | upstream H$_2$ pressure | $8.11 \times 10^4$ | Pa | [!cite](lee2005thin) |
| $P_{H_2O}$ | H$_2$O partial pressure | $3.04 \times 10^3$ | Pa | [!cite](lee2005thin) |
| $\kappa$ | thermal conductivity | 1.05 | W/(m K) | [!cite](tenevich2023mechanical) |
| $c_p$ | specific heat capacity | 120 | J/(mol K) | [!cite](yamanaka2003thermophysical) |
| $D_0^{OH}$ | hydroxyl diffusivity base pre-exponential | 2.03 | m$^2$/s multiplier | [!cite](kreuer1999aspects) |
| $D_0^{V_O}$ | oxygen vacancy diffusivity base pre-exponential | 1.1 | m$^2$/s multiplier | [!cite](kreuer1999aspects) |

## Bayesian Optimization

Due to the large uncertainty in the experimental data and material parameters, this validation case includes a Bayesian optimization driver using the MOOSE Stochastic Tools Module [!citep](slaughter2023moose,dhulipala2025moose). The optimization uses a Gaussian process surrogate model with an Expected Improvement acquisition function. During optimization, the surrogate model is iteratively trained using accumulated simulation results and used to select promising parameter sets for evaluation.

The objective function uses the RMSPE of the hydrogen flux-voltage curves at 773 K and 973 K. The two temperature conditions are evaluated simultaneously because the experiments were performed on the same BCY20 sample:

\begin{equation}
f(x) = \log\left( \frac{1}{\mathrm{RMSPE}^{773 K}(x) + \mathrm{RMSPE}^{973 K}(x)} \right),
\end{equation}

where $x$ is the candidate parameter set. A higher value indicates better agreement between simulation and experiment.

The 14 optimized parameters span reaction thermodynamics, reaction kinetics, transport properties, and electron concentration. The ranges are specified in [/bayesian_main_val2l.i], and the optimized parameter include files are [/parameters_optimized.params] and [/parameters_optimized_manuscript_table.params].

!media comparison_val-2l.py
    image_name=val-2l_bayesian_optimization.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2l_bayesian_optimization
    caption=Evolution of the Bayesian optimization objective function for the BCY20 membrane model.

## Results

Initial simulations using literature-based parameter estimates reproduce the parabolic trend of flux with applied voltage at 773 K but overpredict the flux, especially at 973 K. This discrepancy reflects the large uncertainty in empirical material properties and surface reaction parameters adopted from the literature.

!media comparison_val-2l.py
    image_name=val-2l_initial_flux.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2l_initial_flux
    caption=Hydrogen flux comparison with Lee et al. experimental data under applied voltage at 773 K and 973 K before Bayesian optimization.

After optimization, the simulations without Joule heating align better with the experimental measurements. The remaining discrepancy at high applied voltage under 773 K may be caused by missing voltage-dependent surface kinetics or by near-surface concentration effects not captured in the simplified electron treatment.

!media comparison_val-2l.py
    image_name=val-2l_optimized_flux.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2l_optimized_flux
    caption=Hydrogen flux comparison with Lee et al. experimental data under applied voltage at 773 K and 973 K after Bayesian optimization.

Including Joule heating slightly increases the predicted hydrogen flux at high voltage under 773 K. This effect is modest and does not fully explain the remaining discrepancy between simulation and experiment. The temperature response is much stronger at 773 K than at 973 K because the membrane is more resistive at lower temperature.

!media comparison_val-2l.py
    image_name=val-2l_joule_flux.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2l_joule_flux
    caption=Hydrogen flux comparison with Lee et al. experimental data using optimized parameters with Joule heating. The 773 K no-Joule-heating optimized result is included as a dashed reference.

!media comparison_val-2l.py
    image_name=val-2l_joule_temperature.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2l_joule_temperature
    caption=Steady-state temperature rise from Joule heating as a function of applied voltage.

The optimized material parameters change the hydrogen diffusivity, oxygen vacancy diffusivity, reaction equilibrium constants, and forward reaction rates relative to the literature-based values. These differences indicate parameter uncertainty, possible model inadequacy, or experimental uncertainty. Future work will validate the model against a broader collection of experimental data and use Bayesian inference to identify the dominant uncertainty sources [!citep](dhulipala2025moose,DHULIPALA2025155795).

!media comparison_val-2l.py
    image_name=val-2l_parameter_comparison.png
    style=width:80%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2l_parameter_comparison
    caption=Comparison of initial and optimized transport parameters as functions of inverse temperature.

## Input Files

The no-Joule-heating validation model is defined by [/val-2l_membrane.i] and aggregated over the ten voltage-temperature setpoints by [/val-2l.i]. The Joule-heating membrane model is defined by [/val-2l_joule_heating.i] and aggregated by [/val-2l_joule_heating_aggregator.i]. The Bayesian optimization driver is [/bayesian_main_val2l.i]. The regression tests are listed in [/tests]. The figure-generation script is [/comparison_val-2l.py] and mirrored in [comparison_val-2l.py](figures/comparison_val-2l.py) for MooseDocs figure generation.

!alert note title=V&V versus regression cost
The full validation calculations use a 300-element membrane mesh and ten voltage-temperature setpoints, so the primary model and Bayesian optimization tests are marked as heavy. The documentation figures use compact gold CSV summaries to avoid storing large Exodus output files for this validation case.

!bibtex bibliography
