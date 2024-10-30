# val-2d

# Thermal Desorption Spectroscopy on Tungsten

## Case Description

This validation problem is based on the work from [!cite](hino1998hydrogen) to exercise surface-law dependent diffusion boundary conditions and the multiple trapping capability. In this experiment, H$_3^+$ is implanted at 5 keV and a flux of 1 $\times 10^{19}$ H/m$_2$/s for 5,000 seconds into a polycrystalline tungsten foil 50 x 50 mm$^2$ and 0.1 mm thick at room temperature of 300 K. Background pressure in the implantation chamber is 10$^{-3}$ Pa while the implantation is going on and 10$^{-5}$ Pa at other times. Following the implantation, the sample is subjected to thermal desorption spectroscopy by heating under vacuum at 50 K/min to 1,273 K and then held at that temperature for several minutes.

We model this system in TMAP8 using the structure of []. The implantation chamber (Enclosure 1) has a volume of 0.1 $m^3$ and is evacuated by a turbo-molecular vacuum pump. The implantation chamber is defined for this problem as a enclosure having a preprogrammed temperature of 300 K for 5,000 seconds followed by a ramp to 1,273 K at a ramp rate of 50 K/min. Gas leakage from the ion source is represented by a enclosure with a pressure of $1 \times 10^{-3}$ Pa during implantation followed by $1 \times 10^{-5}$ Pa and flow to the implantation chamber at the vacuum pumping rate. Flow rate from the implantation chamber is taken to be 0.07 m$^3$/s on the basis of the stated pressure in the test chamber during implantation, given that nearly all implanted gas re-emerges during that time. The vacuum pump is represented by a enclosure (Enclosure 2) held at 10-8 Pa.

Based on TRIM calculation [!citep](eckstein2013computer,biersack1982stopping), implantation in the sample shows a normal distribution, which has a peak at 4.6 nm below the surface and a characteristic half width of 3 nm. Implantation is activated for 5,000 s and then terminated.

Three traps are assumed in the sample. Trap concentrations and distributions are considered adjustable parameters while energies were determined by TDS peak temperatures. The first trap is assumed to be associated with implantation (damage and precipitation) and to be normally distributed with a peak at 4.6 nm and a characteristic width of 10 nm, consistent with the observations of [!cite](haasz1999effect) that damage zone exceeds the implantation depth. Its trap energy is adjusted, based on the temperature of the first peak, to be 1.2 eV, and it is assumed to be 0.086 atom fraction at the peak. The second is a uniform trap associated with dislocations and is assigned a trap release energy of 1.6 eV, typical of but slightly higher than that seen by [!cite](anderl1992deuterium). Its concentration is adjusted to 0.00175 atom fraction. The third trap is also assumed to be uniformly distributed and to have a trapping energy of 3.1 eV, nearly the same as the deep trap seen by [!cite](frauenfelder1969solution) with a concentration of 0.002 atom fraction. It is only marginally filled during the implantation because of the diffusive limitation to flow into the depth of the sample.

Therefore, the diffusion of tritium in sample is described as:

\begin{equation} \label{eq:diffusion}
\frac{d C}{d t} = \nabla D \nabla C + S + \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{dC_{T_i}}{dt} ,
\end{equation}

and, for $i=1$, $i=2$, and $i=3$:

\begin{equation}
    \label{eqn:trapped_rate}
    \frac{dC_{T_i}}{dt} = \alpha_t^i  \frac {C_{T_i}^{empty} C } {(N \cdot \text{trap\_per\_free})} - \alpha_r^i C_{T_i},
\end{equation}

and

\begin{equation}
    C_{T_i}^{empty} = (C_{{T_i}0} \cdot N - \text{trap\_per\_free} \cdot C_{T_i}  ) ,
\end{equation}

where $C$ is the concentration of tritium, $t$ is the time, $S$ is the source term in sample due to the tritium ion implantation, $C_{T_i}$ is the trapped species in trap $i$, $\alpha_t^i$ and $\alpha_r^i$ are the trapping and release rate coefficients for trap $i$, $\text{trap\_per\_free}$ is a factor scaling $C_{T_i}$ to be closer to $C_M$ for better numerical convergence, $C_{{T_i}0}$ is the fraction of host sites $i$ that can contribute to trapping, $C_{T_i}^{empty}$ is the concentration of empty trapping sites, and $N$ is the host density, and $D$ is the tritium diffusivity in tungsten, which is defined as:

\begin{equation} \label{eq:diffusivity}
D = D_{0} \exp \left( - \frac{E_{D}}{k_b T} \right),
\end{equation}

where $D_{0}$ is the maximum diffusivity coefficient, $E_{D}$ is the diffusion activation energy, $k_b$ is the Boltzmann’s constant, $T$ is the temperature.

$\alpha_t^i$ and $\alpha_r^i$ are defined as:

\begin{equation} \label{eq:trapping}
\alpha_t = \alpha_{t0} \exp(-\epsilon_t / T),
\end{equation}

and

\begin{equation} \label{eq:release}
\alpha_r = \alpha_{r0} \exp(-\epsilon_r / T),
\end{equation}

where $\alpha_{t0}$ and $\alpha_{r0}$ are pre-exponential factors of trapping and release rate coefficients, respectively, $\epsilon_t$ and $\epsilon_r$ are the trapping and detrapping energies, respectively.

All the model parameters are taken from [!cite](hino1998hydrogen,haasz1999effect,anderl1992deuterium,frauenfelder1969solution,ambrosek2008verification) and listed in [val-2d_set_up_values].

## Model Description

In this case, TMAP8 simulates a one-dimensional domain to represent the tritium implantation, diffusion, and trapping and detrapping in a raising thermal field. Note that this case can easily be extended to a two- or three-dimensional case.

The source term in the model is described as a normal distribution in [eq:normal_distribution]:

\begin{equation} \label{eq:normal_distribution}
S = F \frac{0.002156}{\sigma \sqrt{2 \pi}} \exp \left( - \frac{(x - \mu )^2}{2 \sigma^2} \right),
\end{equation}

where $F$ is the implantation flux provided in [val-2d_set_up_values], $\sigma = 3 \times 10^{-9}$ m is the characteristic width of the normal distribution, and $\mu = 4.6 \times 10^{-9}$ m is the depth of the normal distribution from the upstream side. [eq:normal_distribution] uses the factor of 0.002156 to correspond to the peak atom fraction of 0.086 from [!citep](ambrosek2008verification).

The boundary conditions on the both sides are surfdep condition. The recombination flux is describe as:

\begin{equation} \label{eq:recombination_ignore_Pressure}
J = 2 \frac{K_r}{K_r + K_b} D_s \lambda C^2,
\end{equation}

where $C$ is the concentration of tritium on both sides, $\lambda$ is the lattice parameter, K_r and K_b are release and dissociation coefficients, respectively, and D_s is surface diffusivity coefficient. These coefficients are defined as:

\begin{equation} \label{eq:release_coefficient}
K_r = \nu \exp \left( \frac{E_c - E_x}{k_b T} \right),
\end{equation}

\begin{equation} \label{eq:dissociation_coefficient}
K_b = \nu \exp \left( - \frac{E_b}{k_b T} \right),
\end{equation}

and

\begin{equation} \label{eq:surface_diffusivity}
D_s = D_{0} \exp \left( - \frac{E_{D_s}}{k_b T} \right),
\end{equation}

where $\nu$ is the Debye frequency, $E_x$ is the adsorption barrier energy, $E_c$ is the surface binding energy, $E_b$ is the dissociation activation energy, and $E_{D_s}$ is the surface diffusion activation energy.


## Case and Model Parameters



!table id=val-2d_set_up_values caption=Values of material properties.
| Parameter | Description                          | Value                                                       | Units                 | Reference                 |
| --------- | ------------------------------------ | ----------------------------------------------------------- | --------------------- | --------------------- |
| $K_{d,l}$ | upstream dissociation coefficient    | 8.959 $\times 10^{18} (1-0.9999 \exp(-6 \times 10^{-5} t))$ | at/m$^2$/s/Pa$^{0.5}$ |  |
| $K_{d,r}$ | downstream dissociation coefficient  | 1.7918$\times 10^{15}$                                      | at/m$^2$/s/Pa$^{0.5}$ |  |
| $K_{r,l}$ | upstream recombination coefficient   | 1$\times 10^{-27} (1-0.9999 \exp(-6 \times 10^{-5} t))$     | m$^4$/at/s            |  |
| $K_{r,r}$ | downstream recombination coefficient | 2$\times 10^{-31}$                                          | m$^4$/at/s            |  |
| $P_{l}$   | upstream pressure                    | 0                                                           | Pa                    |  |
| $P_{r}$   | downstream pressure                  | 0                                                           | Pa                    |  |
| $D$       | deuterium diffusivity in PCA         | 3$\times 10^{-10}$                                          | m$^2$/2               |  |
| $d$       | diameter of PCA                      | 0.025                                                       | m                     |  |
| $l$       | thickness of PCA                     | 5$\times 10^{-4}$                                           | m                     |  |
| $T$       | temperature                          | 703                                                         | K                     |  |


!alert note title=This validation case only uses the data from TMAP4
Both TMAP4 ([!citep](longhurst1992verification)) and TMAP7 ([!citep](ambrosek2008verification)) have the validation case for ion implantation experiment. However, the experimental data in TMAP7 are far away from the data in [!cite](anderl1985tritium). We only used the data from TMAP4 in this validation case.

## Results

[val-2d_comparison_TMAP4] shows the comparison of the TMAP8 calculation and the experimental data. There is reasonable agreement between the TMAP predictions and the experimental data with the root mean square percentage error of RMSPE =  %, respectively. Note that the agreement could be improved by adjusting the model parameters. It is also possible to perform this optimization with [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html).

### Comparison based on data from TMAP4

!media comparison_val-2d.py
       image_name=val-2d_comparison_TMAP4.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2d_comparison_TMAP4
       caption=Comparison of TMAP8 calculation with the experimental data with unit of atom/m$^2$/s

## Input files

!style halign=left
The input files for this case can be found at [/val-2d.i], which is also used as test in TMAP8 at [/val-2d/tests].

!bibtex bibliography
