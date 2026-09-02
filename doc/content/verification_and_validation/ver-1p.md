
# Steady State Transport in Fluid and Pipe Permeator Wall

## General Case Description

This verification case compares the TMAP8 solution with an independent analytical implementation of the steady state permeator against vacuum (PAV) transport model based on [!cite](fuerst2023parametric). The model represents hydrogen isotope transport from flowing PbLi through a cylindrical vanadium membrane and into an ideal vacuum.

The transport process includes liquid mass transfer, jump between PbLi and vanadium surface, radial diffusion through the vanadium membrane, and recombination at the vacuum surface. The calculation is steady state and isothermal, and the hydrogen isotope partial pressure on the vacuum side is assumed to be zero.

TMAP8 represents the 5 m permeator with 20 axial control volumes. The independent Python reference uses the same radial transport model but solves the corresponding continuous axial mass balance equation.


## Case Setup

The geometry and operating parameters are summarized in [ver_1p_set_up_values].

!table id=ver_1p_set_up_values caption=Geometry and operating parameters used for the PAV verification case.
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

The gas constant is $R=8.31446261815324$ J/(mol K), consistent with [PhysicalConstants](source/utils/TMAP8PhysicalConstants.md). The vanadium recombination coefficient $K_R$ is based on [!cite](FUERST2021118949).

### Material properties and liquid mass transfer

The PbLi hydrogen isotope diffusivity is [!cite](S.Fukada2013MG201203)

\begin{equation}
D_L=D_{L,0}\exp\left(-\frac{E_{D,L}}{RT}\right),
\end{equation}

and the PbLi density is

\begin{equation}
\rho_{\mathrm{PbLi}}=\rho_0-a_\rho T.
\end{equation}

The effective PbLi molar concentration is

\begin{equation}
C_{\mathrm{PbLi}}=\frac{\rho_{\mathrm{PbLi}}}{M_{\mathrm{PbLi}}},
\end{equation}

where $M_{\mathrm{PbLi}}=0.1731558$ kg/mol. The PbLi solubility coefficient used in the model is based on [!cite](AIELLO2006639)

The PbLi solubility coefficient uses the coefficient
reported by [!cite](fuerst2023parametric) based on [!cite](AIELLO2006639):

\begin{equation}
K_L=K_{L,\mathrm{base}}C_{\mathrm{PbLi}},
\end{equation}

with $K_{L,\mathrm{base}}=4.32\times10^{-7}$ Pa$^{-1/2}$.

For the vanadium membrane, the hydrogen isotope diffusivity is based on [!cite](VOLKL1975231),

\begin{equation}
D_S=D_{S,0}\exp\left(-\frac{E_{D,S}}{RT}\right),
\end{equation}

and the hydrogen isotope solubility is based on [!cite](10.1021/j100723a033):

\begin{equation}
K_S=K_{S,0}\exp\left(\frac{E_{K,S}}{RT}\right).
\end{equation}

The hydraulic diameter is

\begin{equation}
D_h=2r_i.
\end{equation}

Using the specified Reynolds number, the kinematic visc osity and Schmidt number are

\begin{equation}
\nu_{\mathrm{PbLi}}=\frac{uD_h}{Re},
\end{equation}

and

\begin{equation}
Sc=\frac{\nu_{\mathrm{PbLi}}}{D_L}.
\end{equation}

The Sherwood number and liquid mass transfer coefficient are calculated using
the correlation of [!cite](linton1950mass):

\begin{equation}
Sh=\alpha Re^\beta Sc^\gamma.
\end{equation}

and

\begin{equation}
K_T=\frac{ShD_L}{D_h}.
\end{equation}

At 673.15 K, the material property model parameters and calculated
transport quantities used in the reference implementation are summarized in
[ver_1p_calculated_values].

!table id=ver_1p_calculated_values caption=Material-property parameters and calculated transport quantities for the PAV verification case.
| Parameter | Description | Value | Units | Basis |
| --- | --- | ---: | --- | --- |
| $D_{L,0}$ | PbLi diffusivity pre-exponential factor | $8.30\times10^{-9}$ | m$^2$/s | [!cite](S.Fukada2013MG201203) |
| $E_{D,L}$ | PbLi diffusivity activation energy | $7.37\times10^3$ | J/mol | [!cite](S.Fukada2013MG201203) |
| $K_{L,\mathrm{base}}$ | PbLi solubility coefficient factor | $4.32\times10^{-7}$ | Pa$^{-1/2}$ | [!cite](fuerst2023parametric) |
| $D_{S,0}$ | Vanadium diffusivity pre-exponential factor | $2.90\times10^{-8}$ | m$^2$/s | [!cite](VOLKL1975231) |
| $E_{D,S}$ | Vanadium diffusivity activation energy | $4.20\times10^3$ | J/mol | [!cite](VOLKL1975231) |
| $K_{S,0}$ | Vanadium solubility pre-exponential factor | 0.138 | mol/(m$^3$ Pa$^{1/2}$) | [!cite](10.1021/j100723a033) |
| $E_{K,S}$ | Vanadium solubility exponential coefficient | $29.0\times10^3$ | J/mol | [!cite](10.1021/j100723a033) |
| $D_L$ | Isotope diffusivity in PbLi | $2.22432\times10^{-9}$ | m$^2$/s | Calculated |
| $\rho_{\mathrm{PbLi}}$ | PbLi density | $9.71896\times10^3$ | kg/m$^3$ | Calculated |
| $K_L$ | PbLi solubility coefficient | $2.42475\times10^{-2}$ | mol/(m$^3$ Pa$^{1/2}$) | Calculated |
| $D_S$ | Isotope diffusivity in vanadium | $1.36929\times10^{-8}$ | m$^2$/s | Calculated |
| $K_S$ | Vanadium solubility coefficient | $2.45560\times10^1$ | mol/(m$^3$ Pa$^{1/2}$) | Calculated |
| $Sc$ | Schmidt number | 76.0233 | - | Calculated |
| $Sh$ | Sherwood number | 1376.29 | - | Calculated |
| $K_T$ | Liquid mass transfer coefficient | $3.22243\times10^{-4}$ | m/s | Calculated |
| $\alpha$ | Sherwood correlation coefficient | 0.023 | - | [!cite](linton1950mass) |
| $\beta$ | Reynolds number exponent | 0.83 | - | [!cite](linton1950mass) |
| $\gamma$ | Schmidt number exponent | $1/3$ | - | [!cite](linton1950mass) |

## Analytical solution

The analytical solution is based on the analysis by [!cite](fuerst2023parametric). For a local bulk PbLi concentration $C$, the liquid mass transfer relation is

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
J=\frac{r_o}{r_i} K_R C_{S2}^2.
\end{equation}

Defining

\begin{equation}
b=\frac{a}{K_T}+R_{\mathrm{mem}},
\end{equation}

and eliminating the intermediate interface concentrations gives

\begin{equation}
b \frac{r_o}{r_i} K_R C_{S2}^2+C_{S2}-aC=0.
\end{equation}

The positive root is

\begin{equation}
C_{S2}(C)=\frac{2aC}{1+\sqrt{1+4b\frac{r_o}{r_i}K_RaC}},
\end{equation}

and the local permeation flux is

\begin{equation}
J(C)=K_R\left[\frac{2aC}{1+\sqrt{1+4b\frac{r_o}{r_i} K_RaC}}\right]^2.
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
C=\frac{y+b \frac{r_o}{r_i} K_Ry^2}{a}.
\end{equation}

Combining this relation with the continuous axial balance and integrating from the inlet to axial location $z$ gives

\begin{equation}
\frac{1}{y}-\frac{1}{y_0}
-2b \frac{r_o}{r_i} K_R\ln\left(\frac{y}{y_0}\right)
=\frac{2\pi r_i aK_R}{Q}z,
\end{equation}

where

\begin{equation}
y_0=\frac{2aC_{\mathrm{in}}}{1+\sqrt{1+4b \frac{r_o}{r_i} K_RaC_{\mathrm{in}}}}.
\end{equation}

The Python comparison solves this scalar analytical relation at the same axial locations used by the TMAP8 control volume model and recovers the bulk concentration from

\begin{equation}
C(z)=\frac{y(z)+b \frac{r_o}{r_i} K_Ry(z)^2}{a}.
\end{equation}


## Results

[ver-1p_comparison_analytical_concentration.png] compares the 20 segment TMAP8 solution with the continuous analytical reference. The concentration profile root mean square percentage error (RMSPE) is approximately 0.127 %.

!media comparison_ver-1p.py
       image_name=ver-1p_comparison_analytical_concentration.png
       style=width:70%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1p_comparison_analytical_concentration.png
       caption=Comparison of the 20 segment TMAP8 bulk concentration profile with the continuous analytical PAV reference solution.

The numerical comparison is summarized in [ver_1p_results].

!table id=ver_1p_results caption=Comparison of the TMAP8 solution with the analytical reference.
| Quantity | TMAP8 | Analytical | Relative error |
| --- | ---: | ---: | ---: |
| Outlet concentration, mol/m$^3$ | 0.759275 | 0.760904 | 0.214 % |
| Extraction efficiency | 0.240725 | 0.239096 | 0.681 % |
| Average permeation flux, mol/(m$^2$ s) | $2.03533\times10^{-4}$ | $2.02156\times10^{-4}$ | 0.681 % |

The extraction efficiency is calculated as

\begin{equation}
\eta=1-\frac{C_{\mathrm{out}}}{C_{\mathrm{in}}},
\end{equation}

## Input files

!style halign=left
The input file for this case can be found at [!file](/ver-1p.i), which is used as a test in TMAP8 at [!file](/ver-1p/tests). The independent analytical comparison and figure generation are implemented in [!file](/ver-1p/comparison_ver-1p.py).


!bibtex bibliography
