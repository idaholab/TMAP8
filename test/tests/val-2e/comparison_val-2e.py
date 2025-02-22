import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Define methods

def numerical_solution_on_experiment_input(experiment_input, tmap_input, tmap_output):
    """interpolate numerical solution to the experimental time step

    Args:
        experiment_input (float, ndarray): experimental input data points
        tmap_input (float, ndarray): numerical input data points
        tmap_output (float, ndarray): numerical output data points

    Returns:
        float, ndarray: updated tmap_output based on the data points in experiment_input
    """
    new_tmap_output = np.zeros(len(experiment_input))
    for i in range(len(experiment_input)):
        left_limit = np.argwhere((np.diff(tmap_input < experiment_input[i])))[0][0]
        right_limit = left_limit + 1
        new_tmap_output[i] = (experiment_input[i] - tmap_input[left_limit]) / (tmap_input[right_limit] - tmap_input[left_limit]) * (tmap_output[right_limit] - tmap_output[left_limit]) + tmap_output[left_limit]
    return new_tmap_output

def read_csv_from_TMAP8(file_name, parameter_names):
    """Read simulation data in csv files from TMAP8

    Args:
        file_name (string): the file name at simulation folder
        parameter_names (list): the list of parameters extracted from csv files

    Returns:
        float, ndarray: the matrix keep the simulation results, first axis depended on len(parameter_names)
    """
    if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
        csv_folder = f"../../../../test/tests/val-2e/gold/{file_name}"
    else:                                  # if in test folder
        csv_folder = f"./gold/{file_name}"
    simulation_data = pd.read_csv(csv_folder)
    simulation_results = []
    for i in range(len(parameter_names)):
        simulation_results.append(simulation_data[parameter_names[i]])
    return simulation_results

#===============================================================================
# Physical constants
kb = 1.380649e-23  # J/K Boltzmann constant
R = 8.31446261815324 # J/mol/K Gas constant
Na = 6.02214076e23 # atom/mol Avogadro's number

# Model parameters for a/b/c
Q = 0.1 # m^3/s flow rate
T = [825, 825, 865] # K
Area = 1.8e-4 # m^2 area
time_history = np.array([150,250,350,450,550,650,750,850,950,1050,1150,1250,1350,1900]) # s
pressure_history = np.array([1.20e-4,2.41e-4,6.06e-4,1.30e-3,2.53e-3,7.08e-3,1.45e-2,2.63e-2,6.51e-2,0.116,0.297,0.760,1.550,3.370]) # Pa
pressure_enclosure1 = 1e-6 # Pa
dt_maximum = 5 # s - from the input file

################################################################################
################################# Val-2e a/b/c #################################
################################################################################
# Extract predictions in 1D model for val2e-abc
simulation_file_names = ["val-2ea_out.csv", "val-2eb_out.csv", "val-2ec_out.csv"]
parameter_names = ['time','flux_surface_right_D','pressure_upstream_D2','pressure_downstream_D2']
simulation_results_list = []
for i in range(len(simulation_file_names)):
    file_name = simulation_file_names[i]
    simulation_results = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
    simulation_results[parameter_names.index('flux_surface_right_D')] = -simulation_results[parameter_names.index('flux_surface_right_D')] * 1e12 / Na # D atoms/mum^2/s -> D2 mol/m^2/s
    simulation_results_list.append(simulation_results)

# find the pressure and flux
pressure_up_array = []
pressure_down_array = []
flux_array = []
flux_calculated_array = []
time_array = []
for index in range(len(simulation_results_list)):
    tmp_pressure_up_array = []
    tmp_pressure_down_array = []
    tmp_flux_array = []
    tmp_flux_calculated_array = []
    tmp_time_array = []
    time_history_copy = np.copy(time_history)
    for i in range(len(simulation_results_list[index][parameter_names.index('time')])):
        if len(time_history_copy) == 0: break
        if (time_history_copy[0] - simulation_results_list[index][parameter_names.index('time')][i]) < dt_maximum:
            tmp_pressure_up_array.append(simulation_results_list[index][parameter_names.index('pressure_upstream_D2')][i])
            tmp_pressure_down_array.append(simulation_results_list[index][parameter_names.index('pressure_downstream_D2')][i])
            tmp_flux_array.append(simulation_results_list[index][parameter_names.index('flux_surface_right_D')][i])
            tmp_time_array.append(simulation_results_list[index][parameter_names.index('time')])

            tmp_flux_calculated = (tmp_pressure_down_array[-1] - pressure_enclosure1) * Q / R / T[index] / Area
            tmp_flux_calculated_array.append(tmp_flux_calculated)
            time_history_copy = time_history_copy[1:]
    pressure_up_array.append(tmp_pressure_up_array)
    pressure_down_array.append(tmp_pressure_down_array)
    flux_array.append(tmp_flux_array)
    flux_calculated_array.append(tmp_flux_calculated_array)
    time_array.append(tmp_time_array)
    if len(tmp_time_array) < len(time_history):
        print(f"Some data missing: \n{time_array} \nand \n{time_history}")

# ============================================================================ #
# Extract data from experiments
experiment_results_list = []
experiment_file_names = ["experiment_thick_825K.csv", "experiment_thin_825K.csv", "experiment_thin_865K.csv"]

experiment_parameter_names = ['Pressure [Pa]','Flux [mol/m^2/s]']
for i in range(len(experiment_file_names)):
    file_name = experiment_file_names[i]
    experiment_results = read_csv_from_TMAP8(file_name, experiment_parameter_names) # read csv file
    experiment_results_list.append(experiment_results)

# ============================================================================ #
# Plot pressure history
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

time_history_plot = np.array([0,150,150,250,250,350,350,450,450,550,550,
                            650,650,750,750,850,850,950,950,1050,1050,
                            1150,1150,1250,1250,1350,1350,1900]) # s
pressure_history_plot = np.array([1.20e-4,1.20e-4,2.41e-4,2.41e-4,6.06e-4,6.06e-4,
                                1.30e-3,1.30e-3,2.53e-3,2.53e-3,7.08e-3,7.08e-3,
                                1.45e-2,1.45e-2,2.63e-2,2.63e-2,6.51e-2,6.51e-2,
                                0.116,0.116,0.297,0.297,0.760,0.760,1.550,1.550,
                                3.370,3.370]) # Pa
time_history_plot_mixture = np.array([0,150,150,250,250,350,350,450,450,550,550,
                            650,650,750,750,1900]) # s
pressure_history_plot_mixture_D2 = np.array([1.8421-4,1.8421-4,1e-3,1e-3,3e-3,3e-3,
                                0.009,0.009,0.027,0.027,0.081,0.081,0.243,0.243,
                                0.729,0.729]) # Pa
plt.plot(time_history_plot, pressure_history_plot, label = r'D$_2$')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Pressure (Pa)")
ax.set_xlim([0,1900])
ax.legend(loc="best")
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('val-2e_comparison_pressure_history.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ============================================================================ #
# Plot figure for pressure and flux for 2e-abc
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

label_name = ["0.05mm, 825K", "0.025mm, 825K", "0.025mm, 865K"]
label_name_postfix = ["val-2ea", "val-2eb", "val-2ec"]
signal_list = ['o','s','^']
for index in [2,1,0]:
    ax.plot(pressure_up_array[index], flux_calculated_array[index], label=f'{label_name[index]} in {label_name_postfix[index]} (TMAP8)', c=f'C{index}')
for index in [2,1,0]:
    ax.plot(experiment_results_list[index][experiment_parameter_names.index('Pressure [Pa]')],
            experiment_results_list[index][experiment_parameter_names.index('Flux [mol/m^2/s]')],
            signal_list[index], label=f'{label_name[index]} (experiment)', c=f'C{index}')
ax.set_xlabel(u'Pressure (Pa)')
ax.set_ylabel(r"Flux (mol/m$^2$/s)")
ax.legend(loc="best")
ax.set_xlim([1e-4,1e1])
ax.set_xscale('log')
ax.set_yscale('log')
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
text_loc = [[5e-3,5e-7], [2.5e-4,1.8e-6], [8e-4,8e-6]]
for index in range(len(simulation_results_list)):
    experiment_input = experiment_results_list[index][experiment_parameter_names.index('Pressure [Pa]')]
    experiment_output = experiment_results_list[index][experiment_parameter_names.index('Flux [mol/m^2/s]')]
    tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_input,
                                                                pressure_up_array[index],
                                                                flux_calculated_array[index])
    RMSPE = np.sqrt(np.mean(((tmap_flux_for_rmspe-experiment_output)/experiment_output)**2) )*100
    ax.text(text_loc[index][0],text_loc[index][1], 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',color=f'C{index}')
ax.minorticks_on()
plt.savefig('val-2e_comparison_diffusion.png', bbox_inches='tight', dpi=300)
plt.close(fig)


################################################################################
################################## Val-2e d/e ##################################
################################################################################
# Modeling data for d/e
T = 870 # K
time_history = np.array([150,250,350,450,550,650,750,1000])
pressure_history_D = np.array([1.8421e-4,1e-3,3e-3,0.009,0.027,0.081,0.243,0.729])
pressure_history_H = 0.063
pressure_enclosure1 = 1e-7

# Extract predictions in 1D model for val2e-de
simulation_results_list = []
simulation_file_names = ["val-2ed_out.csv"]
parameter_names = ['time','pressure_downstream_H2','pressure_downstream_D2','pressure_downstream_HD','pressure_upstream_H2','pressure_upstream_D2','pressure_upstream_HD','flux_surface_right_D','flux_surface_right_H']
for i in range(len(simulation_file_names)):
    file_name = simulation_file_names[i]
    simulation_results = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
    simulation_results[parameter_names.index('flux_surface_right_D')] = -simulation_results[parameter_names.index('flux_surface_right_D')] * 1e12 / Na # D atoms/mum^2/s -> D mol/m^2/s
    simulation_results[parameter_names.index('flux_surface_right_H')] = -simulation_results[parameter_names.index('flux_surface_right_H')] * 1e12 / Na # D atoms/mum^2/s -> D mol/m^2/s
    simulation_results_list.append(simulation_results)

# find the pressure and flux
pressure_array_H2 = []
pressure_array_D2 = []
pressure_array_HD = []
pressure_down_array_H2 = []
pressure_down_array_D2 = []
pressure_down_array_HD = []
flux_array_H2 = []
flux_array_D2 = []
flux_array_HD = []
flux_array_sum = []
for index in range(len(simulation_results_list)):
    tmp_pressure_array_H2 = []
    tmp_pressure_array_D2 = []
    tmp_pressure_array_HD = []
    tmp_pressure_down_array_H2 = []
    tmp_pressure_down_array_D2 = []
    tmp_pressure_down_array_HD = []
    tmp_flux_array_H2 = []
    tmp_flux_array_D2 = []
    tmp_flux_array_HD = []
    tmp_flux_array_sum = []
    time_history_copy = np.copy(time_history)
    for i in range(len(simulation_results_list[index][parameter_names.index('time')])):
        if len(time_history_copy) == 0: break
        if (time_history_copy[0] - simulation_results_list[index][parameter_names.index('time')][i]) < dt_maximum:
            # Get pressure
            tmp_pressure_array_H2.append(simulation_results_list[index][parameter_names.index('pressure_upstream_H2')][i])
            tmp_pressure_array_D2.append(simulation_results_list[index][parameter_names.index('pressure_upstream_D2')][i])
            tmp_pressure_array_HD.append(simulation_results_list[index][parameter_names.index('pressure_upstream_HD')][i])
            tmp_pressure_down_array_H2.append(simulation_results_list[index][parameter_names.index('pressure_downstream_H2')][i])
            tmp_pressure_down_array_D2.append(simulation_results_list[index][parameter_names.index('pressure_downstream_D2')][i])
            tmp_pressure_down_array_HD.append(simulation_results_list[index][parameter_names.index('pressure_downstream_HD')][i])
            # Get flux
            tmp_flux_H2 = (tmp_pressure_down_array_H2[-1] - pressure_enclosure1) * Q / R / T / Area
            tmp_flux_D2 = (tmp_pressure_down_array_D2[-1] - pressure_enclosure1) * Q / R / T / Area
            tmp_flux_HD = (tmp_pressure_down_array_HD[-1] - pressure_enclosure1) * Q / R / T / Area
            tmp_flux_array_H2.append(tmp_flux_H2)
            tmp_flux_array_D2.append(tmp_flux_D2)
            tmp_flux_array_HD.append(tmp_flux_HD)
            tmp_flux_array_sum.append(tmp_flux_H2+tmp_flux_D2+tmp_flux_HD)
            time_history_copy = time_history_copy[1:]
    pressure_array_H2.append(tmp_pressure_array_H2)
    pressure_array_D2.append(tmp_pressure_array_D2)
    pressure_array_HD.append(tmp_pressure_array_HD)
    pressure_down_array_H2.append(tmp_pressure_down_array_H2)
    pressure_down_array_D2.append(tmp_pressure_down_array_D2)
    pressure_down_array_HD.append(tmp_pressure_down_array_HD)
    flux_array_H2.append(tmp_flux_array_H2)
    flux_array_D2.append(tmp_flux_array_D2)
    flux_array_HD.append(tmp_flux_array_HD)
    flux_array_sum.append(tmp_flux_array_sum)

    if len(tmp_pressure_array_D2) < len(time_history):
        print(f"Some data missing: \n{tmp_pressure_array_D2} \nand \n{pressure_history_D}")
pressure_array_H2 = np.array(pressure_array_H2)
pressure_array_D2 = np.array(pressure_array_D2)
pressure_array_HD = np.array(pressure_array_HD)
flux_array_H2 = np.array(flux_array_H2)
flux_array_D2 = np.array(flux_array_D2)
flux_array_HD = np.array(flux_array_HD)
flux_array_sum = np.array(flux_array_sum)

# ============================================================================ #
# Extract data from experiments
experiment_results_list = []
experiment_file_names = ["experiment_mixture_H2.csv", "experiment_mixture_D2.csv", "experiment_mixture_HD.csv"]

experiment_parameter_names = ['Pressure [Pa]','Flux [mol/m^2/s]']
for i in range(len(experiment_file_names)):
    file_name = experiment_file_names[i]
    experiment_results = read_csv_from_TMAP8(file_name, experiment_parameter_names) # read csv file
    experiment_results_list.append(experiment_results)

# get sum results
experiment_results_pressure_sum =  (experiment_results_list[0][experiment_parameter_names.index('Pressure [Pa]')] +
                                    experiment_results_list[1][experiment_parameter_names.index('Pressure [Pa]')] +
                                    experiment_results_list[2][experiment_parameter_names.index('Pressure [Pa]')]) / 3
experiment_results_flux_sum =  (experiment_results_list[0][experiment_parameter_names.index('Flux [mol/m^2/s]')] +
                                experiment_results_list[1][experiment_parameter_names.index('Flux [mol/m^2/s]')] +
                                experiment_results_list[2][experiment_parameter_names.index('Flux [mol/m^2/s]')])

# ============================================================================ #
# Plot pressure history
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

time_history_plot_mixture = np.array([0,150,150,250,250,350,350,450,450,550,550,
                            650,650,750,750,1000]) # s
pressure_history_plot_mixture_D2 = np.array([1.8421e-4,1.8421e-4,1e-3,1e-3,3e-3,3e-3,
                                0.009,0.009,0.027,0.027,0.081,0.081,0.243,0.243,
                                0.729,0.729]) # Pa
pressure_history_plot_mixture_H2 = np.ones(len(pressure_history_plot_mixture_D2)) * pressure_history_H
plt.plot(time_history_plot_mixture, pressure_history_plot_mixture_D2, label = r"D$_2$", color='C0')
plt.plot(time_history_plot_mixture, pressure_history_plot_mixture_H2, label = r"H$_2$", color='C1')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Pressure (Pa)")
ax.legend(loc="best")
ax.set_xlim([0,1000])
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('val-2e_comparison_mixture_pressure_history.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ============================================================================ #
# Plot figure for pressure and flux for 2ed
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

label_name = [r"H$_2$", r"D$_2$", r"HD", r"sum"]
signal_list = ['o','s','^','+']


ax.plot(pressure_array_D2[0] + pressure_array_HD[0] / 2,
        flux_array_sum[0], label=f'{label_name[3]} in val-2ed (TMAP8)', c=f'C{3}')
ax.plot(pressure_array_D2[0] + pressure_array_HD[0] / 2,
        flux_array_D2[0], label=f'{label_name[1]} in val-2ed (TMAP8)', c=f'C{1}')
ax.plot(pressure_array_D2[0] + pressure_array_HD[0] / 2,
        flux_array_H2[0], label=f'{label_name[0]} in val-2ed (TMAP8)', c=f'C{0}')
ax.plot(pressure_array_D2[0] + pressure_array_HD[0] / 2,
        flux_array_HD[0], label=f'{label_name[2]} in val-2ed (TMAP8)', c=f'C{2}')

ax.plot(experiment_results_pressure_sum,
        experiment_results_flux_sum,
        signal_list[3], label=f'{label_name[3]} (experiment)', c=f'C{3}')
ax.plot(experiment_results_list[1][experiment_parameter_names.index('Pressure [Pa]')],
        experiment_results_list[1][experiment_parameter_names.index('Flux [mol/m^2/s]')],
        signal_list[1], label=f'{label_name[1]} (experiment)', c=f'C{1}')
ax.plot(experiment_results_list[0][experiment_parameter_names.index('Pressure [Pa]')],
        experiment_results_list[0][experiment_parameter_names.index('Flux [mol/m^2/s]')],
        signal_list[0], label=f'{label_name[0]} (experiment)', c=f'C{0}')
ax.plot(experiment_results_list[2][experiment_parameter_names.index('Pressure [Pa]')],
        experiment_results_list[2][experiment_parameter_names.index('Flux [mol/m^2/s]')],
        signal_list[2], label=f'{label_name[2]} (experiment)', c=f'C{2}')

ax.set_xlabel(u'Effective deuterium pressure (Pa)')
ax.set_ylabel(r"Partial release rates (mol/m$^2$/s)")
ax.legend(loc="best")
ax.set_xlim([1e-3, 1e0])
ax.set_ylim([2e-8,4e-4])
ax.set_xscale('log')
ax.set_yscale('log')
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
# error
simulation_output_list = [flux_array_H2[0], flux_array_D2[0], flux_array_HD[0], flux_array_sum[0]]
text_loc = [[1.0e-3,1.0e-5], [1.0e-3,1.9e-6], [1.0e-3,1.5e-7], [1.0e-3,3e-5]]
for index in range(len(simulation_output_list)):
    simulation_input = pressure_array_D2[0] + pressure_array_HD[0] / 2
    simulation_output = simulation_output_list[index]
    if index == 3:
        experiment_input = experiment_results_pressure_sum[:-1]
        experiment_output = experiment_results_flux_sum[:-1]
    else:
        experiment_input = experiment_results_list[index][experiment_parameter_names.index('Pressure [Pa]')][:-1]
        experiment_output = experiment_results_list[index][experiment_parameter_names.index('Flux [mol/m^2/s]')][:-1]
    tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_input,
                                                                simulation_input,
                                                                simulation_output)
    RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe-experiment_output)**2) )
    RMSPE = RMSE*100/np.mean(experiment_output)
    ax.text(text_loc[index][0],text_loc[index][1], 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',color=f'C{index}')
ax.minorticks_on()
plt.savefig('val-2e_comparison_mixture_diffusion.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ============================================================================ #
# Extract predictions in 1D model for val2ee
simulation_results_list = []
simulation_file_names = ["val-2ee_out.csv"]
parameter_names = ['time','pressure_downstream_H2','pressure_downstream_D2','pressure_downstream_HD','pressure_upstream_H2','pressure_upstream_D2','pressure_upstream_HD','flux_surface_right_D','flux_surface_right_H','flux_on_left_D2','flux_on_left_H2','flux_on_left_HD']
for i in range(len(simulation_file_names)):
    file_name = simulation_file_names[i]
    simulation_results = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
    simulation_results[parameter_names.index('flux_surface_right_D')] = -simulation_results[parameter_names.index('flux_surface_right_D')] * 1e12 / Na # D atoms/mum^2/s -> D mol/m^2/s
    simulation_results[parameter_names.index('flux_surface_right_H')] = -simulation_results[parameter_names.index('flux_surface_right_H')] * 1e12 / Na # D atoms/mum^2/s -> D mol/m^2/s
    simulation_results[parameter_names.index('flux_on_left_D2')] = -simulation_results[parameter_names.index('flux_on_left_D2')] * 1e12 / Na # D atoms/mum^2/s -> D mol/m^2/s
    simulation_results[parameter_names.index('flux_on_left_H2')] = -simulation_results[parameter_names.index('flux_on_left_H2')] * 1e12 / Na # D atoms/mum^2/s -> D mol/m^2/s
    simulation_results[parameter_names.index('flux_on_left_HD')] = -simulation_results[parameter_names.index('flux_on_left_HD')] * 1e12 / Na # D atoms/mum^2/s -> D mol/m^2/s
    simulation_results_list.append(simulation_results)

# find the pressure and flux
pressure_array_H2 = []
pressure_array_D2 = []
pressure_array_HD = []
pressure_down_array_H2 = []
pressure_down_array_D2 = []
pressure_down_array_HD = []
flux_array_H2 = []
flux_array_D2 = []
flux_array_HD = []
flux_array_sum = []
for index in range(len(simulation_results_list)):
    tmp_pressure_array_H2 = []
    tmp_pressure_array_D2 = []
    tmp_pressure_array_HD = []
    tmp_pressure_down_array_H2 = []
    tmp_pressure_down_array_D2 = []
    tmp_pressure_down_array_HD = []
    tmp_flux_array_H2 = []
    tmp_flux_array_D2 = []
    tmp_flux_array_HD = []
    tmp_flux_array_sum = []
    time_history_copy = np.copy(time_history)
    for i in range(len(simulation_results_list[index][parameter_names.index('time')])):
        if len(time_history_copy) == 0: break
        if (time_history_copy[0] - simulation_results_list[index][parameter_names.index('time')][i]) < dt_maximum:
            # Get pressure
            tmp_pressure_array_H2.append(simulation_results_list[index][parameter_names.index('pressure_upstream_H2')][i])
            tmp_pressure_array_D2.append(simulation_results_list[index][parameter_names.index('pressure_upstream_D2')][i])
            tmp_pressure_array_HD.append(simulation_results_list[index][parameter_names.index('pressure_upstream_HD')][i])
            tmp_pressure_down_array_H2.append(simulation_results_list[index][parameter_names.index('pressure_downstream_H2')][i])
            tmp_pressure_down_array_D2.append(simulation_results_list[index][parameter_names.index('pressure_downstream_D2')][i])
            tmp_pressure_down_array_HD.append(simulation_results_list[index][parameter_names.index('pressure_downstream_HD')][i])
            # Get flux
            tmp_flux_H2 = (tmp_pressure_down_array_H2[-1] - pressure_enclosure1) * Q / R / T / Area
            tmp_flux_D2 = (tmp_pressure_down_array_D2[-1] - pressure_enclosure1) * Q / R / T / Area
            tmp_flux_HD = (tmp_pressure_down_array_HD[-1] - pressure_enclosure1) * Q / R / T / Area
            tmp_flux_array_H2.append(tmp_flux_H2)
            tmp_flux_array_D2.append(tmp_flux_D2)
            tmp_flux_array_HD.append(tmp_flux_HD)
            tmp_flux_array_sum.append(tmp_flux_H2+tmp_flux_D2+tmp_flux_HD)
            time_history_copy = time_history_copy[1:]
    pressure_array_H2.append(tmp_pressure_array_H2)
    pressure_array_D2.append(tmp_pressure_array_D2)
    pressure_array_HD.append(tmp_pressure_array_HD)
    pressure_down_array_H2.append(tmp_pressure_down_array_H2)
    pressure_down_array_D2.append(tmp_pressure_down_array_D2)
    pressure_down_array_HD.append(tmp_pressure_down_array_HD)
    flux_array_H2.append(tmp_flux_array_H2)
    flux_array_D2.append(tmp_flux_array_D2)
    flux_array_HD.append(tmp_flux_array_HD)
    flux_array_sum.append(tmp_flux_array_sum)

    if len(tmp_pressure_array_D2) < len(time_history):
        print(f"Some data missing: \n{tmp_pressure_array_D2} \nand \n{pressure_history_D}")
pressure_array_H2 = np.array(pressure_array_H2)
pressure_array_D2 = np.array(pressure_array_D2)
pressure_array_HD = np.array(pressure_array_HD)
flux_array_H2 = np.array(flux_array_H2)
flux_array_D2 = np.array(flux_array_D2)
flux_array_HD = np.array(flux_array_HD)
flux_array_sum = np.array(flux_array_sum)


# ============================================================================ #
# Plot figure for pressure and flux for 2ee
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

label_name = [r"H$_2$", r"D$_2$", r"HD", r"sum"]
signal_list = ['o','s','^','+']

layer = 0
ax.plot(pressure_array_D2[layer] + pressure_array_HD[layer] / 2,
        flux_array_sum[layer], label=f'{label_name[3]} in val-2ee (TMAP8)', c=f'C{3}')
ax.plot(pressure_array_D2[layer] + pressure_array_HD[layer] / 2,
        flux_array_D2[layer], label=f'{label_name[1]} in val-2ee (TMAP8)', c=f'C{1}')
ax.plot(pressure_array_D2[layer] + pressure_array_HD[layer] / 2,
        flux_array_HD[layer], label=f'{label_name[2]} in val-2ee (TMAP8)', c=f'C{2}')
ax.plot(pressure_array_D2[layer] + pressure_array_HD[layer] / 2,
        flux_array_H2[layer], label=f'{label_name[0]} in val-2ee (TMAP8)', c=f'C{0}')
ax.plot(experiment_results_pressure_sum,
        experiment_results_flux_sum,
        signal_list[3], label=f'{label_name[3]} (experiment)', c=f'C{3}')
ax.plot(experiment_results_list[1][experiment_parameter_names.index('Pressure [Pa]')],
        experiment_results_list[1][experiment_parameter_names.index('Flux [mol/m^2/s]')],
        signal_list[1], label=f'{label_name[1]} (experiment)', c=f'C{1}')
ax.plot(experiment_results_list[2][experiment_parameter_names.index('Pressure [Pa]')],
        experiment_results_list[2][experiment_parameter_names.index('Flux [mol/m^2/s]')],
        signal_list[2], label=f'{label_name[2]} (experiment)', c=f'C{2}')
ax.plot(experiment_results_list[0][experiment_parameter_names.index('Pressure [Pa]')],
        experiment_results_list[0][experiment_parameter_names.index('Flux [mol/m^2/s]')],
        signal_list[0], label=f'{label_name[0]} (experiment)', c=f'C{0}')


ax.set_xlabel(u'Effective deuterium pressure (Pa)')
ax.set_ylabel(r"Partial release rates (mol/m$^2$/s)")
ax.legend(loc="best")
ax.set_xlim([1e-3, 1e0])
ax.set_ylim([2e-8,4e-4])
ax.set_xscale('log')
ax.set_yscale('log')
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
# error
simulation_output_list = [flux_array_H2[0], flux_array_D2[0], flux_array_HD[0], flux_array_sum[0]]
text_loc = [[1e-3,1.0e-5], [2.5e-3,4e-8 ], [1.0e-3,3.0e-7], [1.0e-3,2.5e-5]]
for index in range(len(simulation_output_list)):
    simulation_input = pressure_array_D2[0] + pressure_array_HD[0] / 2
    simulation_output = simulation_output_list[index]
    if index == 3:
        experiment_input = experiment_results_pressure_sum[:-1]
        experiment_output = experiment_results_flux_sum[:-1]
    else:
        experiment_input = experiment_results_list[index][experiment_parameter_names.index('Pressure [Pa]')][:-1]
        experiment_output = experiment_results_list[index][experiment_parameter_names.index('Flux [mol/m^2/s]')][:-1]
    tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_input,
                                                                simulation_input,
                                                                simulation_output)
    RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe-experiment_output)**2) )
    RMSPE = RMSE*100/np.mean(experiment_output)
    ax.text(text_loc[index][0],text_loc[index][1], 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',color=f'C{index}')
ax.minorticks_on()
plt.savefig('val-2e_comparison_mixture_diffusion_recombination.png', bbox_inches='tight', dpi=300)
plt.close(fig)

