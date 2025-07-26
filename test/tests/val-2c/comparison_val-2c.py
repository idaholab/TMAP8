import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import json
import os
from scipy.stats import norm

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Define methods

def common_times_generator(time_exp, value_exp, time_solution, value_solution):
    """samples the experimental data and the simulation data to generate a common time array to enable RMSE calculations

    Args:
        time_exp (np.array): array of times for experimental data (in strictly increasing order)
        value_exp (np.array): array of experimental values defined with steps
        time_solution (np.array): array of solution time (in strictly increasing order)
        value_solution (np.array): array of solution value over time

    Returns:
        time_sample (np.array): array of time values (in strictly increasing order)
        value_exp_sampled (np.array): array of experimental values corresponding to time_sample values
        value_solution_sampled (np.array): array of simulation values corresponding to time_sample values
    """
    time_sample = []
    index_exp = 1
    value_exp_sampled = []
    value_solution_sampled = []

    for i in range(len(time_solution)):
        # we determine the smallest index_exp for which time_exp[index_exp] is smaller than time_solution[i+1]
        if time_solution[i] < time_exp[len(time_exp)-1]: # there is no experimental data beyond this time value
            index_exp = next(k for k, value in enumerate(time_exp) if value > time_solution[i])
            if (index_exp >= 1) and (index_exp % 2): # the current time falls within a range where there is experimental data (index_exp is odd), and it is sampled
                time_sample.append(time_solution[i])
                value_exp_sampled.append(value_exp[index_exp])
                value_solution_sampled.append(value_solution[i])
    return np.array(time_sample), np.array(value_exp_sampled), np.array(value_solution_sampled)

def sample_solution(time_stamps, time_solution, value_solution):
    """sample a solution at the desired time stamps

    Args:
        time_stamps (np.array): array of time stamps to sample the solution at (in strictly increasing order)
        time_solution (np.array): array of solution time (in strictly increasing order)
        value_solution (np.array): array of solution value over time

    Returns:
        np.array: array of solution data at desired time stamps
    """
    value_solution_samples = len(time_stamps)*[0]
    for i in range(len(time_stamps)):
        # find the index of the first element greater than the current time stamp
        if time_stamps[i+1] > time_solution[len(time_solution)-1]:  ##### -1 does not work for this
            index_1 = len(time_solution)-2
            index_2 = len(time_solution)-1
        else:
            index = next(k for k, value in enumerate(time_solution)
                            if value >= time_stamps[i+1])
            # determine the two times around the current time stamp
            if index==0:
                index_1 = 0
                index_2 = 1
            else:
                index_1 = index-1
                index_2 = index
        # interpolate the solution value (linear apprimation)
        value_solution_samples[i] = (value_solution[index_2]-value_solution[index_1])/(time_solution[index_2]-time_solution[index_1])* (time_stamps[i+1]-time_solution[index_1]) + value_solution[index_1]
    return value_solution_samples

#===============================================================================
# Physical constants, conversion, and model constants
Curie = 3.7e10 # desintegrations/s - activity of one Curie
decay_rate_tritium = 1.78199e-9 # desintegrations/s/atoms
conversion_Ci_atom = decay_rate_tritium / Curie # 1 tritium at = ~4.82e-20 Ci
length_scale = 1e6 # m -> microns
time_scale = 60*60 # h -> s

#===============================================================================
# Extract TMAP8 predictions
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/val-2c_immediate_injection_csv.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2c_immediate_injection_csv.csv"
tmap8_prediction = pd.read_csv(csv_folder)
tmap8_time = tmap8_prediction['time']
tmap8_t2_enclosure_concentration = tmap8_prediction['t2_enclosure_edge_concentration']
tmap8_hto_enclosure_concentration = tmap8_prediction['hto_enclosure_edge_concentration']

# Extract TMAP8 predictions - delay
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/val-2c_delay_csv.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2c_delay_csv.csv"
tmap8_prediction_delay = pd.read_csv(csv_folder)
tmap8_time_delay = tmap8_prediction_delay['time']
tmap8_t2_enclosure_concentration_delay = tmap8_prediction_delay['t2_enclosure_edge_concentration']
tmap8_hto_enclosure_concentration_delay = tmap8_prediction_delay['hto_enclosure_edge_concentration']

# Extract TMAP8 predictions - calibrated
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/val-2c_delay_calibrated_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2c_delay_calibrated_out.csv"
tmap8_prediction_delay_calibrated = pd.read_csv(csv_folder)
tmap8_time_delay_calibrated = tmap8_prediction_delay_calibrated['time']
tmap8_t2_enclosure_concentration_delay_calibrated = tmap8_prediction_delay_calibrated['t2_enclosure_edge_concentration']
tmap8_hto_enclosure_concentration_delay_calibrated = tmap8_prediction_delay_calibrated['hto_enclosure_edge_concentration']

#===============================================================================
# Extract information from Parallel Subset Simulation calibration study

# Feature of the Parallel Subset Simulation
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    file_json = "../../../../test/tests/val-2c/gold/val-2c_pss_results/val-2c_pss_main_out.json"
else:                                  # if in test folder
    file_json = "./gold/val-2c_pss_results/val-2c_pss_main_out.json"
n_procs = 5 # number of processors with which the pss study was conducted
n_subsets = 5 # number of subset used in pss study
n_samples_per_subset = 1000 # number of samples per subset used in pss study
parameters = ['reaction_rate', 'diffusivity_elemental_tritium', 'diffusivity_tritiated_water', 'log_solubility_elemental_tritium', 'log_solubility_tritiated_water', 'time_injection_T2_end']
parameters_legend = ['$K^0$', '$D^e$', '$D^w$', 'log($K_S^e$)', 'log($K_S^w$)', '$t_{injection}$']
n_variables = len(parameters)

# Open output file of pss study
f = open(file_json,)
data = json.load(f)

# determine number of steps and create appropriate input and output files
n_steps = int(n_subsets * n_samples_per_subset / n_procs)
n_trials = n_procs*(n_steps-1)
outputs = np.zeros(n_trials)
inputs = np.zeros((n_trials,n_variables))

# extract the input values and the corresponding outputs - loop through all steps
for i in np.arange(n_steps):
    ind1 = np.arange((i-1)*n_procs,(i)*n_procs,1).astype(int)
    outputs[ind1] = np.array(data["time_steps"][i.astype(int)]["adaptive_MC"]["output_required"])
    tmp = np.array(data["time_steps"][i.astype(int)]["adaptive_MC"]["inputs"])
    # loop through all input dimensions
    for j in np.arange(0,n_variables):
        inputs[ind1,j] = tmp[j,:].reshape(n_procs)

# plot the ouputs to check behavior
fig, ax = plt.subplots(figsize=(5,3))
ax.plot(outputs)
ax.set_xlabel(r'Number of steps (-)')
ax.set_ylabel(r"Metric to be optimized")
ax.set_xlim(left=0)
ax.set_xlim(right=n_trials)
ax.set_ylim(bottom=0) # assumes the metric is positive
ax.set_ylim(top=np.max(outputs)*1.05)
ax.minorticks_on()
plt.savefig('val-2c_pss_output.png', bbox_inches='tight', dpi=300);

# plot the inputs to check behavior (needs to be adapted if the number of inputs changes)
fig, axs = plt.subplots(2, 3, figsize=(10, 6), layout='constrained')
for nn, ax in enumerate(axs.flat):
    row, col = nn//3, nn%3
    ax.plot(inputs[:, nn])
    ax.set_xlim(left=0)
    ax.set_xlim(right=n_trials)
    ax.set_xlabel('Number of steps (-)')
    ax.set_ylabel(parameters_legend[nn])
plt.savefig('val-2c_pss_inputs.png', bbox_inches='tight', dpi=300);

# identified calibrated parameters (maximum output data)
# find latest index of max output
index_best = len(outputs) - np.argmax(outputs[::-1]) - 1
# extract corresponding calibrated input parameter values
calibrated_inputs = inputs[index_best, :]
lines = [parameters[i] + ' = ' + str(calibrated_inputs[i]) + '\n' for i in range(n_variables)]

filename = 'calibrated_parameter_values.txt'
if os.path.exists(filename):
    os.remove(filename)

with open(filename, 'a') as f:
    f.writelines(lines)

Curie = 3.7e10 # 1/s
decay_rate_tritium = 1.78199e-9 # 1/s/at
conversion_Ci_atom = decay_rate_tritium / Curie # 1/at
m_to_mum = 1e6

# provide average and std values for each parameter following a normal distribution, in the same order as `parameters_normal`
indices_parameters_normal = [0, 1, 2, 5] # indices of the parameters vector corresponding to parameters following a normal distribution
parameters_normal = [parameters[i] for i in indices_parameters_normal]
parameters_legend_normal = [parameters_legend[i] for i in indices_parameters_normal]
calibrated_inputs_normal = [calibrated_inputs[i] for i in indices_parameters_normal]
parameters_normal_average = [2.8 * 2.0e-10*conversion_Ci_atom*m_to_mum**3,
                             4.0e-12 * m_to_mum**2 * (1.0-0.1),
                             1.0e-14 * m_to_mum**2 * (1.0+0.4),
                             3*60*60]
parameters_normal_std = [5/100 * parameters_normal_average[0],
                         10/100 * parameters_normal_average[1],
                         20/100 * parameters_normal_average[2],
                         10/100 * parameters_normal_average[-1]]

# Plot the calibrate inputs on the normal distribution
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
num_bins = 16
x_limit = [-4,4]
y_limit = [0,0.5]

# perfect normal distribution
perfect_norm_distribution_x = np.linspace(x_limit[0], x_limit[1], 1000)
perfect_norm_distribution_y = norm.pdf(perfect_norm_distribution_x, 0, 1)
ax1.plot(perfect_norm_distribution_x, perfect_norm_distribution_y, '-', color='k')

# Plot the calibrated value of each parameters on the Gaussian curve
for i in range(len(parameters_normal)):
    norm_optimized_input = (calibrated_inputs_normal[i] - parameters_normal_average[i]) / parameters_normal_std[i]
    ax1.plot([norm_optimized_input,norm_optimized_input], y_limit, '--', label=parameters_legend_normal[i])

ax1.set_xlabel(u'parameters')
ax1.set_ylabel(u"frequency")
ax1.set_xlim(x_limit)
ax1.set_ylim(y_limit)
ax1.set_xticks([-3,-2,-1,0,1,2,3],[r"$\mu-3\sigma$",r"$\mu-2\sigma$",r"$\mu-1\sigma$",r"$\mu$",r"$\mu+1\sigma$",r"$\mu+2\sigma$",r"$\mu+3\sigma$"])
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
plt.legend()
plt.savefig('val-2c_pss_inputs_normal_calibrated.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# provide average and std values for each parameter following a uniform distribution, in the same order as `parameters_uniform`
indices_parameters_uniform = [3, 4] # indices of the parameters vector corresponding to parameters following a uniform distribution
parameters_uniform = [parameters[i] for i in indices_parameters_uniform]
parameters_legend_uniform = [parameters_legend[i] for i in indices_parameters_uniform]
calibrated_inputs_uniform = [calibrated_inputs[i] for i in indices_parameters_uniform]
solubility_elemental_tritium = 4.0e19 / m_to_mum**3 # 1/mum^3/Pa
solubility_tritiated_water = 6.0e24 / m_to_mum**3 # 1/mum^3/Pa
parameters_uniform_min = [np.log(1e-4 * solubility_elemental_tritium),
                         np.log(1e-4 * solubility_tritiated_water)]
parameters_uniform_max = [np.log(1e-3 * solubility_elemental_tritium),
                         np.log(1e-3 * solubility_tritiated_water)]

# Plot the calibrate inputs on the uniform distribution
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
x_limit = [1.1*min(parameters_uniform_min),max(parameters_uniform_max)*1.1]
y_limit = [0,1.3]

# Plot the calibrated value of each parameters on the uniform distribution
for i in range(len(parameters_uniform)):
    # perfect uniform distribution
    uniform_distribution_x = np.linspace(x_limit[0], x_limit[1], 1000)
    uniform_distribution_y = [parameters_uniform_min[i] <= x <= parameters_uniform_max[i] for x in uniform_distribution_x]
    ax1.plot(uniform_distribution_x, uniform_distribution_y, '-', color='k')
    ax1.plot([calibrated_inputs_uniform[i],calibrated_inputs_uniform[i]], y_limit, '--', label=parameters_legend_uniform[i])

ax1.set_xlabel(u'parameters (log scale)')
ax1.set_ylabel(u"frequency")
ax1.set_xlim(x_limit)
ax1.set_ylim(y_limit)
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax1.minorticks_on()
plt.legend()
plt.savefig('val-2c_pss_inputs_uniform_calibrated.png', bbox_inches='tight', dpi=300)
plt.close(fig)

#===============================================================================
# Extract Experimental data
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/Experimental_data_HTO_concentration.csv"
else:                                  # if in test folder
    csv_folder = "./gold/Experimental_data_HTO_concentration.csv"
experimental_data_hto = pd.read_csv(csv_folder)
experimental_time_hto = experimental_data_hto['time (s)'] / time_scale
experimental_hto_enclosure_concentration = experimental_data_hto['Concentration (Ci/m3)']

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/Experimental_data_T2_concentration.csv"
else:                                  # if in test folder
    csv_folder = "./gold/Experimental_data_T2_concentration.csv"
experimental_data_t2 = pd.read_csv(csv_folder)
experimental_time_t2 = experimental_data_t2['time (s)'] / time_scale
experimental_t2_enclosure_concentration = experimental_data_t2['Concentration (Ci/m3)']

#===============================================================================
# Unit conversion for consistency

tmap8_time = tmap8_time / time_scale # s -> h
tmap8_t2_enclosure_concentration_Ci = tmap8_t2_enclosure_concentration * 2 * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3 - the factor 2 is because there are 2 T atoms per T2 molecule
tmap8_hto_enclosure_concentration_Ci = tmap8_hto_enclosure_concentration * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3

tmap8_time_delay = tmap8_time_delay / time_scale # s -> h
tmap8_t2_enclosure_concentration_Ci_delay = tmap8_t2_enclosure_concentration_delay * 2 * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3 - the factor 2 is because there are 2 T atoms per T2 molecule
tmap8_hto_enclosure_concentration_Ci_delay = tmap8_hto_enclosure_concentration_delay * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3

tmap8_time_delay_calibrated = tmap8_time_delay_calibrated / time_scale # s -> h
tmap8_t2_enclosure_concentration_Ci_delay_calibrated = tmap8_t2_enclosure_concentration_delay_calibrated * 2 * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3 - the factor 2 is because there are 2 T atoms per T2 molecule
tmap8_hto_enclosure_concentration_Ci_delay_calibrated = tmap8_hto_enclosure_concentration_delay_calibrated * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3

#===============================================================================
# Plot figure for validation - HTO concentration in enclosure

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_time,tmap8_hto_enclosure_concentration_Ci,label=r"TMAP8 HTO - immediate injection",c='tab:gray', linestyle='--')
ax.plot(tmap8_time_delay,tmap8_hto_enclosure_concentration_Ci_delay,label=r"TMAP8 HTO - delayed injection",c='tab:gray', linestyle=':')
ax.plot(tmap8_time_delay_calibrated,tmap8_hto_enclosure_concentration_Ci_delay_calibrated,label=r"TMAP8 HTO - delayed injection - calibrated",c='tab:red', linestyle=':')
for i in range(int(len(experimental_time_hto)/2)):
    if i==0:
        ax.plot([experimental_time_hto[2*i], experimental_time_hto[2*i+1]],[experimental_hto_enclosure_concentration[2*i], experimental_hto_enclosure_concentration[2*i+1]],label=r"Experimental data HTO",c='k', linestyle='-')
    else:
        ax.plot([experimental_time_hto[2*i], experimental_time_hto[2*i+1]],[experimental_hto_enclosure_concentration[2*i], experimental_hto_enclosure_concentration[2*i+1]],c='k', linestyle='-')
ax.set_xlabel(u'Time (hr)')
ax.set_ylabel(r"HTO enclosure concentration (Ci/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_time))
def Ci_m3_to_molecules_microns3(x):
    return x / 2 / conversion_Ci_atom / length_scale**3
def molecules_microns3_to_Ci_m3(x):
    return x * 2 * conversion_Ci_atom * length_scale**3
ax2 = ax.secondary_yaxis(
    'right', functions=(Ci_m3_to_molecules_microns3, molecules_microns3_to_Ci_m3))
ax2.set_ylabel(r"(molecules/$\mu$m$^3$)")
ax.set_yscale('log')
ax.set_ylim(bottom=1e-8)
ax.set_ylim(top=1e-3)
ax.minorticks_on()

# calculate RMSPE
time_sample, experimental_hto_enclosure_concentration_sampled, tmap8_hto_enclosure_concentration_Ci_sampled = common_times_generator(experimental_time_hto, experimental_hto_enclosure_concentration, tmap8_time,tmap8_hto_enclosure_concentration_Ci)
RMSE = np.sqrt(np.mean((tmap8_hto_enclosure_concentration_Ci_sampled-experimental_hto_enclosure_concentration_sampled)**2))
RMSPE = RMSE*100/np.mean(experimental_hto_enclosure_concentration_sampled)
ax.text(0.8,3.9e-5, '(immediate) RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
time_sample_delay, experimental_hto_enclosure_concentration_delay_sampled, tmap8_hto_enclosure_concentration_Ci_delay_sampled = common_times_generator(experimental_time_hto, experimental_hto_enclosure_concentration, tmap8_time_delay,tmap8_hto_enclosure_concentration_Ci_delay)
RMSE = np.sqrt(np.mean((tmap8_hto_enclosure_concentration_Ci_delay_sampled-experimental_hto_enclosure_concentration_delay_sampled)**2))
RMSPE = RMSE*100/np.mean(experimental_hto_enclosure_concentration_delay_sampled)
ax.text(7.5,1.2e-5, '(delay) RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
time_sample_delay_calibrated, experimental_hto_enclosure_concentration_delay_calibrated_sampled, tmap8_hto_enclosure_concentration_Ci_delay_calibrated_sampled = common_times_generator(experimental_time_hto, experimental_hto_enclosure_concentration, tmap8_time_delay_calibrated,tmap8_hto_enclosure_concentration_Ci_delay_calibrated)
RMSE = np.sqrt(np.mean((tmap8_hto_enclosure_concentration_Ci_delay_calibrated_sampled-experimental_hto_enclosure_concentration_delay_calibrated_sampled)**2))
RMSPE = RMSE*100/np.mean(experimental_hto_enclosure_concentration_delay_calibrated_sampled)
ax.text(11,4e-6, '(delay) RMSPE (calibrated) = %.2f '%RMSPE+'%',fontweight='bold',c='tab:red')

# save figure
plt.savefig('val-2c_comparison_TMAP8_Exp_HTO_Ci.png', bbox_inches='tight', dpi=300);
plt.close(fig)

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_time,tmap8_t2_enclosure_concentration_Ci,label=r"TMAP8 T$_2$ - immediate injection",c='tab:gray', linestyle='--')
ax.plot(tmap8_time_delay,tmap8_t2_enclosure_concentration_Ci_delay,label=r"TMAP8 T$_2$ - delayed injection",c='tab:gray', linestyle=':')
ax.plot(tmap8_time_delay_calibrated,tmap8_t2_enclosure_concentration_Ci_delay_calibrated,label=r"TMAP8 T$_2$ - delayed injection - calibrated",c='tab:red', linestyle=':')
ax.scatter(experimental_time_t2[0], experimental_t2_enclosure_concentration[0], label=r"Experimental data T$_2$ (amount injected)",c='k',alpha = 0.6)
ax.scatter(experimental_time_t2[1:], experimental_t2_enclosure_concentration[1:], label=r"Experimental data T$_2$",c='k')
ax.set_xlabel(u'Time (hr)')
ax.set_ylabel(r"T$_2$ enclosure concentration (Ci/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_time))
def Ci_m3_to_molecules_microns3(x):
    return x / 2 / conversion_Ci_atom / length_scale**3
def molecules_microns3_to_Ci_m3(x):
    return x * 2 * conversion_Ci_atom * length_scale**3
ax2 = ax.secondary_yaxis(
    'right', functions=(Ci_m3_to_molecules_microns3, molecules_microns3_to_Ci_m3))
ax2.set_ylabel(r"(molecules/$\mu$m$^3$)")
ax.set_yscale('log')
ax.set_ylim(bottom=1e-4)
ax.set_ylim(top=14)

# calculate RMSPE
tmap8_t2_enclosure_concentration_Ci_sampled = sample_solution(experimental_time_t2[1:], tmap8_time, tmap8_t2_enclosure_concentration_Ci)
RMSE = np.sqrt(np.mean((tmap8_t2_enclosure_concentration_Ci_sampled-experimental_t2_enclosure_concentration[1:])**2))
RMSPE = RMSE*100/np.mean(experimental_t2_enclosure_concentration[1:])
ax.text(0.5,1.2e-4, '(immediate) \n RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
tmap8_t2_enclosure_concentration_Ci_delay_sampled = sample_solution(experimental_time_t2[1:], tmap8_time_delay, tmap8_t2_enclosure_concentration_Ci_delay)
RMSE = np.sqrt(np.mean((tmap8_t2_enclosure_concentration_Ci_delay_sampled-experimental_t2_enclosure_concentration[1:])**2))
RMSPE = RMSE*100/np.mean(experimental_t2_enclosure_concentration[1:])
ax.text(19,8e-4, '(delay) RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
tmap8_t2_enclosure_concentration_Ci_delay_calibrated_sampled = sample_solution(experimental_time_t2[1:], tmap8_time_delay_calibrated, tmap8_t2_enclosure_concentration_Ci_delay_calibrated)
RMSE = np.sqrt(np.mean((tmap8_t2_enclosure_concentration_Ci_delay_calibrated_sampled-experimental_t2_enclosure_concentration[1:])**2))
RMSPE = RMSE*100/np.mean(experimental_t2_enclosure_concentration[1:])
ax.text(20,4e-4, '(delay) RMSPE (calibrated) = %.2f '%RMSPE+'%',fontweight='bold',c='tab:red')

# save figure
plt.savefig('val-2c_comparison_TMAP8_Exp_T2_Ci.png', bbox_inches='tight', dpi=300);
plt.close(fig)
