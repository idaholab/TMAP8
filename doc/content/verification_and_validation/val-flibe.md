# val-flibe

# Permeation experiment with FLiBe

## Case Description

In this experiment from [!cite](calderoni2008measurement), tritium permeation through molten FLiBe (2LiF–BeF$_2$) is measured using a stainless steel permeation cell composed of two internal volumes separated by a 2 mm thick nickel membrane. The bottom side of the membrane is exposed to a T$_2$/argon gas mixture at controlled partial pressures ranging from 1 to 1250 Pa, while the top side is in contact with molten FLiBe. Temperatures are varied between 500 °C and 700 °C (773–973 K). As tritium permeated through the membrane and dissolved in the FLiBe, it is carried away from the liquid surface by an argon sweep gas containing 5 $\%$ H$_2$.

## Model Description

The diffusion for tritium in the nickel membrane and FLiBe can be expressed by

\begin{equation}
\frac{\partial C_{T_2, \,  \text{Ni}}}{\partial t} = \nabla D_{\text{Ni}} \nabla C_{T_2, \,  \text{Ni}},
\end{equation}
and
\begin{equation}
\frac{\partial C_{T_2, \,  \text{FLiBe}}}{\partial t} = \nabla D_{\text{FLiBe}} \nabla C_{T_2, \,  \text{FLiBe}},
\end{equation}

where $C_{T_2, \,  \text{Ni}}$ and $C_{T_2, \,  \text{FLiBe}}$ represent the concentration fields in the nickel membrane and FLiBe respectively, $t$ is the time, and $D_{\text{Ni}}$ and $D_{\text{FLiBe}}$ denotes the diffusivity coefficients.

The concentration in FLiBe is related to the partial pressure and concentration in the nickel membrane via the interface sorption law:

\begin{equation}
C_{T_2, \,  \text{FLiBe}} = K_{s, \,  \text{Ni}} P_{T_2, \,  \text{Ni}}^n = K_{s, \,  \text{Ni}} \left( C_{T_2, \,  \text{Ni}} RT \right)^n,
\end{equation}

where $R$ is the ideal gas constant in J/mol/K, $T$ is the temperature, $K_{s, \,  \text{Ni}}$ is the solubility for tritium in nickel, and $n$ is the exponent of the sorption law. For Sieverts' law, $n=0.5$.

A Dirichlet boundary condition imposes equilibrium between tritium pressure at the bottom surface of the membrane and the tritium concentration in the membrane on Sieverts' law:

\begin{equation}
C_{T_2, \,  \text{Ni}} = K_{s, \,  \text{Ni}} P_{T_2}^n,
\end{equation}

where $P_{T_2}$ is the input pressure of tritium and $n$ is the exponent of the sorption law. Again for Sieverts' law, $n=0.5$.

## Model Parameters

| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $l_{\mathrm{Ni}}$ | Ni membrane thickness | $2$ | mm | [!cite](calderoni2008measurement) |
| $l_{\mathrm{FLiBe}}$ | FLiBe membrane thickness | $81$ | mm | [!cite](calderoni2008measurement) |
| $P_{T_2}$ | Input pressure | $1210$ | Pa | [!cite](hattab2024openfoam) |
| $P_{T_2, \mathrm{Ni}}$ | Initial pressure in the nickel membrane | $1\times 10^{-10}$ | Pa | - |
| $P_{T_2, \mathrm{FLiBe}}$ | Initial pressure in FLiBe | $1\times 10^{-10}$ | Pa | - |
| $D_{\mathrm{FLiBe}}$ | Diffusivity of tritium in FLiBe | $9.3 \times 10^{-7} \exp(- 42 \times 10^3 / RT)$ | m$^2$/s | [!cite](calderoni2008measurement) |
| $K_{s, \mathrm{FLiBe}}$ | Henry's law solubility for tritium in FLiBe | $7.9 \times 10^{-2} \exp(- 35 \times 10^3 / RT)$ | mol/m$^3$/Pa | [!cite](calderoni2008measurement) |
| $D_{\mathrm{Ni}}$ | Diffusivity of tritium in nickel | $7 \times 10^{-7} \exp(- 39.5 \times 10^3 / RT)$ | m$^2$/s | [!cite](causey2012tritium) |
| $K_{s, \mathrm{Ni}}$ | Sieverts' law solubility for tritium in nickel | $564 \times 10^{-3} \exp(- 15.8 \times 10^3 / RT)$ | mol/m$^3$/Pa$^{0.5}$ | [!cite](calderoni2008measurement) |
| $K_{d, \mathrm{Ni}}$ | Surface rate of tritium in nickel | $1.44 \times 10^{-6} \exp(- 29.68 \times 10^3 / RT)$ | mol/m$^{2}$/s/Pa | [!cite](altunoglu1991permeation) |

## Results and discussion

# flux conservation

!media comparison_val-flibe.py
       image_name=val-flibe_flux_conservation.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-flibe_flux_conservation
       caption= Evaluation of the flux conservation by comparing tritium flux at the nickel membrane boundaries for $T = 823$ K and $P_{T_2} = 1210$ Pa.

# sorption law ratio conservation at both sides

!media comparison_val-flibe.py
       image_name=val-flibe_concentration_ratio_enclosure-Ni.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-flibe_concentration_ratio_enclosure-Ni
       caption= Assessment of Sieverts' law equilibrium ratio at the enclosure-nickel membrane interface for $T = 823$ K and $P_{T_2} = 1210$ Pa.

!media comparison_val-flibe.py
       image_name=val-flibe_concentration_ratio_Ni-FLiBe.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-flibe_concentration_ratio_Ni-FLiBe
       caption= Assessment of Henry's law equilibrium ratio at the nickel membrane-FLiBe interface for $T = 823$ K and $P_{T_2} = 1210$ Pa.

# results with flux wrt initial pressure

!media comparison_val-flibe.py
       image_name=val-flibe_flux.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-flibe_flux
       caption= Steady state permeation flux through Ni and FLiBe at different temperatures and input pressures. TMAP8 results (TMAP8) vs [!cite](calderoni2008measurement) (exp).

## Input files

!style halign=left
The input file for this case can be found at [/val-flibe.i].

[/val-flibe/tests] used `cli_args` to modify [/val-flibe.i] into simulating the different range of temperatures and initial pressures used during the experiment.

To limit the computational costs of the test case, the test runs a version of the file with a smaller simulation time. More information about the changes can be found in the test specification file for this case, namely [/val-flibe/tests].
