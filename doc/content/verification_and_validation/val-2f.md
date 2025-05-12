# val-2f

# Modelling self-damaged tungsten effects on deuterium transport

## Case Description

The case being used for validation here involves the use of recrystallized polycrystalline tungsten (PCW) samples, which are subjected to ion irradiation and subsequent analysis using thermal desorption spectroscopy (TDS). The primary objective is to determine how damage influences deuterium trapping and release. This case is drawn from [!cite](dark2024modelling).

The TDS process is simulated using TMAP8 in a 1D tungsten sample with a thickness of 0.8 mm. The TDS simulation consisted of three phases: implantation, resting, and desorption.

The sample temperature histories are shown in [val-2f_temperature_history].

!media comparison_val-2f.py
    image_name=val-2f_temperature_history.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2f_temperature_history
    caption=Temperature history.

## Model Description

### 1. Implantation phase:

During the charging phase, deuterium is continuously implanted into the tungsten sample over a period of 72 hours. The temperature is maintained at 370 K throughout this phase. The surface is exposed to a constant flux of $\phi=5.79\times 10^{19}$ atoms/m$^2$/s, corresponding to a total fluence of $1.5\times 10^{25}$ atoms/m$^2$. The implantation profile follows a Gaussian distribution centered at the mean implantation depth of $R_p=0.7$ nm, with a standard deviation of $\sigma = 0.5$ nm :

\begin{equation}
    \label{eq:source_term}
    S(x) = \frac{1}{\sigma \sqrt{2\pi}} \exp\left( -\frac{(x - R_p)^2}{2\sigma^2} \right) \cdot \phi_{\text{surface}}(t)
\end{equation}

where the surface flux function is given by:

\begin{equation}
    \phi_{\text{surface}}(t) =
    \begin{cases}
        \phi, & t < 72 h \\
        0, & \text{otherwise}
    \end{cases}
\end{equation}

The implantation distribution is illustrated in [val-2f_implantation_distribution]: most of the implanted atoms are found within a few standard deviations ($\sigma$) of the mean implantation depth ($R_p$). In this context, it means that the mesh in the region where deuterium implantation occurs should be refined to a size comparable to $\sigma$. In this TMAP8 simulation, the first mesh region is set to length of $6\sigma$, divided into 100 elements. This allows to capture the majority of the implantation profile and ensure that the mesh is sufficiently refined in this region.

!media comparison_val-2f.py
    image_name=val-2f_implantation_distribution.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2f_implantation_distribution
    caption=Deuterium implantation.

### 2. Desorption phase:

After the implantation phase, the system enters the cooldown phase, lasting 12 hours. During this period, the sample temperature is rapidly reduced from 370 K to 295 K. No additional deuterium is introduced during this phase, meaning the source term is set to zero.

### 3. Cooldown phase:

The final stage of the simulation is the desorption phase, during which the sample is gradually heated from 300 K to 1000 K at a constant rate of $\beta = 0.05$ K/s.

## Governing equations

The general form of the transport equations for the deuterium in tungsten is given by:

\begin{equation}
    \label{eq:diffusion}
    \frac{\partial C_M}{\partial t} = \nabla D \nabla C_M + S + \text{trap\_per\_free} \cdot \sum_{i=1}^{2} \frac{\partial C_{T_i}}{\partial t}
\end{equation}

and, for $i=1$ and $i=2$:

\begin{equation}
    \label{eq:trapped_rate}
    \frac{\partial C_{T_i}}{\partial t} = \alpha_t^i  \frac {C_{T_i}^{empty} C_M } {(N \cdot \text{trap\_per\_free})} - \alpha_r^i C_{T_i}
\end{equation}

and

\begin{equation}
    C_{T_i}^{empty} = (C_{{T_i}0} \cdot N - \text{trap\_per\_free} \cdot C_{T_i})
\end{equation}

where $C_M$ is the concentration of mobile tritium, $t$ is the time, $S$ is the source term in sample due to the deuterium implantation ([eq:source_term]), $C_{T_i}$ is the trapped species in trap $i$, $\alpha_t^i$ and $\alpha_r^i$ are the trapping and release rate coefficients for trap $i$, $\text{trap\_per\_free}$ is a factor scaling $C_{T_i}$ to be closer to $C$ for better numerical convergence, $C_{{T_i}0}$ is the fraction of host sites $i$ that can contribute to trapping, $C_{T_i}^{empty}$ is the concentration of empty trapping sites, and $N$ is the host density, and $D$ is the tritium diffusivity in tungsten, which is defined as:

\begin{equation} \label{eq:diffusivity}
D = D_{0} \exp \left( - \frac{E_{D}}{k_b T} \right)
\end{equation}

where $E_{D}$ is the diffusion activation energy, $k_b$ is the Boltzmann’s constant, $T$ is the temperature, and $D_{0}$ is the maximum diffusivity coefficient.

$\alpha_t^i$ and $\alpha_r^i$ are defined as:

\begin{equation} \label{eq:trapping}
\alpha_t^i = \alpha_{t0}^i \exp(-\epsilon_t^i / T)
\end{equation}

and

\begin{equation} \label{eq:release}
\alpha_r^i = \alpha_{r0}^i \exp(-\epsilon_r^i / T)
\end{equation}

where $\alpha_{t0}^i$ and $\alpha_{r0}^i$ are the pre-exponential factors of trapping and release. The trapping energy $E_{\mathrm{t},i}$ is equal to the diffusion activation energy $E_D$.

At the surfaces, deuterium recombines into gas. It can be described by the following surface flux:

\begin{equation}
    J = 2 A K_r C^2
\end{equation}

where $J$ represents the recombination flux exiting the sample on both the left and right sides, $A$ is the surface area, and $K_r$ is the deuterium recombination coefficient. The coefficient of 2 accounts for the fact that 2 deuterium atoms combine to form one D$_2$ molecule.

The emission rate of deuterium from the sample is recorded as a function of temperature to assess how deuterium is released from the material.

## Case and Model Parameters

All the model parameters are listed in [val-2f_set_up_values]:

!table id=val-2f_set_up_values caption=Values of material properties.
| Parameter | Description                          | Value                                                       | Units                 | Reference                 |
| --------- | ------------------------------------ | ----------------------------------------------------------- | --------------------- | --------------------- |
| $k_b$     | Boltzmann constant                   | 1.380649 $\times 10^{-23}$                                  | J/K                   | [PhysicalConstants.h](https://physics.nist.gov/cgi-bin/cuu/Value?r) |
| $T_{\text{initial}}$ | Initial temperature       | 370                                                         | K                     | [!cite](dark2024modelling) |
| $T_{\text{cooldown}}$ | Cooldown temperature     | 295                                                         | K                     | [!cite](dark2024modelling) |
| $T_{\text{desorption,min}}$ | Desorption start temperature | 300                                               | K                     | [!cite](dark2024modelling) |
| $T_{\text{desorption,max}}$ | Desorption end temperature | 1000                                                | K                     | [!cite](dark2024modelling) |
| $\beta$   | Desorption heating rate              | 0.05                                                        | K/s                   | [!cite](dark2024modelling) |
| $t_{\text{charge}}$ | Charging time              | 72                                                          | h                     | [!cite](dark2024modelling) |
| $t_{\text{cooldown}}$ | Cooldown duration        | 12                                                          | h                     | [!cite](dark2024modelling) |
| $D_0$     | Diffusion pre-factor                 | 1.6 $\times 10^{-7}$                                | m$^2$/s               | [!cite](dark2024modelling) |
| $E_D$     | Activation energy for deuterium diffusion      | 0.28                                              | eV                    | [!cite](dark2024modelling) |
| $R_p$     | Mean implantation depth              | 0.7                                                         | nm                    | [!cite](dark2024modelling) |
| $\sigma$  | Standard deviation of implantation profile | 0.5                                                   | nm                    | [!cite](dark2024modelling) |
| $\Phi$    | Incident fluence                     | 1.5 $\times 10^{25}$                                        | atoms/m$^2$           | [!cite](dark2024modelling) |
| $\phi$    | Incident flux                        | 5.79 $\times 10^{19}$                                       | atoms/m$^2$/s         | [!cite](dark2024modelling) |
| $l_W$     | Length of the tungsten sample        | 0.8                                                         | mm                    | [!cite](dark2024modelling) |
| $K_r$     | Deuterium recombination coefficient  | 3.8$\times 10^{-26} \exp\left(\frac{0.34 (\text{eV})}{k_b \cdot T}\right)$ | m$^4$/at/s | [!cite](zhao2020deuterium) |
| $N$     | Tungten density                      | 6.3222 $\times 10^{28 }$                                    | at/m$^3$              | [!cite](dark2024modelling) |

All the traps parameters are listed in [val-2f_traps_values].

!table id=val-2f_traps_values caption=Values of traps parameters for 0.1 dpa.
| Parameter | Description                            | Value                                                       | Units                 | Reference                 |
| --------- | ------------------------------------   | ----------------------------------------------------------- | --------------------- | --------------------- |
| $\alpha_{t0}^i$ | Pre-factor of trapping rate coefficient | $\frac{D_0}{6 \cdot (1.1\times 10^{-10})^2}$                                           | atoms/s               | [!cite](dark2024modelling) |
| $\alpha_{r0}^i$ | Pre-factor of release rate coefficient | $10^{13}$                                           | atoms/s               | [!cite](dark2024modelling) |
| $\epsilon_t^i$ | Trapping energy for two traps     | 0.28                                                        | eV                    | [!cite](dark2024modelling) |
| $\epsilon_r^1$ | Release energy for trap 1     | 1.15                                                        | eV                    | [!cite](dark2024modelling) |
| $\epsilon_r^2$ | Release energy for trap 2     | 1.35                                                        | eV                    | [!cite](dark2024modelling) |
| $N_1$ | Density for trap 1                          | 4.8$\times 10^{25}$                                         | atoms/m$^3$           | [!cite](dark2024modelling) |
| $N_2$ | Density for trap 2                             | 3.8$\times 10^{25}$                                         | atoms/m$^3$           | [!cite](dark2024modelling) |

## Results

[val-2f_comparison] shows the comparison of the TMAP8 calculation and the experimental data during desorption. The experimental data are provided by T. Schwarz-Selinger and are available [here](https://zenodo.org/records/11085134). The distinctive shape of the TMAP8 curve arises from the detrapping energies of trap 1 and trap 2. By including additional traps in the simulations, the TMAP8 results are expected to better align with the experimental data.

!media comparison_val-2f.py
       image_name=val-2f_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_comparison
       caption=Comparison of TMAP8 calculations with experimental data on deuterium flux (atoms/m$^2$/s) for a damage of 0.1 dpa.

[val-2f_deuterium_desorption] displays the quantities of mobile, trapped (in trap 1 and trap 2), and desorbing deuterium atoms during the desorption process. During desorption, the temperature increases from 300 K to 1000 K. The amount of deuterium trapped will decrease as the temperature rises and the various trapping energies are reached, meaning that deuterium will leave the traps, become mobile, and diffuse out. Trap 1 will release deuterium before trap 2, as its trapping energy is lower.
During desorption, no further implantation occurs, resulting in a decrease in the number of mobile and trapped deuterium atoms and an increase in the number of desorbed deuterium atoms. Mass conservation is well maintained during desorption, with only a 0.02% root mean squared percentage error (RMSPE) between the initial number of mobile and trapped deuterium atoms and the total number of deuterium atoms (mobile, trapped, and desorbed).

!media comparison_val-2f.py
       image_name=val-2f_deuterium_desorption.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_deuterium_desorption
       caption=Quantity of deuterium atoms during the desorption process.

## Input files

!style halign=left
The input file for this case can be found at [/val-2f.i]. To limit the computational costs of the test case, the test runs a version of the file with a smaller and coarser mesh, and fewer time steps. More information about the changes can be found in the test specification file for this case, namely [/val-2f/tests].
