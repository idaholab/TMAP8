# val-2f

# Modelling neutron damage effects on tritium transport in tungsten

## Test Description

The case under study involves the use of recrystallized polycrystalline tungsten (PCW) samples, which are subjected to ion irradiation and subsequent analysis using thermal desorption spectroscopy (TDS). The primary objective is to determine how damage influences deuterium trapping and release.

The TDS process is simulated using TMAP8 in a 1D tungsten sample with a thickness of 0.8 mm. The TDS simulation consisted of three phases: implantation, resting, and desorption.

During the charging phase, deuterium is continuously implanted into the tungsten sample over a period of 72 hours. The temperature is maintained at 370 K throughout this phase. The surface is exposed to a constant flux of $\phi=5.79\times 10^{19}$ atoms/m $^2$/s, corresponding to a total fluence of $1.5\times 10^{25}$ atoms/m $^2$. The implantation profile follows a Gaussian distribution centered at the mean implantation depth of $R_p=0.7$ nm, with a standard deviation of $\sigma = 0.5$ nm :

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

After the implantation phase, the system enters the cooldown phase, lasting 12 hours. During this period, the sample temperature is rapidly reduced from 370 K to 295 K. No additional deuterium is introduced during this phase, meaning the source term is set to zero.

The final stage of the simulation is the desorption phase, during which the sample is gradually heated from 300 K to 1000 K at a constant rate of $\beta = 0.05$ K/s.

The general form of the governing diffusion equation for the deuterium concentration $C(x,t)$ in tungsten is given by:

\begin{equation}
    \frac{\partial C}{\partial t} = \nabla \cdot \left( D \nabla C \right) + S(x, t)
\end{equation}

The diffusion coefficient $D(T)$ follows an Arrhenius-type dependency on temperature:

\begin{equation}
    D(T) = D_0 \exp\left(-\frac{E_D}{k_B T}\right)
\end{equation}

The emission rate of deuterium from the sample was recorded as a function of temperature to assess how deuterium diffused and was released from the material. In that way, the emission rate from the sample could be measured as a function of temperature. The sample temperature histories are shown in [val-2f_temperature_pressure_history].

!media comparison_val-2f.py
    image_name=val-2f_temperature_history.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2f_temperature_pressure_history
    caption=Pressure and temperature histories.

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
| $D_0$     | Diffusion coefficient pre-exponential factor | 1.6 $\times 10^{-7}$                                | m$^2$/s               | [!cite](dark2024modelling) |
| $E_D$     | Activation energy for deuterium diffusion      | 0.28                                              | eV                    | [!cite](dark2024modelling) |
| $R_p$     | Mean implantation depth              | 0.7                                                         | nm                    | [!cite](dark2024modelling) |
| $\sigma$  | Standard deviation of implantation profile | 0.5                                                   | nm                    | [!cite](dark2024modelling) |
| $\Phi$    | Incident fluence                     | 1.5 $\times 10^{25}$                                        | atoms/m$^2$           | [!cite](dark2024modelling) |
| $\phi$    | Incident flux                        | 5.79 $\times 10^{19}$                                       | atoms/m$^2$/s         | [!cite](dark2024modelling) |
| $l_W$     | Length of the tungsten sample        | 0.8                                                         | mm                    | [!cite](dark2024modelling) |



## Results

!media comparison_val-2f.py
       image_name=val-2f_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_comparison
       caption=Comparison of TMAP8 calculation with the experimental data on the deuterium flux (atoms/m$^2$/s).

## Input files

!style halign=left
The input file for this case can be found at [/val-2f.i].
To achieve short regression tests (under 2 seconds walltime), the tests in [/val-2f/tests] run a version of the files with a shorter history, looser tolerance, and larger time step. More information about the changes can be found in the test specification file for this case, namely [/ver-1d/tests].
