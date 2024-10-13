import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# ===============================================================================
# First Case - low mobile concentration
# ===============================================================================

# ===============================================================================
# Extract TMAP8 predictions - time evolution
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1jb/gold/ver-1jb_time_dependent_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1jb_time_dependent_out.csv"
tmap8_solution = pd.read_csv(csv_folder)
tmap8_time = tmap8_solution['time']
tmap8_tritium_mobile = tmap8_solution['tritium_mobile_inventory']
tmap8_tritium_trapped = tmap8_solution['tritium_trapped_inventory']
tmap8_helium = tmap8_solution['helium_inventory']

# ===============================================================================
# Case set up
slab_length = 1.5 # m
slab_height = 1 # m - assumed for integrations
slab_width = 1 # m - assumed for integrations
trapping_sites_atomic_fraction_max = 0.001 # at.frac.
trapping_sites_fraction_occupied_initial = 0.5 # (-)
density_material = 6.34e28 # atoms/m^3 # for tungsten
normal_center_position =  slab_length/2 # m
normal_standard_deviation = slab_length/4 # m

# ===============================================================================
# Calculate the analytical solution
tritium_mobile_concentration_initial = 1 # atoms/m^3
tritium_trapped_inventory_initial = 2.8438315780556e25 * slab_height * slab_width # atoms -- integral of the normal distribution over the slab length * area
tritium_mobile_inventory_initial = tritium_mobile_concentration_initial * slab_length * slab_height * slab_width # atoms
half_life = 12.3232 # years
conversion_years_to_s = 365.25*24*60*60
half_life_s = half_life*conversion_years_to_s # s
decay_rate_constant = 0.693/half_life_s # 1/s

analytical_tritium = (tritium_mobile_inventory_initial + tritium_trapped_inventory_initial) * np.exp(- decay_rate_constant * tmap8_time)
analytical_helium = (tritium_mobile_inventory_initial + tritium_trapped_inventory_initial) * ( 1. - np.exp(- decay_rate_constant * tmap8_time))

#  ===============================================================================
# Plot figure for verification of tritium decay - time evolution
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
tmap8_time_years = [t/conversion_years_to_s for t in tmap8_time]
ax.plot(tmap8_time_years,tmap8_tritium_trapped + tmap8_tritium_mobile,label=r"$I_{tot}$ - TMAP8",c='k', alpha=0.5)
ax.plot(tmap8_time_years,analytical_tritium,label=r"$I_{tot}$ - Analytical",c='k', linestyle='--')
ax.plot(tmap8_time_years,tmap8_tritium_trapped,label=r"$I_T$ - TMAP8",c='tab:blue', alpha=0.8, ls=':')
ax.plot(tmap8_time_years,tmap8_tritium_mobile,label=r"$I_M$ - TMAP8",c='tab:green', alpha=0.8, ls=':')
ax.plot(tmap8_time_years,tmap8_helium,label=r"$I_{He}$ - TMAP8",c='tab:red', alpha=0.5)
ax.plot(tmap8_time_years,analytical_helium,label=r"$I_{He}$ - Analytical",c='r', linestyle='--')
# Root Mean Square Percentage Error calculations
RMSE_Ctot = np.linalg.norm(tmap8_tritium_trapped + tmap8_tritium_mobile - analytical_tritium)
RMSPE_Ctot = RMSE_Ctot*100/np.mean(analytical_tritium)
ax.text(33, 0.6e25, '$I_{tot}$ RMSPE = %.2f '%RMSPE_Ctot+'%',fontweight='bold',color = 'k')
RMSE_CHe = np.linalg.norm(tmap8_helium-analytical_helium)
RMSPE_CHe = RMSE_CHe*100/np.mean(analytical_helium)
ax.text(52, 2.6e25, '$I_{He}$ RMSPE = %.2f '%RMSPE_CHe+'%',fontweight='bold',color = 'tab:red')

ax.set_xlabel(u'Time (years)')
ax.set_ylabel(r"Inventory (atoms)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('ver-1jb_comparison_analytical_time_evolution.png', bbox_inches='tight', dpi=300);
plt.close(fig)

# ===============================================================================
# Extract TMAP8 predictions - concentration profile
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder_profile = "../../../../test/tests/ver-1jb/gold/ver-1jb_profile_out_line_0048.csv"
else:                                  # if in test folder
    csv_folder_profile = "./gold/ver-1jb_profile_out_line_0048.csv"
tmap8_solution = pd.read_csv(csv_folder_profile)
tmap8_position = tmap8_solution['x']
tmap8_tritium_mobile = tmap8_solution['tritium_mobile_concentration']
tmap8_tritium_trapped = tmap8_solution['tritium_trapped_concentration']
tmap8_helium = tmap8_solution['helium_concentration']

#  ===============================================================================
# Plot figure for verification of tritium decay - concentration profile
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
tmap8_tritium_trapped_init = trapping_sites_fraction_occupied_initial * density_material * trapping_sites_atomic_fraction_max * np.exp(-1/2*((tmap8_position-normal_center_position)/normal_standard_deviation)**2)
ax.plot(tmap8_position,tmap8_tritium_trapped_init,label=r"$C_T(t=0)$",c='tab:blue', alpha=0.5, ls=':')
tmap8_tritium_mobile_init = [tritium_mobile_concentration_initial]*len(tmap8_position)
ax.plot(tmap8_position,tmap8_tritium_mobile_init,label=r"$C_T(t=0)$",c='tab:green', alpha=0.5, ls=':')
ax.plot(tmap8_position,tmap8_tritium_trapped,label=r"$C_T(t=45 \text{years})$",c='tab:blue', alpha=1)
ax.plot(tmap8_position,tmap8_tritium_mobile,label=r"$C_M(t=45 \text{years})$",c='tab:green', alpha=1)
ax.plot(tmap8_position,tmap8_helium,label=r"$C_{He}(t=45 \text{years})$",c='tab:red', alpha=1)
ax.set_xlabel(u'Position (m)')
ax.set_ylabel(r"Concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=slab_length)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('ver-1jb_profile.png', bbox_inches='tight', dpi=300);
plt.close(fig)

# ===============================================================================
# Second Case - equivalent mobile and tritium concentrations
# ===============================================================================

# ===============================================================================
# Extract TMAP8 predictions - time evolution
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1jb/gold/ver-1jb_equivalent_concentrations_time_dependent_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1jb_equivalent_concentrations_time_dependent_out.csv"
tmap8_solution = pd.read_csv(csv_folder)
tmap8_time = tmap8_solution['time']
tmap8_tritium_mobile = tmap8_solution['tritium_mobile_inventory']
tmap8_tritium_trapped = tmap8_solution['tritium_trapped_inventory']
tmap8_helium = tmap8_solution['helium_inventory']

# ===============================================================================
# Case set up
slab_length = 1.5 # m
slab_height = 1 # m - assumed for integrations
slab_width = 1 # m - assumed for integrations
trapping_sites_atomic_fraction_max = 0.001 # at.frac.
trapping_sites_fraction_occupied_initial = 0.5 # (-)
density_material = 6.34e28 # atoms/m^3 # for tungsten
normal_center_position =  slab_length/2 # m
normal_standard_deviation = slab_length/4 # m

# ===============================================================================
# Calculate the analytical solution
tritium_mobile_concentration_initial = 1e25 # atoms/m^3
tritium_trapped_inventory_initial = 2.8438315780556e25 * slab_height * slab_width # atoms -- integral of the normal distribution over the slab length * area
tritium_mobile_inventory_initial = tritium_mobile_concentration_initial * slab_length * slab_height * slab_width # atoms
half_life = 12.3232 # years
conversion_years_to_s = 365.25*24*60*60
half_life_s = half_life*conversion_years_to_s # s
decay_rate_constant = 0.693/half_life_s # 1/s

analytical_tritium = (tritium_mobile_inventory_initial + tritium_trapped_inventory_initial) * np.exp(- decay_rate_constant * tmap8_time)
analytical_helium = (tritium_mobile_inventory_initial + tritium_trapped_inventory_initial) * ( 1. - np.exp(- decay_rate_constant * tmap8_time))

#  ===============================================================================
# Plot figure for verification of tritium decay - time evolution
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
tmap8_time_years = [t/conversion_years_to_s for t in tmap8_time]
ax.plot(tmap8_time_years,tmap8_tritium_trapped + tmap8_tritium_mobile,label=r"$I_{tot}$ - TMAP8",c='k', alpha=0.5)
ax.plot(tmap8_time_years,analytical_tritium,label=r"$I_{tot}$ - Analytical",c='k', linestyle='--')
ax.plot(tmap8_time_years,tmap8_tritium_trapped,label=r"$I_T$ - TMAP8",c='tab:blue', alpha=0.8, ls=':')
ax.plot(tmap8_time_years,tmap8_tritium_mobile,label=r"$I_M$ - TMAP8",c='tab:green', alpha=0.8, ls=':')
ax.plot(tmap8_time_years,tmap8_helium,label=r"$I_{He}$ - TMAP8",c='tab:red', alpha=0.5)
ax.plot(tmap8_time_years,analytical_helium,label=r"$I_{He}$ - Analytical",c='r', linestyle='--')
# Root Mean Square Percentage Error calculations
RMSE_Ctot = np.linalg.norm(tmap8_tritium_trapped + tmap8_tritium_mobile - analytical_tritium)
RMSPE_Ctot = RMSE_Ctot*100/np.mean(analytical_tritium)
ax.text(33, 0.75e25, '$I_{tot}$ RMSPE = %.2f '%RMSPE_Ctot+'%',fontweight='bold',color = 'k')
RMSE_CHe = np.linalg.norm(tmap8_helium-analytical_helium)
RMSPE_CHe = RMSE_CHe*100/np.mean(analytical_helium)
ax.text(52, 3.8e25, '$I_{He}$ RMSPE = %.2f '%RMSPE_CHe+'%',fontweight='bold',color = 'tab:red')

ax.set_xlabel(u'Time (years)')
ax.set_ylabel(r"Inventory (atoms)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('ver-1jb_equivalent_concentrations_comparison_analytical_time_evolution.png', bbox_inches='tight', dpi=300);
plt.close(fig)

# ===============================================================================
# Extract TMAP8 predictions - concentration profile
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder_profile = "../../../../test/tests/ver-1jb/gold/ver-1jb_equivalent_concentrations_profile_out_line_0048.csv"
else:                                  # if in test folder
    csv_folder_profile = "./gold/ver-1jb_equivalent_concentrations_profile_out_line_0048.csv"
tmap8_solution = pd.read_csv(csv_folder_profile)
tmap8_position = tmap8_solution['x']
tmap8_tritium_mobile = tmap8_solution['tritium_mobile_concentration']
tmap8_tritium_trapped = tmap8_solution['tritium_trapped_concentration']
tmap8_helium = tmap8_solution['helium_concentration']

#  ===============================================================================
# Plot figure for verification of tritium decay - concentration profile
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
tmap8_tritium_trapped_init = trapping_sites_fraction_occupied_initial * density_material * trapping_sites_atomic_fraction_max * np.exp(-1/2*((tmap8_position-normal_center_position)/normal_standard_deviation)**2)
ax.plot(tmap8_position,tmap8_tritium_trapped_init,label=r"$C_T(t=0)$",c='tab:blue', alpha=0.5, ls=':')
tmap8_tritium_mobile_init = [tritium_mobile_concentration_initial]*len(tmap8_position)
ax.plot(tmap8_position,tmap8_tritium_mobile_init,label=r"$C_T(t=0)$",c='tab:green', alpha=0.5, ls=':')
ax.plot(tmap8_position,tmap8_tritium_trapped,label=r"$C_T(t=45 \text{years})$",c='tab:blue', alpha=1)
ax.plot(tmap8_position,tmap8_tritium_mobile,label=r"$C_M(t=45 \text{years})$",c='tab:green', alpha=1)
ax.plot(tmap8_position,tmap8_helium,label=r"$C_{He}(t=45 \text{years})$",c='tab:red', alpha=1)
ax.set_xlabel(u'Position (m)')
ax.set_ylabel(r"Concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=slab_length)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('ver-1jb_equivalent_concentrations_profile.png', bbox_inches='tight', dpi=300);
plt.close(fig)
