# val-2i

# Deuterium Retention in Neutron-irradiated Single-crystal Tungsten

## Case Description

!style halign=left
This case reproduces, in updated form, the analysis published in [!cite](Shimada2018), where a modified form of the TMAP4 code (updated to include multiple trapping sites, though only one is used in this study) was utilized to explore deuterium retention and trapping within single-crystal tungsten samples irradiated in the [High Flux Isotope Reactor (HFIR)](https://neutrons.ornl.gov/hfir) facility at Oak Ridge National Laboratory and then exposed to a deuterium plasma within the [Tritium Plasma Experiment (TPE)](https://inl.gov/fusion-safety/star/) at Idaho National Laboratory. This was undertaken as part of the US-Japan Technological Assessment of Plasma Facing Components for DEMO Reactors (PHENIX) project [!citep](Katoh2017phenix, Shimada2017phenix).

In the experimental phase, six single-crystal tungsten disks were prepared from micro-tensile specimens using electrical discharge machining; the dimensions of the samples after machining were $4.0 \times 4.0 \times 0.5 \text{mm}^3$. After mechanical polishing, heat treatment was not performed to remove any remaining surface damage due to the production process (e.g., shallow cracks from machining and parallel striations from polishing) prior to neutron irradiation. As opposed to mirror-like laboratory conditions, these were judged to represent more realistic surfaces that might be experienced in plasma facing components in fusion devices. Experimental conditions for both the HFIR and TPE phases of the experiment are shown in [val-2i-experimental-conditions].

!table id=val-2i-experimental-conditions caption=The experimental (HFIR irradiation and TPE plasma) conditions for val-2i, from [!cite](Shimada2018).
| Specimen ID | HFIR irradiation temp. ($K$) | TPE exposure temp. ($K$) | TPE exposure flux ($\text{m}^{-2} \text{s}^{-1}$) | TPE exposure fluence ($\text{m}^{-2}$)
| - | - | - | - | - |
| W53A | 633  | 673 | $7.1 \times 10^{21}$ | $5.1 \times 10^{25}$ |
| W53B | 633  | 673 | $4.7 \times 10^{21}$ | $5.0 \times 10^{25}$ |
| W55A | 963  | 873 | $8.2 \times 10^{21}$ | $5.2 \times 10^{25}$ |
| W55B | 963  | 873 | $5.9 \times 10^{21}$ | $5.0 \times 10^{25}$ |
| W26A | 1073 | 973 | $8.4 \times 10^{21}$ | $5.0 \times 10^{25}$ |
| W26B | 1073 | 973 | $7.5 \times 10^{21}$ | $5.0 \times 10^{25}$ |

Note that the HFIR irradiation dose was calculated to approximately 0.1 dpa, and the incident ion energy in TPE was approximately 100eV (more info available in [!cite](Shimada2018)). In this model, the W53A, W55A, and W26A samples were used as the targets for comparison with the model for the thermal desorption spectroscopy (TDS) measurements.

2-4 hours after deuterium plasma exposure (long enough for the specimen to cool from the TPE exposure temperature to approximately 300 K), the specimens were transferred to the TDS vacuum chamber. The TDS measurement process consisted of three phases:

1. +Pumpdown phase:+ After placing a specimen in the chamber, the system was pumped down until a vacuum pressure of $1.0 \times 10^{-5}$ Pa was reached.
2. +Thermal desorption phase:+ The sample temperature was increased using a furnace at a linear ramp rate of 10 K/min to 1173 K, causing trapped deuterium to be released.
3. +Hold phase (0.5 hour):+ The sample temperature was held at 1173 K until the end of the experiment.

To replicate the TPE exposure, cooldown period, and TDS conditions, the temperature history shown in [val-2i_temperature_history] was used in the TMAP8 model.

!media val-2i_temperature_history.py
    image_name=val-2i_temperature_history.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2i_temperature_history
    caption=Temperature history used in the TMAP8 simulation for the 673 K exposure (specimen W53A), 873 K exposure (specimen W55A), and 973 K exposure (specimen W26A). This reproduces Figure 3 from [!cite](Shimada2018).

## Model Description

### Diffusion of Mobile Species

!style halign=left
In this model, one mobile species is considered: deuterium. The hydrogen isotope transport model considers diffusion, a single trapping site, and an idealized treatment of the reactions at the exposed surface. The governing equation for deuterium in this scenario is described as

\begin{equation}
\frac{\partial C_M}{\partial t} = \nabla \cdot D \nabla C_M - \frac{\partial C_T}{\partial t} + S,
\end{equation}

where $C_M$ is the concentration of mobile deuterium, $D$ is the diffusivity, $C_T$ is the concentration of trapped deuterium in the material, and $S$ is the deuterium implantation source term from the TPE exposure. The diffusivity follows an Arrhenius relationship:

\begin{equation}
D = D_{0} \exp\left(-\frac{E_{a}}{k_B T}\right)
\end{equation}

where $D_{0}$ is the pre-exponential factor, $E_{a}$ is the activation energy, $k_B$ is the Boltzmann constant, and $T$ is temperature. The implantation profile is in the form of a normal distribution, whose one-dimensional form is given by

\begin{equation}
S(x, t) = S_s(t) \frac{(1-R_{\text{ref}})}{w_s \sqrt{2 \pi}} \exp \left[-\frac{1}{2} \left(\frac{x - d_s}{w_s}\right)^2 \right],
\end{equation}

where $S_s$ is the surface flux as a function of time, $R_{\text{ref}}$ is a reflection coefficient (chosen to account for complex plasma-surface interactions described shortly), $w_s$ is the implantation source width, and $d_s$ is the implantation source depth. As mentioned in [!cite](Shimada2018), these parameters were obtained for 100 eV deuterium in tungsten by fitting output from the SRIM code. All parameters presented in this section are shown in [val-2i_diffusion_parameters].

### Trapping and Detrapping

!style halign=left
The model includes a single trapping site to capture deuterium retention effects observed in the TDS spectra. The trapped concentration $C_T$ evolves according to:

\begin{equation}
\frac{\partial C_T}{\partial t} = \alpha_t \frac{C_T^{\text{empty}} C_M}{N} - \alpha_r C_T
\end{equation}

where $N$ is the lattice site density, and $C_T^{\text{empty}} = \chi N - C_T$ is the empty trap concentration with $\chi$ being the trap site fraction. $N$ is assumed to be the atomic density of tungsten.

The trapping and release rate coefficients follow Arrhenius relationships:

\begin{equation}
\alpha_t = \alpha_{t0} \exp\left(-\frac{\epsilon_t}{k_B T}\right)
\end{equation}

\begin{equation}
\alpha_r = \alpha_{r0} \exp\left(-\frac{\epsilon_r}{k_B T}\right)
\end{equation}

where $\alpha_{t0}$ and $\alpha_{r0}$ are pre-factors of trapping and release rate coefficients and $\epsilon_t$ and $\epsilon_r$ are trapping and release energies. In this model, $\alpha_{t0}$ is defined as

\begin{equation}
\alpha_{t0} = \frac{D_0}{\lambda_W^2}
\end{equation}

where $\lambda_W$ is the lattice constant for tungsten.

!alert note title=Typo in [!cite](Shimada2018), Section 3
There appears to be a typo for the definition of $\alpha_{t0}$ in [!cite](Shimada2018), where $\lambda_W$ is in the denominator instead of $\lambda_W^2$. This is inconsistent with the TMAP4 input file used in the original work, so we have corrected it in the documentation here and used the correct form for trapping coefficient in the TMAP8 input file.

The release energy is defined as

\begin{equation}
\epsilon_r = E_b + \epsilon_t
\end{equation}

where $E_b$ is the binding energy of deuterium atoms in the trapping site. An initial uniform distribution of empty traps was assumed at the beginning of the simulation. All trapping parameters presented in this section are shown in [val-2i_trapping_parameters].

### Surface Reactions

!style halign=left
In addition to diffusion and trapping within the bulk material, hydrogen isotope transport also involves chemical reactions and physical interactions at the surface. It is assumed that the deuterium release from the tungsten surface is idealized and not rate limited by recombination, as suggested by [!cite](Causey2002), leading to a surface mobile deuterium concentration of zero. That is, for a one dimensionsal model, we apply

\begin{equation}
C_M(x = 0, t) = 0.
\end{equation}

As mentioned previously, the reflection coefficient $R_{ref}$ was adjusted as a fitting parameter to the model to account for plasma-surface interactions. To elaborate, at high deuterium flux with low diffusivity the location concentration of deuterium within the implantation depth is high. Coupled with the very high equilibrium gas pressure, near-surface precipitation follows, as described by [!cite](Kolasinski2013). Interconnected gas bubbles within the tungsten gives pathways for these precipitated $D_2$ molecules to escape, leading to a smaller diffusion length for the release of deuterium from solution. Subsequently, the amount of deuterium available to diffuse further past the implantation region is reduced. Thus, a portion of the implanted deuterium is "reflected" and unavailable as a source to the diffusion model.

## Case and Model Parameters

!style halign=left
[val-2i_diffusion_parameters] summarizes the detail of sample and experimental conditions from Shimada et al. [!citep](Shimada2018), as well as the model parameters from TODO, TODO, and estimated from validation cases in TMAP8. Where there are different parameters for each case, these are listed in order by specimen: W53A, W55A, and W26A. [val-2i_trapping_parameters] includes the trapping parameters from Karmonik et al. [!citep](karmonik1995proton) and estimated based on existing validation cases in TMAP8.

!table id=val-2i_diffusion_parameters caption=Experimental set up and diffusion parameters from Shimada et al. [!citep](Shimada2018) for deuterium transport in neutron-irradiated single-crystal tungsten.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $T_{\text{initial}}$ | Initial / plasma exposure temperature | \[673, 873, 973\] | K | [!cite](Shimada2018) |
| $T_{\text{low}}$ | Cooldown final temperature | 300 | K | Estimated from [!cite](Shimada2018) |
| $T_{\text{high}}$ | Desorption final temperature | 1173 | K | [!cite](Shimada2018) |
| $\beta$ | Heating rate | 10 | K/min | [!cite](Shimada2018) |
| $l$ | Sample thickness | 0.5 | mm | [!cite](Shimada2018) |
| $D_0$ | Diffusivity pre-exponential factor | $4.1 \times 10^{-7} / \sqrt{2}$ | m$^2$/s | [!cite](frauenfelder1969solution) and corrected for deuterium by [!cite](Causey2002) |
| $E_a$ | Activation energy of deuterium | 0.39 | eV | [!cite](frauenfelder1969solution) |
| $C_{M,0}$ | Initial concentration of mobile species | 0 | at. / m$^{3}$ | [!cite](Shimada2018) |

!table id=val-2i_trapping_parameters caption=Trapping parameters for deuterium transport in single-crystal tungsten used in this case.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $N$ | Lattice site density | $6.323 \times 10^{28}$ | at. / m$^{-3}$ | [!cite](Shimada2018) |
| $\lambda_W$ | Lattice constant for tungsten | $3.6 \times 10^{-10}$ | m | [!cite](Shimada2018) |
| $\epsilon_{t}$ | Trapping energy | 0.39 | eV | [!cite](frauenfelder1969solution) |
| $\alpha_{r0}$ | Release rate coefficient | $1 \times 10^{13}$ | 1/s | [!cite](Shimada2018) |
| $E_b$ | Binding energy of deuterium in trapping site | \[1.41, 1.91, 2.21\] | eV | [!cite](Shimada2018) |
| $\chi$ | Trapping site atom fraction | \[0.002, 0.0002, 0.0002\] | - | [!cite](Shimada2018) |

!alert note title=Typo in [!cite](Shimada2018), Section 3
There appears to be a typo for the definition of $\alpha_{r0}$ in [!cite](Shimada2018), where it is stated to be $10^{-13} \text{s}^{-1}$. This is inconsistent with the TMAP4 input file used in the original work, so we have corrected it in the documentation here and used the correct form for release rate coefficient in the TMAP8 input file.

!table id=val-2i_implantation_parameters caption=Implantation parameters for deuterium transport in single-crystal tungsten used in this case.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $S_s(t=0)$ | Initial plasma exposure flux | 0 | at. / m$^{2}$ / s | [!cite](Shimada2018) |
| $S_s(t)$ | Plasma exposure flux | $7.1 \times 10^{21}$ | at. / m$^{2}$ / s | [!cite](Shimada2018) |
| $R_{\text{ref}}$ | Reflection coefficient | \[0.90, 0.99, 0.99\] | - | [!cite](Shimada2018) |
| $w_s$ | Implantation source width | $3.58 \times 10^{-9}$ | m | [!cite](Shimada2018) |
| $d_s$ | Implantation source depth | $2.64 \times 10^{-9}$ | m | [!cite](Shimada2018) |

## Results

!style halign=left
Using the model described here and in [!cite](Shimada2018), the output from TMAP8 is compared to that of TMAP4 as well as the experimental data, shown in [val-2i_comparison]. The model captures the delayed release of deuterium during the TDS heating process and produces peak shapes that are consistent with both the TMAP4 model results and the experimental data.

!media comparison_val-2i.py
    image_name=val-2i_comparison.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2i_comparison
    caption=Comparison of TMAP8 calculations (with trapping) with TMAP4 results and experimental data during TDS process. RMSPE values are shown on the plot.

## Input files

!style halign=left
The input file for this validation case is:

- [/val-2i.i]: Simulates deuterium transport in neutron-irradiated single-crystal tungsten with
  trapping effects using the parameters and model configuration described in this text.

!alert note
The base input file shows the parameters specific to the 673 K (W53A) case. The other cases are run in testing using command line arguments to adjust the trapping site fraction, the plasma exposure temperature, the binding energy, and the reflection coefficient on-the-fly.

More information about these tests can be found in the test specification file for this case, namely [/val-2i/tests].

!bibtex bibliography
