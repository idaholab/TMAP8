# val-2f

# Modelling self-damaged tungsten effects on deuterium transport

## Case Description

The case being used for validation here involves the use of recrystallized polycrystalline tungsten (PCW) samples, which are subjected to ion irradiation and subsequent analysis using thermal desorption spectroscopy (TDS). The primary objective is to determine how damage influences deuterium trapping and release. This case is drawn and updated from [!cite](dark2024modelling).

The TDS process is simulated using TMAP8 in a 1D tungsten sample with a thickness of 0.8 mm. The TDS simulation consisted of three phases: implantation, cooldown, and desorption.

The sample temperature histories are shown in [val-2f_temperature_history].

!media comparison_val-2f.py
    image_name=val-2f_temperature_history.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2f_temperature_history
    caption=Temperature history.

## Model Description

### 1- Implantation phase:

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

### 2- Cooldown phase:

After the implantation phase, the system enters the cooldown phase, lasting 12 hours. During this period, the sample temperature is rapidly reduced from 370 K to 295 K. No additional deuterium is introduced during this phase, meaning the source term is set to zero.

### 3- Desorption phase:

The final stage of the simulation is the desorption phase, during which the sample is gradually heated from 300 K to 1000 K at a constant rate of $\beta = 0.05$ K/s.

## Governing equations

### • Model description for bulk behavior

The model for the bulk behavior is equivalent to the one presented in [!cite](dark2024modelling). The main difference resides in the description of the surface recombination, which is described in the next section.
The general form of the transport equations for the deuterium in tungsten is given by

\begin{equation}
    \label{eq:mobile_transport_equations}
    \frac{\partial C_M}{\partial t} = \nabla D \nabla C_M + S + r_{T/M} \cdot \sum_{i=1}^{6} \frac{\partial C_{T_i}}{\partial t},
\end{equation}

and, for $i \in [1,6]$ representing the trapping sites,

\begin{equation}
    \label{eq:trapped_differential_equations}
    \frac{\partial C_{T_i}}{\partial t} = \alpha_t^i  \frac {C_{T_i}^{empty} C_M } {(N \cdot r_{T/M})} - \alpha_r^i C_{T_i},
\end{equation}

where $C_M$ is the concentration of mobile tritium, $t$ is the time, and $D$ is the deuterium diffusivity in tungsten, which is defined as

\begin{equation}
    \label{eq:diffusivity}
    D = D_{0} \exp \left( - \frac{E_{D}}{k_b T} \right),
\end{equation}

where $E_{D}$ is the diffusion activation energy, $T$ is the temperature, and $D_{0}$ is the maximum diffusivity coefficient. In [eq:mobile_transport_equations], $S$ is the tritium source term in the sample due to the deuterium implantation (see [eq:source_term]), $C_{T_i}$ is the concentration of trapped species in trap $i$, and $r_{T/M}$ is a factor scaling $C_{T_i}$ to be closer to $C_M$ for better numerical convergence. In [eq:trapped_differential_equations], $\alpha_t^i$ and $\alpha_r^i$ are the trapping and release rate coefficients for trap $i$, respectively, $N$ is the host density, and $C_{T_i}^{empty}$ is the concentration of empty trapping sites, defined as

\begin{equation}
    C_{T_i}^{empty} = C_{{T_i}0} \cdot N - r_{T/M} \cdot C_{T_i},
\end{equation}

with $C_{{T_i}0}$ is the fraction of host sites $i$ that can contribute to trapping. The trapping and release rates $\alpha_t^i$ and $\alpha_r^i$ are defined as
\begin{equation}
    \label{eq:trapping}
    \alpha_t^i = \alpha_{t0}^i \exp(-\epsilon_t^i / T),
\end{equation}

and

\begin{equation}
    \label{eq:release}
    \alpha_r^i = \alpha_{r0}^i \exp(-\epsilon_r^i / T),
\end{equation}

where $\alpha_{t0}^i$ and $\alpha_{r0}^i$ are the pre-exponential factors of trapping and release. The trapping energy $\epsilon_t^i$ is equal to the diffusion activation energy $E_D$.

The evolution of the trapping site density, $N_i$, over time under irradiation is described in [!cite](dark2024modelling):

\begin{equation}
    \label{eq:ODE_trapping_sites}
    \frac{\partial N_i}{\partial t} = \Phi \cdot K_c \left[ 1 - \frac{N_i}{N_{\text{max,}\Phi}} \right] - A \cdot N_i.
\end{equation}

This equation consists of two terms. The first term, $\Phi \cdot K_c \left[ 1 - \frac{N_i}{n_{\text{max}, \Phi}} \right]$, represents the creation of trapping sites. It increases the trap density up to a saturation density, $N_{\text{max,}\Phi}$, due to the damage imposed on the sample. Here, $\Phi$ is the damage rate in (dpa/s) and $K_c$ is the trap creation factor in (traps/m$^3$/dpa).
The second term, $A \cdot N_i$, accounts for the annealing effect which decreases the density of trapping sites. $A$ is the trap annealing rate in (1/s) and follows an Arrhenius law given by

\begin{equation}
    \label{eq:trapping_sites_annealing_rate}
    A = A_0 \exp\left(\frac{-E_A}{k_B T}\right),
\end{equation}

where $A_0$ is a pre-exponential factor, $E_A$ is the activation energy, $k_B$ is the Boltzmann constant, and $T$ is the temperature.
The parameters for the evolution of the irradiation-induced traps are provided in [!cite](dark2024modelling) and reproduced in [damaged_induced_traps].
The analytical solution for the ODE is given by [!cite](dark2024modelling) as:

\begin{equation}
    \label{eq:analytical_sol_trapping_sites}
    N_i(t) = \frac{\Phi K_c}{\frac{\Phi K_c}{N_{\text{max}, \Phi}} + A} \left[ 1 - \exp\left(-\left(\frac{\Phi K_c}{N_{\text{max}, \Phi}} + A\right)t\right) \right].
\end{equation}

For the radiation-induced traps, the spatial distribution of available trap sites follows a sigmoidal function centered at a characteristic depth, representing damage profiles observed in self-irradiated tungsten:

\begin{equation}
\label{eq:trap_distribution_function}
C_{{T_i}0}(x,t) = \frac{N_i(t)}{N} \cdot\frac{1}{1 + \exp\left(\frac{x - x_c}{w}\right)},
\end{equation}

where $N$ is the tungsten density, $x_c$ is the center of the damage profile and $w$ characterizes the width of the distribution.

### • Model description for surface behavior

There are several ways to model the surface behavior of deuterium, and this study tested two options. One can assume that every deuterium atom at the surface is immediately desorbed from the materials, effectively assuming an infinite recombination rate at the surface and imposing a null Dirichlet boundary condition for the mobile deuterium concentration ($C_M = 0$ atoms/m$^3$). This is the assumption used in [!cite](dark2024modelling).

However, it is also possible to capture the finite rate of deuterium recombination at the surface as it recombines into gas. It can be described by the surface flux

\begin{equation}
    \label{eq:surface_flux}
    J = 2 A K_r C^2
\end{equation}

to describe the recombination of two deuterium atoms into a molecule. In [eq:surface_flux], $J$ represents the recombination flux exiting the sample on both the left and right sides, $A$ is the surface area, and $K_r$ is the deuterium recombination coefficient. The coefficient of 2 accounts for the fact that two deuterium atoms combine to form one D$_2$ molecule. Using this condition, the surface concentration will not be imposed, but be governed by the concentration of deuterium coming to the surface from the bulk and the rate of recombination.

## Case and Model Parameters

This section provides the model parameters for this validation case. [set_up_values] provides the parameters related to the set up of the validation case. In [damaged_induced_traps], we list the parameters related to the damage-induced traps defined in [eq:analytical_sol_trapping_sites], and [val-2f_trap_induced_density] illustrates the analytical evolution of trap densities over the damage range from 0 to 3 dpa. [analytical_trap_densities] presents the trap density values at 0.1 dpa for each trap. [traps_values] summarizes the fitted parameter values used in [!cite](dark2024modelling) to reproduce the TDS experimental data at 0.1 dpa. Notably, it includes the fitted trap densities, which differ from the analytical values in [analytical_trap_densities]. This distinction is also highlighted in [val-2f_trap_induced_density], where the fitted trap densities are shown as discrete data points.

!table id=set_up_values caption=Parameter values for sample history.
| Parameter                 | Description                        | Value                     | Units            | Reference                      |
|---------------------------|------------------------------------|---------------------------|------------------|--------------------------------|
| $k_B$                     | Boltzmann constant                 | $1.380649 \times 10^{-23}$ | J/K             | [PhysicalConstants.h](https://physics.nist.gov/cgi-bin/cuu/Value?r)          |
| $T_{\text{initial}}$      | Initial temperature                | 370                       | K                | [!cite](dark2024modelling)       |
| $T_{\text{cooldown}}$     | Cooldown temperature               | 295                       | K                | [!cite](dark2024modelling)       |
| $T_{\text{desorption,min}}$ | Desorption start temperature     | 300                       | K                | [!cite](dark2024modelling)       |
| $T_{\text{desorption,max}}$ | Desorption end temperature       | 1000                      | K                | [!cite](dark2024modelling)       |
| $\beta$                   | Desorption heating rate            | 0.05                      | K/s              | [!cite](dark2024modelling)       |
| t$_{\text{charge}}$       | Charging time                      | 72                        | h                | [!cite](dark2024modelling)       |
| t$_{\text{cooldown}}$     | Cooldown duration                  | 12                        | h                | [!cite](dark2024modelling)       |
| $R_p$                     | Mean implantation depth            | 0.7                       | nm               | [!cite](dark2024modelling)       |
| $\sigma$                  | Standard deviation of implantation profile | 0.5               | nm               | [!cite](dark2024modelling)       |
| $\Phi_D$                  | Incident fluence                   | $1.5 \times 10^{25}$      | atoms/m$^2$      | [!cite](dark2024modelling)       |
| $\phi_D$                  | Incident flux                      | $5.79 \times 10^{19}$     | atoms/m$^2$/s    | [!cite](dark2024modelling)       |
| $l_W$                     | Length of tungsten sample          | 0.8                       | mm               | [!cite](dark2024modelling)       |
| $N$                       | Tungsten density                   | $6.3222 \times 10^{28}$   | at/m$^3$         | [!cite](schwarz-selinger)        |
| $x_c$                     | Center of the damage distribution  | $2.5$                     | $\mu$m           | [!cite](schwarz-selinger)        |
| $w$                       | Width of the damage distribution   | $0.5$                     | $\mu$m           | [!cite](schwarz-selinger)        |

!table id=damaged_induced_traps caption=Damaged-induced traps parameters from [!cite](dark2024modelling) used in [eq:ODE_trapping_sites] to capture the evolution of trap properties with irradiation.
| Trap   | $\Phi$ (dpa/s)         | $K_c$ (traps/m$^3$/dpa)       | $N_{\max,\Phi}$ (atoms/m$^3$) | $A_0$ (1/s)            | $E_A$ (eV) | $T$ (K) |
|--------|------------------------|-------------------------------|-------------------------------|------------------------|------------|---------|
| Trap 1 | $8.9 \times 10^{-5}$   | $9.0 \times 10^{26}$          | $6.9 \times 10^{25}$          | $6.18 \times 10^{-3}$  | 0.24       | 800     |
| Trap 2 | $8.9 \times 10^{-5}$   | $4.2 \times 10^{26}$          | $7.0 \times 10^{25}$          | $6.18 \times 10^{-3}$  | 0.24       | 800     |
| Trap 3 | $8.9 \times 10^{-5}$   | $2.5 \times 10^{26}$          | $6.0 \times 10^{25}$          | $6.18 \times 10^{-3}$  | 0.30       | 800     |
| Trap 4 | $8.9 \times 10^{-5}$   | $5.0 \times 10^{26}$          | $4.7 \times 10^{25}$          | $6.18 \times 10^{-3}$  | 0.30       | 800     |
| Trap 5 | $8.9 \times 10^{-5}$   | $1.0 \times 10^{26}$          | $2.0 \times 10^{25}$          | 0                      | -          | 800     |

!table id=analytical_trap_densities caption=Analytical values of traps densities for 0.1 dpa from [eq:analytical_sol_trapping_sites].
| Parameter          | Description        | Value                   | Units        | Reference                          |
|--------------------|--------------------|-------------------------|--------------|----------------------------------- |
| $N_{1,analytical}$ | Density for trap 1 | $4.63 \times 10^{25}$   | atoms/m$^3$  | [eq:analytical_sol_trapping_sites] |
| $N_{2,analytical}$ | Density for trap 2 | $2.87 \times 10^{25}$   | atoms/m$^3$  | [eq:analytical_sol_trapping_sites] |
| $N_{3,analytical}$ | Density for trap 3 | $1.96 \times 10^{25}$   | atoms/m$^3$  | [eq:analytical_sol_trapping_sites] |
| $N_{4,analytical}$ | Density for trap 4 | $2.97 \times 10^{25}$   | atoms/m$^3$  | [eq:analytical_sol_trapping_sites] |
| $N_{5,analytical}$ | Density for trap 5 | $7.87 \times 10^{24}$   | atoms/m$^3$  | [eq:analytical_sol_trapping_sites] |

!media comparison_val-2f.py
       image_name=val-2f_trap_induced_density.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_trap_induced_density
       caption=Trap densities as a function of damage. The analytical solutions are represented by the solid curve, while the points indicate the fitted values used in [!cite](dark2024modelling) at 0.1 dpa.

!table id=traps_values caption=Calibrated values of traps parameters for 0.1 dpa from [!cite](dark2024modelling) to match the experimental desorption data.
| Parameter            | Description                         | Value                         | Units         | Reference                   |
|----------------------|-------------------------------------|-------------------------------|---------------|-----------------------------|
| $D_0$                | Diffusion pre-factor                | $1.60 \times 10^{-7}$         | m$^2$/s       | [!cite](holzner2020solute)    |
| $E_a$                | Diffusion energy                    | 0.28                          | eV            | [!cite](holzner2020solute)    |
| $\alpha_{t0}^i$      | Pre-factor of trapping rate coefficient | $\frac{D_0}{6(1.1 \times 10^{-10})^2}$ | atoms/s | [!cite](schwarz-selinger) |
| $\alpha_{r0}^i$      | Pre-factor of release rate coefficient | $10^{13}$                      | atoms/s   | [!cite](schwarz-selinger)     |
| $\epsilon_t^i$       | Trapping energy for all traps       | $\frac{D_0}{k_B}$             | eV            | [!cite](dark2024modelling)    |
| $\epsilon_r^1$       | Release energy for trap 1           | 1.15                          | eV            | [!cite](dark2024modelling)    |
| $\epsilon_r^2$       | Release energy for trap 2           | 1.35                          | eV            | [!cite](dark2024modelling)    |
| $\epsilon_r^3$       | Release energy for trap 3           | 1.65                          | eV            | [!cite](dark2024modelling)    |
| $\epsilon_r^4$       | Release energy for trap 4           | 1.85                          | eV            | [!cite](dark2024modelling)    |
| $\epsilon_r^5$       | Release energy for trap 5           | 2.05                          | eV            | [!cite](dark2024modelling)    |
| $\epsilon_r^6$       | Release energy for intrinsic trap   | 1.04                          | eV            | [!cite](dark2024modelling)    |
| $N_1$                | Density for trap 1                  | $4.8 \times 10^{25}$          | atoms/m$^3$   | [!cite](schwarz-selinger)     |
| $N_2$                | Density for trap 2                  | $3.8 \times 10^{25}$          | atoms/m$^3$   | [!cite](schwarz-selinger)     |
| $N_3$                | Density for trap 3                  | $2.6 \times 10^{25}$          | atoms/m$^3$   | [!cite](schwarz-selinger)     |
| $N_4$                | Density for trap 4                  | $3.6 \times 10^{25}$          | atoms/m$^3$   | [!cite](schwarz-selinger)     |
| $N_5$                | Density for trap 5                  | $1.1 \times 10^{25}$          | atoms/m$^3$   | [!cite](schwarz-selinger)     |
| $N_6$                | Density for intrinsic trap          | $2.4 \times 10^{22}$          | atoms/m$^3$   | [!cite](dark2024modelling)    |

We use two different approaches for the description of the surface recombination rates. We first impose $C_M = 0$ atoms/m$^3$ to reproduce the results from [!cite](dark2024modelling). However, we also capture the finite kinetics of surface reaction using the recombination rate from [!cite](zhao2020deuterium). Then, we calibrate the full model including surface recombination kinetics. This optimization effort is designed to span the wide range of diffusion and recombination coefficients found in the literature, in order to identify the values that best reproduce the experimental data.

The recombination rate reported in the literature ([!cite](ogorodnikova2019recombination, lee2011ion, anderl1992deuterium, liu2019low, zhao2020deuterium, takagi2011deuterium)) are summarized in [recombination_rates] and illustrated in [deuterium_recombination_literature], and are used in the calibration. In [deuterium_recombination_literature], the upper and lower envelope lines provide calibration bounds that encompass these values. Although the value reported by [!cite](ogorodnikova2019recombination) are mostly within the proposed envelope, the energy barrier published by [!cite](ogorodnikova2019recombination), an outlier, has not been included in the calibration. The variability in the recombination coefficients can be attributed to differences in the surface properties of the tungsten used in the various studies---for instance, surface roughness or purity---which can significantly influence both the pre-factor and the activation energy.

!table id=recombination_rates caption=Recombination coefficient parameters from various literature sources.
| Pre-factor $K_0$ (m$^4$/at/s) | Activation Energy $E_a$ (eV) | Temperature range (K) | Reference                              |
|-------------------------------|------------------------------|-----------------------|--------------------------------------- |
| $6.9 \times 10^{-27}$         | $-1.12$                      | 800--1000             | [!cite](pick1985model)                 |
| $1.0 \times 10^{-16}$         | $0.90$                       | 800--909              | [!cite](pick1985model)                 |
| $3.2 \times 10^{-15}$         | $1.16$                       | 625--833              | [!cite](anderl1992deuterium)           |
| $6.9 \times 10^{-26}$         | $-0.54$                      | 800--1000             | [!cite](liu2019low)                    |
| $3.8 \times 10^{-26}$         | $0.15$                       | 741--1176             | pristine [!cite](zhao2020deuterium)    |
| $3.8 \times 10^{-26}$         | $0.34$                       | 741--1176             | clean [!cite](zhao2020deuterium)       |
| $4.5 \times 10^{-25}$         | $0.78$                       | 426--654              | [!cite](takagi2011deuterium)           |
| $3.0 \times 10^{-25}$         | $-2.06$                      | 455--1111             | [!cite](ogorodnikova2019recombination) |

!alert warning title=Typo in formula from [!cite](zhao2020deuterium)
There is a typo in the expression for the deuterium recombination coefficient for clean tungsten surfaces from [!cite](zhao2020deuterium) where the minus sign in the exponential is missing, even though the data shows it should be present. Consequently, we used the corrected value in our simulations, which includes the minus sign.

!media comparison_val-2f.py
       image_name=val-2f_recombination_literature.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=deuterium_recombination_literature
       caption=Recombination coefficients from the literature ([!cite](ogorodnikova2019recombination, lee2011ion, anderl1992deuterium, liu2019low, zhao2020deuterium, takagi2011deuterium)) and envelope for calibration.

[deuterium_diffusion_literature] presents a range of diffusion coefficient values reported in the literature (see [!cite](boda2020diffusion, frauenfelder1969solution, holzner2020solute, ahlgren2016concentration, heinola2010first, grigorev2015interaction, ikeda2011application, alimov2022deuterium)). The upper and lower envelope curves provide calibration bounds that encompass these values. The value reported by [!cite](alimov2022deuterium) has not been included in the calibration since it significantly differs from other studies. The corresponding values are compiled in [diffusion_coefficients].

!media comparison_val-2f.py
       image_name=val-2f_deuterium_diffusion_literature.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=deuterium_diffusion_literature
       caption=Diffusion coefficients in the literature ([!cite](boda2020diffusion, frauenfelder1969solution, holzner2020solute, ahlgren2016concentration, heinola2010first, grigorev2015interaction, ikeda2011application, alimov2022deuterium)). Upper and lower envelopes include the different diffusion coefficients values.

!table id=diffusion_coefficients caption=Diffusion coefficient parameters for hydrogen and deuterium in tungsten from various literature sources.
| Pre-factor $D_0$ (m$^2$/s)   | Activation Energy $E_a$ (eV) | Temperature Range (K) | Reference                         |
|------------------------------|------------------------------|-----------------------|---------------------------------- |
| $1.86 \times 10^{-7}$        | $0.193$                      | 200--2000             | [!cite](boda2020diffusion)        |
| $4.10 \times 10^{-7}$        | $0.39$                       | 1000--2600            | [!cite](frauenfelder1969solution) |
| $1.60 \times 10^{-7}$        | $0.28$                       | 1600--2600            | [!cite](holzner2020solute)        |
| $1.12 \times 10^{-7}$        | $0.25$                       | 300--1500             | [!cite](ahlgren2016concentration) |
| $4.80 \times 10^{-8}$        | $0.26$                       | 138--2600             | [!cite](heinola2010first)         |
| $9.33 \times 10^{-9}$        | $0.23$                       | 300--1500             | [!cite](grigorev2015interaction)  |
| $3.80 \times 10^{-7}$        | $0.4126$                     | 308--343              | [!cite](ikeda2011application)     |
| $2.50 \times 10^{-3}$        | $1.12$                       | 323--813              | [!cite](alimov2022deuterium)      |

## Results

The figures below show the comparison of the TMAP8 calculation and the experimental data during desorption. The experimental data are provided by T. Schwarz-Selinger and are available [here](https://zenodo.org/records/11085134).

### Reproducing Dark et al. with infinite recombination rate

We first reproduce the results from [!cite](dark2024modelling) using a null Dirichlet boundary condition for the concentration at the surface and using the calibrated trapping properties from [traps_values]. The diffusion coefficients used in this case are taken from [!cite](holzner2020solute).

[val-2f_deuterium_desorption_inf_recombination] displays the quantities of mobile, trapped, and desorbing deuterium atoms during the desorption process. During desorption, the temperature increases from 300 K to 1000 K. The amount of deuterium trapped will decrease as the temperature rises and the various trapping energies are reached, meaning that deuterium will leave the traps, become mobile, and diffuse out. During desorption, no further implantation occurs, resulting in a decrease in the number of mobile and trapped deuterium atoms and an increase in the number of desorbed deuterium atoms.

Mass conservation in [val-2f_deuterium_desorption_inf_recombination] is maintained during desorption, with a 0.01 % root mean squared percentage error (RMSPE) between the initial number of mobile and trapped deuterium atoms at the beginning of the desorption, and the total number of deuterium atoms (mobile, trapped, and desorbed). TMAP8 tracks the deuterium content in each trap and we can observe each trapping sites desorbing deuterium as temperature increases.

[val-2f_comparison_inf_recombination] shows a good alignment with the experimental data and the results presented in [!cite](dark2024modelling), as expected. With an infinite recombination rate, the amount of mobile deuterium is minimal compared to the trapped deuterium, as demonstrated in [val-2f_deuterium_desorption_inf_recombination]. Consequently, the desorbed deuterium flux is almost solely due to the deuterium desorbing from the traps.

!media comparison_val-2f.py
       image_name=val-2f_deuterium_desorption_inf_recombination.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_deuterium_desorption_inf_recombination
       caption=Quantity of deuterium atoms during the desorption process for an infinite recombination rate and calibrated trapping properties.

!media comparison_val-2f.py
       image_name=val-2f_comparison_inf_recombination.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_comparison_inf_recombination
       caption=Comparison of TMAP8 calculations with experimental data on deuterium flux (atoms/m$^2$/s) for a damage of 0.1 dpa, an infinite recombination rate and calibrated trapping properties.

### Finite recombination rate

In this section, the deuterium recombination rate is set to a finite value, in contrast to the infinite recombination rate assumed in the previous section, while everything else remains the same. The chosen recombination coefficient is based on the value from [!cite](zhao2020deuterium) for a clean tungsten surface. Meanwhile, the trap densities used here are the same as the previous case with the calibrated trapping properties from [traps_values], and the diffusion coefficients are taken from [!cite](holzner2020solute), as in the previous case. Given the low recombination rate (especially compared to an infinite one), the overall deuterium content in the sample at the start of desorption is much higher than in [val-2f_deuterium_desorption_inf_recombination], as expected. This higher content results in a significant fraction of the implanted deuterium remaining in a mobile state. This behavior is clearly observed in [val-2f_deuterium_desorption].

As the temperature increases during the desorption phase, the majority of the deuterium released from the sample corresponds to mobile deuterium, giving rise to the rapid first desorption peak shown in [val-2f_comparison]. However, as illustrated in [val-2f_comparison], introducing a finite recombination rate without updating the rest of the model substantially alters the simulation outcome, leading to poor agreement with the experimental data. The trapped deuterium remains trapped at much higher temperatures due to the lower recombination kinetics and resulting increased overall deuterium content. Since the diffusion coefficients, trapping and detrapping energies, and calibrated trap densities are identical to those used by [!cite](dark2024modelling), the introduction of a finite recombination rate is shown to have a significant impact on the model prediction. The model parameters therefore need to be re-calibrated in the context of the new model including the recombination rate. Consequently, a calibration of the physical parameters—summarized in [traps_values], [recombination_rates] and [diffusion_coefficients]—will be undertaken in the next section to achieve better alignment with the experimental results.

!media comparison_val-2f.py
       image_name=val-2f_deuterium_desorption.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_deuterium_desorption
       caption=Quantity of deuterium atoms during the desorption process for an adapted recombination rate and uncalibrated trapping properties.

!media comparison_val-2f.py
       image_name=val-2f_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_comparison
       caption=Comparison of TMAP8 calculations with experimental data on deuterium flux (atoms/m$^2$/s) for a damage of 0.1 dpa, an adapted recombination rate and uncalibrated trapping properties.

### Calibration - single objective with 0.1 dpa

In this section, we present the calibration results for tungsten exposed to 0.1 dpa of damage, obtained using the PSS method. [pss_inputs] displays the evolution of six arbitrarily selected parameters out of the 27 total model parameters throughout the PSS calibration process. Each trace corresponds to the value of a single parameter across iterations, illustrating how the sampling progressively concentrates within narrower regions of the parameter space as the algorithm advances. For certain parameters---such as the release energy of trap 4---convergence is achieved after approximately 60,000 iterations. However, other parameters remain confined near local maxima of the objective function. Achieving full convergence across all parameters, corresponding to the identification of a global maximum, is expected to require a greater number of iterations.

!media val-2f_PSS_study.py
       image_name=val-2f_pss_selected_inputs.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=pss_inputs
       caption=Evolution of six selected model parameters out of the 27 during the PSS calibration at 0.1 dpa.

In [calibrated_diffusion] and [calibrated_recombination], the calibrated diffusion and recombination coefficients at 0.1 dpa are compared against literature data. Both fitted values lie within the predefined upper and lower envelopes, indicating physical consistency with previously reported ranges. In [calibrated_densities], the calibrated trap densities at 0.1 dpa are compared to the analytical predictions (solid curves, from [eq:analytical_sol_trapping_sites]) as well as to the values used in the infinite recombination case from [!cite](dark2024modelling) (shaded markers). Finally, [calibrated_detrapping_energy] presents the calibrated release energies for all traps (vertical lines), alongside the normalized mean value corresponding to the values used in [!cite](dark2024modelling).

!media comparison_val-2f.py
       image_name=val-2f_deuterium_diffusion_literature_PSS.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=calibrated_diffusion
       caption=Calibrated diffusion coefficients at 0.1 dpa obtained using PSS, compared with values reported in the literature.

!media comparison_val-2f.py
       image_name=val-2f_recombination_literature_PSS.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=calibrated_recombination
       caption=Calibrated recombination coefficients at 0.1 dpa obtained using PSS, compared with values reported in the literature.

!media comparison_val-2f.py
       image_name=val-2f_trap_induced_density_PSS.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=calibrated_densities
       caption=Calibrated trap density values at 0.1 dpa obtained using PSS (non-transparent dots), compared with the analytical solution (solid lines) and the trap densities (transparent dots) adopted in the infinite recombination case from [!cite](dark2024modelling).

!media val-2f_trapping_optimization_inputs_PSS.py
       image_name=val-2f_trapping_inputs_detrapping_energy.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=calibrated_detrapping_energy
       caption=Calibrated release energies for all traps at 0.1 dpa obtained using PSS. The overlaid Gaussian curve represents the normalized distribution of the parameters exploration during PSS, centered around the reference values of the trapping energies from [!cite](dark2024modelling). The vertical lines indicate the calibrated values obtained through PSS, showing departure from nominal value.

[pss_output] tracks the evolution of the objective function throughout the PSS process. The stepwise increase in the objective value reflects the progressive refinement of the sampled parameter space toward regions that yield better agreement with experimental data. Each plateau corresponds to a completed subset stage, after which new MCMC chains are launched from the best-performing samples. After 60,000 iterations, the objective function reaches a plateau, indicating reasonable convergence and a good fit.
While it is possible that another plateau could be found later, the PSS approach has effectively zoned in on calibrated input parameters, making it unlikely to find a significantly better fit. Therefore, while this may not be the absolute maximum, the current solution is sufficiently optimized.

!media val-2f_PSS_study.py
       image_name=val-2f_pss_output.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=pss_output
       caption=Evolution of the objective function during the PSS calibration at 0.1 dpa.

The final optimized values for all model parameters are summarized in [pss_optimized_params], and the corresponding model predictions are presented in [deuterium_desorption_calibrated] and [comparison_pss]. In [deuterium_desorption_calibrated], the use of a finite surface recombination rate enables the presence of mobile deuterium during thermal desorption, in contrast to the infinite recombination rate case shown in [val-2f_deuterium_desorption_inf_recombination], where trapped deuterium is released directly at the surface without a significant mobile concentration. Compared to [val-2f_deuterium_desorption] (i.e., uncalibrated model with finite recombination kinetics), the amount of mobile deuterium is reduced due to the calibration of surface recombination parameters, and the distribution of deuterium among the traps has changed following the calibration of trap densities.

[comparison_pss] shows that the calibrated model incorporating a finite recombination rate not only captures more realistic surface physics but also yields better agreement with the experimental data. The RMSPE improves from 12.23 % in the infinite recombination case to 10.98 % with the calibrated finite-rate model. The result from the infinite recombination model is included as a dashed line for reference.

!table id=pss_optimized_params caption=Optimized model parameters obtained from the PSS calibration at 0.1 dpa. The table includes values for diffusion coefficients, trap site characteristics, and recombination rates.
| Parameter            | Description                           | Value                      | Units              |
|----------------------|---------------------------------------|----------------------------|--------------------|
| $D_0$                | Diffusion prefactor                   | $1.6 \times 10^{-6.95}$    | m$^2$/s            |
| $E_a^\text{\, diffusion}$ | Diffusion activation energy      | 0.424                      | eV                 |
| $K_0$                | Surface recombination prefactor       | $3.8 \times 10^{-23.7}$    | m$^4$/at/s         |
| $E_a^\text{\, recombination}$ | Surface recombination activation energy | -0.056          | eV                 |
| $\alpha_{r0}^i$      | Pre-factor of the release rate coefficient | 9.985 $\times 10^{12}$  | atoms/s            |
| $A_0$                | Pre-factor of the trap annealing rate | 0.0071                     | 1/s                |
| $\epsilon_r^1$       | Release energy for trap 1             | 13426                      | eV                 |
| $K_c^1$              | Trap creation factor for trap 1       | 9.548 $\times 10^{26}$     | traps/m$^3$/dpa    |
| $N_{\max,\Phi}^1$    | Saturation density for trap 1         | 8.2 $\times 10^{25}$       | atoms/m$^3$        |
| $E_A^1$              | Annealing energy for trap 1           | 0.254                      | eV                 |
| $\epsilon_r^2$       | Release energy for trap 2             | 15796                      | eV                 |
| $K_c^2$              | Trap creation factor for trap 2       | 4.811 $\times 10^{26}$     | traps/m$^3$/dpa    |
| $N_{\max,\Phi}^2$    | Saturation density for trap 2         | 6.799 $\times 10^{25}$     | atoms/m$^3$        |
| $E_A^2$              | Annealing energy for trap 2           | 0.256                      | eV                 |
| $\epsilon_r^3$       | Release energy for trap 3             | 19712                      | eV                 |
| $K_c^3$              | Trap creation factor for trap 3       | 3.089 $\times 10^{26}$     | traps/m$^3$/dpa    |
| $N_{\max,\Phi}^3$    | Saturation density for trap 3         | 6.603 $\times 10^{25}$     | atoms/m$^3$        |
| $E_A^3$              | Annealing energy for trap 3           | 0.312                      | eV                 |
| $\epsilon_r^4$       | Release energy for trap 4             | 21992                      | eV                 |
| $K_c^4$              | Trap creation factor for trap 4       | 5.470 $\times 10^{26}$     | traps/m$^3$/dpa    |
| $N_{\max,\Phi}^4$    | Saturation density for trap 4         | 4.423 $\times 10^{25}$     | atoms/m$^3$        |
| $E_A^4$              | Annealing energy for trap 4           | 0.295                      | eV                 |
| $\epsilon_r^5$       | Release energy for trap 5             | 21617                      | eV                 |
| $K_c^5$              | Trap creation factor for trap 5       | 1.031 $\times 10^{26}$     | traps/m$^3$/dpa    |
| $N_{\max,\Phi}^5$    | Saturation density for trap 5         | 2.004 $\times 10^{25}$     | atoms/m$^3$        |
| $\epsilon_r^6$       | Release energy for intrinsic trap     | 13619                      | eV                 |
| $N_6$                | Density for intrinsic trap            | 25268                      | atoms/m$^3$        |

!media comparison_val-2f.py
       image_name=val-2f_deuterium_desorption_PSS.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=deuterium_desorption_calibrated
       caption=Quantity of deuterium atoms during the desorption process for the PSS-calibrated model with a finite recombination rate at 0.1 dpa.

!media comparison_val-2f.py
       image_name=val-2f_comparison_overlay.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=comparison_pss
       caption=Comparison of TMAP8 calculations with the PSS-calibrated model with a finite recombination rate against experimental data on deuterium flux (atoms/m$^2$/s) for a damage of 0.1 dpa. For comparison, the calibrated results obtained using an infinite recombination rate (as shown in [val-2f_comparison_inf_recombination]) are included as dashed lines. The new model is more physical (finite recombination kinetics) and compares better to the experiment.

## Input files

!style halign=left
To minimize the length of the input file and organize it, it is divided into several parts:

- [/val-2f.params] lists the key values and model parameters used in this simulation
- [/val-2f_base.i] provides the common structure for both the finite and the infinite recombination cases
- [/val-2f_finite_recombination.params] provides the recombination parameter values and the traps parameters for the finite recombination case
- [/val-2f.i] provides the structure for the finite recombination case
- [/val-2f_infinite_recombination.params] provides the traps parameters for the infinite recombination case
- [/val-2f_infinite_recombination.i] provides the structure for the infinite recombination case
- [/val-2f_trapping_intrinsic.i] provides the blocks necessary to introduce the intrinsic traps in the simulation
- [/val-2f_trapping_1.i], [/val-2f_trapping_2.i], [/val-2f_trapping_3.i], [/val-2f_trapping_4.i], [/val-2f_trapping_5.i] provide the blocks necessary to introduce the trapping sites 1, 2, 3, 4, and 5, respectively, in the simulation.
- [/val-2f_pss.i] adds key blocks to the val-2f_base.i input file for the PSS optimization
- [/val-2f_pss_sub.i] is the subfile for the PSS optimization
- [/val-2f_pss_main.params] provides the parameters distributions for the PSS optimization
- [/val-2f_pss_main.i] is the Parallel Subset Simulation file for val-2f

Depending on your intended use, there are several possible cases:

- To simulate the infinite recombination case, run [/val-2f_infinite_recombination.i]
- To simulate the finite recombination case using the same trap and diffusion parameters as the infinite recombination case, run [/val-2f.i]. The only difference is the introduction of finite recombination coefficient
- To optimize the model parameters using PSS in order to fit the experimental data, run [/val-2f_pss_main.i]

[/val-2f.i], [/val-2f_infinite_recombination.i] and [/val-2f_pss_main.i] use the `!include` feature to combine several input and parameters files into one input file.

[/val-2f/tests] uses `cli_args` to modify [/val-2f.i] for a lightweight test of the finite recombination case, and to adapt[/val-2f_pss_main.i] for a single-subset, single-sample PSS optimization.

To limit the computational costs of the test case, the test runs a version of the file with a smaller and coarser mesh, and fewer time steps. More information about the changes can be found in the test specification file for this case, namely [/val-2f/tests].
