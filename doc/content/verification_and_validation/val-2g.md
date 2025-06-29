# val-2g

# Permeation experiment with FLiBe

## Case Description

In this experiment from [!cite](calderoni2008measurement), tritium permeation through molten FLiBe (2LiF–BeF$_2$) is measured using a stainless steel permeation cell composed of two internal volumes separated by a 2 mm thick nickel membrane. The bottom side of the membrane is exposed to a T$_2$/argon gas mixture at controlled partial pressures ranging from 1 to 1250 Pa, while the top side is in contact with molten FLiBe. Temperatures are varied between 500°C and 700°C (773–973 K). As tritium permeated through the membrane and dissolved in the FLiBe, it is carried away from the liquid surface by an argon sweep gas containing 5$\%$ H$_2$.

## Model Description

The diffusion for tritium in the nickel membrane and FLiBe can be expressed by

\begin{equation}
\frac{\partial C_{T_2, \,  \text{Ni}}}{\partial t} = \nabla D_{\text{Ni}} \nabla C_{T_2, \,  \text{Ni}},
\end{equation}
and
\begin{equation}
\frac{\partial C_{T_2, \,  \text{FLiBe}}}{\partial t} = \nabla D_{\text{FLiBe}} \nabla C_{T_2, \,  \text{FLiBe}},
\end{equation}

where $C_{T_2, \,  \text{Ni}}$ and $C_{T_2, \,  \text{FLiBe}}$ represent the concentration fields in the nickel membrane and FLiBe, respectively, $t$ is the time, and $D_{\text{Ni}}$ and $D_{\text{FLiBe}}$ denotes the diffusivity coefficients.

The concentration in FLiBe is related to the partial pressure and concentration in the nickel membrane via the interface sorption law:

\begin{equation}
C_{T_2, \,  \text{Ni}} = K_{s, \,  \text{FLiBe}} P_{T_2, \,  \text{FLiBe}}^n = K_{s, \,  \text{FLiBe}} \left( C_{T_2, \,  \text{FLiBe}} RT \right)^n,
\end{equation}

where $R$ is the ideal gas constant in J/mol/K, $T$ is the temperature, $K_{s, \,  \text{Ni}}$ is the solubility for tritium in nickel, and $n$ is the exponent of the sorption law. For Henry's law, $n=1$.

At the top of the experimental setup, a Dirichlet boundary condition with a tritium concentration set to zero is imposed, reflecting the assumption that tritium is continuously swept away from the surface:

\begin{equation}
C_{T_2, \,  \text{FLiBe}} = 0.
\end{equation}

An Dirichlet boundary condition at the membrane-air interface imposes an equilibrium for the tritium concentration based on Sieverts' law:

\begin{equation}
C_{T_2, \,  \text{Ni}} = K_{s, \,  \text{Ni}} P_{T_2}^n,
\end{equation}

where $P_{T_2}$ is the input pressure of tritium and $n$ is the exponent of the sorption law, defined as $n=0.5$ for Sieverts' law.

## Model Parameters

In this section, [val-2g_set_up_values] provides the model parameters for this validation case.

!table id=val-2g_set_up_values caption=Model parameters.
| Parameter | Description | Value | Units | Reference |
| --------- | ----------- | ----- | ----- | --------- |
| $l_{\mathrm{Ni}}$ | Ni membrane thickness | $2$ | mm | [!cite](calderoni2008measurement) |
| $l_{\mathrm{FLiBe}}$ | FLiBe membrane thickness | $81$ | mm | [!cite](calderoni2008measurement) |
| $P_{T_2}$ | Input pressure | $1210$ | Pa | [!cite](calderoni2008measurement) |
| $C_{T_2, \mathrm{Ni}}$ | Initial concentration in the nickel membrane | $1\times 10^{-20}$ | mol/m$^3$ | - |
| $C_{T_2, \mathrm{FLiBe}}$ | Initial concentration in FLiBe | $1\times 10^{-20}$ | mol/m$^3$ |  |
| $D_{\mathrm{FLiBe}}$ | Diffusivity of tritium in FLiBe | $9.3 \times 10^{-7} \exp(- 42 \times 10^3 / RT)$ | m$^2$/s | [!cite](calderoni2008measurement) |
| $K_{s, \mathrm{FLiBe}}$ | Henry's law solubility for tritium in FLiBe | $7.9 \times 10^{-2} \exp(- 35 \times 10^3 / RT)$ | mol/m$^3$/Pa | [!cite](calderoni2008measurement) |
| $D_{\mathrm{Ni}}$ | Diffusivity of tritium in nickel | $7 \times 10^{-7} \exp(- 39.5 \times 10^3 / RT)$ | m$^2$/s | [!cite](causey2012tritium) |
| $K_{s, \mathrm{Ni}}$ | Sieverts' law solubility for tritium in nickel | $564 \times 10^{-3} \exp(- 15.8 \times 10^3 / RT)$ | mol/m$^3$/Pa$^{0.5}$ | [!cite](calderoni2008measurement) |

## Results and discussion

# flux conservation

!media comparison_val-2g.py
       image_name=val-2g_flux_conservation.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2g_flux_conservation
       caption= Evaluation of the flux conservation by comparing tritium flux at the nickel membrane boundaries for $T = 823$ K and $P_{T_2} = 1210$ Pa.

# sorption law ratio conservation at both sides

!media comparison_val-2g.py
       image_name=val-2g_concentration_ratio_enclosure-Ni.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2g_concentration_ratio_enclosure-Ni
       caption= Assessment of Sieverts' law equilibrium ratio at the enclosure-nickel membrane interface for $T = 823$ K and $P_{T_2} = 1210$ Pa.

!media comparison_val-2g.py
       image_name=val-2g_concentration_ratio_Ni-FLiBe.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2g_concentration_ratio_Ni-FLiBe
       caption= Assessment of Henry's law equilibrium ratio at the nickel membrane-FLiBe interface for $T = 823$ K and $P_{T_2} = 1210$ Pa.

# results of tritium flux as a function of temperature and initial pressure

!media comparison_val-2g.py
       image_name=val-2g_tritium_flux.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2g_tritium_flux
       caption= Steady state permeation flux through Ni and FLiBe at different temperatures and input pressures. The TMAP8 results are compared against experimental results from [!cite](calderoni2008measurement).

## Input files

!style halign=left
The input file for this case can be found at [/val-2g.i].

[/val-2g/tests] uses `cli_args` to modify [/val-2g.i] and impose the desired temperatures and initial pressures to reproduce the experimental conditions.

To limit the computational costs of the test case, the test runs a version of the file with a smaller simulation time. More information about the changes can be found in the test specification file for this case, namely [/val-2g/tests].
