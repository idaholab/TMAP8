# val-2k

# Oxide effects on deuterium release from self-irradiated tungsten

## Case Description

This validation case is based on the natural-oxide and thin-oxide experiments reported in [!cite](Kremer2022oxide). The long-term goal of `val-2k` is to incrementally model deuterium release from self-irradiated tungsten as progressively more oxide-related physics is introduced. The experimental study measured deuterium thermal desorption spectra from tungsten samples with a natural oxide layer and with electrochemically grown oxide layers between 5 nm and 100 nm.

Unlike the existing one-shot validation cases, `val-2k` is intentionally developed in stages so that each additional piece of physics can be compared against experiment before the next one is introduced. The current deuterium-only stage now contains two closely related cases: the original tungsten-only natural-oxide surrogate and a companion case with an explicit 5 nm oxide transport layer.

## Current Scope

The current implementation covers two deuterium-only configurations for the staged `val-2k` workflow. It includes:

- the original one-dimensional tungsten-only surrogate for the natural-oxide reference sample
- a companion one-dimensional model with a front 5 nm oxide layer and a tungsten substrate
- six trap families in the self-irradiated tungsten near-surface region using the [SpeciesTrappingPhysics](physics/SpeciesTrappingPhysics.md) syntax
- deuterium release through phenomenological D$_2$ and D$_2$O surface channels on the free surfaces
- the experimental desorption temperature history digitized from `Experimental_desorption_temperature.csv`

The current implementation does not yet include:

- explicit hydrogen-containing species
- HDO or D$_2$O formation
- oxide reduction during desorption

Those additions are deferred to later iterations so their individual influence on the match with experiment can be assessed cleanly.

## Sample history

The reference sample history is still taken from the natural-oxide experiment in [!cite](Kremer2022oxide). In the experiment, the tungsten specimen is first prepared with a self-damaged near-surface region, then loaded with deuterium so that the retained inventory is concentrated in the first few micrometers of the sample. The tungsten-only input keeps that history but does not add an explicit oxide block, so it remains the original baseline surrogate for the natural-oxide case. The companion 5 nm input keeps the same deuterium preload and tungsten trapping model, but inserts a separate front oxide transport layer so the effect of that additional barrier can be assessed directly against the 5 nm experimental curve.

Both desorption calculations start from the same preloaded tungsten state and follow the digitized temperature history from `Experimental_desorption_temperature.csv`, which heats the sample from about 296 K to about 1001 K over roughly 4.17 h. This stepwise setup isolates the contribution of the explicit oxide layer from the already-established tungsten diffusion, trapping, and surface release model. A phenomenological D$_2$O surface-loss channel is now included in parallel with the existing D$_2$ release channel, but it does not yet consume or evolve an explicit oxygen inventory.

The initial deuterium profile used at the start of desorption is shown in [val-2k_natural_oxide_iteration_1_profile]. This figure is reported for the tungsten-only baseline because that preload is the common starting point used before the explicit 5 nm oxide layer is added. In the current six-trap baseline, most of the retained inventory is placed in the irradiation-induced traps inside the damaged zone, while the mobile deuterium concentration is comparatively small. The sharp drop beyond the first few micrometers reflects the prescribed trap-density distribution used to localize the self-damage near the exposed surface; this figure reports the model initial condition for the desorption calculation rather than a direct fit of the measured depth profile.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_profile.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_profile
    caption=Initial deuterium concentration profile used to start the `val-2k` desorption calculation. The profile shows the mobile deuterium concentration, the six trapped populations, and their total.

## Model Description

The current reference iteration consists of two related one-dimensional slabs. The original baseline models a 0.8 mm tungsten slab with no explicit oxide block. The companion oxide case adds a 5 nm front oxide layer ahead of the same tungsten substrate.
The mesh is refined across the first 8 $\mu$m from the exposed surface so that the near-surface trapped inventory remains well resolved in both cases, and so the oxide/tungsten interface is also resolved in the 5 nm companion case.
The irradiated defect-rich near-surface region is described using the intrinsic plus five damage-induced trap families adopted from [val-2f](val-2f.md). In the tungsten-only baseline the traps occupy the full single material block, while in the 5 nm companion case the same traps are restricted to the tungsten block only.
The density of the intrinsic trap, since it is independent of irradiation, is homogeneous in the sample.
The densities of irradiation-induced traps, however, are homogeneous in the 2.5 $\mu$m-thick self-damaged region, and then quickly decrease to 0 in the bulk of the sample, with a transition length of 0.05 $\mu$m.
The full set of trap site densities is scaled uniformly from [val-2f](val-2f.md) values so the initial areal inventory matches the earlier `val-2k` natural-oxide preload.

As in the current `val-2f` implementation, `val-2k` is solved in dimensionless form using:

\begin{equation}
\hat{x} = \frac{x}{L_{\text{ref}}}, \qquad \hat{t} = \frac{t}{t_{\text{ref}}}, \qquad
\hat{C}_M = \frac{C_M}{C_{M,\text{ref}}}, \qquad
\hat{C}_{T_i} = \frac{C_{T_i}}{C_{T_i,\text{ref}}},
\end{equation}

with $L_{\text{ref}} = 1$ $\mu$m and $t_{\text{ref}} = 1$ s.

The mobile deuterium balance solved in the input file is:

\begin{equation}
\frac{\partial \hat{C}_M}{\partial \hat{t}} =
\hat{\nabla} \cdot \hat{D} \hat{\nabla} \hat{C}_M +
\sum_{i \in \{intr,1,\dots,5\}}
\frac{C_{T_i,\text{ref}}}{C_{M,\text{ref}}}
\frac{\partial \hat{C}_{T_i}}{\partial \hat{t}}
\end{equation}

The trapped species are introduced using six [SpeciesTrappingPhysics](physics/SpeciesTrappingPhysics.md) blocks, one for each trap family. Each block creates the time derivative, trapping, releasing, and mobile-species coupling terms automatically. The dimensionless trapping and release groups are:

\begin{equation}
\hat{k}_{t,i} = t_{\text{ref}} \alpha_{t,i} \frac{C_{M,\text{ref}}}{N}
\qquad \text{and} \qquad
\hat{k}_{r,i} = t_{\text{ref}} \alpha_{r,i}
\end{equation}

while the same Arrhenius diffusivity and detrapping energetics as [val-2f](val-2f.md) are retained:

\begin{equation}
\hat{D} = \hat{D}_0 \exp \left(- \frac{E_D}{k_B T} \right)
\end{equation}

The surface release is modeled as finite fluxes on both free surfaces. The baseline D$_2$ channel uses the same dimensionless recombination form as [val-2f](val-2f.md):

\begin{equation}
\hat{J} = 2 \hat{K}_r \hat{C}_M^2
\end{equation}

The same phenomenological form is also used for a D$_2$O surface-loss channel with its own Arrhenius parameters. In the current stage those D$_2$O parameters are set equal to the D$_2$ values, which means the water-release mechanism is present structurally but still assumes an effectively constant oxygen supply at the surface. The companion 5 nm oxide layer is modeled here as a constant barrier with effective thickness and Arrhenius diffusivity parameters. No oxide-specific traps, no partition coefficient, and no oxide reduction are included yet. Both input files write physical-unit auxiliary variables and postprocessors for the mobile and trapped deuterium populations, and the comparison script reads those physical outputs directly when generating the TDS, inventory, and initial-profile figures. This remains a deliberate simplification for the current stage: the tungsten-only surrogate is preserved as the original baseline, the explicit 5 nm oxide geometry is added only as a controlled next comparison, and the new D$_2$O channel is a phenomenological release mechanism rather than a mechanistic oxide-reduction model.

## Case and Model Parameters

The current baseline parameters are listed in [val-2k_parameters].

!table id=val-2k_parameters caption=Parameters used in the current deuterium-only implementation stage of `val-2k`.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $l_W$ | Tungsten thickness | 0.8 | mm | [!cite](Kremer2022oxide) |
| $l_{ox}$ | Oxide thickness in the companion oxide case | 5 | nm | 5 nm experimental comparison case from [!cite](Kremer2022oxide) |
| $l_d$ | Self-damaged depth | 2.3 | $\mu$m | [!cite](Kremer2022oxide) |
| $T_0$ | Initial desorption temperature | 295.775 | K | Digitized from `Experimental_desorption_temperature.csv` |
| $T_f$ | Final desorption temperature | 1001.408 | K | Digitized from `Experimental_desorption_temperature.csv` |
| $t_f$ | Final desorption time | 4.166 | h | Digitized from `Experimental_desorption_temperature.csv` |
| $D_0$ | Diffusivity prefactor | 1.6 $\times 10^{-7}$ | m$^2$/s | Adopted from [val-2f](val-2f.md) for the initial baseline |
| $E_D$ | Diffusion activation energy | 0.28 | eV | Adopted from [val-2f](val-2f.md) for the initial baseline |
| $D_{0,ox}$ | Oxide diffusivity prefactor in the companion oxide case | 1 $\times 10^{-10}$ | m$^2$/s | Initial effective oxide-layer assumption |
| $E_{D,ox}$ | Oxide diffusion activation energy in the companion oxide case | 0.28 | eV | Initial effective oxide-layer assumption |
| $x_c$ | Trap-distribution center | 2.5 | $\mu$m | Adopted from [val-2f](val-2f.md) |
| $w_d$ | Trap-distribution width | 0.05 | $\mu$m | Sharpened by one order of magnitude from the earlier `val-2k` baseline |
| $L_{\text{ref}}$ | Reference length for the dimensionless solve | 1 | $\mu$m | Chosen to match the val-2f adimensionalization |
| $t_{\text{ref}}$ | Reference time for the dimensionless solve | 1 | s | Chosen to match the val-2f adimensionalization |
| $C_{M,\text{ref}}$ | Mobile reference concentration | 6.3222 $\times 10^{16}$ | at/m$^3$ | Adopted from [val-2f](val-2f.md) |
| $C_{T,\text{ref}}^{intr}$ | Intrinsic-trap reference concentration | 6.3222 $\times 10^{17}$ | at/m$^3$ | Adopted from [val-2f](val-2f.md) |
| $C_{T,\text{ref}}^{1-5}$ | Non-intrinsic trap reference concentration | 6.3222 $\times 10^{20}$ | at/m$^3$ | Adopted from [val-2f](val-2f.md) |
| $s_T$ | Uniform trap-density scale factor | 6.644848 | - | Chosen so the six-trap model matches the prior `val-2k` initial areal inventory |
| $E_{T,intr}$ | Intrinsic detrapping energy | 1.04 | eV | Adopted from [val-2f](val-2f.md) |
| $E_{T,1}$ | Trap 1 detrapping energy | 1.15 | eV | Adopted from [val-2f](val-2f.md) |
| $E_{T,2}$ | Trap 2 detrapping energy | 1.35 | eV | Adopted from [val-2f](val-2f.md) |
| $E_{T,3}$ | Trap 3 detrapping energy | 1.65 | eV | Adopted from [val-2f](val-2f.md) |
| $E_{T,4}$ | Trap 4 detrapping energy | 1.85 | eV | Adopted from [val-2f](val-2f.md) |
| $E_{T,5}$ | Trap 5 detrapping energy | 2.05 | eV | Adopted from [val-2f](val-2f.md) |
| $C_{T,intr,0}$ | Intrinsic trap site density | 1.595 $\times 10^{23}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_1,0}$ | Trap 1 site density | 3.076 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_2,0}$ | Trap 2 site density | 1.910 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_3,0}$ | Trap 3 site density | 1.304 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_4,0}$ | Trap 4 site density | 1.972 $\times 10^{26}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $C_{T_5,0}$ | Trap 5 site density | 5.228 $\times 10^{25}$ | at/m$^3$ | Scaled from [val-2f](val-2f.md) |
| $K_r$ | Recombination prefactor | 3.8 $\times 10^{-16}$ | m$^4$/at/s | Adopted from [val-2f](val-2f.md) for the initial baseline |
| $E_r$ | Recombination activation energy | 0.34 | eV | Adopted from [val-2f](val-2f.md) for the initial baseline |
| $K_r^{D_2O}$ | D$_2$O surface-release prefactor | 3.8 $\times 10^{-16}$ | m$^4$/at/s | Provisional assumption, set equal to $K_r$ in the current stage |
| $E_r^{D_2O}$ | D$_2$O surface-release activation energy | 0.34 | eV | Provisional assumption, set equal to $E_r$ in the current stage |

## Results

The current branch state keeps the scaled six-trap `val-2f` tungsten-only model as the original baseline and adds a second input with a constant front 5 nm oxide transport layer. Both solves use the same `val-2f`-style adimensional mobile transport and `SpeciesTrappingPhysics` syntax in tungsten, while the comparison script converts the results back to physical units. The script now overlays the natural-oxide and 5 nm experimental `HD + D_2` curves together with the experimental `HDO + D_2O` curves against their corresponding model predictions, while the profile and inventory figures continue to document the shared tungsten preload baseline.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_comparison
    caption=Current `val-2k` deuterium-only comparison state, showing the tungsten-only natural-oxide surrogate and the companion explicit 5 nm oxide-layer case against the corresponding Fig. 6 experimental curves.

[val-2k_natural_oxide_iteration_1_comparison] compares the tungsten-only baseline against the digitized natural-oxide `HD + D_2` and `HDO + D_2O` desorption data from Fig. 6 of [!cite](Kremer2022oxide), and also compares the explicit 5 nm oxide input against the corresponding 5 nm experimental curves from the same figure. The added temperature trace on the right axis shows exactly when both models begin to release deuterium relative to the experimental heating history. At this stage, the figure should be interpreted as a controlled side-by-side reference point: the no-oxide case preserves the earlier surrogate baseline, the explicit 5 nm case isolates the effect of adding a simple transport barrier, and the new D$_2$O curves should be interpreted as a phenomenological surface-release partition rather than a mechanistic water-formation model.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_inventory.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_inventory
    caption=Evolution of the mobile and trapped deuterium inventories during desorption for the current `val-2k` natural-oxide baseline, with the imposed temperature history shown on the right axis.

[val-2k_natural_oxide_iteration_1_inventory] shows that the shared tungsten preload is dominated by the trapping populations, while the mobile deuterium inventory remains much smaller throughout the desorption ramp. The lower-energy traps begin to empty first as the temperature rises, followed by the deeper trap populations later in the ramp. The imposed experimental temperature history is shown on the right axis so the changes in each trap inventory can be related directly to the heating schedule used in the TDS experiment.

## Planned Extensions

The intended order of future extensions is:

1. retune and assess the tungsten-only and 5 nm explicit-oxide deuterium-only cases side by side
2. add hydrogen-containing release pathways without changing the preserved tungsten-only baseline
3. extend the constant-layer model from 5 nm to the 10 nm and 15 nm oxide cases from Fig. 6
4. add oxide reduction only after the constant-layer trends are understood

## Input files

!style halign=left
The tungsten-only baseline input file for this staged validation case is [/val-2k.i]. The companion explicit-oxide input is [/val-2k_5nm_oxide.i]. The shared tungsten-only parameters live in [/parameters_val-2k.params], while the oxide companion extends them in [/parameters_val-2k_5nm_oxide.params]. The oxide-specific additions are organized using [/val-2k_5nm_oxide_layer.i], [/val-2k_traps_5nm_oxide.i], and [/val-2k_surface_5nm_oxide.i]. The associated tests are defined in [/val-2k/tests].

!alert note title=Current test strategy
The first robust automated test for `val-2k` uses the same fine-mesh baseline input as the validation run and is therefore marked as a heavy test. A lighter surrogate test may be added later, but only after it is shown to converge without changing the modeled behavior.

!bibtex bibliography
