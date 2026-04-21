# Mini-Canister Hydrogen Transport

TMAP8 is used to model hydrogen transport and permeation through an aluminum-clad used nuclear fuel (AUNF) mini-canister storage device from Savannah River National Laboratory (SRNL) [!citep](d'entremont2024aunfminicanister). The mini-canisters house irradiated AUNF assemblies where gamma and neutron radiation from the fuel drives radiolytic decomposition of water, generating H$_2$ gas. Over time, this hydrogen will disassociate and diffuse through the surrounding 304 stainless steel wall, raising concern for potential accumulation. This example demonstrates how TMAP8 can model these processes through two distinct input files:

1. [steel_only.i] — isolates hydrogen diffusion through the steel wall with an assumed boundary partial pressure. This simpler model permits verification against an analytical solution, provided the Dirichlet boundary conditions are time-independent.
2. [gas_steel.i] — simulates the full system: radiolytic H$_2$ generation, gas-phase transport inside the canister, and simultaneous permeation through the steel wall. This model is validated against SRNL experimental measurements [!citep](d'entremont2024aunfminicanister).

!media examples/figures/srnl_mini_canister.jpeg
  id=fig:canister
  caption=SRNL AUNF mini-canister storage device.
  style=display:block;margin-left:auto;margin-right:auto;width:40%

Both models share the same 1D axisymmetric geometry and material parameters for the steel wall. The progression from [steel_only.i] to [gas_steel.i] illustrates the flexibility of TMAP8 in building complexity incrementally.

## Canister Geometry and Mesh

!style halign=left
Both models represent the canister as a 1D axisymmetric domain in cylindrical coordinates ($r$, $z$), assuming a near-uniform radial concentration profile along the height of the canister. The canister dimensions [!citep](d'entremont2024aunfminicanister), are listed in [tab:geometry].

!table id=tab:geometry caption=Canister geometry.
| Parameter | Value | Units |
| --- | --- | --- |
| Inner radius, $r_i$ | 1.415 in (35.94 mm) | mm |
| Steel wall thickness, $\delta_s$ | 0.085 in (2.16 mm) | mm |
| Outer radius, $r_o = r_i + \delta_s$ | 1.500 in (38.10 mm) | mm |
| Canister height, $h$ | 7.06 in (179.3 mm) | mm |
| Internal gas volume, $V_g = \pi r_i^2 h$ | $\approx$ 727,400 | mm$^3$ |

In the input files, the 1D mesh represents the radial ($r$) direction only. For [steel_only.i], the mesh spans from $r_i$ to $r_o$ with 2,000 elements. For [gas_steel.i], two adjacent mesh blocks share the same element spacing: the gas block from $r = 0$ to $r = r_i$ and the steel block from $r = r_i$ to $r = r_o$.

!listing test/tests/mini_canister/steel_only.i link=false block=Mesh

!listing test/tests/mini_canister/gas_steel.i link=false block=Mesh

## Nomenclature

!style halign=left
[tab:variables] lists the variables and physical parameters used in this example with their units.

!table id=tab:variables caption=Nomenclature of variables and physical parameters.
| Symbol | Description | Units |
| --- | --- | --- |
| $C_s$ | Mobile H atom concentration in steel | $\mu$mol mm$^{-3}$ |
| $C_g$ | Mobile H$_2$ molecule concentration in gas | $\mu$mol mm$^{-3}$ |
| $D_s$ | Diffusivity of H in 304 stainless steel | mm$^2$ day$^{-1}$ |
| $D_g$ | Diffusivity of H$_2$ in He | mm$^2$ day$^{-1}$ |
| $K_s$ | Solubility of H in steel (Sieverts' constant) | $\mu$mol mm$^{-3}$ Pa$^{-1/2}$ |
| $P$ | Partial pressure of H$_2$ | Pa |
| $T$ | Temperature (constant) | K |
| $R$ | Ideal gas constant | J K$^{-1}$mol$^{-1}$ |
| $S$ | Volumetric H$_2$ generation rate in gas | $\mu$mol mm$^{-3}$ day$^{-1}$ |
| $N(t)$ | Cumulative H$_2$ yield in gas | $\mu$mol |
| $t$ | Time | day |

## Steel-Only Model

### Governing Equations

!style halign=left
In the steel-only model, only hydrogen transport within the steel wall is simulated. The governing equation is a 1D diffusion model:

\begin{equation} \label{eq:steel_diffusion}
\frac{\partial C_s}{\partial t} = \frac{\partial}{\partial x}\left(D_s\frac{\partial C_s}{\partial x} \right),
\end{equation}

where the diffusivity follows an Arrhenius temperature dependence [!citep](san_marchi2012hydrogensteel):

\begin{equation} \label{eq:diffusivity}
D_s(T) = D_{s,0} \exp\!\left( - \frac{E_{D}}{RT} \right).
\end{equation}

### Boundary Conditions

!style halign=left
At the inner steel surface ($r = r_i$), the hydrogen concentration is implemented in TMAP8 using `ADInterfaceSorption`, using Sieverts' law with the internal H$_2$ partial pressure:

\begin{equation} \label{eq:sieverts_bc}
C_s(r_i, t) = 2 K_s(T) \sqrt{P},
\end{equation}

where the factor of 2 converts from molecular H$_2$ equilibrium to atomic H concentration, and the solubility follows an Arrhenius dependence:

\begin{equation} \label{eq:solubility}
K_s(T) = K_{s,0} \exp\!\left( - \frac{E_{K}}{RT} \right).
\end{equation}

!style halign=left
The H$_2$ partial pressure $P$ is provided as an auxiliary variable, set by a function representing one of three options: (1) a constant value, (2) a linear time ramp from zero to the constant value over 3 hours, or (3) a power-law fit to experimental SRNL pressure data. The default configuration uses the constant pressure option:

\begin{equation} \label{eq:assumed_pressure}
P = 0.10 \times 24 \text{ psi} \approx 16{,}547 \text{ Pa},
\end{equation}

which assumes 10% of the 24 psi He-backfilled canister pressure is attributable to H$_2$ [!citep](d'entremont2024aunfminicanister,hlushko2024aunf).

At the outer steel surface ($r = r_o$), hydrogen is released to the ambient environment, and the concentration is set to zero by a Dirichlet condition:

\begin{equation} \label{eq:outer_bc}
C_s(r_o, t) = 0.
\end{equation}

### Model Parameters

!table id=tab:steel_only_params caption=Steel-only model parameters.
| Parameter | Description | Value | Units | Reference |
| --- | --- | --- | --- | --- |
| $D_{s,0}$ | Diffusivity pre-exponential factor | $0.20 \times 10^{-6}$ | m$^2$ s$^{-1}$ | [!cite](san_marchi2012hydrogensteel) |
| $E_{D}$ | Diffusivity activation energy | 49.3 | kJ mol$^{-1}$ | [!cite](san_marchi2012hydrogensteel) |
| $K_{s,0}$ | Solubility pre-exponential factor | $266 \times 10^{-6}$ | $\mu$mol mm$^{-3}$ Pa$^{-1/2}$ | [!cite](san_marchi2012hydrogensteel) |
| $E_{K}$ | Solubility activation energy | 6.86 | kJ mol$^{-1}$ | [!cite](san_marchi2012hydrogensteel) |
| $T$ | Temperature | 313.15 | K | [!cite](hlushko2024aunf) |
| $P$ | Assumed H$_2$ partial pressure | $\approx$ 16,547 | Pa | [!cite](hlushko2024aunf) |

### Results

#### Diffusion Front Verification

!style halign=left
For a semi-infinite slab with a constant-concentration boundary condition, the diffusion front advances as $\ell(t) = \sqrt{\pi D_s t}$, defined here as the $x$-intercept of the tangent line to the concentration profile at the inner surface. This analytical result provides a straightforward check that the numerical diffusion is correctly implemented. [fig:diffusion_length] shows the simulated diffusion front length, using a constant pressure, compared to the analytical expression.

!media steel_only_comparison.py
  image_name=diffusion_length.png
  style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
  id=fig:diffusion_length
  caption=Comparison of the simulated and analytical ($\sqrt{\pi D_s t}$) diffusion front length in the steel wall over 0.25 years.

#### Conservation of Mass

!style halign=left
As an internal consistency check, the total hydrogen mass integrated over the steel domain is compared against the time-integrated net diffusive flux across the boundaries. It is important to note that these integrals are weighted due to the axisymmetric assumption. [fig:steel_conservation] shows the two quantities track closely throughout the simulation, confirming mass conservation.

!media steel_only_comparison.py
  image_name=steel_only_conservation_of_mass.png
  style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
  id=fig:steel_conservation
  caption=Conservation of mass check for the steel-only model: accumulated boundary flux vs. total H mass in the steel domain.

## Gas-Steel Model

### Governing Equations

!style halign=left
The gas-steel model resolves both the gas phase and steel simultaneously. In the gas phase ($0 \leq r \leq r_i$), H$_2$ is generated by radiolysis and transported by diffusion:

\begin{equation} \label{eq:gas_diffusion}
\frac{\partial C_g}{\partial t} = \frac{\partial}{\partial x}\left(D_g \frac{\partial C_g}{\partial x} \right) + S(t),
\end{equation}

where $D_g$ is the diffusivity of H$_2$ in the He carrier gas [!citep](middha2002hydrogenhelium). In the steel wall ($r_i \leq r \leq r_o$), [eq:steel_diffusion] applies as before.

### Hydrogen Generation Source Term

!style halign=left
The cumulative radiolytic H$_2$ yield is modeled using a power-law fit to the SRNL experimental data [!citep](d'entremont2024aunfminicanister):

\begin{equation} \label{eq:H2_yield}
N(t) = 69.7055 \, t^{0.6808} \quad [\mu\text{mol}],
\end{equation}

where $t$ is time in days, calibrated assuming a Co-60 irradiator dose rate of approximately 124.7 Gy/min [!citep](d'entremont2024aunfminicanister). The volumetric source term in [eq:gas_diffusion] is obtained by differentiating [eq:H2_yield] with respect to time and normalizing by the gas volume:

\begin{equation} \label{eq:source_term}
S(t) = \frac{1}{V_g} \frac{dN}{dt} = \frac{69.7055 \times 0.6808}{V_g} \, t^{0.6808 - 1} \quad [\mu\text{mol mm}^{-3}\text{ day}^{-1}].
\end{equation}

### Interface Condition

!style halign=left
At the gas-steel interface ($r = r_i$), hydrogen equilibrium between the gas and solid phases is enforced via Sieverts' law. Using the ideal gas law to convert gas-phase concentration to partial pressure ($P = C_g R T$), the equilibrium atomic hydrogen concentration in the steel is:

\begin{equation} \label{eq:interface_sieverts}
C_s(r_i, t) = 2 K_s(T) \sqrt{C_g(r_i, t) \, R \, T},
\end{equation}

implemented in TMAP8 using the `ADInterfaceSorption` kernel with a unit-conversion factor to account for the difference between gas-phase ($\mu$mol mm$^{-3}$) and SI pressure units.

### Model Parameters

!table id=tab:gas_steel_params caption=Additional gas-steel model parameters (steel parameters as in [tab:steel_only_params]).
| Parameter | Description | Value | Units | Reference |
| --- | --- | --- | --- | --- |
| $D_g$ | H$_2$ diffusivity in He | 2.7 | cm$^2$ s$^{-1}$ | [!cite](middha2002hydrogenhelium) |
| $a$ | H$_2$ yield pre-factor | 69.7055 | $\mu$mol day$^{-0.6808}$ | [!cite](d'entremont2024aunfminicanister) |
| $b$ | H$_2$ yield exponent | 0.6808 | — | [!cite](d'entremont2024aunfminicanister) |
| $V_g$ | Internal gas volume | $\approx$ 727,400 | mm$^3$ | Computed |
| $T$ | Temperature | 313.15 | K | [!cite](hlushko2024aunf) |

### Results

#### Partial Pressure Validation

!style halign=left
[fig:partial_pressure] compares the simulated H$_2$ partial pressure at the gas-steel interface against pressure measurements from the SRNL irradiation experiment [!citep](d'entremont2024aunfminicanister). The simulation uses the ideal gas law to approximate the gas-phase H$_2$ concentration to partial pressure.

!media gas_steel_comparison.py
  image_name=partial_pressure_comparison.png
  style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
  id=fig:partial_pressure
  caption=Comparison of TMAP8 simulated H$_2$ partial pressure at the gas-steel interface against SRNL experimental measurements.

#### Gas-Phase Hydrogen Yield Validation

!style halign=left
[fig:gas_yield] compares the total atomic hydrogen mass in the gas phase against the cumulative H$_2$ yield measured by SRNL [!citep](d'entremont2024aunfminicanister). Agreement between the simulation and experiment reflects the accuracy of the power-law source model ([eq:H2_yield]). It is important to note that we are comparing against data that is also fed into the model. Future work will include a more complex generation model independent of this data.

!media gas_steel_comparison.py
  image_name=gas_phase_validation.png
  style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
  id=fig:gas_yield
  caption=Comparison of TMAP8 total gas-phase hydrogen mass against SRNL experimental cumulative H$_2$ yield data.

#### Comparison of Steel Hydrogen Uptake Between Models

!style halign=left
[fig:model_comparison] compares the total atomic hydrogen mass accumulated in the steel wall between the steel-only and gas-steel models. While the steel-only model uses a constant assumed H$_2$ partial pressure, the gas-steel model evolves the interface pressure self-consistently. The steel-only model can also utilize time-dependent pressure data from SRNL [!citep](d'entremont2024aunfminicanister) by changing pressure_function in [steel_only.i] or on the command line, nullifying the assumptions for the diffusion length verification but greatly improving agreement between the two models.

!media gas_steel_comparison.py
  image_name=hydrogen_yield_model_comparison.png
  style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
  id=fig:model_comparison
  caption=Comparison of total H mass in the steel wall between the steel-only (constant pressure) and gas-steel simulations.

#### Conservation of Mass

!style halign=left
[fig:gas_steel_conservation] verifies conservation of mass in the gas-steel model by comparing the total hydrogen mass in the domain against the sum of the time-integrated boundary flux and the cumulative source term. The two quantities track closely, confirming that mass contributions from the coupled gas-generation, gas-phase transport, interface transfer, and steel diffusion are all consistently accounted for.

!media gas_steel_comparison.py
  image_name=conservation_of_mass.png
  style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
  id=fig:gas_steel_conservation
  caption=Conservation of mass check for the gas-steel model: accumulated boundary flux plus source term vs. total H mass in the domain.

## Input Files

!style halign=left
The input files for this example are [/steel_only.i] and [/gas_steel.i], and both are also used as tests in TMAP8 at [/mini_canister/tests].

!listing test/tests/mini_canister/steel_only.i link=false

!listing test/tests/mini_canister/gas_steel.i link=false

!bibtex bibliography
