# val-2j

# Tritium Thermal Desorption Spectroscopy from Li$_2$TiO$_3$ Solid Breeder

## Case Description

This validation case models tritium thermal desorption spectroscopy (TDS) from neutron-irradiated Li$_2$TiO$_3$ (lithium titanate) crystalline grains, a candidate solid tritium breeding material for D-T fusion reactors. The experimental data and model are from [!cite](kobayashi2015developing).

Li$_2$TiO$_3$ samples were irradiated at the Kyoto University Reactor (KUR) at various neutron fluences. After irradiation, the tritium release behavior was measured by TDS with a heating rate of 5 K/min using pure helium as the purge gas. The average grain radius was 1.5 $\mu$m.

Sample E (high defect density, $D_{id}$ = 0.018 defect/Li$_2$TiO$_3$) is modeled, where tritium release is significantly influenced by trapping at O$^{-}$-centers and defect annihilation.

## Model Description

TMAP8 simulates tritium diffusion and trapping in a single spherical grain of Li$_2$TiO$_3$ using 1D spherical coordinates (RSPHERICAL). The governing equation for mobile tritium concentration $C$ is [!citep](kobayashi2015developing):

\begin{equation} \label{eq:diffusion_trapping}
\frac{\partial C}{\partial t} = D \left( \frac{\partial^2 C}{\partial r^2} + \frac{2}{r} \frac{\partial C}{\partial r} \right) + q_{dt} - q_{t},
\end{equation}

where $D$ is the temperature-dependent diffusivity following the Arrhenius law:

\begin{equation} \label{eq:diffusivity}
D = D_0 \exp \left( -\frac{E_d}{k_B T} \right).
\end{equation}

### O$^{-}$-center trapping

Only O$^{-}$-center (hydroxyl group) trapping is included in this model. As noted by [!cite](kobayashi2015developing) (p. 26), tritium release controlled by detrapping from F$^+$-centers (oxygen vacancies) occurs near 580 K, which corresponds to the release temperature controlled by the diffusion process itself. Because F$^+$-center detrapping is not rate-limiting relative to diffusion, it does not produce a distinct feature in the TDS spectrum, and is therefore excluded from the model.

The trapping and detrapping rates for O$^{-}$-centers are:

\begin{equation} \label{eq:trapping_rate}
q_{t} = k_{t} C \frac{T_{t} - C_{t}}{M},
\end{equation}

\begin{equation} \label{eq:detrapping_rate}
q_{dt} = k_{dt} C_{t},
\end{equation}

where $C_{t}$ is the trapped tritium concentration, $T_{t}$ is the trap density, $M$ is the lattice density, and the rate coefficients follow Arrhenius temperature dependence:

\begin{equation}
k_{t} = k_{t,0} \exp \left( -\frac{E_t}{k_B T} \right), \quad
k_{dt} = k_{dt,0} \exp \left( -\frac{E_{dt}}{k_B T} \right).
\end{equation}

The trapping rate parameters ($k_{t,0}$ and $E_t$) follow the McNabb-Foster assumption that the trapping energy is related to the diffusion activation energy.

### Defect annihilation

During TDS heating, radiation-induced defect sites undergo first-order annihilation [!citep](kobayashi2015developing):

\begin{equation} \label{eq:annihilation}
\frac{d D_{id}}{dt} = -k_{dp-da} \, D_{id},
\end{equation}

where the annihilation rate coefficient is:

\begin{equation} \label{eq:annihilation_rate}
k_{dp-da} = k_{dp-da,0} \exp \left( -\frac{E_{dp-da}}{k_B T} \right).
\end{equation}

This reduces the available trap sites: the trap density $T_{t}(t)$ decays over time following [eq:annihilation], preventing re-trapping into annihilated sites. This is implemented by solving the annihilation ODE self-consistently as an additional variable within the simulation, using a `ReleasingNodalKernel`.

The initial trap density equals the total defect fraction: $T_t(0) = D_{id}$.

### Boundary and initial conditions

- $\partial C / \partial r = 0$ at $r = 0$ (symmetry at grain center)
- $C = 0$ at $r = r_g$ (fast surface release, [!cite](kobayashi2015developing))

The mobile and trapped tritium concentrations are initialized at their local trapping/detrapping equilibrium values at the starting temperature $T_{\text{start}}$ = 300 K. The equilibrium mobile concentration is computed from the balance of trapping and detrapping rates. This avoids an initial transient from any imbalance between trapping and detrapping. Since TDS output is normalized to arbitrary units, only the shape of the release curve matters, not the absolute concentrations. The temperature increases linearly at 5 K/min from 300 K.

## Case and Model Parameters

!table id=val-2j_parameters caption=Values of model parameters.
| Parameter | Description | Value | Units | Reference |
| --- | --- | --- | --- | --- |
| $r_g$ | Grain radius | 1.5 | $\mu$m | [!cite](kobayashi2015developing) |
| $D_0$ | Diffusivity pre-exponential | 6.9 $\times 10^{-7}$ | m$^2$/s | [!cite](kobayashi2015developing), Eq. 11 |
| $E_d$ | Diffusion activation energy | 1.07 | eV | [!cite](kobayashi2015developing), Eq. 11 |
| $k_{dt,0}$ | O$^{-}$-center detrapping prefactor | 4.1 $\times 10^{6}$ | s$^{-1}$ | [!cite](kobayashi2015developing), Eq. 13 |
| $E_{dt}$ | O$^{-}$-center detrapping energy | 1.19 | eV | [!cite](kobayashi2015developing), Eq. 13 |
| $k_{t,0}$ | Trapping prefactor | 4.2 $\times 10^{8}$ | s$^{-1}$ | [!cite](kobayashi2015developing), Eq. 21 |
| $E_t$ | Trapping energy | 1.04 | eV | [!cite](kobayashi2015developing), Eq. 21 |
| $k_{dp-da,0}$ | Annihilation prefactor | 1.0 $\times 10^{2}$ | s$^{-1}$ | [!cite](kobayashi2015developing), Eq. 18 |
| $E_{dp-da}$ | Annihilation energy | 0.9 | eV | [!cite](kobayashi2015developing), Eq. 18 |
| $M$ | Lattice density | 1.88 $\times 10^{28}$ | m$^{-3}$ | Calculated |
| $\beta$ | TDS heating rate | 5 | K/min | [!cite](kobayashi2015developing) |
| $D_{id,E}$ | Defect fraction (Sample E) | 0.018 | - | [!cite](kobayashi2015developing), Table 1 |

## Results

[val-2j_comparison_e] shows the comparison between TMAP8 and the experimental TDS spectrum for Sample E (high defect density). The O$^{-}$-center trapping model with defect annihilation captures the broad release profile. The high detrapping energy of O$^{-}$-centers (1.19 eV) produces a release peak above 650 K that is distinct from the diffusion-controlled release. The defect annihilation mechanism reduces the effective trap density at high temperatures, suppressing re-trapping and allowing tritium to escape more efficiently.

!media comparison_val-2j.py
       image_name=val-2j_comparison_sample_e.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2j_comparison_e
       caption=Comparison of TMAP8 calculation with the experimental TDS data for Sample E (high defect density).

## Parameter Optimization

The agreement between the TMAP8 simulation and experimental data can be improved by optimizing the model parameters using [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html). A batch Bayesian optimization approach [!citep](DHULIPALA2026102776) was applied to fit six key parameters — three Arrhenius pre-exponential factors (in log$_{10}$ space) and three activation energies — to the experimental TDS curve for Sample E. The optimization used Gaussian Process active learning with Expected Improvement acquisition, running 40 iterations with 5 parallel proposals per iteration.

[val-2j_optimized_parameters] compares the reference values from [!cite](kobayashi2015developing) with the Bayesian-optimized parameters.

!table id=val-2j_optimized_parameters caption=Reference and Bayesian-optimized parameter values.
| Parameter | Reference | Optimized | Units |
| --- | --- | --- | --- |
| $D_0$ | 6.9 $\times 10^{-7}$ | 5.82 $\times 10^{-5}$ | m$^2$/s |
| $E_d$ | 1.07 | 1.15 | eV |
| $k_{t,0}$ | 4.2 $\times 10^{8}$ | 1.02 $\times 10^{8}$ | s$^{-1}$ |
| $E_t$ | 1.04 | 0.99 | eV |
| $k_{dt,0}$ | 4.1 $\times 10^{6}$ | 1.91 $\times 10^{5}$ | s$^{-1}$ |
| $E_{dt}$ | 1.19 | 1.09 | eV |

[val-2j_comparison_optimized] shows the comparison between TMAP8 with the optimized parameters and the experimental data. The optimized parameters significantly reduce the RMSPE compared to the reference parameters, demonstrating improved agreement with the experimental TDS spectrum. The optimized diffusivity pre-exponential ($D_0$) is approximately two orders of magnitude larger than the reference value, compensated by a slightly higher activation energy ($E_d$), which shifts the effective diffusion onset. The trapping and detrapping prefactors and energies are adjusted to better capture the shape and position of the high-temperature release peak.

!media comparison_val-2j.py
       image_name=val-2j_comparison_optimized.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2j_comparison_optimized
       caption=Comparison of TMAP8 calculation with Bayesian-optimized parameters against the experimental TDS data for Sample E (high defect density).

## Input files

!style halign=left
The input file for this case can be found at [/val-2j.i], the Bayesian optimization driver is [/bayesian_main_val2j.i], the Bayesian sub-app is [/val-2j_bayesian.i], and the test specification is [/val-2j/tests].

!bibtex bibliography
