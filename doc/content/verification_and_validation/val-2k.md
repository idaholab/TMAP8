# val-2k

# Oxide effects on deuterium release from self-irradiated tungsten

## Overall Case Description

This validation case is based on the natural-oxide and thin-oxide experiments reported in [!cite](Kremer2022oxide).
The experimental study performs thermal desorption spectroscopy (TDS) and measures deuterium release during from self-irradiated tungsten samples with a natural oxide layer and with electrochemically grown oxide layers between 5 nm and 100 nm.
This case uses the same overarching model (e.g., tungsten diffusion, trapping, and surface-release formulation) to capture the deuterium release behavior of four self irradiated tungsten samples with distinct oxygen-field configurations: natural-oxide and 5 nm, 10 nm, and 15 nm thin oxide films.
The effect of the thin oxide films on the release is discussed, with the model providing key mechanistic insights into the observed experimental behavior.
The release behavior is captured as the time-dependant D release in HD, D$_2$, HDO, and D$_2$O forms as the temperature increases.

The aim of this study is to understand the effect of the presence of an oxide layer on deuterium retention and release from tungsten samples.
While tungsten oxidation is expected to be limited in fusion power plant conditions, it does take place in laboratory environments, which can affect laboratory observations.
Understanding oxide effects can thus help better tie laboratory experiments to performance in fusion-relevant environments.

## Sample history and dimensions

The reference sample history is taken from [!cite](Kremer2022oxide).
In the experiment, the 0.8 mm tungsten specimens are first self-irradiated, which generates a self-damaged near-surface region (2.3 $\mu$m thick).
The samples are then loaded with deuterium so that the retained inventory is concentrated in the first few micrometers of the sample.
The loading is performed at 370 K to enable deuterium mobility while minimizing defect annealing in the self-damaged region.
Once loaded, a thin oxide layer is deposited using an electrochemical process at low temperature.
The advantage of this approach is that compared to thermal oxidation, the temperature remains low (e.g., room temperature), which limits deuterium transport and defect annealing.
[!cite](Kremer2022oxide) note that electro-chemically grown tungsten oxide has an amorphous structure and therefore differs from thermally grown oxide or natural oxide, which might affect the release behavior.

While [!cite](Kremer2022oxide) offer a wide range of data and observations for oxide layers thickness reaching up to 100 nm, the current study focuses on the thinner oxide films discussed in the experimetal paper, namely a sample with a natural oxide layer (assumed here to be 0.5 nm thick), and then samples with a 5 nm, 10 nm, and 15 nm-thick oxide film.
All four desorption calculations start from the same preloaded tungsten state and follow the digitized temperature history from Fig. 6 in [!cite](Kremer2022oxide), which heats the sample from about 296 K to about 1000 K over roughly 4.17 h.

The initial deuterium profile used at the start of desorption is shown in [val-2k_natural_oxide_profile] for the 15 nm configuration (the same approach is used for the other samples).
The shaded regions identify the oxide, damaged tungsten, and bulk tungsten sections in the plotted depth range.
In this configuration, most of the retained inventory is placed in the irradiation-induced traps inside the damaged region, while the mobile deuterium concentration remains comparatively negligible.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_profile.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_profile
    caption=Initial deuterium concentration profile used to start the 15 nm `val-2k` desorption calculation. The profile shows the mobile deuterium concentration (negligible), the six trapped populations, their total, and the oxide, damaged tungsten, and bulk tungsten sections.

## Model Description

To capture the deteurium release behavior from self irraiated tungsten with a thin oxide film, the model includes the following features:

- a one-dimensional geometry with a oxide layer (with four different thicknesses based on the case of interest), a self-damaged region, and the tungsten bulk, as illustrated in [val-2k_natural_oxide_profile].
- deuterium transport involves fickian diffusion, trapping and resolution, and surface reactions.
- trapping and reolution is governed by six trap (one intrinsic trap, and 5 irradiation-induced traps) families. This is directly inspired from (val-2f)[val-2f.md], which validates TMAP8 based on deuterium release from self-irradiated tungsten. The full set of trap site densities is adapted from [val-2f](val-2f.md) values so the initial areal inventory matches the prescribed `val-2k` preload.
- The density of the intrinsic trap, since it is independent of irradiation, is homogeneous in the sample. The densities of irradiation-induced traps, however, are homogeneous in the 2.3 $\mu$m-thick self-damaged region, and then quickly decrease to 0 in the bulk of the sample, with a transition length of 0.05 $\mu$m.
- deuterium release takes place either as D$_2$ or as D$_2$O by combining with an oxygen atom at the surface. The surface recombination rates of these reactions are different.
- The oxide layer is modeled as an additional layer on top of the self-damaged region. The transport properties of deuterium in the oxide layer remain equal to those in tungsten (e.g., same diffusivity), expect that no trapping sites are present in the oxide layer. Note that the thickness of the oxygen layer does not evolve in time, even as oxygen atoms are released as D$_2$O. These simplifications are considered reasonable as the oxide layer represents only a small volume and thickness in these cases.
- The oxide layer is initialized with a given oxygen concentration (consistent across cases), which is null everywhere else. The diffusivity of oxygen in the oxide layer is accounted for, but the diffusion of oxygen deeper into the tungsten sample is suppressed.
- To accurately capture the surface reactions, oxygen transport, behavior in the self-damaged region, and resolve the oxide-to-damaged-tungsten and damaged-to-bulk-tungsten transitions, the mesh is refined near the exposed surface, with a coarser mesh beeper in the sample.
- The only difference between the four configurations of interest (e.g., natural oxide and 5, 10, and 15 nm-thick oxide films) is the thickness of the oxide layer and the mesh refinement area. The model formulation, other initial conditions, and all the model parameters are consistent across all cases.


As in (val-2f)[val-2f.md], this is solved in dimensionless form using:

\begin{equation}
\hat{x} = \frac{x}{L_{\text{ref}}}, \qquad \hat{t} = \frac{t}{t_{\text{ref}}}, \qquad
\hat{C}_M = \frac{C_M}{C_{M,\text{ref}}}, \qquad
\hat{C}_{T_i} = \frac{C_{T_i}}{C_{T_i,\text{ref}}}, \qquad
\hat{C}_O = \frac{C_O}{C_{O,\text{ref}}},
\end{equation}

with $L_{\text{ref}} = 1$ $\mu$m and $t_{\text{ref}} = 1$ s.

The dimensionless mobile deuterium balance solved in the input file is:

\begin{equation}
\frac{\partial \hat{C}_M}{\partial \hat{t}} =
\hat{\nabla} \cdot \left(\hat{D}_W \hat{\nabla} \hat{C}_M \right) +
\sum_{i \in \{intr,1,\dots,5\}}
\frac{C_{T_i,\text{ref}}}{C_{M,\text{ref}}}
\frac{\partial \hat{C}_{T_i}}{\partial \hat{t}}
\end{equation}

and the oxygen field satisfies

\begin{equation}
\frac{\partial \hat{C}_O}{\partial \hat{t}} =
\hat{\nabla} \cdot \left(\hat{D}_O \hat{\nabla} \hat{C}_O \right).
\end{equation}

The trapped species are introduced using six [SpeciesTrappingPhysics](physics/SpeciesTrappingPhysics.md) blocks, one for each trap family. Each block creates the time derivative, trapping, releasing, and mobile-species coupling terms automatically. The dimensionless trapping and release groups are

\begin{equation}
\hat{k}_{t,i} = t_{\text{ref}} \alpha_{t,i} \frac{C_{M,\text{ref}}}{N}
\qquad \text{and} \qquad
\hat{k}_{r,i} = t_{\text{ref}} \alpha_{r,i}
\end{equation}

and the temperature-dependent transport and surface coefficients are written as

\begin{equation}
\hat{D}_W = \hat{D}_{W,0} \exp \left(- \frac{E_{D}}{k_B T} \right),
\qquad
\hat{D}_O = \hat{D}_{O,0} \exp \left(- \frac{E_{D,O}}{k_B T} \right),
\end{equation}

\begin{equation}
\hat{K}_{r,D_2} = \hat{K}_{r,D_2,0} \exp \left(- \frac{E_{r,D_2}}{k_B T} \right),
\qquad
\hat{K}_{r,D_2O} = \hat{K}_{r,D_2O,0} \exp \left(- \frac{E_{r,D_2O}}{k_B T} \right).
\end{equation}

The surface release is modeled as finite fluxes on both free surfaces, with

***** write chemical reactions *****

\begin{equation}
\hat{J}_{D_2} = -2 \hat{K}_{r,D_2} \hat{C}_M^2,
\qquad
\hat{J}_{D_2O} = -2 \hat{K}_{r,D_2O} \hat{C}_O \hat{C}_M^2,
\qquad
\hat{J}_O = \hat{s}_O \hat{J}_{D_2O},
\end{equation}

where $\hat{s}_O$ is the stoichiometric factor that converts the D$_2$O surface loss into oxygen loss.
The initial oxygen concentration is derived from the paper-reported removal of $100 \times 10^{19}$ O/m$^2$ from the first 13.5 nm of oxide and is reduced by an additional factor of 1.5 in the current calibrated model, which yields about $4.94 \times 10^{28}$ O/m$^3$.
Oxygen transport is also restricted to the oxide region through the same smooth oxide mask used to initialize the front-surface oxygen field.
The current oxygen diffusivity and D$_2$O release parameters are therefore best interpreted as calibrated effective kinetics for matching the observed TDS trends rather than as a direct literature transcription.
Future work will involved a thorough Bayesian inference study and comparison of optimized model parameters agains literature values.

## Case and Model Parameters

The literature-based and calibrated model parameters, geometry, and sample history conditions are listed in [val-2k_parameters].

!table id=val-2k_parameters caption=Parameters used in the current deuterium-only implementation stage of `val-2k`.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $l_W$ | Tungsten thickness | 0.8 | mm | [!cite](Kremer2022oxide) |
| $l_{ox}$ | Oxide thickness in the oxide comparison cases | 0.5, 5, 10, 15 | nm | Natural-oxide proxy plus explicit thin-film cases from [!cite](Kremer2022oxide) |
| $w_{ox}$ | Tanh transition width used for oxide-to-W blending | 0.25 | nm | Numerical resolution choice |
| $l_d$ | Self-damaged depth | 2.3 | $\mu$m | [!cite](Kremer2022oxide) |
| $T_0$ | Initial desorption temperature | $\approx$ 295.775 | K | Digitized from Fig. 6 in [!cite](Kremer2022oxide) |
| $T_f$ | Final desorption temperature | $\approx$ 1001.408 | K | Digitized from Fig. 6 in [!cite](Kremer2022oxide) |
| $t_f$ | Final desorption time | 4.166 | h | Digitized from Fig. 6 in [!cite](Kremer2022oxide) |
| $D_0$ | Deuterium diffusivity prefactor | 1.6 $\times 10^{-7}$ | m$^2$/s | From [val-2f](val-2f.md) |
| $E_D$ | Deuterium diffusion activation energy | 0.28 | eV | From [val-2f](val-2f.md) |
| $D_{0,O}$ | Oxygen diffusivity prefactor in oxide film | 2.0 $\times 10^{-17}$ | m$^2$/s | Calibrated, starting from [!cite](Jiang2009oxygenDiffusion) |
| $E_{D,O}$ | Oxygen diffusion activation energy in oxide film | 0.45 | eV | Calibrated, starting from [!cite](Jiang2009oxygenDiffusion) |
| $C_{O,0}$ | Initial oxygen concentration in oxide film | 4.94 $\times 10^{28}$ | at/m$^3$ | Adapted from the oxygen areal density from [!cite](Kremer2021oxideBarrier) |
| $w_d$ | Tanh transition width used for damaged-to-bulk W blending | 0.05 | $\mu$m | Numerical resolution choice |
| $L_{\text{ref}}$ | Reference length for the dimensionless solve | 1 | $\mu$m | Chosen to match the val-2f adimensionalization |
| $t_{\text{ref}}$ | Reference time for the dimensionless solve | 1 | s | Chosen to match the val-2f adimensionalization |
| $C_{M,\text{ref}}$ | Mobile reference concentration | 6.3222 $\times 10^{16}$ | at/m$^3$ | From [val-2f](val-2f.md) |
| $C_{T,\text{ref}}^{intr}$ | Intrinsic-trap reference concentration | 6.3222 $\times 10^{17}$ | at/m$^3$ | From [val-2f](val-2f.md) |
| $C_{T,\text{ref}}^{1-5}$ | Non-intrinsic trap reference concentration | 6.3222 $\times 10^{20}$ | at/m$^3$ | From [val-2f](val-2f.md) |
| $s_T$ | Uniform trap-density scale factor | 6.644848 | - | Chosen so the six-trap model matches the prior `val-2k` initial areal inventory |
| $E_{T,intr}$ | Intrinsic detrapping energy | 1.08 | eV | Adapted from [val-2f](val-2f.md) |
| $E_{T,1}$ | Trap 1 detrapping energy | 1.20 | eV | Adapted from [val-2f](val-2f.md) |
| $E_{T,2}$ | Trap 2 detrapping energy | 1.38 | eV | Adapted from [val-2f](val-2f.md) |
| $E_{T,3}$ | Trap 3 detrapping energy | 1.65 | eV | From [val-2f](val-2f.md) |
| $E_{T,4}$ | Trap 4 detrapping energy | 1.85 | eV | From [val-2f](val-2f.md) |
| $E_{T,5}$ | Trap 5 detrapping energy | 2.05 | eV | From [val-2f](val-2f.md) |
| $C_{T,intr,0}$ | Intrinsic trap site density | 1.595 $\times 10^{23}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_1,0}$ | Trap 1 site density | 3.076 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_2,0}$ | Trap 2 site density | 1.910 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_3,0}$ | Trap 3 site density | 1.304 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_4,0}$ | Trap 4 site density | 2.392 $\times 10^{26}$ | at/m$^3$ | Adapted from [val-2f](val-2f.md) |
| $C_{T_5,0}$ | Trap 5 site density | 7.330 $\times 10^{25}$ | at/m$^3$ | Adapted from [val-2f](val-2f.md) |
| $K_r$ | Recombination prefactor | 3.8 $\times 10^{-16}$ | m$^4$/at/s | Adapted from [val-2f](val-2f.md) |
| $E_r$ | Recombination activation energy | 0.34 | eV | Adapted from [val-2f](val-2f.md) |
| $K_r^{D_2O}$ | D$_2$O surface-release prefactor | 3.8 $\times 10^{1}$ | m$^4$/at/s | Calibrated |
| $E_r^{D_2O}$ | D$_2$O surface-release activation energy | 2.10 | eV | Calibrated |

## Results

[val-2k_comparison] compares the deuterium release behavior of all four oxide layer configuration against the digitized natural-oxide HD + D$_2$ and HDO + D$_2$O desorption data from Fig. 6 of [!cite](Kremer2022oxide).
The figure also overlays the time-dependent temperatureof the TDS experiment.
While [val-2k_comparison] shows the experimentally measured and simulated D$_2$ and D$_2$O release curves for all four configurations, [val-2k_natural_oxide_case_comparison], [val-2k_5nm_oxide_case_comparison], [val-2k_10nm_oxide_case_comparison], and [val-2k_15nm_oxide_case_comparison] show a subset of the same data by focussing, for clarity, on the natural oxide case, and the 5 nm, 10 nm, and 15 nm-thick oxide film case, respectively.
This makes it easier to inspect the onset temperature, peak placement, D$_2$/D$_2$O balance, and general trends for each oxide thickness without visual crowding from the other three cases.

!media comparison_val-2k.py
    image_name=val-2k_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_comparison
    caption=Comparison of the D$_2$ and D$_2$O release simulation predictions against TDS experimental measurements from [!cite](Kremer2022oxide) for all four oxide thicknesses.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_case_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_case_comparison
    caption=Focused comparison of the D$_2$ and D$_2$O release simulation predictions against TDS experimental measurements from [!cite](Kremer2022oxide) for the natural-oxide case (0.5 nm thick). The data is a subset of the data in [val-2k_comparison].

!media comparison_val-2k.py
    image_name=val-2k_5nm_oxide_case_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_5nm_oxide_case_comparison
    caption=Focused comparison of the D$_2$ and D$_2$O release simulation predictions against TDS experimental measurements from [!cite](Kremer2022oxide) for the 5 nm-thick oxide case. The data is a subset of the data in [val-2k_comparison].

!media comparison_val-2k.py
    image_name=val-2k_10nm_oxide_case_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_10nm_oxide_case_comparison
    caption=Focused comparison of the D$_2$ and D$_2$O release simulation predictions against TDS experimental measurements from [!cite](Kremer2022oxide) for the 10 nm-thick oxide case. The data is a subset of the data in [val-2k_comparison].

!media comparison_val-2k.py
    image_name=val-2k_15nm_oxide_case_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_15nm_oxide_case_comparison
    caption=Focused comparison of the D$_2$ and D$_2$O release simulation predictions against TDS experimental measurements from [!cite](Kremer2022oxide) for the 15 nm-thick oxide case. The data is a subset of the data in [val-2k_comparison].

In the case of the natural oxide shown in [val-2k_natural_oxide_case_comparison], the deuterium release is dominated by D$_2$ release with two main peaks dictated by the trapping energies.
This is consistent with the results discussed in [val-2f](val-2f.md) and [!cite](dark2024modelling,Kadz2026).
The low release in D$_2$O form is attributed to the lower availability of oxygen, since the 0.5 nm thin layer quickly gets depleated, as shown in [val-2k_natural_oxide_oxygen_inventory].
The model capture the main trends observed experimentally.
The position and magnitude of the two peaks for D$_2$ release are predicted, as well as the ratio of D$_2$ to D$_2$O release.
The main difference in trends is the short peak in D$_2$O instead of the wider peak observed experimentally.
This could be attributed to some oxygen availability from deeper into the tungsten or within the experimental set up.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_oxygen_inventory.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_oxygen_inventory
    caption=Total oxygen inventory remaining in the sample over time. As described in [!cite](Kremer2022oxide), the oxide layer disapears during TDS for most cases, but some remains for the 15 nm-thick oxide film case. Note that while no oxide was observed after TDS for the 10 nm sample, the simulation predicts some remaining inventory, albeit only a small fraction of the initial amount.

[val-2k_natural_oxide_inventory] shows the evolution of the deuterium inventory as a mobile species and in each trap over time.
The deuterium release is dominated by the trapping populations, while the mobile deuterium inventory remains much smaller throughout the desorption ramp, as mobile deuterium quickly react at the surface of the sample.
The lower-energy traps begin to empty first as the temperature rises, followed by the deeper trap populations later in the ramp, as expected.
This behavior is found to be common to all four cases, with no significant effect of the oxide thickness on the detrapping behavior.
This is expected since the traps description is common across all cases.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_inventory.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_inventory
    caption=Evolution of the mobile and trapped deuterium inventories during desorption for the 0.5 nm natural-oxide sample. This behavior is common to all four cases.

As the oxide film thickness increases, the following trends are observable experimentally in [val-2k_comparison]:

- The ratio of D$_2$O release over D$_2$ increases as oxygen availability increases.
- The low temperature peak D$_2$ maintains it position, but its magnitude decreases consistently.
- The high temperature peak shifts to higher temperatures and its magnitude decreases, even disapearing when the oxide thickness increases from 10 nm to 15 nm.
- The magnitude of the D$_2$O increases, with a first update aligned with the first D$_2$ peak, then a stable region, and then either a decrease in the case of the 5 nm-thick oxide, or another peak aligned with the second D$_2$ peak. This secondary peak for D$_2$O in the case of the 10 nm oxide decreases sooner than in the case of the 15 nm oxide.

These trends are all qualitatively captured by the calibrated model.
Furthermore, even if the model lacks a purely mechanistic description of the deuterium and oxide behavior, the simulations offer some physical insights into these observed trends.

Oxygen availability was found to be a key parameter during model calibration.
As the oxide thickness increases and the oxygen inventory increases (see [val-2k_natural_oxide_oxygen_inventory]), the ratio of D$_2$ to D$_2$O release decreases.
Then, as the oxygen inventory gets depleated, D$_2$O release naturally decreases.
This explains the lack of secondary peak in D$_2$O release for the 5 nm oxide sample, as well as the thinner secondary D$_2$O peak for the 10 nm oxide sample compared to the 15 nm oxide sample.

For oxygen to be effectively used for D$_2$O release, however, the ratio of the rate of the D$_2$ and D$_2$O surface reactions must be advantageous, and the oxygen diffusion in the oxide layer needs to be sufficient.
The slight delay in the onset in D$_2$O release at low temperature compared to D$_2$ release is captured by a lower D$_2$O surface reaction rate at low temperature.
However, at high temperature, the surface recation rate of D$_2$O need to surpass the one of D$_2$ to observe the suppression of the secondary D$_2$ peak in favor of the secondary D$_2$O peak.
[val-2k_natural_oxide_recombination_rates] shows the two phenomenological surface-release coefficients over the experimental desorption temperature window.
In the calibrated parameter set, the D$_2$O channel is strongly suppressed at low temperature by its larger activation energy, then rises more steeply and overtakes the D$_2$ coefficient at about 520 K, enabling the behavior discussed above.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_recombination_rates.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_recombination_rates
    caption=Arrhenius-form surface recombination coefficients used for the D$_2$ and D$_2$O release reactions.

In the case of the 15 nm-thick oxide, the secondary D$_2$ peak is not completely surpressed in the current model.
However, this might be resolved with further model calibration.


To check the numerical accuracy of the simulation presented here, the mass conservation of deuterium and oxygen are computed.
[val-2k_natural_oxide_mass_conservation] tracks the deuterium mass-balance residual normalized by the initial deuterium inventory for every currently available modeled case.
The residual is formed from the change in deuterium retained in the sample plus the time-integrated left and right surface release fluxes, so values close to zero indicate mass conservation, which is the case here.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_mass_conservation.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_mass_conservation
    caption=Relative deuterium mass-balance residual over time for all four cases, which shows that mass conservation errors are below reasonable limits.

[val-2k_natural_oxide_oxygen_conservation] tracks the oxygen conservation residual normalized by the initial oxygen inventory in each available oxygen-field case.
The residual is formed from the change in oxygen retained in the sample plus the time-integrated oxygen loss tied to D$_2$O release, so values close to zero indicate mass conservation, which is the case here.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_oxygen_conservation.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_oxygen_conservation
    caption=Relative oxygen conservation residual over time for all four cases, which shows that mass conservation errors are below reasonable limits.


## Discussion and future work

The model proposed herein uses a general formulation and consistent parameters for all four samples with different oxide thicknesses, and qualitatively captures the main experimentally-observed trends and differences between all configurations published in [!cite](Kremer2022oxide).
By doing so, it provides key physical insights into the experimental measurements and observations.
This insight is valuable to tie laboratory observations, where tungsten oxidation often takes place, to performances in fusion power plant environments.

This model, however, has limitations that should be addressed by future work.
The limitations discussed in [!cite](Kremer2022oxide) (e.g., electro-chemically grown oxide being different than thermally grown oxide) still apply to this study.
A more thorough characterization of the oxide and a general analysis including different oxide structures would help generalize the current model, which currently does not model the oxide structure and would not differentiate between different oxide types.
In addition, the model makes other key assumptions and simplification that could be challenged in the future to confirm the interpretation proposed in this study.
For example, the model does not capture the increased surface diffusion of deuterium, which is discussed in the original paper [!citep](Kremer2022oxide) as a key release mechanism as deuterium atoms diffuse wlong the sample surface to find remaining pockets of oxygen to be released as D$_2$O.
To model this, the geometry should be expanded to a 2D or 3D model, which is possible in TMAP8 [!citep](Franklin2025,Shimada2024,Simon2022,Simon2025).

The current study implemented the model and performed ad hoc calibration of the model paremeters based on the potential driving mechanisms of oxide evolution and deuterium detrapping, diffusion, and surface reactions.
While the experimentally observed trends are qualitatively captured by the model, the simulation results are quantitatively different from the experimetal measurements.
Using Bayesian inference across all sets of experimental data would enable to calibrate the model to the experimental data while quantifying uncertainties and sources of errors from model inadequacy, experimental errors, and model parameter uncertainty [!citep](DHULIPALA2026102776,DHULIPALA2025155795).
This analysis is left for future work.

## Input files

!style halign=left
The input files for this case are structured as follows:

- The four cases, i.e., natural oxide, 5 nm, 10 nm, and 15 nm oxide thickness samples, are simulated using the [/val-2k_natural_oxide.i], [/val-2k_5nm_oxide.i], [/val-2k_10nm_oxide.i], and [/val-2k_15nm_oxide.i] inputs, respectively.
- Their shared geometry, history, and material properties are listed in [/parameters_val-2k_common.params], while the case-specific oxide thickness, output file names, and profile-output subfolder paths are defined directly in the wrapper input files.
- The shared models are organized using [/val-2k_base.i], [/val-2k_layer.i], [/val-2k_traps.i], and [/val-2k_surface.i].

The associated tests are defined in [/val-2k/tests].

!alert note title=Not optimized for performance
The input files used in this study are not optimized for performance. The solver and preconditionner type, mesh size, and time stepper could be optimized to reduce computational costs and memory needs.

!bibtex bibliography
