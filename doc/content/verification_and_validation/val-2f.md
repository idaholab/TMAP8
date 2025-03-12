# val-2f

# Modelling neutron damage effects on tritium transport in tungsten

## Test Description

The case under study involves the use of polished beryllium wafers, each 0.4 mm thick and with a surface area of 104 mm$^2$.
The primary focus of the experiment is to analyze how deuterium interacts with beryllium under controlled thermal conditions.

During the deuterium charging phase, the sample is exposed to 13.3 kPa of deuterium gas (D$_2$) at a temperature of 773 K for 50 hours. Following this, it is cooled under an ultra-high vacuum of 1 $\mu$Pa, with a cooling time constant of 5 hours to let the temperature go down closer to 300 K. This cooling step was crucial for ensuring a controlled transition before the desorption phase.
In the subsequent thermal desorption phase, the sample was transferred to a furnace under vacuum conditions and gradually heated from 300 K to 1073 K at a rate of 3 K/min.
The emission rate of deuterium from the sample was recorded as a function of temperature to assess how deuterium diffused and was released from the material. In that way, the emission rate from the sample could be measured as a function of temperature. The sample pressure and temperature histories are shown in [val-2f_temperature_pressure_history].

The experiment is simulated using a bulk beryllium one-segment model in TMAP8. The beryllium bulk is modeled with 40 elements, each 50 µm thick, using a reflective boundary condition at the mid-plane. In this case, the primary focus is on modeling deuterium behavior in beryllium (Be), meaning that the bulk material considered in the calculations is pure Be without explicitly modeling a BeO layer. However, to observe simulation results, we apply BeO solubility conditions at the left boundary. Diffusivities and solubilities used in the simulation are listed in [val-2f_parameters].

!media comparison_val-2f.py
    image_name=val-2f_temperature_pressure_history.png
    style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
    id=val-2f_temperature_pressure_history
    caption=Pressure and temperature histories.

!table id=val-2f_parameters caption=Model parameter values for the charging and the desorption phases [!citep](longhurst1992verification,ambrosek2008verification). $T$ is the temperature in Kelvin.
| Property of deuterium | Value for charging phase              | Value for desorption phase            | Units               |
| --------------------- | ------------------------------------- | ------------------------------------- | ------------------- |
| Diffusivity in Be     | $8.0 \times 10^{-9} \exp(-4220/T)$    | $8.0 \times 10^{-9} \exp(-4220/T)$    | m$^2$/s             |
| Solubility in Be      | $7.156 \times 10^{27} \exp(-11606/T)$ | $7.156 \times 10^{27} \exp(-11606/T)$ | at/m$^3$/Pa$^{1/2}$ |
| Solubility in BeO     | $5.00 \times 10^{20} \exp(9377.7/T)$  | $5.00 \times 10^{20} \exp(9377.7/T)$  | at/m$^3$/Pa$^{1/2}$ |

## Results

[val-2f_comparison] shows deuterium flux (atoms/m$^2$/s) as a function of temperature (K), obtained using the TMAP8 model. The curve shows a sharp peak around 350 K, where the deuterium flux reaches its maximum, slightly above 3.0 × 10$^23$ atoms/m$^2$/s. After this peak, the flux rapidly decreases as the temperature increases, following an exponential-like decay. Around 500 K, the flux becomes relatively low, with a small secondary feature near 600 K, before continuing its decline towards near-zero values beyond 700 K. This behavior suggests that deuterium desorption from the material is temperature-dependent, with a strong release occurring at lower temperatures (near 350 K), followed by a much weaker release at higher temperatures.

!media comparison_val-2f.py
       image_name=val-2f_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2f_comparison
       caption=TMAP8 calculation of the deuterium flux (atoms/m$^2$/s) as a function of temperature (K).

## Input files

!style halign=left
The input file for this case can be found at [/val-2f.i].
To achieve short regression tests (under 2 seconds walltime), the tests in [/val-2f/tests] run a version of the files with a shorter history, looser tolerance, and larger time step. More information about the changes can be found in the test specification file for this case, namely [/ver-1d/tests].
