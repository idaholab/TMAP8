# val-2b

# Diffusion Experiment in Beryllium

## Test Description

This validation problem is taken from [!cite](macaulay1991deuterium). He and co-workers conducted thermal absorption and desorption experiments, as well as implantation experiments, on wafers of polished beryllium. Of the several data sets presented, the one modeled here is that represented in Figure 12(a) in their publication. The beryllium sample was 0.4 mm thick and had an area of 104 mm$^2$. It was polished to a mirror finish and then exposed to 13.3 kPa of deuterium at 773 K for 50 hours. It was quickly cooled under a vacuum of about 1 $\mu$Pa. The cooling time constant for the apparatus is taken as 45 minutes. After removing the sample from the charging furnace, it was transferred in the air to a thermal desorption furnace where the temperature was increased from ambient (300 K) to 1073 K at the rate of 3 K/min. This was done under vacuum, and the pressure of the chamber was monitored by the residual gas analysis and calibrated against standard leaks. In that way, the emission rate from the sample could be measured as a function of temperature. Data from that measurement, given in Figure 12 (a) of their publication are reproduced in [val-2b_comparison] here.


!media figures/val-2b_schematic.jpg
    style=width:75%;margin-bottom:2%
    id=val-2b_schematic
    caption=Schematic of the experiment setup (figure elements are not to scale).

!media figures/val-2b_pressure_temp_variation.jpg
    style=width:35%;margin-bottom:2%
    id=val-2b_pressure_temp_variation
    caption=Variation of pressure and temperature that the sample was subjected to (figure is not to scale).

From Rutherford backscattering measurements made on the samples before charging with deuterium, they deduced that the thickness of the oxide film was 18 nm. This is typical for polished beryllium. The metal is so reactive in air that the film forms almost immediately after any surface oxide removal. On the other hand, it is relatively stable and would only grow slightly when exposed to air between charging and thermal desorption.

This experiment is modeled using a two-segment model in TMAP8 with the segments linked. The first segment is the BeO film which is modeling using 36 elements each 0.5 nm in length. The second segment is the beryllium water with reflective boundary condition at the mid-plane. The beryllium segment is modeled using 40 elements each 50 $\mu$m thick. The solubility of deuterium in beryllium used was that given by [!cite](wilson1990beryllium) based on the work done by W. A. Swansiger also of Sandia National Laboratory.

The diffusivity of deuterium in beryllium was measured by [!cite](abramov1990deuterium). They made measurements on high-grade (99$\%$ pure) and extra-grade (99.8$\%$ pure). The values used here are those for high-grade beryllium, consistent with Dr. Macaulay-Newcombe's measurements of the purity of his samples.

Deuterium transport properties of the BeO are more challenging. First, it is not clear in which state the deuterium exists in the BeO. However, it has been observed [!cite](longhurst1990tritium) that an activation energy of -78 kJ/mol (exothermic reaction) is evident for tritium coming out of neutron irradiated beryllium in work done by D. L. Baldwin of Battelle Pacific Northwest Laboratory. The same value of energy has appeared in other results (can be inferred from Dr. Swansiger's work cited by [!cite](wilson1990beryllium) and by [!cite](causey1990tritium), among others), so one may be justified in using it. The solubility coefficient is not well known. Measurements reported by [!cite](macaulay1992thermal) and in follow-up conversations indicate about 200 appm of D in BeO after exposure to 13.3 kPa fo D$_2$ at 773 K. That suggests a coefficient of only 1.88 x 10$^{18}$ d/m$^3$Pa$^{1/2}$. Since much of the deuterium in the oxide layer will get out during the cool-down process (and because it gives a good fit) the solubility coefficient is taken to be 5 x 10$^{20}$ d/m$^3$Pa$^{1/2}$.

Deuterium diffusion measurements in BeO were made by [!cite](fowler1977tritium). They found a wide range of results for diffusivity in BeO, depending on the physical form of the material, having measured it for single-crystal, sintered, and powdered BeO. This model uses one expression for the charging phase and another for the thermal desorption phase, believing that the surface film changed somewhat during the transfer between the two furnaces. For the charging phase diffusivity, the model uses 20 times that for the sintered BeO. Thermal expansion mismatches tend to open up cracks and channels in the oxide layer, so this seems a reasonable value. The same activation energy of 48.5 kJ/mol, is retained, however. For the thermal desorption phase, the diffusivity prefactor of the sintered material (7x10$^{-5}$ m$^2$/sec) and an activation energy of 223.7 kJ/mol (53.45 kcal/mol) are used. These values give good results and lie well within the scaller of Fowler's data. Exposure of the sample to air after heating should have made the oxide more like single crystal by healing the cracks that may have developed. Diffusivities and solubilities used in the simulation are listed below with T being the temperature in Kelvin:

| Property of deuterium | Value for charging phase      | Value for desorption phase    |
| --------------------- | ----------------------------- | ----------------------------- |
| Diffusivity in Be     | 8.0x10$^{-9}$ exp(-4220/T)    | 8.0x10$^{-9}$ exp(-4220/T)    |
| Diffusivity in BeO    | 1.40x10$^{-4}$ exp(-24408/T)  | 7x10$^{-5}$ exp(-27000/T)     |
| Solubility in Be      | 7.156x10$^{27}$ exp(-11606/T) | 7.156x10$^{27}$ exp(-11606/T) |
| Solubility in BeO     | 5.00x10$^{20}$ exp(9377.7/T)  | 5.00x10$^{20}$ exp(9377.7/T)  |


The model applies 13.3 kPa of D$_2$ for 50 hours and 15 seconds followed by evacuation to 1 $\mu$Pa and cool down with a 45 minute time constant for one hour (the cooldown phase starts after 50 hours). The deuterium concentrations in the sample have a complex distribution that results from first charging the sample and then discharging it during the cool down. This problem is then restarted with different equations to simulate thermal desorption in the 1 $\mu$Pa environment. That begins at 300 K and goes to 1073 K. Again, the concentration profiles in both the substrate beryllium and the oxide film have a peculiar interaction because of the activation energies involved, but the flux from the sample gives a good fit to the experimental data as shown in [val-2b_comparison].


## Results


[val-2b_comparison] shows the comparison of the TMAP8 calculation and the experimental data. There is good agreement between the TMAP predictions and the experimental data with a root mean square percentage error of RMSPE = 19.41 %.

!media comparison_val-2b.py
       image_name=val-2b_comparison.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2b_comparison
       caption=Comparison of TMAP8 calculation with the experimental data

## Input files

!style halign=left
The input file for this case can be found at [/val-2b.i], which is also used as test in TMAP8 at [/val-2b/tests].

!bibtex bibliography
