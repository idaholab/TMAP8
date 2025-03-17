import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# ================================= Functions ================================ #
def interpolation_on_expected_input(date_x, data_y, expected_input):
    """Get new numerical solution based on the experimental input data points

    Args:
        expected_input (float): expected input data points
        date_x (float, ndarray): numerical input data points
        data_y (float, ndarray): numerical output data points

    Returns:
        float: updated expected output based on the data points in expected_input
    """
    left_limit = np.argwhere((np.diff(date_x < expected_input)))[0][0]
    right_limit = left_limit + 1
    return (expected_input - date_x[left_limit]) / (date_x[right_limit] - date_x[left_limit]) * (data_y[right_limit] - data_y[left_limit]) + data_y[left_limit]


def read_csv_from_TMAP8(file_name, parameter_names):
    # Read simulation data
    if "/TMAP8/doc/" in script_folder:     # if in documentation folder
        csv_folder = f"../../../../test/tests/fuel_cycle_benchmark/gold/{file_name}"
    else:                                  # if in test folder
        csv_folder = f"./gold/{file_name}"
    simulation_data = pd.read_csv(csv_folder)
    simulation_results = []
    for i in range(len(parameter_names)):
        simulation_results.append(simulation_data[parameter_names[i]])
    simulation_results = np.array(simulation_results)
    return simulation_results

# ================================ parameters ================================ #
# reserve inventory
time_unit = 3600 * 24 # time unit - days
two_year = 3600 * 24 * 365 * 2 # double time
twenty_days = 3600 * 24 * 20 # double time
tritium_burn_rate = 8.99e-7 # kg/s
TBE = 0.02
q = 0.25
t_res = 24 * 3600 # s
initial_inventory = 1.14 # kg
AF = 0.7
reserve_inventory = tritium_burn_rate / TBE * q * t_res * AF
print(f"Required reserve inventory = {reserve_inventory} kg")

# =========================== TMAP8 data extraction ========================== #
file_name = "fuel_cycle_out.csv"
parameter_names = ['time','T_01_BZ','T_02_TES','T_09_ISS','T_10_storage']
simulation_results = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
simulation_results[parameter_names.index('time')] = simulation_results[parameter_names.index('time')] / time_unit # update time unit

# inflection point
inflection_y = np.min(simulation_results[parameter_names.index('T_10_storage')])
inflection_x = simulation_results[parameter_names.index('time')][np.argmin(simulation_results[parameter_names.index('T_10_storage')])]
print(f"TMAP8_base: Inflection time = {round(inflection_x,5)} days, and inventory = {round(inflection_y,5)} kg")

# ======================== Benchmark data extraction ======================== #
file_name = "inventory_paper_20days.csv"
parameter_names_benchmark = ['time [s]','blanket inventory [kg]','TES inventory [kg]','ISS inventory [kg]','storage inventory [kg]']
benchmark_results = read_csv_from_TMAP8(file_name, parameter_names_benchmark) # read csv file
benchmark_results[parameter_names_benchmark.index('time [s]')] = benchmark_results[parameter_names_benchmark.index('time [s]')] / time_unit # update time unit

# inflection point
inflection_y = np.min(benchmark_results[parameter_names_benchmark.index('storage inventory [kg]')])
inflection_x = benchmark_results[parameter_names_benchmark.index('time [s]')][np.argmin(benchmark_results[parameter_names_benchmark.index('storage inventory [kg]')])]
print(f"benchmark: Inflection time = {round(inflection_x,5)} days, and inventory = {round(inflection_y,5)} kg")

figure_base = 'fuel_cycle_comparison'
# =================================== Plot =================================== #
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

for i in range(len(parameter_names)-1):
    if i==0:
        ax.plot(simulation_results[parameter_names.index('time')], simulation_results[i+1], linestyle='-', label=r"TMAP8", c='tab:grey')
        ax.plot(benchmark_results[parameter_names_benchmark.index('time [s]')], benchmark_results[i+1], '--', label=r"MatLab", c='tab:blue')
    else:
        ax.plot(simulation_results[parameter_names.index('time')], simulation_results[i+1], linestyle='-', c='tab:grey')
        ax.plot(benchmark_results[parameter_names_benchmark.index('time [s]')], benchmark_results[i+1], '--', c='tab:blue')
ax.text(10, 5.5e-3, 'BZ',fontweight='bold')
ax.text(10, 1e-1, 'TES',fontweight='bold')
ax.text(10, 2.05e-1, 'ISS',fontweight='bold')
ax.text(10, 9.5e-1, 'storage',fontweight='bold')

ax.set_xlabel(u'time (days)')
ax.set_ylabel(u"Tritium Inventory (kg)")
ax.legend(loc="best",ncols=3)
ax.set_ylim(bottom=0.001,top=1e2)
ax.set_xlim(left=0.1)
plt.xscale('log')
plt.yscale('log')
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig(f'{figure_base}.png', bbox_inches='tight', dpi=300)
plt.close(fig)
