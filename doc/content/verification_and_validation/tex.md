
# Steady State Transport in Fluid and Pipe Permeator Wall

## General Case Description

This verification case compares the TMAP8 solution with an independent analytical implementation of the steady state permeator against vacuum (PAV) transport model based on [!cite](fuerst2023parametric). The model represents hydrogen isotope transport from flowing PbLi through a cylindrical vanadium membrane and into an ideal vacuum.

The transport process includes liquid mass transfer, jump between PbLi and vanadium surface, radial diffusion through the vanadium membrane, and recombination at the vacuum surface. The calculation is steady state and isothermal, and the hydrogen isotope partial pressure on the vacuum side is assumed to be zero.

TMAP8 represents the 5 m permeator with 20 axial control volumes. The independent Python reference uses the same radial transport model but solves the corresponding continuous axial mass balance equation.


## Case Set up

The geometry and operating parameters are summarized in [tex_set_up_values].

!table id=tex_set_up_values caption=Geometry and operating parameters used for the PAV verification case.
| Parameter | Description | Value | Units |
| --- | --- | ---: | --- |
| $T$ | Temperature | 673.15 | K |
| $L$ | Active permeator length | 5.00 | m |
| $r_i$ | Inner tube radius | $4.75\times10^{-3}$ | m |
| $r_o$ | Outer tube radius | $5.00\times10^{-3}$ | m |
| $N$ | Number of TMAP8 axial control volumes | 20 | - |
| $C_{\mathrm{in}}$ | Inlet dissolved-isotope concentration | 1.0 | mol/m$^3$ |
| $u$ | PbLi velocity | 1.78 | m/s |
| $Re$ | Reynolds number | $1.0\times10^5$ | - |
| $K_R$ | Recombination coefficient | $3.1582\times10^{-9}$ | m$^4$/(mol s) |

The gas constant is $R=8.31446261815324$ J/(mol K), consistent with [PhysicalConstants](source/utils/TMAP8PhysicalConstants.md).

### Material properties and liquid mass transfer

The PbLi hydrogen isotope diffusivity is

\begin{equation}
D_L=8.30\times10^{-9}\exp\left(-\frac{7.37\times10^3}{RT}\right),
\end{equation}

and the PbLi density is

\begin{equation}
\rho_{\mathrm{PbLi}}=10520.35-1.19051T.
\end{equation}

The effective PbLi molar concentration is

\begin{equation}
C_{\mathrm{PbLi}}=\frac{\rho_{\mathrm{PbLi}}}{M_{\mathrm{PbLi}}},
\end{equation}

where $M_{\mathrm{PbLi}}=0.1731558$ kg/mol. The PbLi solubility coefficient used in the model is

\begin{equation}
K_L=K_{L,\mathrm{base}}C_{\mathrm{PbLi}},
\end{equation}

with $K_{L,\mathrm{base}}=4.32\times10^{-7}$ Pa$^{-1/2}$.

For the vanadium membrane,

\begin{equation}
D_S=2.90\times10^{-8}\exp\left(-\frac{4.2\times10^3}{RT}\right),
\end{equation}

and

\begin{equation}
K_S=0.138\exp\left(\frac{29.0\times10^3}{RT}\right).
\end{equation}

The hydraulic diameter is

\begin{equation}
D_h=2r_i.
\end{equation}

Using the specified Reynolds number, the kinematic viscosity and Schmidt number are

\begin{equation}
\nu_{\mathrm{PbLi}}=\frac{uD_h}{Re},
\end{equation}

and

\begin{equation}
Sc=\frac{\nu_{\mathrm{PbLi}}}{D_L}.
\end{equation}

The Sherwood number and liquid mass transfer coefficient are

\begin{equation}
Sh=0.023Re^{0.83}Sc^{1/3},
\end{equation}

and

\begin{equation}
K_T=\frac{ShD_L}{D_h}.
\end{equation}

At 673.15 K, the values calculated by the reference implementation are listed in [tex_calculated_values].

!table id=tex_calculated_values caption=Calculated transport quantities at 673.15 K.
| Parameter | Description | Value | Units |
| --- | --- | ---: | --- |
| $D_L$ | Isotope diffusivity in PbLi | $2.22432\times10^{-9}$ | m$^2$/s |
| $\rho_{\mathrm{PbLi}}$ | PbLi density | $9.71896\times10^3$ | kg/m$^3$ |
| $K_L$ | PbLi solubility coefficient | $2.42475\times10^{-2}$ | mol/(m$^3$ Pa$^{1/2}$) |
| $D_S$ | Isotope diffusivity in vanadium | $1.36929\times10^{-8}$ | m$^2$/s |
| $K_S$ | Vanadium solubility coefficient | $2.45560\times10^1$ | mol/(m$^3$ Pa$^{1/2}$) |
| $Sc$ | Schmidt number | 76.0233 | - |
| $Sh$ | Sherwood number | 1376.29 | - |
| $K_T$ | Liquid mass transfer coefficient | $3.22243\times10^{-4}$ | m/s |

## Analytical solution

For a local bulk PbLi concentration $C$, the liquid mass transfer relation is

\begin{equation}
J=K_T(C-C_{L2}),
\end{equation}

where $C_{L2}$ is the PbLi concentration adjacent to the membrane. Equilibrium partitioning gives

\begin{equation}
C_{S1}=\frac{K_S}{K_L}C_{L2}.
\end{equation}

Defining

\begin{equation}
a=\frac{K_S}{K_L},
\end{equation}

radial diffusion through the cylindrical vanadium membrane is

\begin{equation}
J=\frac{D_S(C_{S1}-C_{S2})}{r_i\ln(r_o/r_i)}.
\end{equation}

The membrane resistance is therefore

\begin{equation}
R_{\mathrm{mem}}=\frac{r_i\ln(r_o/r_i)}{D_S}.
\end{equation}

At the vacuum surface, the model uses

\begin{equation}
J=K_R C_{S2}^2.
\end{equation}

Defining

\begin{equation}
b=\frac{a}{K_T}+R_{\mathrm{mem}},
\end{equation}

and eliminating the intermediate interface concentrations gives

\begin{equation}
bK_R C_{S2}^2+C_{S2}-aC=0.
\end{equation}

The positive root is

\begin{equation}
C_{S2}(C)=\frac{2aC}{1+\sqrt{1+4bK_RaC}},
\end{equation}

and the local permeation flux is

\begin{equation}
J(C)=K_R\left[\frac{2aC}{1+\sqrt{1+4bK_RaC}}\right]^2.
\end{equation}

### Continuous axial reference solution

TMAP8 applies the radial permeation relation in 20 axial control volumes. For the analytical calculation, the axial balance is instead treated continuously:

\begin{equation}
Q\frac{dC}{dz}=-2\pi r_iJ(C),
\end{equation}

where

\begin{equation}
Q=u\pi r_i^2.
\end{equation}

Let

\begin{equation}
y=C_{S2}.
\end{equation}

From the radial solution,

\begin{equation}
C=\frac{y+bK_Ry^2}{a}.
\end{equation}

Combining this relation with the continuous axial balance and integrating from the inlet to axial location $z$ gives

\begin{equation}
\frac{1}{y}-\frac{1}{y_0}
-2bK_R\ln\left(\frac{y}{y_0}\right)
=\frac{2\pi r_i aK_R}{Q}z,
\end{equation}

where

\begin{equation}
y_0=\frac{2aC_{\mathrm{in}}}{1+\sqrt{1+4bK_RaC_{\mathrm{in}}}}.
\end{equation}

The Python comparison solves this scalar analytical relation at the same axial locations used by the TMAP8 control volume model and recovers the bulk concentration from

\begin{equation}
C(z)=\frac{y(z)+bK_Ry(z)^2}{a}.
\end{equation}


## Results

[tex_comparison_analytical_concentration.png] compares the 20 segment TMAP8 solution with the continuous analytical reference. The concentration profile root mean square percentage error (RMSPE) is approximately 0.125 %.

!media comparison_tex.py
       image_name=tex_comparison_analytical_concentration.png
       style=width:70%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=tex_comparison_analytical_concentration.png
       caption=Comparison of the 20 segment TMAP8 bulk concentration profile with the continuous analytical PAV reference solution.


The extraction efficiency is calculated as

\begin{equation}
\eta=1-\frac{C_{\mathrm{out}}}{C_{\mathrm{in}}},
\end{equation}

## Input files

!style halign=left
The input file for this case can be found at [!file](/ver-1p.i), which is used as a test in TMAP8 at [!file](/ver-1p/tests). The independent analytical comparison and figure generation are implemented in [!file](/ver-1p/comparison_ver-1p.py).


!bibtex bibliography
