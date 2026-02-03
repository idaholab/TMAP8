import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os
import json
from scipy.stats import norm

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Constants and history (see input file val-2b.i)

N_A = 6.02214076e23 # at/mol
q = 1.602176634e-19 # C/at
# A = np.pi * (7.5e-3 / 2) ** 2 # m
A = 7.7e-3 * 2.2e-3 # m

#===============================================================================
# Define methods
def read_csv_from_TMAP8(file_name, parameter_names):
    """Read simulation data in csv files from TMAP8

    Args:
        file_name (string): the file name at simulation folder
        parameter_names (list): the list of parameters extracted from csv files

    Returns:
        float, ndarray: the matrix keep the simulation results, first axis depended on len(parameter_names)
    """
    if "/TMAP8/doc/" in script_folder:     # if in documentation folder
        csv_folder = f"../../../../test/tests/val-2g/gold/{file_name}"
    else:                                  # if in test folder
        csv_folder = f"./gold/{file_name}"
    simulation_data = pd.read_csv(csv_folder)
    simulation_results = []
    for i in range(len(parameter_names)):
        simulation_results.append(simulation_data[parameter_names[i]])
    simulation_results = np.array(simulation_results)
    return simulation_results

################################################################################
############################## Result Extraction ###############################
################################################################################

# thermal and model parameters
temperature_low = 300 # K
temperature_initial = 873 # K
temperature_high = 1400 # K
temperature_rate = 0.5 # K/s
dissolve_duration = 3600 # s
cooldown_duration = 3600 # s
desorption_duration = (temperature_high - temperature_low) / temperature_rate
endtime = dissolve_duration + cooldown_duration + desorption_duration

# ============================================================================ #
# Extract BZY predictions in 2D model

parameter_names = ['time','recombination_flux_T2O_dry_left','recombination_flux_T2_dry_left','recombination_flux_T2O_wet_left','recombination_flux_T2_wet_left','temperature_average', 'pressure_T2_average', 'pressure_T2O_average', 'RMSPE_T2O_dry', 'RMSPE_T2_dry', 'RMSPE_T2O_wet', 'RMSPE_T2_wet']

# Cache index lookups for performance
IDX_TIME = parameter_names.index('time')
IDX_FLUX_T2_DRY = parameter_names.index('recombination_flux_T2_dry_left')
IDX_FLUX_T2O_DRY = parameter_names.index('recombination_flux_T2O_dry_left')
IDX_FLUX_T2_WET = parameter_names.index('recombination_flux_T2_wet_left')
IDX_FLUX_T2O_WET = parameter_names.index('recombination_flux_T2O_wet_left')
IDX_TEMP = parameter_names.index('temperature_average')

file_name = './val-2g_no_trapping_initial_parameters.csv'
simulation_results2 = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
simulation_results2[IDX_FLUX_T2_DRY] = simulation_results2[IDX_FLUX_T2_DRY] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results2[IDX_FLUX_T2O_DRY] = simulation_results2[IDX_FLUX_T2O_DRY] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results2[IDX_FLUX_T2O_WET] = simulation_results2[IDX_FLUX_T2O_WET] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results2[IDX_FLUX_T2_WET] = simulation_results2[IDX_FLUX_T2_WET] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s

file_name = './val-2g_trapping_initial_parameters.csv'
simulation_results3 = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
simulation_results3[IDX_FLUX_T2_DRY] = simulation_results3[IDX_FLUX_T2_DRY] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results3[IDX_FLUX_T2O_DRY] = simulation_results3[IDX_FLUX_T2O_DRY] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results3[IDX_FLUX_T2O_WET] = simulation_results3[IDX_FLUX_T2O_WET] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results3[IDX_FLUX_T2_WET] = simulation_results3[IDX_FLUX_T2_WET] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s

file_name = './val-2g_trapping_calibrated.csv'
simulation_results4 = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
simulation_results4[IDX_FLUX_T2_DRY] = simulation_results4[IDX_FLUX_T2_DRY] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results4[IDX_FLUX_T2O_DRY] = simulation_results4[IDX_FLUX_T2O_DRY] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results4[IDX_FLUX_T2O_WET] = simulation_results4[IDX_FLUX_T2O_WET] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s
simulation_results4[IDX_FLUX_T2_WET] = simulation_results4[IDX_FLUX_T2_WET] * 1e12 * 2 # atoms/mum^2/s -> atoms/m^2/s

# select only the simulation data for desorption
start_time = 2 * 3600 # s
chosen_matrix2 = simulation_results2[IDX_TIME]>=start_time
chosen_matrix3 = simulation_results3[IDX_TIME]>=start_time
chosen_matrix4 = simulation_results4[IDX_TIME]>=start_time

# ============================================================================ #
# Extract BZY from experiments

experiment_parameter_names = ['Time','Flux'] # s, mol/s
file_name = './BZY_873K_D2_exposed_D2_flux.csv' # D2 under dry
experiment_results1 = read_csv_from_TMAP8(file_name, experiment_parameter_names) # read csv file
file_name = './BZY_873K_D2_exposed_D2O_flux.csv' # D2O under dry
experiment_results2 = read_csv_from_TMAP8(file_name, experiment_parameter_names) # read csv file
file_name = './BZY_873K_D2O_exposed_D2_flux.csv' # D2 under wet
experiment_results3 = read_csv_from_TMAP8(file_name, experiment_parameter_names) # read csv file
file_name = './BZY_873K_D2O_exposed_D2O_flux.csv' # D2O under wet
experiment_results4 = read_csv_from_TMAP8(file_name, experiment_parameter_names) # read csv file

# Experiment results
experiment_input = (experiment_results1[experiment_parameter_names.index('Time')] - dissolve_duration - cooldown_duration) * temperature_rate + temperature_low
experiment_output = experiment_results1[experiment_parameter_names.index('Flux')]
experiment2_input = (experiment_results2[experiment_parameter_names.index('Time')] - dissolve_duration - cooldown_duration) * temperature_rate + temperature_low
experiment2_output = experiment_results2[experiment_parameter_names.index('Flux')]

experiment3_input = (experiment_results3[experiment_parameter_names.index('Time')] - dissolve_duration - cooldown_duration) * temperature_rate + temperature_low
experiment3_output = experiment_results3[experiment_parameter_names.index('Flux')]
experiment4_input = (experiment_results4[experiment_parameter_names.index('Time')] - dissolve_duration - cooldown_duration) * temperature_rate + temperature_low
experiment4_output = experiment_results4[experiment_parameter_names.index('Flux')]

################################################################################
######################## Plot dry case from no trapping ########################
################################################################################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
ax1.plot(experiment_input,
        experiment_output, 's', label=rf"experiment: D from D$_2$", c='C0', markersize=3)
ax1.plot(simulation_results2[IDX_TEMP][chosen_matrix2],
        simulation_results2[IDX_FLUX_T2_DRY][chosen_matrix2] * A / N_A, label=rf"no trapping: D from D$_2$", c='C0')
ax1.plot(simulation_results2[IDX_TEMP][chosen_matrix2],
        simulation_results2[IDX_FLUX_T2O_DRY][chosen_matrix2] * A / N_A, label=rf"no trapping: D from D$_2$O", c='C1')
ax1.plot(experiment2_input,
        experiment2_output, '.', label=rf"experiment: D from D$_2$O", c='C1')
ax1.set_xlabel(u'Temperature (K)',fontsize=14)
ax1.set_ylabel(u"Deuterium flux (mol/s)",fontsize=14)
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
ax1.tick_params(axis='y')
ax1.set_xlim([300,1400])
ax1.set_ylim([0,1.55e-11])
simulation_result2_temperature = simulation_results2[IDX_TEMP][chosen_matrix2]
simulation_result2_flux = simulation_results2[IDX_FLUX_T2_DRY][chosen_matrix2]
sorted_indices = np.argsort(simulation_result2_temperature)
simulation_result2_temperature_order = simulation_result2_temperature[sorted_indices]
simulation_result2_flux_order = simulation_result2_flux[sorted_indices]
flux_trapping = np.interp(experiment_input,
                                                        simulation_result2_temperature_order,
                                                        simulation_result2_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment_output)**2))/np.mean(experiment_output)*100
ax1.text(380,1.0e-11, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C0',fontsize=11)
simulation_result2_temperature = simulation_results2[IDX_TEMP][chosen_matrix2]
simulation_result2_flux = simulation_results2[IDX_FLUX_T2O_DRY][chosen_matrix2]
sorted_indices = np.argsort(simulation_result2_temperature)
simulation_result2_temperature_order = simulation_result2_temperature[sorted_indices]
simulation_result2_flux_order = simulation_result2_flux[sorted_indices]
flux_trapping = np.interp(experiment2_input,
                                                        simulation_result2_temperature_order,
                                                        simulation_result2_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment2_output)**2))/np.mean(experiment2_output)*100
ax1.text(380,0.35e-11, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C1',fontsize=11)
plt.legend(fontsize=12)
plt.savefig('./val-2g_dry_no_trapping_flux_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

################################################################################
######################## Plot wet case from no trapping ########################
################################################################################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
ax1.plot(simulation_results2[IDX_TEMP][chosen_matrix2],
        simulation_results2[IDX_FLUX_T2O_WET][chosen_matrix2] * A / N_A, label=rf"no trapping: D from D$_2$O", c='C1')
ax1.plot(experiment4_input,
        experiment4_output, '.', label=rf"experiment: D from D$_2$O", c='C1')
ax1.plot(experiment3_input,
        experiment3_output, 's', label=rf"experiment: D from D$_2$", c='C0', markersize=3)
ax1.plot(simulation_results2[IDX_TEMP][chosen_matrix2],
        simulation_results2[IDX_FLUX_T2_WET][chosen_matrix2] * A / N_A, label=rf"no trapping: D from D$_2$", c='C0')
ax1.set_xlabel(u'Temperature (K)',fontsize=14)
ax1.set_ylabel(u"Deuterium flux (mol/s)",fontsize=14)
ax1.set_xlim([300,1400])
ax1.set_ylim([0,2.2e-9])
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
ax1.tick_params(axis='y')
simulation_result2_temperature = simulation_results2[IDX_TEMP][chosen_matrix2]
simulation_result2_flux = simulation_results2[IDX_FLUX_T2_WET][chosen_matrix2]
sorted_indices = np.argsort(simulation_result2_temperature)
simulation_result2_temperature_order = simulation_result2_temperature[sorted_indices]
simulation_result2_flux_order = simulation_result2_flux[sorted_indices]
flux_trapping = np.interp(experiment3_input,
                                                        simulation_result2_temperature_order,
                                                        simulation_result2_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment3_output)**2))/np.mean(experiment3_output)*100
ax1.text(380,0.5e-9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C0',fontsize=11)
simulation_result2_temperature = simulation_results2[IDX_TEMP][chosen_matrix2]
simulation_result2_flux = simulation_results2[IDX_FLUX_T2O_WET][chosen_matrix2]
sorted_indices = np.argsort(simulation_result2_temperature)
simulation_result2_temperature_order = simulation_result2_temperature[sorted_indices]
simulation_result2_flux_order = simulation_result2_flux[sorted_indices]
flux_trapping = np.interp(experiment4_input,
                                                        simulation_result2_temperature_order,
                                                        simulation_result2_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment4_output)**2))/np.mean(experiment4_output)*100
ax1.text(380,1.45e-9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C1',fontsize=11)
plt.legend(fontsize=12)
plt.savefig('./val-2g_wet_no_trapping_flux_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

################################################################################
######################## Plot dry case from trapping ########################
################################################################################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
ax1.plot(experiment_input,
        experiment_output, 's', label=rf"experiment: D from D$_2$", c='C0', markersize=3)
ax1.plot(simulation_results3[IDX_TEMP][chosen_matrix3],
        simulation_results3[IDX_FLUX_T2_DRY][chosen_matrix3] * A / N_A, label=rf"trapping: D from D$_2$", c='C0')
ax1.plot(simulation_results3[IDX_TEMP][chosen_matrix3],
        simulation_results3[IDX_FLUX_T2O_DRY][chosen_matrix3] * A / N_A, label=rf"trapping: D from D$_2$O", c='C1')
ax1.plot(experiment2_input,
        experiment2_output, '.', label=rf"experiment: D from D$_2$O", c='C1')
ax1.set_xlabel(u'Temperature (K)',fontsize=14)
ax1.set_ylabel(u"Deuterium flux (mol/s)",fontsize=14)
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
ax1.tick_params(axis='y')
simulation_result3_temperature = simulation_results3[IDX_TEMP][chosen_matrix3]
simulation_result3_flux = simulation_results3[IDX_FLUX_T2_DRY][chosen_matrix3]
sorted_indices = np.argsort(simulation_result3_temperature)
simulation_result3_temperature_order = simulation_result3_temperature[sorted_indices]
simulation_result3_flux_order = simulation_result3_flux[sorted_indices]
flux_trapping = np.interp(experiment_input,
                                                        simulation_result3_temperature_order,
                                                        simulation_result3_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment_output)**2))/np.mean(experiment_output)*100
ax1.text(350,1.0e-11, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C0',fontsize=11)
simulation_result3_temperature = simulation_results3[IDX_TEMP][chosen_matrix3]
simulation_result3_flux = simulation_results3[IDX_FLUX_T2O_DRY][chosen_matrix3]
sorted_indices = np.argsort(simulation_result3_temperature)
simulation_result3_temperature_order = simulation_result3_temperature[sorted_indices]
simulation_result3_flux_order = simulation_result3_flux[sorted_indices]
flux_trapping = np.interp(experiment2_input,
                                                        simulation_result3_temperature_order,
                                                        simulation_result3_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment2_output)**2))/np.mean(experiment2_output)*100
ax1.text(1100,1.0e-11, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C1',fontsize=11)
plt.legend(fontsize=12)
plt.savefig('./val-2g_dry_trapping_flux_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

################################################################################
######################## Plot wet case from trapping ########################
################################################################################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
ax1.plot(simulation_results3[IDX_TEMP][chosen_matrix3],
        simulation_results3[IDX_FLUX_T2O_WET][chosen_matrix3] * A / N_A, label=rf"trapping: D from D$_2$O", c='C1')
ax1.plot(experiment4_input,
        experiment4_output, '.', label=rf"experiment: D from D$_2$O", c='C1')
ax1.plot(experiment3_input,
        experiment3_output, 's', label=rf"experiment: D from D$_2$", c='C0', markersize=3)
ax1.plot(simulation_results3[IDX_TEMP][chosen_matrix3],
        simulation_results3[IDX_FLUX_T2_WET][chosen_matrix3] * A / N_A, label=rf"trapping: D from D$_2$", c='C0')
ax1.set_xlabel(u'Temperature (K)',fontsize=14)
ax1.set_ylabel(u"Deuterium flux (mol/s)",fontsize=14)
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
ax1.tick_params(axis='y')
simulation_result3_temperature = simulation_results3[IDX_TEMP][chosen_matrix3]
simulation_result3_flux = simulation_results3[IDX_FLUX_T2_WET][chosen_matrix3]
sorted_indices = np.argsort(simulation_result3_temperature)
simulation_result3_temperature_order = simulation_result3_temperature[sorted_indices]
simulation_result3_flux_order = simulation_result3_flux[sorted_indices]
flux_trapping = np.interp(experiment3_input,
                                                        simulation_result3_temperature_order,
                                                        simulation_result3_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment3_output)**2))/np.mean(experiment3_output)*100
ax1.text(350,1.0e-9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C0',fontsize=11)
simulation_result3_temperature = simulation_results3[IDX_TEMP][chosen_matrix3]
simulation_result3_flux = simulation_results3[IDX_FLUX_T2O_WET][chosen_matrix3]
sorted_indices = np.argsort(simulation_result3_temperature)
simulation_result3_temperature_order = simulation_result3_temperature[sorted_indices]
simulation_result3_flux_order = simulation_result3_flux[sorted_indices]
flux_trapping = np.interp(experiment4_input,
                                                        simulation_result3_temperature_order,
                                                        simulation_result3_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment4_output)**2))/np.mean(experiment4_output)*100
ax1.text(1100,1.0e-9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C1',fontsize=11)
plt.legend(fontsize=12)
plt.savefig('./val-2g_wet_trapping_flux_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

################################################################################
#################### Plot dry case from calibrated results #####################
################################################################################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
ax1.plot(experiment_input,
        experiment_output, 's', label="experiment: D from D2", c='C0', markersize=3)
ax1.plot(simulation_results4[IDX_TEMP][chosen_matrix4],
        simulation_results4[IDX_FLUX_T2_DRY][chosen_matrix4] * A / N_A, label=rf"trapping: D from D$_2$", c='C0')
ax1.plot(simulation_results4[IDX_TEMP][chosen_matrix4],
        simulation_results4[IDX_FLUX_T2O_DRY][chosen_matrix4] * A / N_A, label=rf"trapping: D from D$_2$O", c='C1')
ax1.plot(experiment2_input,
        experiment2_output, '.', label="experiment: D from D2O", c='C1')
ax1.set_xlabel(u'Temperature (K)',fontsize=14)
ax1.set_ylabel(u"Deuterium flux (mol/s)",fontsize=14)
ax1.set_xlim([300,1400])
ax1.set_ylim(bottom=0)
# ax1.set_yscale("log")
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
ax1.tick_params(axis='y')
simulation_result4_temperature = simulation_results4[IDX_TEMP][chosen_matrix4]
simulation_result4_flux = simulation_results4[IDX_FLUX_T2_DRY][chosen_matrix4]
sorted_indices = np.argsort(simulation_result4_temperature)
simulation_result4_temperature_order = simulation_result4_temperature[sorted_indices]
simulation_result4_flux_order = simulation_result4_flux[sorted_indices]
flux_trapping = np.interp(experiment_input,
                                                        simulation_result4_temperature_order,
                                                        simulation_result4_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment_output)**2))/np.mean(experiment_output)*100
ax1.text(380,1.0e-11, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C0',fontsize=11)
simulation_result4_temperature = simulation_results4[IDX_TEMP][chosen_matrix4]
simulation_result4_flux = simulation_results4[IDX_FLUX_T2O_DRY][chosen_matrix4]
sorted_indices = np.argsort(simulation_result4_temperature)
simulation_result4_temperature_order = simulation_result4_temperature[sorted_indices]
simulation_result4_flux_order = simulation_result4_flux[sorted_indices]
flux_trapping = np.interp(experiment2_input,
                                                        simulation_result4_temperature_order,
                                                        simulation_result4_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment2_output)**2))/np.mean(experiment2_output)*100
ax1.text(380,0.35e-11, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C1',fontsize=11)
plt.legend(fontsize=12)
plt.savefig('./val-2g_dry_trapping_flux_calibrated_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

################################################################################
##################### Plot wet case from calibrated results ####################
################################################################################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
ax1.plot(simulation_results4[IDX_TEMP][chosen_matrix4],
        simulation_results4[IDX_FLUX_T2O_WET][chosen_matrix4] * A / N_A, label=rf"trapping: D from D$_2$O", c='C1')
ax1.plot(experiment4_input,
        experiment4_output, '.', label="experiment: D from D2O", c='C1')
ax1.plot(experiment3_input,
        experiment3_output, 's', label="experiment: D from D2", c='C0', markersize=3)
ax1.plot(simulation_results4[IDX_TEMP][chosen_matrix4],
        simulation_results4[IDX_FLUX_T2_WET][chosen_matrix4] * A / N_A, label=rf"trapping: D from D$_2$", c='C0')
ax1.set_xlabel(u'Temperature (K)',fontsize=14)
ax1.set_ylabel(u"Deuterium flux (mol/s)",fontsize=14)
ax1.set_xlim([300,1400])
ax1.set_ylim([0,2.4e-9])
# ax1.set_yscale("log")
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
ax1.tick_params(axis='y')
simulation_result4_temperature = simulation_results4[IDX_TEMP][chosen_matrix4]
simulation_result4_flux = simulation_results4[IDX_FLUX_T2_WET][chosen_matrix4]
sorted_indices = np.argsort(simulation_result4_temperature)
simulation_result4_temperature_order = simulation_result4_temperature[sorted_indices]
simulation_result4_flux_order = simulation_result4_flux[sorted_indices]
flux_trapping = np.interp(experiment3_input,
                                                        simulation_result4_temperature_order,
                                                        simulation_result4_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment3_output)**2))/np.mean(experiment3_output)*100
ax1.text(380,0.5e-9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C0',fontsize=11)
simulation_result4_temperature = simulation_results4[IDX_TEMP][chosen_matrix4]
simulation_result4_flux = simulation_results4[IDX_FLUX_T2O_WET][chosen_matrix4]
sorted_indices = np.argsort(simulation_result4_temperature)
simulation_result4_temperature_order = simulation_result4_temperature[sorted_indices]
simulation_result4_flux_order = simulation_result4_flux[sorted_indices]
flux_trapping = np.interp(experiment4_input,
                                                        simulation_result4_temperature_order,
                                                        simulation_result4_flux_order)
RMSPE = np.sqrt(np.mean((flux_trapping * A / N_A - experiment4_output)**2))/np.mean(experiment4_output)*100
ax1.text(380,1.45e-9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='C1',fontsize=11)
plt.legend(fontsize=12)
plt.savefig('./val-2g_wet_trapping_flux_calibrated_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

################################################################################
######################### Extract json file information ########################
################################################################################
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    file = f"../../../../test/tests/val-2g/gold/val-2g_PSS/both_cases_trapping.json"
else:                                  # if in test folder
    file = f"./gold/val-2g_PSS/both_cases_trapping.json"
num_iter = 10
parallel_props = 1
dim = 18
num_cases = num_iter * parallel_props

with open(file) as f:
    data = json.load(f)
inputs = np.zeros((num_iter,dim,parallel_props))
obj_values = np.zeros((num_iter,parallel_props))
for ii in np.arange(1,num_iter+1,1):
    inputs[ii-1,:,:] = np.array(data["time_steps"][ii]['PSS_reporter']['inputs'])
    obj_values[ii-1, :] = np.array(data["time_steps"][ii]['PSS_reporter']['output_required'])

index_max = np.argmax(obj_values[:,:]) # max index in 1D
index_max_2d = np.unravel_index(index_max, obj_values.shape) # max index in 2D
input_optimized = inputs[index_max_2d[0],:,index_max_2d[1]] # input in max index
# print('Optimized input values: '+str(input_optimized))
# print(f'Optimized objective (log inv error): {obj_values[index_max_2d]} at {index_max_2d}')
plt.plot(np.maximum.accumulate(obj_values))
plt.xlabel('Iteration',fontsize=14)
plt.ylabel('Log inverse error',fontsize=14)
plt.xlim([0, num_iter-1])
plt.ylim([-0.24, -0.2])
plt.savefig("./val-2g_trapping_optimization_PSS_iterations", bbox_inches='tight', dpi=300)
plt.close()

# ======================== plot parameter distribution ======================= #

corresponding_ave = [1.244, -2.557, 8.91, 17.898, 4.670e-01, -1.61, -30.403, -44.027, 1.902e-9, 0.1216, 1.237e-7, 1.003e5, 2.063e-2, 9.535e4, -1.564e5, -1.374e2, -1.122e5, -3.699e1]
corresponding_std = [0.001 , 0.001  , 0.01  , 0.001 , 0.001, 0.01,  0.001 ,   0.001, 0.001e-9, 0.0001, 0.001e-7, 0.001e5, 0.001e-2, 0.001e4, 0.001e5,  0.001e2, 0.001e5 ,  0.001e1]
label_names = [r"$\epsilon_r$", r"$\chi$", r"$\tau_{t0}$", r"$\tau_{r0}$", r"$\epsilon_t$",r"$C_{e^\prime0}$",r"$K_1^{D_2O}$",r"$K_1^{D_2}$",r"$D_0^{OD^{\cdot}}$",r"$E^{OD^{\cdot}}$",r"$D_0^{V_O^{\cdot\cdot}}$","$E^{V_O^{\cdot\cdot}}$","$D_0^{e^\prime}$","$E^{e^\prime}$",r"$\Delta H_{D_2O}^0$",r"$\Delta S_{D_2O}^0$",r"$\Delta H_{D_2}^0$",r"$\Delta S_{D_2}^0$"]

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
num_bins = 16
x_limit = [-4,4]
y_limit = [0.00,0.7]

# perfect normal distribution
perfect_norm_distribution_x = np.linspace(x_limit[0], x_limit[1], 1000)
perfect_norm_distribution_y = norm.pdf(perfect_norm_distribution_x, 0, 1)
ax1.plot(perfect_norm_distribution_x, perfect_norm_distribution_y, '-', color='k')
colors = [
    '#1f77b4',  # blue
    '#ff7f0e',  # orange
    '#2ca02c',  # green
    '#d62728',  # red
    '#9467bd',  # purple
    '#8c564b',  # brown
    '#e377c2',  # pink
    '#7f7f7f',  # gray
    '#bcbd22',  # yellow-green
    '#17becf',  # teal
    '#aec7e8',  # light blue
    '#ffbb78',  # light orange
    '#98df8a',  # light green
    '#ff9896',  # light red
    '#c5b0d5',  # light purple
    '#c49c94',  # light brown
    '#f7b6d2',  # light pink
    '#c7c7c7',  # light gray
    '#dbdb8d',  # light yellow-green
    '#9edae5'   # light teal
]

# Each parameters
for i in range(dim):
    organized_input = inputs[:,i,:].flatten()
    average_input = np.mean(organized_input)
    std_input = np.std(organized_input)
    norm_optimized_input = (input_optimized[i] - corresponding_ave[i]) / corresponding_std[i]
    ax1.plot([norm_optimized_input,norm_optimized_input], y_limit, '--', color=colors[i], label=label_names[i])

ax1.set_xlabel(u'Parameters',fontsize=18)
ax1.set_ylabel(u"Frequency",fontsize=18)
ax1.set_xlim(x_limit)
ax1.set_ylim(y_limit)
ax1.set_xticks([-3,-2,-1,0,1,2,3],[r"$\mu-3\sigma$",r"$\mu-2\sigma$",r"$\mu-1\sigma$",r"$\mu$",r"$\mu+1\sigma$",r"$\mu+2\sigma$",r"$\mu+3\sigma$"])
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
plt.legend(loc=[1.01,0.01],fontsize=18,ncols=2)
plt.savefig('./val-2g_trapping_optimization_inputs_PSS.png', bbox_inches='tight', dpi=300)
plt.close(fig)
