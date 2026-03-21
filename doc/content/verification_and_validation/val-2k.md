# val-2k

# Oxide effects on deuterium release from self-irradiated tungsten

## Case Description

This validation case is based on the natural-oxide and thin-oxide experiments reported in [!cite](Kremer2022oxide). The long-term goal of `val-2k` is to incrementally model deuterium release from self-irradiated tungsten as progressively more oxide-related physics is introduced. The experimental study measured deuterium thermal desorption spectra from tungsten samples with a natural oxide layer and with electrochemically grown oxide layers between 5 nm and 100 nm.

Unlike the existing one-shot validation cases, `val-2k` is intentionally developed in stages so that each additional piece of physics can be compared against experiment before the next one is introduced. The first implementation stage focuses only on the natural-oxide reference sample and only on deuterium in tungsten.

## Current Scope

The current implementation is the natural-oxide baseline for the staged `val-2k` workflow. It includes:

- one-dimensional deuterium diffusion in tungsten
- two trapped populations in the self-irradiated near-surface region
- deuterium recombination and release as D$_2$ on both free surfaces
- the experimental TDS temperature ramp from 300 K to 1000 K at 3 K/min

The current implementation does not yet include:

- explicit hydrogen-containing species
- HDO or D$_2$O formation
- an explicit oxide transport layer
- oxide reduction during desorption

Those additions are deferred to later iterations so their individual influence on the match with experiment can be assessed cleanly.

## Model Description

The first iteration models only the tungsten response. A 0.8 mm tungsten slab is represented as a one-dimensional domain. The first 2.3 micrometers correspond to the self-irradiated region that initially contains the trapped deuterium inventory. Two trapped populations are used as a simplified baseline representation of the defect-rich layer.

The mobile deuterium concentration $C_M$ is governed by:

\begin{equation}
\frac{\partial C_M}{\partial t} = \nabla \cdot D \nabla C_M + \sum_{i=1}^{2} f_{T/M,i} \frac{\partial C_{T_i}}{\partial t}
\end{equation}

and each trapped population follows:

\begin{equation}
\frac{\partial C_{T_i}}{\partial t} = \alpha_t^i \frac{C_{T_i}^{empty} C_M}{N f_{T/M,i}} - \alpha_r^i C_{T_i}
\end{equation}

with:

\begin{equation}
C_{T_i}^{empty} = C_{{T_i}0} N - f_{T/M,i} C_{T_i}
\end{equation}

The mobile deuterium diffusivity is modeled using:

\begin{equation}
D = D_0 \exp \left(- \frac{E_D}{k_B T} \right)
\end{equation}

The surface release is modeled as a finite recombination flux on both free surfaces:

\begin{equation}
J = 2 K_r C_M^2
\end{equation}

This is a deliberate simplification for the first stage. The natural oxide is not yet represented as an explicit transport layer. Instead, the current model establishes the tungsten diffusion, trapping, and D$_2$ release baseline that later iterations will build on.

## Case and Model Parameters

The current baseline parameters are listed in [val-2k_parameters].

!table id=val-2k_parameters caption=Parameters used in the first implementation stage of `val-2k`.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $l_W$ | Tungsten thickness | 0.8 | mm | [!cite](Kremer2022oxide) |
| $l_d$ | Self-damaged depth | 2.3 | $\mu$m | [!cite](Kremer2022oxide) |
| $T_0$ | Initial temperature | 300 | K | [!cite](Kremer2022oxide) |
| $T_f$ | Final temperature | 1000 | K | [!cite](Kremer2022oxide) |
| $\beta$ | Heating rate | 3 | K/min | [!cite](Kremer2022oxide) |
| $D_0$ | Diffusivity prefactor | 1.6 $\times 10^{-7}$ | m$^2$/s | Adopted from [val-2f](val-2f.md exact=True) for the initial baseline |
| $E_D$ | Diffusion activation energy | 0.28 | eV | Adopted from [val-2f](val-2f.md exact=True) for the initial baseline |
| $E_{T,1}$ | Trap 1 detrapping energy | 1.15 | eV | Stage 1 baseline value |
| $E_{T,2}$ | Trap 2 detrapping energy | 1.65 | eV | Stage 1 baseline value |
| $C_{T_1,0}$ | Trap 1 site density | 1.264 $\times 10^{27}$ | at/m$^3$ | Stage 1 baseline value, equal to 0.020 $N_W$ |
| $C_{T_2,0}$ | Trap 2 site density | 9.483 $\times 10^{26}$ | at/m$^3$ | Stage 1 baseline value, equal to 0.015 $N_W$ |
| $K_r$ | Recombination prefactor | 3.8 $\times 10^{-16}$ | m$^4$/at/s | Adopted from [val-2f](val-2f.md exact=True) for the initial baseline |
| $E_r$ | Recombination activation energy | 0.34 | eV | Adopted from [val-2f](val-2f.md exact=True) for the initial baseline |

## Results

The first result of `val-2k` is the initial natural-oxide baseline simulation. The comparison script is already structured to overlay digitized data from Fig. 6 of [!cite](Kremer2022oxide). At this stage, the experimental CSV is only a placeholder, so the generated figure reports the simulation baseline and marks the pending data digitization step explicitly.

!media comparison_val-2k.py
    image_name=val-2k_natural_oxide_iteration_1_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2k_natural_oxide_iteration_1_comparison
    caption=Stage 1 natural-oxide baseline for `val-2k`. The comparison infrastructure is in place and will be extended as digitized experimental data are added.

## Planned Extensions

The intended order of future extensions is:

1. connect digitized natural-oxide experimental data to the Stage 1 baseline
2. add hydrogen-containing release pathways without an explicit oxide layer
3. add a constant oxide transport layer for the natural-oxide case
4. extend the constant-layer model to the 5 nm, 10 nm, and 15 nm oxide cases from Fig. 6
5. add oxide reduction only after the constant-layer trends are understood

## Input files

!style halign=left
The main input file for this staged validation case is [/val-2k.i]. The shared parameters live in [/parameters_val-2k.params], and the current incremental physics are organized using [/val-2k_traps.i] and [/val-2k_surface_natural_oxide.i]. The associated tests are defined in [/val-2k/tests].

!alert note title=Current test strategy
The first robust automated test for `val-2k` uses the same fine-mesh baseline input as the validation run and is therefore marked as a heavy test. A lighter surrogate test may be added later, but only after it is shown to converge without changing the modeled behavior.

!bibtex bibliography
