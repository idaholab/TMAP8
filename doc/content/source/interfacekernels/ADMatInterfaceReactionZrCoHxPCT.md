# ADMatInterfaceReactionZrCoHxPCT

!syntax description /InterfaceKernels/ADMatInterfaceReactionZrCoHxPCT

## Description

The composition of metal hydrides like zirconium-cobalt hydride (ZrCoHx) is described by pressure-composition-temperature (PCT) data.
In TMAP8, the PCT curve can be imposed by an interface kernel that then dictates the material composition.
Hence, the `ADMatInterfaceReactionZrCoHxPCT` interface kernel imposes the surface concentration of H in ZrCoHx based on the input pressure (Pa) and temperature (K). `ADMatInterfaceReactionZrCoHxPCT` is related to [ADMatInterfaceReaction.md], but includes the ZrCoHx PCT curves.
 At the interface between a solid (main) and a gas (neighbor), it imposes:
\begin{equation} \label{eq:test_interfacereactionZr2FeHx}
\frac{d C_s}{dt} = 0 = K_b f_{at}(T,P) \rho -  K_f C_s ,
\end{equation}
where $C_s$ is the surface H concentration in mol/m$^3$,
$K_b$ and $K_f$ are the backward and forward surface reaction rate in 1/s, respectively,
$f_{at}(T,P)$ is the composition in atomic fraction of H in ZrCoHx given a gas temperature $T$ and gas pressure $P$,
and $\rho$ is the zirconium-cobalt atomic density in mol/m$^3$.

[ZrCoHx_PCT_Data] shows the data used in this interface kernel. The experimental data was selected from several authors [!cite](jat2013hydrogen) for (433.15 K) and (604.15 K) and [!cite](nagasaki1986zirconium) for (573.15 K) since a clean PCT curve is required for accurate modelling.

!media comparison_ZrCoHx_PCT.py
       image_name=ZrCoHx_PCT_Data.png
       style=width:80%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ZrCoHx_PCT_Data
       caption=PCT data for ZrCoHx from [!cite](jat2013hydrogen) and [!cite](nagasaki1986zirconium).

To include this PCT data in TMAP8 modelling capabilites the high and low pressure regions were extracted and regressed for the resulting equations.

The low pressure is captured as:
\begin{equation}\label{eq:low_pressure}
f_{at}(T,P) = 0.5-\left[1.00 \times 10^{-3}+\exp(-4.29+ 0.020 T + (-1.07+ 5.69 \times 10^{-4} T) (\log\left(P_{lim}(T) - P\right)))\right]^{-1},
\end{equation}

The high pressure is captured as:
\begin{equation}\label{eq:high_pressure}
f_{at}(T,P) = 2.5-3.42\left[1.4+\exp(7.97 - 0.012 T + (-0.17 + 1.19 \times 10^{-3} T) (\log\left(P - P_{lim}(T)\right)))\right]^{-1},
\end{equation}

[ZrCoHx_PCT_fit_2D] shows the fitting and TMAP8 results used in this interface kernel.

!media comparison_ZrCoHx_PCT.py
       image_name=ZrCoHx_PCT_fit_2D.png
       style=width:80%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ZrCoHx_PCT_fit_2D
       caption=PCT data for ZrCoHx from [!cite](jat2013hydrogen) and [!cite](nagasaki1986zirconium) implemented in TMAP8, and test results.


The plateau representing phase transition is captured as:
\begin{equation} \label{eq:pressure_plateau}
P_{lim} = \exp\left(12.43-4.84 \times 10^{-2} T +7.14 \times 10^{-5} T^2 \right),
\end{equation}
with $P_{lim}$ being the hydrogen partial pressure limit delineating the plateau in Pa and $T$ being the temperature in K.
This fit is shown in [ZrCoHx_PCT_plateau_pressure_fit].

!media comparison_ZrCoHx_PCT.py
       image_name=ZrCoHx_PCT_plateau_pressure_fit.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ZrCoHx_PCT_plateau_pressure_fit
       caption=Fit phase transition region as pressure as a function of temperature.

The jump between the low low high pressure occurs if the atomic fraction is equal to 0.50, while from high to low pressure occurs if the atomic fraction is equal to 1.4. These end points follow the [eq:low_pressure] and [eq:high_pressure] maximum and minimum,respectively.

## Test

[/ZrCoHx_PCT.i] tests the implantation of the ZrCoHx PCT curves in TMAP8.
The domain contains two blocks: gas (left) and ZrCoHx (right) with an interface between the two blocks.
The diffusion is for this test case is given by [!citep](yu2024hydrogen) and the surface reaction rate $K$ is taken from [!citep](jat2013hydrogen) ($K_f=K_b=K$). Note that the diffusion used is based on ZrH$_{1.58}$ hydride since there is not diffusion value on ZrCo hydride. This should not affect the end results of the test case since simulation time goes until equlibrium is achieved.
To model the interface, the input file employs the [InterfaceDiffusion.md] object to model the flux of hydrogen at the surface, and `ADMatInterfaceReactionZrCoHxPCT` to model the steady-state condition for the hydrogen concentration at the surface $C_s$ defined by:
\begin{equation} \label{eq:test_interfacereaction}
\frac{d C_s}{dt} = 0 = K (f_{at}(T,P) \rho - C_s),
\end{equation}
where $\rho$ is the zirconium-cobalt atomic density.

The results of the high pressure test for ($T$, $P$) = (433.15 K, $3 \times 10^{4}$ Pa), (433.15 K, $1 \times 10^{4}$ Pa), (573.15 K, $1 \times 10^{4}$ Pa), and (604.15 K, $5 \times 10^{4}$ Pa). The results of the low pressure test for ($T$, $P$) = (433.15 K, $1 \times 10^{2}$ Pa), (573.15 K, $1 \times 10^{3}$ Pa), (604.15 K, $1 \times 10^{4}$ Pa), and (604.15 K, $3 \times 10^{3}$ Pa) are shown in [ZrCoHx_PCT_fit_2D]. Both show good agreement.

## Example Input File Syntax

!listing test/tests/ZrCo_hydrogen_system/ZrCoHx_PCT.i block=InterfaceKernels/interface_reaction_ZrCoHx_PCT


!syntax parameters /InterfaceKernels/ADMatInterfaceReactionZrCoHxPCT

!syntax inputs /InterfaceKernels/ADMatInterfaceReactionZrCoHxPCT

!syntax children /InterfaceKernels/ADMatInterfaceReactionZrCoHxPCT

