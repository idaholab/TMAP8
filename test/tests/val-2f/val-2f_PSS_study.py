import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import json
import os

# Set working directory to script directory
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Path to JSON file
if "/tmap8/doc/" in script_folder.lower():
    file_json = "../../../../test/tests/val-2f/val-2f_pss_results/val-2f_pss_main_out.json"
else:
    file_json = "./val-2f_pss_results/val-2f_pss_main_out.json"

# Parameter list
parameters = [
    'diffusion_W_preexponential_exp', 'diffusion_W_energy',
    'recombination_preexponential_exp', 'recombination_energy',
    'detrapping_prefactor', 'A0',
    'detrapping_energy_1', 'K_1', 'nmax_1', 'Ea_1',
    'detrapping_energy_2', 'K_2', 'nmax_2', 'Ea_2',
    'detrapping_energy_3', 'K_3', 'nmax_3', 'Ea_3',
    'detrapping_energy_4', 'K_4', 'nmax_4', 'Ea_4',
    'detrapping_energy_5', 'K_5', 'nmax_5',
    'detrapping_energy_intrinsic', 'trap_density_01dpa_intrinsic'
]
n_variables = len(parameters)

# Load data
with open(file_json, 'r') as f:
    data = json.load(f)

# Infer number of steps and processors per step
n_steps = len(data["time_steps"])
n_procs = len(data["time_steps"][0]["adaptive_MC"]["output_required"])
n_trials = n_procs * (n_steps - 1)

# Allocate arrays
outputs = np.zeros(n_trials)
inputs = np.zeros((n_trials, n_variables))

# Populate input/output arrays
for i in range(1, n_steps):
    start = (i - 1) * n_procs
    end = i * n_procs
    outputs[start:end] = np.array(data["time_steps"][i]["adaptive_MC"]["output_required"])
    tmp = np.array(data["time_steps"][i]["adaptive_MC"]["inputs"])
    for j in range(n_variables):
        inputs[start:end, j] = tmp[j, :n_procs]

# Plot output evolution
fig, ax = plt.subplots(figsize=(5, 3))
ax.plot(outputs)
ax.set_xlabel(r'Number of steps (-)')
ax.set_ylabel(r"Metric to be optimized")
ax.set_xlim(left=0, right=n_trials)
ax.set_ylim(bottom=0, top=np.max(outputs) * 1.05)
ax.minorticks_on()
plt.savefig('val-2f_pss_output.png', bbox_inches='tight', dpi=300)

# Plot parameter evolution
fig, axs = plt.subplots(9, 3, figsize=(15, 27), layout='constrained')
for nn in range(n_variables):
    ax = axs.flat[nn]
    ax.plot(inputs[:, nn])
    ax.set_xlim(left=0, right=n_trials)
    ax.set_xlabel('Number of steps (-)')
    ax.set_ylabel(parameters[nn])
# Hide unused subplot
for i in range(len(parameters), len(axs.flat)):
    axs.flat[i].axis('off')
plt.savefig('val-2f_pss_inputs.png', bbox_inches='tight', dpi=300)

# Identify best input parameters
index_best = len(outputs) - np.argmax(outputs[::-1]) - 1
calibrated_inputs = inputs[index_best, :]
lines = [f"{parameters[i]}={calibrated_inputs[i]}\n" for i in range(n_variables)]

# Save best parameters
filename = 'calibrated_parameter_values.txt'
if os.path.exists(filename):
    os.remove(filename)
with open(filename, 'w') as f:
    f.writelines(lines)

# === Selected 6 parameters for detailed plot ===
selected_params = {
    'diffusion_W_preexponential_exp': 'Diffusion Prefactor',
    'diffusion_W_energy': 'Diffusion Activation Energy',
    'recombination_preexponential_exp': 'Recombination Prefactor',
    'recombination_energy': 'Recombination Energy',
    'nmax_1': 'Trap 1 Saturation Density',
    'detrapping_energy_4': 'Release Energy Trap 4'
}
selected_indices = [parameters.index(p) for p in selected_params.keys()]

fig, axs = plt.subplots(2, 3, figsize=(21, 12), layout='constrained')
for i, idx in enumerate(selected_indices):
    ax = axs.flat[i]
    ax.plot(inputs[:, idx])
    ax.set_xlim(left=0, right=n_trials)
    ax.set_xlabel('Number of steps (-)')
    ax.set_ylabel(selected_params[parameters[idx]])
plt.savefig('val-2f_pss_selected_inputs.png', bbox_inches='tight', dpi=300)
