# val-2j

# Tritium Thermal Desorption Spectroscopy from Li$_2$TiO$_3$ Solid Breeder

## Case Description

This validation case models tritium thermal desorption spectroscopy (TDS) from neutron-irradiated Li$_2$TiO$_3$ (lithium titanate) crystalline grains, a candidate solid tritium breeding material for Deuterium-Tritium (D-T) fusion reactors. The experimental data and model are from [!cite](kobayashi2015developing).

Li$_2$TiO$_3$ samples were irradiated at the Kyoto University Reactor (KUR) at various neutron fluences. After irradiation, the tritium release behavior was measured by TDS with a heating rate of 5 K/min using pure helium as the purge gas. The average grain radius was 1.5 $\mu$m.

Sample E (high defect density, $D_{id}$ = 0.018 defect/Li$_2$TiO$_3$) is modeled, where tritium release is significantly influenced by trapping at O$^{-}$-centers and defect annihilation.

## Model Description

### Diffusion of Mobile Species

TMAP8 simulates tritium diffusion and trapping in a single spherical grain of Li$_2$TiO$_3$ using 1D spherical coordinates (`coord_type = RSPHERICAL`). The governing equation for mobile tritium concentration $C$ is [!citep](kobayashi2015developing):

\begin{equation} \label{eq:diffusion_trapping}
\frac{\partial C}{\partial t} = D \left( \frac{\partial^2 C}{\partial r^2} + \frac{2}{r} \frac{\partial C}{\partial r} \right) - \frac{\partial C_T}{\partial t},
\end{equation}

where $C_T$ is the concentration of trapped tritium in O$^{-}$-centers, $D$ is the temperature-dependent diffusivity following the Arrhenius law:

\begin{equation} \label{eq:diffusivity}
D = D_0 \exp \left( -\frac{E_d}{k_B T} \right),
\end{equation}

where $D_0$ is the pre-exponential factor, $E_d$ is the activation energy, $k_B$ is the Boltzmann constant, and $T$ is temperature.

### Trapping and Detrapping

Only O$^{-}$-center (hydroxyl group) trapping is included in this model. As noted by [!cite](kobayashi2015developing) (p. 26), tritium release controlled by detrapping from F$^+$-centers (oxygen vacancies) occurs near 580 K, which corresponds to the release temperature controlled by the diffusion process itself. Because F$^+$-center detrapping is not rate-limiting relative to diffusion, it does not produce a distinct feature in the TDS spectrum, and is therefore excluded from the model.

The trapped concentration $C_T$ evolves according to:

\begin{equation}  \label{eq:trapping}
\frac{\partial C_T}{\partial t} = \alpha_t \frac{C_T^{\text{empty}} C_M}{N} - \alpha_r C_T
\end{equation}

where $N$ is the lattice site density, and $C_T^{\text{empty}} = \chi N - C_T$ is the empty trap concentration with $\chi$ being the trap site fraction.

The trapping and detrapping rate coefficients follow Arrhenius relationships:

\begin{equation} \label{eq:trapping_rate}
\alpha_t = \alpha_{t0} \exp\left(-\frac{\epsilon_t}{k_B T}\right)
\end{equation}

\begin{equation} \label{eq:detrapping_rate}
\alpha_r = \alpha_{r0} \exp\left(-\frac{\epsilon_r}{k_B T}\right)
\end{equation}

where $\alpha_{t0}$ and $\alpha_{r0}$ are pre-factors of trapping and release rate coefficients, $\epsilon_t$ and $\epsilon_r$ are trapping and release energies, and $k_B$ is the Boltzmann constant.

### Defect annihilation

During TDS heating, radiation-induced defect sites undergo first-order annihilation [!citep](kobayashi2015developing):

\begin{equation} \label{eq:annihilation}
\frac{d D_{id}}{dt} = -k_{dp-da} \, D_{id},
\end{equation}

where $D_{id}$ is defect density. The trap site fraction $\chi$ is related to radiation defect density $D_{id}$. However, the exact relationship haven't been indicated in [!citep](kobayashi2015developing). Therefore, the initial trap site fraction is assumed to equal the defect density with $\chi(0) = D_{id}$.

The annihilation rate coefficient, k_{dp-da}, is described as:

\begin{equation} \label{eq:annihilation_rate}
k_{dp-da} = k_{dp-da,0} \exp \left( -\frac{E_{dp-da}}{k_B T} \right).
\end{equation}

The raising temperature reduces the available trap sites: the trap site fraction $\chi$ decays over time following [eq:annihilation], preventing re-trapping into annihilated sites. This is implemented by solving the annihilation equation self-consistently as an additional variable within the simulation, using a `ReleasingNodalKernel`.

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
| $\alpha_{r0}$ | detrapping prefactor | 4.1 $\times 10^{6}$ | s$^{-1}$ | [!cite](kobayashi2015developing), Eq. 13 |
| $\epsilon_r$ | detrapping energy | 1.19 | eV | [!cite](kobayashi2015developing), Eq. 13 |
| $\alpha_{t0}$ | Trapping prefactor | 4.2 $\times 10^{8}$ | s$^{-1}$ | [!cite](kobayashi2015developing), Eq. 21 |
| $\epsilon_t$ | Trapping energy | 1.04 | eV | [!cite](kobayashi2015developing), Eq. 21 |
| $k_{dp-da,0}$ | Annihilation prefactor | 1.0 $\times 10^{2}$ | s$^{-1}$ | [!cite](kobayashi2015developing), Eq. 18 |
| $E_{dp-da}$ | Annihilation energy | 0.9 | eV | [!cite](kobayashi2015developing), Eq. 18 |
| $N$ | Lattice density | 1.88 $\times 10^{28}$ | m$^{-3}$ | Calculated |
| $\beta$ | TDS heating rate | 5 | K/min | [!cite](kobayashi2015developing) |
| $D_{id,E}$ | Defect fraction (Sample E) | 0.018 | - | [!cite](kobayashi2015developing), Table 1 |

## Results

### Results before optimization

[val-2j_comparison_e] shows the comparison between TMAP8 and the experimental TDS spectrum for Sample E (high defect density). The O$^{-}$-center trapping model with defect annihilation captures the broad release profile. The high detrapping energy of O$^{-}$-centers (1.19 eV) produces a release peak above 650 K that is distinct from the diffusion-controlled release. The defect annihilation mechanism reduces the effective trap density at high temperatures, suppressing re-trapping and allowing tritium to escape more efficiently.

!media comparison_val-2j.py
       image_name=val-2j_comparison_sample_e.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2j_comparison_e
       caption=Comparison of TMAP8 calculation with the experimental TDS data for Sample E (high defect density).

### Results after optimization

The agreement between the TMAP8 simulation and experimental data can be improved by optimizing the model parameters using [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html). A Bayesian optimization approach [!citep](DHULIPALA2026102776) was applied to optimize six key parameters, three Arrhenius pre-exponential factors (in log$_{10}$ space) and three activation energies, to the experimental TDS curve for Sample E. The optimization used Gaussian Process active learning with Expected Improvement acquisition, running 40 iterations with 5 parallel proposals per iteration.

[val-2j_optimized_parameters] compares the reference values from [!cite](kobayashi2015developing) with the Bayesian-optimized parameters.

!table id=val-2j_optimized_parameters caption=Reference and Bayesian-optimized parameter values.
| Parameter | Reference | Optimized | Units |
| --- | --- | --- | --- |
| $D_0$ | 6.9 $\times 10^{-7}$ | 5.82 $\times 10^{-5}$ | m$^2$/s |
| $E_d$ | 1.07 | 1.15 | eV |
| $\alpha_{t0}$ | 4.2 $\times 10^{8}$ | 1.02 $\times 10^{8}$ | s$^{-1}$ |
| $\epsilon_t$ | 1.04 | 0.99 | eV |
| $\alpha_{r0}$ | 4.1 $\times 10^{6}$ | 1.91 $\times 10^{5}$ | s$^{-1}$ |
| $\epsilon_r$ | 1.19 | 1.09 | eV |

[val-2j_comparison_optimized] shows the comparison between TMAP8 with the optimized parameters and the experimental data. The optimized parameters significantly reduce the RMSPE compared to the reference parameters, demonstrating improved agreement with the experimental TDS spectrum.

!media comparison_val-2j.py
       image_name=val-2j_comparison_optimized.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2j_comparison_optimized
       caption=Comparison of TMAP8 calculation with Bayesian-optimized parameters against the experimental TDS data for Sample E (high defect density).

## Input files

!style halign=left
The input files for this validation case are:

- [/val-2j.i]: Simulates tritium transport in Li$_2$TiO$_3$ spherical sample with original input parameters. [/optimal_bayesian_params.i] includes the optimal initial parameters from bayesian optimization.
- [/bayesian_main_val2j.i] and [/val-2j_bayesian.i]: Include the optimization main and sub input files, respectively, to initialize the bayesian optimization.

More information about these tests can be found in the test specification file for this case, namely [/val-2j/tests].

!bibtex bibliography
