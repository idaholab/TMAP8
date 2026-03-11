# ADMatInterfaceReactionZr2FeHx

!syntax description /InterfaceKernels/ADMatInterfaceReactionZr2FeHxPCT

## Description

The composition of metal hydrides like zirconium-iron hydride (Zr2FeHx) is described by pressure-composition-temperature (PCT) data.
In TMAP8, the PCT curve can be imposed by an interface kernel that then dictates the material composition.
Hence, the `ADMatInterfaceReactionZr2FeHxPCT` interface kernel imposes the surface concentration of H in Zr2FeHx based on the input pressure (Pa) and temperature (K). `ADMatInterfaceReactionZr2FeHxPCT` is related to [ADMatInterfaceReaction.md], but includes the Zr2FeHx PCT curves.
 At the interface between a solid (main) and a gas (neighbor), it imposes:
\begin{equation} \label{eq:test_interfacereactionZr2FeHx}
\frac{d C_s}{dt} = 0 = K_b f_{at}(T,P) \rho -  K_f C_s ,
\end{equation}
where $C_s$ is the surface H concentration in mol/m$^3$,
$K_b$ and $K_f$ are the backward and forward surface reaction rate in 1/s, respectively,
$f_{at}(T,P)$ is the composition in atomic fraction of H in Zr2FeHx given a gas temperature $T$ and gas pressure $P$,
and $\rho$ is the zirconium-iron atomic density in mol/m$^3$.


[Zr2FeHx_PCT_fit_2D] shows the fitting and TMAP8 results used in this interface kernel, along with the experimental data from [!cite](yang2025potential).
The  pressure isotherm is captured as:
\begin{equation} \label{eq:atomic_fraction}
f_{at}(T,P) = 4.30-1.81\left[0.5+\exp(5.41 - 1.36 \times 10^{-2} T + (0.232+ 1.51 \times 10^{-4} T) (\log\left(P - P_{lim}(T)\right)))\right]^{-1}.
\end{equation}

Equation [eq:atomic_fraction] is valid for:
\begin{equation} \label{eq:bounds}
0.011 < P [Pa] < 9.e06
\end{equation}

!media comparison_Zr2FeHx_PCT.py
       image_name=Zr2FeHx_PCT_fit_2D.png
       style=width:80%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=Zr2FeHx_PCT_fit_2D
       caption=PCT data for Zr2FeHx from [!cite](yang2025potential) implemented in TMAP8, and test results.

The pressure limit seen in [eq:atomic_fraction] is captured as:
\begin{equation} \label{eq:pressure_plateau}
P_{lim} = \exp\left(-4.12+1.03 \times 10^{-2} T\right),
\end{equation}
with $P_{lim}$ being the hydrogen partial pressure limit in Pa and $T$ being the temperature in K.
Unlike YHx and ZrCoHx, which use the plateau pressure fit as a limiting factor in [eq:atomic_fraction], the Zr₂FeHx model derives its pressure‑limit curve from the pressure corresponding to 1wt% metal–hydrogen at each temperature in the experimental dataset. This is because, as shown in the data, Zr₂FeHx does not exhibit a true plateau; instead, its isotherms display an approximately linear slope with an onset near 1wt%. The curve shown in [Zr2FeHx_PCT_pressure_limiter_fit] represents the fitted pressure-limiting relationship.

!media comparison_Zr2FeHx_PCT.py
       image_name=Zr2FeHx_PCT_pressure_limiter_fit.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=Zr2FeHx_PCT_pressure_limiter_fit
       caption= Pressure-limiter fit as a function of temperature.


The [!param](/InterfaceKernels/ADMatInterfaceReactionZr2FeHxPCT/silence_warnings) option can be used to dictate how TMAP8 reacts when the pressure gets out of the bounds.
If `silence_warnings = false`, which is the default behavior, then TMAP8 will print a warning stating that the pressure and temperature are outside the bounds of the atomic fraction correlation.
If `silence_warnings = true`, then TMAP8 will let the simulation continue without issuing any warnings.

## Test

[/Zr2FeHx_PCT.i] tests the implantation of the Zr2FeHx PCT curves in TMAP8.
The domain contains two blocks: gas (left) and Zr2FeHx (right) with an interface between the two blocks.
The diffusion is given by [!cite](yu2024hydrogen) and the surface reaction rate $K$ is taken from [!cite](yang2025potential) ($K_f=K_b=K$). Note that the diffusion is for ZrH1.8 because no diffusion data exist for Zr2FeHx.
To model the interface, the input file employs the [InterfaceDiffusion.md] object to model the flux of hydrogen at the surface, and `ADMatInterfaceReactionZr2FeHxPCT` to model the steady-state condition for the hydrogen concentration at the surface $C_s$ defined by:
\begin{equation} \label{eq:test_interfacereaction}
\frac{d C_s}{dt} = 0 = K (f_{at}(T,P) \rho - C_s),
\end{equation}
where $\rho$ is the zirconium-iron atomic density.

The results of the high pressure test for ($T$, $P$) = (648.15 K, $1 \times 10^{5}$ Pa), (648.15 K, $1 \times 10^{2}$ Pa), (598.15 K, $1 \times 10^{3}$ Pa), and(623.15 K, $1 \times 10^{4}$ Pa) are shown in [Zr2FeHx_PCT_fit_2D] and show good agreement with [eq:atomic_fraction].

## Example Input File Syntax

!listing test/tests/Zr2Fe_hydrogen_system/Zr2FeHx_PCT.i block=InterfaceKernels/interface_reaction_Zr2FeHx_PCT

!syntax parameters /InterfaceKernels/ADMatInterfaceReactionZr2FeHxPCT

!syntax inputs /InterfaceKernels/ADMatInterfaceReactionZr2FeHxPCT

!syntax children /InterfaceKernels/ADMatInterfaceReactionZr2FeHxPCT

