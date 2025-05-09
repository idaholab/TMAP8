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

The general form of the governing diffusion equation for the deuterium concentration $C(x,t)$ in tungsten is given by:

\begin{equation}
    \frac{\partial C}{\partial t} = \nabla \cdot \left( D \nabla C \right) + S(x, t)
\end{equation}

The diffusion coefficient $D(T)$ follows an Arrhenius-type dependency on temperature:

\begin{equation}
    D(T) = D_0 \exp\left(-\frac{E_D}{k_B T}\right)
\end{equation}

At the surfaces, deuterium recombines into gas. It can be described by the following surface flux:

\begin{equation}
    J = 2 A K_r C^2
\end{equation}

where $J$ represents the recombination flux exiting the sample on both the left and right sides, $A$ is the area that side, and $K_r$ is the deuterium recombination coefficient. The coefficient of 2 accounts for the fact that 2 deuterium atoms combine to form one D$_2$ molecule.

The emission rate of deuterium from the sample is recorded as a function of temperature to assess how deuterium diffuses and is releases from the material. In that way, the emission rate from the sample is measured as a function of temperature.

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
| $n_t$     | Tungten density                      | 6.3222 $\times 10^{28 }$                                    | at/m$^3$              | [!cite](dark2024modelling) |

All the traps parameters are listed in [val-2f_traps_values]. The trapping and de-trapping rates (atoms/s) are $\nu_{\mathrm{t},i} = \nu_\mathrm{\mathrm{t},0}\cdot\exp(-E_{\mathrm{t},i}/(k_{\textrm B}\cdot T))$ and $\nu_{\mathrm{dt},i} = \nu_{\mathrm{dt},0}\cdot\exp(-E_{\mathrm{dt},i}/(k_{\textrm B}\cdot T))$ respectively. The trapping energy $E_{\mathrm{t},i}$ is equal to the diffusion activation energy $E_D$, and the trapping pre-factor $\nu_{\mathrm{t},i}$ is equal to the diffusion pre-factor $D_0$.

!table id=val-2f_traps_values caption=Values of traps parameters for 0.1 dpa.
| Parameter | Description                            | Value                                                       | Units                 | Reference                 |
| --------- | ------------------------------------   | ----------------------------------------------------------- | --------------------- | --------------------- |
| $\nu_{\mathrm{dt},0}$ | Traps de-trapping prefactor | $10^{13}$                                           | atoms/s               | [!cite](dark2024modelling) |
| $E_{\mathrm{dt},1}$ | Trap 1 de-trapping energy     | 1.15                                                        | eV                    | [!cite](dark2024modelling) |
| $n_1$ | Trap 1 density                             | 4.8$\times 10^{25}$                                         | atoms/m$^3$           | [!cite](dark2024modelling) |
| $E_{\mathrm{dt},2}$ | Trap 2 de-trapping energy     | 1.35                                                        | eV                    | [!cite](dark2024modelling) |
| $n_2$ | Trap 2 density                             | 3.8$\times 10^{25}$                                         | atoms/m$^3$           | [!cite](dark2024modelling) |

## Results

[val-2f_comparison] shows the comparison of the TMAP8 calculation and the experimental data during desorption. The experimental data are provided by T. Schwarz-Selinger and are available [here](https://zenodo.org/records/11085134). The distinctive shape of the TMAP8 curve arises from the detrapping energies of trap 1 and trap 2. By including additional traps in the simulations, the TMAP8 results are expected to better align with the experimental data.

!media comparison_val-2f.py
       image_name=val-2f_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_comparison
       caption=Comparison of TMAP8 calculations with experimental data on deuterium flux (atoms/m$^2$/s) for a damage of 0.1 dpa.

[val-2f_deuterium_desorption] displays the quantities of mobile, trapped, and escaping deuterium atoms during the desorption process. During desorption, the temperature increases from 300K to 1000K. The amount of deuterium trapped will decrease as the temperature rises and the various trapping energies are reached. Trap 1 will release deuterium before trap 2, as its trapping energy is smaller.

During desorption, no further implantation occurs, resulting in a decrease in the number of mobile and trapped deuterium atoms and an increase in the number of escaping deuterium atoms. Mass conservation is well maintained during desorption, with only a 0.02% error between the initial number of mobile and trapped deuterium atoms and the total number of deuterium atoms (mobile, trapped and escaping).

!media comparison_val-2f.py
       image_name=val-2f_deuterium_desorption.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_deuterium_desorption
       caption=Quantity of deuterium atoms during the desorption process.

## Input files

!style halign=left
The input file for this case can be found at [/val-2f.i]. To limit the computational costs of the test case, the test runs a version of the file with a smaller and coarser mesh, and fewer time steps. More information about the changes can be found in the test specification file for this case, namely [/val-2f/tests].
