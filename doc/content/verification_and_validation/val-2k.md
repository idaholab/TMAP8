# val-2k

# Oxide effects on deuterium release from self-irradiated tungsten

## Case Description

This validation case is based on the natural-oxide and thin-oxide experiments reported in [!cite](Kremer2022oxide). The model considered here contains four oxygen-field configurations that use the same tungsten diffusion, trapping, and surface-release formulation with front-surface oxygen inventories corresponding to a 0.5 nm natural-oxide proxy and to 5 nm, 10 nm, and 15 nm explicit oxide layers. The experimental study measured deuterium thermal desorption spectra from tungsten samples with a natural oxide layer and with electrochemically grown oxide layers between 5 nm and 100 nm.

## Scope

The model includes:

- a one-dimensional natural-oxide model where the front oxide is represented by a 0.5 nm explicit oxygen field
- companion one-dimensional models where the front 5 nm, 10 nm, and 15 nm oxide layers are represented by explicit oxygen fields while the deuterium transport properties remain those of tungsten
- six trap families in the self-irradiated tungsten near-surface region using the [SpeciesTrappingPhysics](physics/SpeciesTrappingPhysics.md) syntax
- deuterium release through phenomenological D$_2$ and oxygen-gated D$_2$O surface channels on the free surfaces
- the experimental desorption temperature history digitized from `Experimental_desorption_temperature.csv`

The model uses a phenomenological D$_2$O release channel and does not include explicit hydrogen-containing species or oxide reduction during desorption.

## Sample history

The reference sample history is taken from the natural-oxide experiment in [!cite](Kremer2022oxide). In the experiment, the tungsten specimen is first prepared with a self-damaged near-surface region, then loaded with deuterium so that the retained inventory is concentrated in the first few micrometers of the sample. The natural-oxide input represents the front surface through a thin 0.5 nm oxygen concentration field, while the 5 nm, 10 nm, and 15 nm companion inputs use the same deuterium preload and tungsten trapping model but initialize that oxygen field across the corresponding front-oxide thickness instead.

All four desorption calculations start from the same preloaded tungsten state and follow the digitized temperature history from `Experimental_desorption_temperature.csv`, which heats the sample from about 296 K to about 1001 K over roughly 4.17 h. In each configuration, the D$_2$O surface-loss channel is multiplied by the evolving oxygen concentration at the front surface, and the oxygen inventory is depleted stoichiometrically as heavy water is released.

The initial deuterium profile used at the start of desorption is shown in [val-2k_natural_oxide_iteration_1_profile] for the 15 nm configuration. The shaded regions identify the oxide, damaged tungsten, and bulk tungsten sections in the plotted depth range. In this configuration, most of the retained inventory is placed in the irradiation-induced traps inside the damaged region, while the mobile deuterium concentration remains comparatively small.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_profile.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_profile
    caption=Initial deuterium concentration profile used to start the 15 nm `val-2k` desorption calculation. The profile shows the mobile deuterium concentration, the six trapped populations, their total, and the oxide, damaged tungsten, and bulk tungsten sections.

## Model Description

The model consists of four related one-dimensional slabs. The natural-oxide baseline and the 5 nm, 10 nm, and 15 nm companion cases all keep the same 0.8 mm tungsten slab and represent the front oxide through an initial oxygen concentration field together with a sharp tanh suppression of the trap site densities near the exposed surface.
The mesh is refined across the first 8 $\mu$m from the exposed surface so that the near-surface trapped inventory remains well resolved in all cases, and so the oxide-to-tungsten transition is also resolved in the thickest 15 nm companion case. In the current input structure, target element sizes are defined first from the natural-oxide reference spacing and the number of elements in each mesh section is then computed from the active section lengths, with a 1 nm minimum remainder section to avoid negative or vanishing front-end segments as the oxide thickness changes.
The irradiated defect-rich near-surface region is described using the intrinsic plus five damage-induced trap families adopted from [val-2f](val-2f.md). In all oxygen-field cases the same traps are multiplied by a sharp tanh profile so they decay smoothly to zero inside the oxide region, with the natural-oxide case applying that transition over 0.5 nm and the companion cases over 5 nm, 10 nm, and 15 nm.
The density of the intrinsic trap, since it is independent of irradiation, is homogeneous in the sample.
The densities of irradiation-induced traps, however, are homogeneous in the 2.3 $\mu$m-thick self-damaged region, and then quickly decrease to 0 in the bulk of the sample, with a transition length of 0.05 $\mu$m.
The full set of trap site densities is scaled uniformly from [val-2f](val-2f.md) values so the initial areal inventory matches the prescribed `val-2k` preload.

As in `val-2f`, `val-2k` is solved in dimensionless form using:

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

\begin{equation}
\hat{J}_{D_2} = -2 \hat{K}_{r,D_2} \hat{C}_M^2,
\qquad
\hat{J}_{D_2O} = -2 \hat{K}_{r,D_2O} \hat{C}_O \hat{C}_M^2,
\qquad
\hat{J}_O = \hat{s}_O \hat{J}_{D_2O},
\end{equation}

where $\hat{s}_O$ is the stoichiometric factor that converts the D$_2$O surface loss into oxygen loss. The initial oxygen concentration is derived from the paper-reported removal of $100 \times 10^{19}$ O/m$^2$ from the first 13.5 nm of oxide and is reduced by an additional factor of 1.5 in the current hand-calibrated branch state, which yields about $4.94 \times 10^{28}$ O/m$^3$. Oxygen transport is also restricted to the oxide region through the same smooth oxide mask used to initialize the front-surface oxygen field. The current oxygen diffusivity and D$_2$O release parameters are therefore best interpreted as calibrated effective kinetics for matching the observed TDS trends rather than as a direct literature transcription. All input files write physical-unit auxiliary variables and postprocessors for the mobile and trapped deuterium populations, and the comparison script reads those physical outputs directly when generating the TDS, inventory, and initial-profile figures.

## Case and Model Parameters

The current baseline parameters are listed in [val-2k_parameters].

!table id=val-2k_parameters caption=Parameters used in the current deuterium-only implementation stage of `val-2k`.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $l_W$ | Tungsten thickness | 0.8 | mm | [!cite](Kremer2022oxide) |
| $l_{ox}$ | Oxide thickness in the oxide comparison cases | 0.5, 5, 10, 15 | nm | Natural-oxide proxy plus explicit thin-oxide comparison cases from [!cite](Kremer2022oxide) |
| $w_{ox}$ | Tanh transition width used for oxide-to-W blending | 0.25 | nm | Numerical resolution choice for the oxygen-field representation |
| $l_d$ | Self-damaged depth | 2.3 | $\mu$m | [!cite](Kremer2022oxide) |
| $T_0$ | Initial desorption temperature | 295.775 | K | Digitized from `Experimental_desorption_temperature.csv` |
| $T_f$ | Final desorption temperature | 1001.408 | K | Digitized from `Experimental_desorption_temperature.csv` |
| $t_f$ | Final desorption time | 4.166 | h | Digitized from `Experimental_desorption_temperature.csv` |
| $D_0$ | Diffusivity prefactor | 1.6 $\times 10^{-7}$ | m$^2$/s | Adopted from [val-2f](val-2f.md) for the initial baseline |
| $E_D$ | Diffusion activation energy | 0.28 | eV | Adopted from [val-2f](val-2f.md) for the initial baseline |
| $D_{0,O}$ | Oxygen diffusivity prefactor used in the oxide comparison cases | 2.0 $\times 10^{-17}$ | m$^2$/s | Current hand calibration for the oxide-field model |
| $E_{D,O}$ | Oxygen diffusion activation energy used in the oxide comparison cases | 0.45 | eV | Current hand calibration for the oxide-field model |
| $C_{O,0}$ | Initial oxygen concentration in the 0.5 nm, 5 nm, 10 nm, and 15 nm oxide regions | 4.94 $\times 10^{28}$ | at/m$^3$ | Hand-calibrated from the oxygen areal density reported in [!cite](Kremer2021oxideBarrier) |
| $x_c$ | Trap-distribution center | 2.3 | $\mu$m | Adopted from [!cite](Kremer2022oxide) for the current damaged-region depth |
| $w_d$ | Trap-distribution width | 0.05 | $\mu$m | Sharpened by one order of magnitude from the earlier `val-2k` baseline |
| $L_{\text{ref}}$ | Reference length for the dimensionless solve | 1 | $\mu$m | Chosen to match the val-2f adimensionalization |
| $t_{\text{ref}}$ | Reference time for the dimensionless solve | 1 | s | Chosen to match the val-2f adimensionalization |
| $C_{M,\text{ref}}$ | Mobile reference concentration | 6.3222 $\times 10^{16}$ | at/m$^3$ | Adopted from [val-2f](val-2f.md) |
| $C_{T,\text{ref}}^{intr}$ | Intrinsic-trap reference concentration | 6.3222 $\times 10^{17}$ | at/m$^3$ | Adopted from [val-2f](val-2f.md) |
| $C_{T,\text{ref}}^{1-5}$ | Non-intrinsic trap reference concentration | 6.3222 $\times 10^{20}$ | at/m$^3$ | Adopted from [val-2f](val-2f.md) |
| $s_T$ | Uniform trap-density scale factor | 6.644848 | - | Chosen so the six-trap model matches the prior `val-2k` initial areal inventory |
| $E_{T,intr}$ | Intrinsic detrapping energy | 1.08 | eV | Current hand calibration from the val-2f starting point |
| $E_{T,1}$ | Trap 1 detrapping energy | 1.20 | eV | Current hand calibration from the val-2f starting point |
| $E_{T,2}$ | Trap 2 detrapping energy | 1.38 | eV | Current hand calibration from the val-2f starting point |
| $E_{T,3}$ | Trap 3 detrapping energy | 1.65 | eV | Adopted from [val-2f](val-2f.md) |
| $E_{T,4}$ | Trap 4 detrapping energy | 1.85 | eV | Adopted from [val-2f](val-2f.md) |
| $E_{T,5}$ | Trap 5 detrapping energy | 2.05 | eV | Adopted from [val-2f](val-2f.md) |
| $C_{T,intr,0}$ | Intrinsic trap site density | 1.595 $\times 10^{23}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_1,0}$ | Trap 1 site density | 3.076 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_2,0}$ | Trap 2 site density | 1.910 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_3,0}$ | Trap 3 site density | 1.304 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_4,0}$ | Trap 4 site density | 2.392 $\times 10^{26}$ | at/m$^3$ | Current hand calibration from the val-2f starting point |
| $C_{T_5,0}$ | Trap 5 site density | 7.330 $\times 10^{25}$ | at/m$^3$ | Current hand calibration from the val-2f starting point |
| $K_r$ | Recombination prefactor | 3.8 $\times 10^{-16}$ | m$^4$/at/s | Adopted from [val-2f](val-2f.md) for the initial baseline |
| $E_r$ | Recombination activation energy | 0.34 | eV | Adopted from [val-2f](val-2f.md) for the initial baseline |
| $K_r^{D_2O}$ | D$_2$O surface-release prefactor | 3.8 $\times 10^{1}$ | m$^4$/at/s | Current hand-calibrated phenomenological surface-release parameter |
| $E_r^{D_2O}$ | D$_2$O surface-release activation energy | 2.10 | eV | Current hand-calibrated phenomenological surface-release parameter |

## Results

The four oxygen-field inputs use the same scaled six-trap `val-2f` formulation: a 0.5 nm natural-oxide baseline and companion 5 nm, 10 nm, and 15 nm oxide cases. All solves use the same adimensional mobile transport and `SpeciesTrappingPhysics` syntax in tungsten, while the comparison script converts the results back to physical units. The current branch state also includes a hand-calibrated oxygen-side parameter update intended to better match the overall experimental release trends. The script overlays every simulated case for which output files are available against the matching experimental `HD + D_2` and `HDO + D_2O` curves, while the inventory and profile figures report representative internal-state information from the simulated cases.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_comparison
    caption=Current `val-2k` comparison state, showing the 0.5 nm natural-oxide oxygen-field baseline and the available 5 nm, 10 nm, and 15 nm oxide comparison cases against the corresponding Fig. 6 experimental curves.

[val-2k_natural_oxide_iteration_1_comparison] compares the 0.5 nm natural-oxide oxygen-field baseline against the digitized natural-oxide `HD + D_2` and `HDO + D_2O` desorption data from Fig. 6 of [!cite](Kremer2022oxide), and also compares the 5 nm, 10 nm, and 15 nm oxygen-field companion inputs against the corresponding experimental curves whenever those simulation outputs are available. The added temperature trace on the right axis shows when the models begin to release deuterium relative to the experimental heating history.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_recombination_rates.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_recombination_rates
    caption=Arrhenius-form surface recombination coefficients used for the D$_2$ and D$_2$O release channels in `val-2k`, plotted in log scale versus $1000/T$ with a secondary temperature axis in Kelvin.

[val-2k_natural_oxide_iteration_1_recombination_rates] shows the two phenomenological surface-release coefficients over the experimental desorption temperature window. In the current hand-calibrated parameter set, the D$_2$O channel is strongly suppressed at low temperature by its larger activation energy, then rises more steeply and overtakes the D$_2$ coefficient at about 520 K because of its much larger prefactor.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_inventory.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_inventory
    caption=Evolution of the mobile and trapped deuterium inventories during desorption for the current `val-2k` 0.5 nm natural-oxide oxygen-field baseline, with the imposed temperature history shown on the right axis.

[val-2k_natural_oxide_iteration_1_inventory] shows that the tungsten preload is dominated by the trapping populations, while the mobile deuterium inventory remains much smaller throughout the desorption ramp. The lower-energy traps begin to empty first as the temperature rises, followed by the deeper trap populations later in the ramp. The imposed experimental temperature history is shown on the right axis so the changes in each trap inventory can be related directly to the heating schedule used in the TDS experiment.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_oxygen_inventory.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_oxygen_inventory
    caption=Total oxygen inventory remaining in the sample over time for the available `val-2k` oxygen-field cases, using the same case colors as the TDS comparison figure and the imposed temperature history on the right axis.

[val-2k_natural_oxide_iteration_1_oxygen_inventory] shows that the thicker oxygen-field cases begin with larger oxygen inventories and all four cases lose oxygen monotonically as the D$_2$O release channel consumes the front-surface oxide. Using the same case colors as [val-2k_natural_oxide_iteration_1_comparison] makes it easier to relate the oxygen depletion history of each case to the corresponding TDS response.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_mass_conservation.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_mass_conservation
    caption=Relative deuterium mass-balance residual over time for the available `val-2k` oxygen-field cases.

[val-2k_natural_oxide_iteration_1_mass_conservation] tracks the signed deuterium mass-balance residual normalized by the initial deuterium inventory for every currently available modeled case. The residual is formed from the change in deuterium retained in the sample plus the time-integrated left and right surface release fluxes, so values close to zero indicate that the transient inventory loss is consistent with the integrated surface outflow.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_oxygen_conservation.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_oxygen_conservation
    caption=Relative oxygen conservation residual over time for the available `val-2k` oxygen-field cases.

[val-2k_natural_oxide_iteration_1_oxygen_conservation] tracks the signed oxygen conservation residual normalized by the initial oxygen inventory in each available oxygen-field case. The residual is formed from the change in oxygen retained in the sample plus the time-integrated oxygen loss tied to the D$_2$O release channel, so values close to zero indicate that the transient oxygen loss is consistent with the modeled surface outflow.

## Input files

!style halign=left
The natural-oxide input file for this staged validation case is [/val-2k_natural_oxide.i]. The companion oxide inputs are [/val-2k_5nm_oxide.i], [/val-2k_10nm_oxide.i], and [/val-2k_15nm_oxide.i]. Their shared oxygen-field geometry and transport derivations are collected in [/parameters_val-2k_common.params], while the case-specific oxide thickness, output file names, and profile-output subfolder paths are defined directly in the wrapper input files. The shared model body and includes are organized using [/val-2k_base.i], [/val-2k_layer.i], [/val-2k_traps.i], and [/val-2k_surface.i]. The associated tests are defined in [/val-2k/tests].

!alert note title=Current test strategy
The first robust automated test for `val-2k` uses the same fine-mesh baseline input as the validation run and is therefore marked as a heavy test. A lighter surrogate test may be added later, but only after it is shown to converge without changing the modeled behavior.

!bibtex bibliography
