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
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/val-2c_immediate_injection_csv.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2c_immediate_injection_csv.csv"
tmap8_prediction = pd.read_csv(csv_folder)
tmap8_time = tmap8_prediction['time']
tmap8_t2_enclosure_concentration = tmap8_prediction['t2_enclosure_edge_concentration']
tmap8_hto_enclosure_concentration = tmap8_prediction['hto_enclosure_edge_concentration']

# Extract TMAP8 predictions - delay
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/val-2c_delay_csv.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2c_delay_csv.csv"
tmap8_prediction_delay = pd.read_csv(csv_folder)
tmap8_time_delay = tmap8_prediction['time']
tmap8_t2_enclosure_concentration_delay = tmap8_prediction_delay['t2_enclosure_edge_concentration']
tmap8_hto_enclosure_concentration_delay = tmap8_prediction_delay['hto_enclosure_edge_concentration']

#===============================================================================
# Extract Experimental data
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/Experimental_data_HTO_concentration.csv"
else:                                  # if in test folder
    csv_folder = "./gold/Experimental_data_HTO_concentration.csv"
experimental_data_hto = pd.read_csv(csv_folder)
experimental_time_hto = experimental_data_hto['time (hr)']
experimental_hto_enclosure_concentration = experimental_data_hto['Concentration (Ci/m3)']

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2c/gold/Experimental_data_T2_concentration.csv"
else:                                  # if in test folder
    csv_folder = "./gold/Experimental_data_T2_concentration.csv"
experimental_data_t2 = pd.read_csv(csv_folder)
experimental_time_t2 = experimental_data_t2['time (hr)']
experimental_t2_enclosure_concentration = experimental_data_t2['Concentration (Ci/m3)']

#===============================================================================
# Unit conversion for consistency

tmap8_time = tmap8_time / time_scale # s -> h
tmap8_t2_enclosure_concentration_Ci = tmap8_t2_enclosure_concentration * 2 * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3 - the factor 2 is because there are 2 T atoms per T2 molecule
tmap8_hto_enclosure_concentration_Ci = tmap8_hto_enclosure_concentration * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3

tmap8_time_delay = tmap8_time_delay / time_scale # s -> h
tmap8_t2_enclosure_concentration_Ci_delay = tmap8_t2_enclosure_concentration_delay * 2 * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3 - the factor 2 is because there are 2 T atoms per T2 molecule
tmap8_hto_enclosure_concentration_Ci_delay = tmap8_hto_enclosure_concentration_delay * conversion_Ci_atom * length_scale**3 # molecules/microns^3 -> Ci/m^3

#===============================================================================
# Plot figure for validation - HTO concentration in enclosure

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_time,tmap8_hto_enclosure_concentration_Ci,label=r"TMAP8",c='tab:gray', linestyle='--')
ax.plot(tmap8_time_delay,tmap8_hto_enclosure_concentration_Ci_delay,label=r"TMAP8 - delay",c='tab:gray', linestyle=':')
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
ax.text(0.8,3.9e-5, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
time_sample_delay, experimental_hto_enclosure_concentration_delay_sampled, tmap8_hto_enclosure_concentration_Ci_delay_sampled = common_times_generator(experimental_time_hto, experimental_hto_enclosure_concentration, tmap8_time_delay,tmap8_hto_enclosure_concentration_Ci_delay)
RMSE = np.sqrt(np.mean((tmap8_hto_enclosure_concentration_Ci_delay_sampled-experimental_hto_enclosure_concentration_delay_sampled)**2))
RMSPE = RMSE*100/np.mean(experimental_hto_enclosure_concentration_delay_sampled)
ax.text(7.5,1.2e-5, 'RMSPE (delay) = %.2f '%RMSPE+'%',fontweight='bold')

# save figure
plt.savefig('val-2c_comparison_TMAP8_Exp_HTO_Ci.png', bbox_inches='tight', dpi=300);
plt.close(fig)

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_time,tmap8_t2_enclosure_concentration_Ci,label=r"TMAP8 T2",c='tab:gray', linestyle='--')
ax.plot(tmap8_time_delay,tmap8_t2_enclosure_concentration_Ci_delay,label=r"TMAP8 T2 - delay",c='tab:gray', linestyle=':')
ax.scatter(experimental_time_t2[0], experimental_t2_enclosure_concentration[0], label=r"Experimental data T2 (amount injected)",c='k',alpha = 0.6)
ax.scatter(experimental_time_t2[1:], experimental_t2_enclosure_concentration[1:], label=r"Experimental data T2",c='k')
ax.set_xlabel(u'Time (hr)')
ax.set_ylabel(r"T2 enclosure concentration (Ci/m$^3$)")
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
ax.text(0.5,1.2e-4, 'RMSPE (delay) = %.2f '%RMSPE+'%',fontweight='bold')
tmap8_t2_enclosure_concentration_Ci_delay_sampled = sample_solution(experimental_time_t2[1:], tmap8_time_delay, tmap8_t2_enclosure_concentration_Ci_delay)
RMSE = np.sqrt(np.mean((tmap8_t2_enclosure_concentration_Ci_delay_sampled-experimental_t2_enclosure_concentration[1:])**2))
RMSPE = RMSE*100/np.mean(experimental_t2_enclosure_concentration[1:])
ax.text(19,8e-4, 'RMSPE (delay) = %.2f '%RMSPE+'%',fontweight='bold')

# save figure
plt.savefig('val-2c_comparison_TMAP8_Exp_T2_Ci.png', bbox_inches='tight', dpi=300);
plt.close(fig)
