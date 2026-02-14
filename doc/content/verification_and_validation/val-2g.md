# val-2g

# Deuterium Transport in Proton-Conducting Ceramics

## Case Description

This case reproduces the analysis published in [!cite](yang2026elucidating), which proposed a new model that accurately reproduces deuterium transport in a proton-conducting ceramics in both dry and wet environment.
This validation effort involves deuterium gas (D$_2$) and heavy water (D$_2$O) transport in proton-conducting ceramics (PCC), specifically yttrium-doped barium zirconate (BaZr$_{0.9}$Y$_{0.1}$O$_{2.95}$, also known as BZY10). The experimental data used for validation comes from thermal desorption spectroscopy (TDS) measurements performed by Hossain et al. [!citep](hossain2022comparative). The primary objective is to understand and model the mechanisms of hydrogen isotope transport in PCC materials, which are of interest for tritium extraction systems in fusion energy applications.

In proton-conducting ceramics, hydrogen isotopes are transported as protonic defects (OD$^{\bullet}$) through a hopping mechanism between oxygen sites in the crystal lattice. Unlike metals where hydrogen diffuses as interstitial atoms, hydrogen in PCC is incorporated into the oxygen sublattice. This case models the TDS experiment where a BZY10 sample (0.5 mm thick, 7.7 mm $\times$ 2.2 mm surface area) is exposed to either D$_2$ gas (dry condition) or D$_2$O vapor (wet condition), followed by thermal desorption analysis.

The TDS simulation consists of three phases:

1. Dissolution phase (1 hour at 873 K): The sample is exposed to D$_2$ at 1.33 kPa (dry condition) or D$_2$O at 2.8 kPa (wet condition), allowing deuterium to dissolve into the material.
2. Cooldown phase (1 hour): The sample temperature decreases exponentially from 873 K to approximately 300 K while the gas pressure is reduced to vacuum levels.
3. Desorption phase: The sample is heated from 300 K to 1400 K at a constant rate of 0.5 K/s, causing trapped deuterium to be released.

The temperature and pressure histories are shown in [val-2g_environment_history].

!media comparison_val-2g.py
    image_name=val-2g_environment_history.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_environment_history
    caption=Temperature and pressure history during the TDS simulation for the dry (D$_2$) and wet (D$_2$O) condition.

## Model Description

### Diffusion of Mobile Species

In BZY10, three mobile species are considered: protonic defects (OD$^{\bullet}$), oxygen vacancies (V$_{\text{O}}^{\bullet\bullet}$), and electrons (e$'$). The hydrogen isotope transport model for PCCs considers diffusion, trapping within the material, and kinetic chemical reactions on the surface. These transport mechanisms are illustrated in [val-2g_transport_schematic].

!media figures/val-2g_transport_schematic.png
    style=width:35%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_transport_schematic
    caption=Schematic of the hydrogen isotope transport in PCCs.

The governing equations for OD$^{\bullet}$ in PCC materials is described as

\begin{equation}
\frac{\partial C_M}{\partial t} = \nabla \cdot D \nabla C_M - \frac{\partial C_T}{\partial t},
\end{equation}

where $C_M$ is the concentration of mobile OD$^{\bullet}$, $D$ is the diffusivity, $C_T$ is the concentration of trapped OD$^{\bullet}$ in the material. The diffusivity follows an Arrhenius relationship:

\begin{equation}
D = D_{0} \exp\left(-\frac{E_{a}}{RT}\right)
\end{equation}

where $D_{0}$ is the pre-exponential factor, $E_{a}$ is the activation energy, $R$ is the gas constant, and $T$ is temperature. The governing equations for the diffusion of the other mobile species, V$_{\text{O}}^{\bullet\bullet}$ and e$'$, are the same as those for OD$^{\bullet}$, except that no trapping effects are considered.

### Trapping and Detrapping

The model includes a single trapping site to capture deuterium retention effects observed in the TDS spectra. The trapped concentration $C_T$ evolves according to:

\begin{equation}
\frac{\partial C_T}{\partial t} = \alpha_t \frac{C_T^{\text{empty}} C_M}{N} - \alpha_r C_T
\end{equation}

where $N$ is the lattice site density, and $C_T^{\text{empty}} = \chi N - C_T$ is the empty trap concentration with $\chi$ being the trap site fraction.

The trapping and release rate coefficients follow Arrhenius relationships:

\begin{equation}
\alpha_t = \alpha_{t0} \exp\left(-\frac{\epsilon_t}{k_B T}\right)
\end{equation}

\begin{equation}
\alpha_r = \alpha_{r0} \exp\left(-\frac{\epsilon_r}{k_B T}\right)
\end{equation}

where $\alpha_{t0}$ and $\alpha_{r0}$ are pre-factors of trapping and release rate coefficients, $\epsilon_t$ and $\epsilon_r$ are trapping and release energies, and $k_B$ is the Boltzmann constant.

### Surface Reactions

In addition to diffusion and trapping within the bulk material, hydrogen isotope transport also involves chemical reactions at the surface. The chemical reactions using the Kröger–Vink notation are:

D$_2$O hydration reaction (wet condition):

\begin{equation}
\text{D}_2\text{O}_{(g)} + \text{V}_{\text{O}}^{\bullet\bullet} + \text{O}_{\text{O}}^{\times} \rightleftharpoons 2\text{OD}^{\bullet} ,
\end{equation}

D$_2$ incorporation reaction (dry condition):

\begin{equation}
\text{D}_{2(g)} + 2\text{O}_{\text{O}}^{\times} \rightleftharpoons 2\text{OD}^{\bullet} + 2\text{e}'
\end{equation}

The net flux for each reaction is:

\begin{equation}
J_{\text{D}_2\text{O}} = K_f^{\text{D}_2\text{O}} \cdot P_{\text{D}_2\text{O}} \cdot C_{\text{V}_{\text{O}}} \cdot C_{\text{O}} - K_r^{\text{D}_2\text{O}} \cdot C_{\text{OD}}^2 ,
\end{equation}

\begin{equation}
J_{\text{D}_2} = K_f^{\text{D}_2} \cdot P_{\text{D}_2} \cdot C_{\text{O}}^2 - K_r^{\text{D}_2} \cdot C_{\text{OD}}^2 \cdot C_{e'}^2 ,
\end{equation}

where $P_i$ and $C_i$ are the pressure and concentration of D$_2$O or D$_2$, respectively, $K_f^{j}$ and $K_{r}^{j}$ are the forward reaction rate and the reverse reaction rate for reaction $j$, respectively. At equilibrium, the surface concentrations depend on the chemical reaction constant, which is a function of temperature:

\begin{equation}
    \label{eqn:BCs:K_eq_T2O}
    \frac{C_{OD_O^{\cdot}}^2}{P_{D_2O} C_{V_O^{\cdot\cdot}} C_{O_O^x}} = \frac{K_f^{D_2O}}{K_{r}^{D_2O}} = K_{eq}^{D_2O} = \exp\left(\frac{T \Delta S^0_{D_2O} - \Delta H^0_{D_2O}}{k_B T}\right),
\end{equation}

and

\begin{equation}
    \label{eqn:BCs:K_eq_T2}
    \frac{C_{OD_O^{\cdot}}^2 C_{e^{\prime}}^2}{P_{D_2} C_{O_O^x}^2} = \frac{K_f^{D_2}}{K_{r}^{D_2}} = K_{eq}^{D_2} = \exp\left(\frac{T \Delta S^0_{D_2} - \Delta H^0_{D_2}}{k_B T}\right),
\end{equation}

where $K_{eq}^{j}$ is the chemical reaction constant of reaction $j$, $\Delta S^0_{j}$ and $\Delta H^0_{j}$ are the entropy and enthalpy of reaction $j$, respectively.

!alert note title=The comprehensive mechanism and analysis is in [!cite](yang2026elucidating).
This model description is a simplified version of the Method section in [!cite](yang2026elucidating). The comprehensive explanation of mechanism and analysis can be found in [!cite](yang2026elucidating).

## Case and Model Parameters

[val-2g_critical_parameters] summarizes the detail of sample and experimental conditions from Hossain et al. [!citep](hossain2022comparative), as well as the model parameters from Hossain et al. [!citep](hossain2022comparative), Kreuer [!citep](kreuer2003proton), and estimated from validation cases in TMAP8. [val-2g_trapping_parameters] includes the trapping parameters from Karmonik et al. [!citep](karmonik1995proton) and estimated based on existing validation cases in TMAP8.

!table id=val-2g_critical_parameters caption=Experimental set up from Hossain et al. [!citep](hossain2022comparative) and modeling parameters for deuterium transport in a BZY membrane at 873 K from Hossain et al. [!citep](hossain2022comparative) and from Kreuer et al. [!citep](kreuer1999aspects,kreuer2003proton).
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $T_{\text{initial}}$ | Initial/dissolution temperature | 873 | K | [!cite](hossain2022comparative) |
| $T_{\text{low}}$ | Cooldown final temperature | 300 | K | [!cite](hossain2022comparative) |
| $T_{\text{high}}$ | Desorption final temperature | 1400 | K | [!cite](hossain2022comparative) |
| $\beta$ | Heating rate | 0.5 | K/s | [!cite](hossain2022comparative) |
| $t_{\text{dissolve}}$ | Dissolution duration | 1 | h | [!cite](hossain2022comparative) |
| $t_{\text{cooldown}}$ | Cooldown duration | 1 | h | [!cite](hossain2022comparative) |
| $l$ | Sample thickness | 0.5 | mm | [!cite](hossain2022comparative) |
| $A$ | Sample surface area | 16.94 | mm$^2$ | [!cite](hossain2022comparative) |
| $d$ | Sample density | 5.98 | g/cm$^3$ | [!cite](hossain2022comparative) |
| $C_{e^\prime0}$ | Initial electron concentration | $1 \times 10^{-5}$ | g/cm$^3$ | [!cite](hossain2022comparative) |
| $P_{\text{D}_2}^{\text{dry}}$ | D$_2$ pressure (dry condition) | 1.33 | kPa | [!cite](hossain2022comparative) |
| $P_{\text{D}_2\text{O}}^{\text{wet}}$ | D$_2$O pressure (wet condition) | 2.8 | kPa | [!cite](hossain2022comparative) |
| $\Delta S_{D_2O}^0$ | Entropy for D$_2$O reaction | -88.90 | J/mol/K | [!cite](kreuer2003proton) |
| $\Delta H_{D_2O}^0$ | Enthalpy for D$_2$O reaction | $-7.950 \times 10^4$ | J/mol | [!cite](kreuer2003proton) |
| $\Delta S_{D_2}^0$ | Entropy for D$_2$ reaction | -124.53 | J/mol/K | Estimated from [!cite](kreuer2003proton) |
| $\Delta H_{D_2}^0$ | Enthalpy for D$_2$ reaction | $-7.950 \times 10^4$ | J/mol | Estimated from [!cite](kreuer2003proton) |
| $K_1^{D_2O}$ | Forward reaction rate for D$_2$O | $2 \times 10^{-33}$ | m$^4$/atom/s | Estimated from TMAP8 |
| $K_1^{D_2}$ | Forward reaction rate for D$_2$ | $2 \times 10^{-41}$ | m$^4$/atom/s | Estimated from TMAP8 |
| $D_0^{OD^{\cdot}}$ | Diffusivity coefficient for OD$^{\cdot}$ | $2.449 \times 10^{-9}$ | m$^2$/s | [!cite](hossain2022comparative) |
| $E^{OD^{\cdot}}$ | Diffusivity energy for OD$^{\cdot}$ | 0.23 | eV | [!cite](hossain2022comparative) |
| $D_0^{V_O^{\cdot\cdot}}$ | Diffusivity coefficient for V$_O^{\cdot\cdot}$ | $1.021 \times 10^{-7}$ | m$^2$/s | [!cite](kreuer1999aspects) |
| $E^{V_O^{\cdot\cdot}}$ | Diffusivity energy for V$_O^{\cdot\cdot}$ | 89216.77 | J/mol | [!cite](kreuer1999aspects) |
| $D_0^{e^\prime}$ | Diffusivity coefficient for e$^\prime$ | $2.05 \times 10^{-2}$ | m$^2$/s | [!cite](kreuer1999aspects) |
| $E^{e^\prime}$ | Diffusivity energy for e$^\prime$ | 103818.22 | J/mol | [!cite](kreuer1999aspects) |

!table id=val-2g_trapping_parameters caption=Trapping parameters for deuterium transport in BZY membrane from Karmonik et al. [!citep](karmonik1995proton) and estimated from TMAP8.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $\tau_{t0}$ | Trapping rate coefficient | $4.8 \times 10^{11}$ | 1/s | [!cite](karmonik1995proton) |
| $\tau_{r0}$ | Release rate coefficient | $2.6 \times 10^{14}$ | 1/s | [!cite](karmonik1995proton) |
| $\epsilon_{t}$ | Trapping energy | 0.38 | eV | Estimated from TMAP8 |
| $\epsilon_{r}$ | Release energy | 1.60 | eV | Estimated from TMAP8 |
| $\chi$ | Trapping site atom fraction | $3 \times 10^{-5}$ | - | Estimated from TMAP8 |

## Results

### Results Without Trapping Model

Initial simulations were performed without the trapping model using diffusivity and surface reaction parameters from literature. [val-2g_dry_no_trapping_flux_comparison] shows the comparison between TMAP8 predictions and experimental data for the dry condition (D$_2$ exposure), while [val-2g_wet_no_trapping_flux_comparison] shows results for the wet condition (D$_2$O exposure).

As shown in [val-2g_dry_trapping_flux_comparison] and [val-2g_wet_trapping_flux_comparison], the model does not capture the experimental data from Hossain et al [!citep](hossain2022comparative).
The fluxes of D$_2$ and D$_2$O under both dry and wet environments exhibit significant discrepancies between the simulations and experimental results, except for the D$_2$O flux under wet environment. The temperature at which the deuterium flux peak occurs for D$_2$ under dry condition is drastically lower than that of the experimental peak, and the predicted peak is a lot wider than experimentally observed.
Furthermore, the deuterium flux from D$_2$O under dry environment and from D$_2$ under wet environment remains close to 0 and far from the experimental results.
The root mean square percentage error (RMSPE) values exceed 100% for most cases, indicating that this model without traps does not accurately reproduce the experimental results.

!media comparison_val-2g.py
    image_name=val-2g_dry_no_trapping_flux_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_dry_no_trapping_flux_comparison
    caption=Comparison of TMAP8 calculations (without trapping) with experimental data for the dry condition. RMSPE values are shown on the plot.

!media comparison_val-2g.py
    image_name=val-2g_wet_no_trapping_flux_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_wet_no_trapping_flux_comparison
    caption=Comparison of TMAP8 calculations (without trapping) with experimental data for the wet condition. RMSPE values are shown on the plot.

### Results With Trapping Using Initial Parameters

Adding the trapping model with parameters from literature improves the predictions, as shown in [val-2g_dry_trapping_flux_comparison] and [val-2g_wet_trapping_flux_comparison]. The trapping model captures the delayed release of deuterium and produces peak shapes more consistent with the experimental data. However, the peak positions and magnitudes still show significant discrepancies.

!media comparison_val-2g.py
    image_name=val-2g_dry_trapping_flux_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_dry_trapping_flux_comparison
    caption=Comparison of TMAP8 calculations (with trapping, initial parameters) with experimental data for the dry condition. RMSPE values are shown on the plot.

!media comparison_val-2g.py
    image_name=val-2g_wet_trapping_flux_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_wet_trapping_flux_comparison
    caption=Comparison of TMAP8 calculations (with trapping, initial parameters) with experimental data for the wet condition. RMSPE values are shown on the plot.

### Results With Trapping Using Calibrated Parameters

To improve the agreement with experimental data, the model parameters were calibrated using the [Parallel Subset Simulation](samplers/ParallelSubsetSimulation.md) (PSS) approach in [MOOSE's stochastic tools module](modules/stochastic_tools/index.md). The PSS method systematically explores the parameter space to minimize the difference between simulation predictions and experimental measurements. A detailed explanation of this method is provided in [!cite](yang2026elucidating). In this PSS optimization process, an optimization function using RMSPEs is calculated from the four flux results: D$_2$O and D$_2$ fluxes under both dry and wet environments. We calculate the difference from the four fluxes during desorption simultaneously, since the experiments used the same BZY sample. The multi-objective optimization function (log inverse error) is described as:

\begin{equation}
f(x) = \log\left( \frac{1}{\text{RMSPE}^{D_2O}_\text{wet}(x) + \text{RMSPE}^{D_2}_\text{wet}(x) + \text{RMSPE}^{D_2O}_\text{dry}(x) + \text{RMSPE}^{D_2}_\text{dry}(x)} \right),
\end{equation}

where $\text{RMSPE}^{i}_{j}$ is the RMSPE for $D_2O$ or $D_2$ fluxes under dry or wet environment, and $x$ is the results from simulations or experiments. A high $f(x)$ means a better accuracy of the simulation results. [val-2g_trapping_optimization_PSS_iterations] shows the evolution of optimization function from a simplified PSS optimization process using initial parameters close to the calibrated values.

!media comparison_val-2g.py
    image_name=val-2g_trapping_optimization_PSS_iterations.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_trapping_optimization_PSS_iterations
    caption=The evolution of the objective function (log inverse error) during a simplified PSS optimization.

[val-2g_trapping_optimization_inputs_PSS] shows the deviation of all calibrated parameters from the input parameters. All deviations are within three standard deviations of their corresponding normal distribution ranges.

!media comparison_val-2g.py
    image_name=val-2g_trapping_optimization_inputs_PSS.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_trapping_optimization_inputs_PSS
    caption=Deviation of calibrated material parameters from initial values, expressed in standard deviations of their respective normal distribution ranges.

The calibrated parameters are listed in [val-2g_calibrated_diffusivity_parameters], [val-2g_calibrated_trapping_parameters], and [val-2g_calibrated_thermodynamic_parameters]. These calibrated parameters are taken directly from [!cite](yang2026elucidating).

!table id=val-2g_calibrated_diffusivity_parameters caption=Calibrated diffusivity parameters.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $D_0^{\text{OD}}$ | OD$^{\bullet}$ diffusivity pre-factor | 1.90 $\times 10^{-9}$ | m$^2$/s | [!cite](yang2026elucidating) |
| $E_a^{\text{OD}}$ | OD$^{\bullet}$ activation energy | 0.122 | eV | [!cite](yang2026elucidating) |
| $D_0^{\text{V}_{\text{O}}}$ | V$_{\text{O}}^{\bullet\bullet}$ diffusivity pre-factor | 1.24 $\times 10^{-7}$ | m$^2$/s | [!cite](yang2026elucidating) |
| $E_a^{\text{V}_{\text{O}}}$ | V$_{\text{O}}^{\bullet\bullet}$ activation energy | 1.04 | eV | [!cite](yang2026elucidating) |
| $D_0^{e'}$ | e$'$ diffusivity pre-factor | 2.06 $\times 10^{-2}$ | m$^2$/s | [!cite](yang2026elucidating) |
| $E_a^{e'}$ | e$'$ activation energy | 0.99 | eV | [!cite](yang2026elucidating) |

!table id=val-2g_calibrated_trapping_parameters caption=Calibrated trapping parameters.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $\chi$ | Trap site fraction | 1.39 $\times 10^{-2}$ | - | [!cite](yang2026elucidating) |
| $\alpha_{t0}$ | Trapping rate pre-factor | 3.95 $\times 10^{9}$ | 1/s | [!cite](yang2026elucidating) |
| $\epsilon_t$ | Trapping energy | 0.467 | eV | [!cite](yang2026elucidating) |
| $\alpha_{r0}$ | Release rate pre-factor | 1.60 $\times 10^{18}$ | 1/s | [!cite](yang2026elucidating) |
| $\epsilon_r$ | Release energy | 1.24 | eV | [!cite](yang2026elucidating) |

!table id=val-2g_calibrated_thermodynamic_parameters caption=Calibrated thermodynamic parameters.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $\Delta H_{\text{D}_2\text{O}}^0$ | D$_2$O reaction enthalpy | -156.4 | kJ/mol | [!cite](yang2026elucidating) |
| $\Delta S_{\text{D}_2\text{O}}^0$ | D$_2$O reaction entropy | -137.4 | J/mol/K | [!cite](yang2026elucidating) |
| $K_f^{\text{D}_2\text{O}}$ | D$_2$O forward rate constant | 2 $\times 10^{-30}$ | m$^4$/at/s | [!cite](yang2026elucidating) |
| $\Delta H_{\text{D}_2}^0$ | D$_2$ reaction enthalpy | -112.2 | kJ/mol | [!cite](yang2026elucidating) |
| $\Delta S_{\text{D}_2}^0$ | D$_2$ reaction entropy | -37.0 | J/mol/K | [!cite](yang2026elucidating) |
| $K_f^{\text{D}_2}$ | D$_2$ forward rate constant | 2 $\times 10^{-44}$ | m$^4$/at/s | [!cite](yang2026elucidating) |

With these calibrated values, TMAP8 achieves good agreement with the experimental TDS data for both dry and wet conditions, as shown in [val-2g_dry_trapping_flux_calibrated_comparison] and [val-2g_wet_trapping_flux_calibrated_comparison]. The root mean square percentage errors (RMSPE) are 16.59%, 20.49%, 37.60%, and 40.49% for the D$_2$ flux (dry), D$_2$O flux (dry), D$_2$ flux (wet), and D$_2$O flux (wet), respectively.

!media comparison_val-2g.py
    image_name=val-2g_dry_trapping_flux_calibrated_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_dry_trapping_flux_calibrated_comparison
    caption=Comparison of TMAP8 calculations (with trapping, calibrated parameters) with experimental data for the dry condition. RMSPE values are shown on the plot.

!media comparison_val-2g.py
    image_name=val-2g_wet_trapping_flux_calibrated_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2g_wet_trapping_flux_calibrated_comparison
    caption=Comparison of TMAP8 calculations (with trapping, calibrated parameters) with experimental data for the wet condition. RMSPE values are shown on the plot.

The calibrated model successfully reproduces the key features of the TDS spectra:

- The peak temperature positions for both D$_2$ and D$_2$O desorption
- The relative magnitudes of the desorption peaks
- The peak shapes and widths

This validation demonstrates TMAP8's capability to model hydrogen isotope transport in proton-conducting ceramics in both dry and wet environments, including the complex interplay between diffusion, trapping, and surface reactions.

## Input files

!style halign=left
The input files for this validation case are:

- [/val-2g_trapping.i]: Simulates deuterium transport with and without trapping effects using corresponding parameters. [/parameters_no_trapping_initial_validation.params] includes the initial parameters for simulation without trapping, [/parameters_trapping_initial_validation.params] includes the initial parameters for simulation with trapping, and [/parameters_trapping_calibrated_validation.params] includes the calibrated parameters for simulation with trapping.
- [/val-2g_trapping_light.i]: Simulates a version of the file with a coarser mesh, fewer time steps, no trapping effects, and wet environment to limit the computational costs for testing purposes.
- [/val-2g_main_PSS_trapping.i]: Performs a simplified Parallel Subset Simulation optimization with only one step to demonstrate the integrity of input file and a simplified Parallel Subset Simulation optimization study with initial parameters close to the calibrated values to reduce computational cost.

More information about these tests can be found in the test specification file for this case, namely [/val-2g/tests].

!bibtex bibliography
