# geometry and design
radius_coolant = ${units 6.0 mm -> m}
radius_CuCrZr = ${units 7.5 mm -> m}
radius_Cu = ${units 8.5 mm -> m}
block_size = ${units 28 mm -> m}
num_sectors = 36 # (-) defines mesh size

# operation conditions
temperature_initial = ${units 300.0 K}
temperature_coolant_max = ${units 552.0 K}



plasma_ramp_time = 100.0 #s
plasma_ss_duration = 400.0 #s
plasma_cycle_time = 1600.0 #s (3.0e4 s plasma, 2.0e4 SSP)

plasma_ss_end = ${fparse plasma_ramp_time + plasma_ss_duration} #s
plasma_ramp_down_end = ${fparse plasma_ramp_time + plasma_ss_duration + plasma_ramp_time} #s

plasma_max_heat = 1.0e7 #W/m^2 # Heat flux of 10MW/m^2 at steady state
plasma_min_heat = 0.0 # W/m^2 # no flux while the pulse is off.

### Maximum mobile flux of 7.90e-13 at the top surface (1.0e-4 [m])
### 1.80e23/m^2-s = (5.0e23/m^2-s) *(1-0.999) = (7.90e-13)*(${tungsten_atomic_density})/(1.0e-4)  at steady state
plasma_max_flux = 7.90e-13
plasma_min_flux = 0.0

# Materials properties
tungsten_atomic_density = ${units 6.338e28 m^-3}
density_W = 19300                # [g/m^3]
density_Cu = 8960.0               # [g/m^3]
density_CuCrZr = 8900.0 # [g/m^3]
specific_heat_CuCrZr = 390.0     # [ W/m-K], [J/kg-K]

diffusivity_fixed = 5.01e-24   # (3.01604928)/(6.02e23)/[gram(T)/m^2]
# diffusivity_fixed = 5.508e-19   # (1.0e3)*(1.0e3)/(6.02e23)/(3.01604928) [gram(T)/m^2] alternative

N_W = ${units 1.0e0 m^-3}       # = ${tungsten_atomic_density} #/m^3 (W lattice density)
Ct0_W = ${units 1.0e-4 m^-3}  # E.A. Hodille et al 2021 Nucl. Fusion 61 1260033, trap 2
# Ct0 = ${units 1.0e-4 m^-3}   # E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 1
trap_per_free_W = 1.0e0

N_Cu = ${units 1.0e0 m^-3}     # = ${tungsten_atomic_density} #/m^3 (W lattice density)
Ct0_Cu = ${units 5.0e-5 m^-3}    # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
trap_per_free_Cu = 1.0e0

N_CuCrZr = ${units 1.0e0 m^-3}     # = ${tungsten_atomic_density} #/m^3 (W lattice density)
Ct0_CuCrZr = ${units 5.0e-5 m^-3}  # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
# Ct0 = ${units 4.0e-2 m^-3} # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 5
trap_per_free_CuCrZr = 1.0e0

scaling_factor = 3.491e10    # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
scaling_factor_2 = 3.44e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
