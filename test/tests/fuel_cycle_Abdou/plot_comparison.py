import pandas as pd
import scipy.constants as scc
import numpy as np
import matplotlib.pyplot as plt
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)


# ================================= Functions ================================ #

def read_csv_from_TMAP8(file_name, parameter_names, delimiter=','):
    # Read simulation data
    if "/TMAP8/doc/" in script_folder:     # if in documentation folder
        csv_folder = f"../../../../test/tests/fuel_cycle_Abdou/gold/{file_name}"
    else:                                  # if in test folder
        csv_folder = f"./gold/{file_name}"
    simulation_data = pd.read_csv(csv_folder, delimiter=delimiter)
    simulation_results = []
    for i in range(len(parameter_names)):
        simulation_results.append(simulation_data[parameter_names[i]])
    simulation_results = np.array(simulation_results)
    return simulation_results

# =========================== TMAP8 data extraction ========================== #

# Read the output in gold file
file_name = "fuel_cycle_out.csv"
x_keys = ['time','T_01_BZ','T_02_TES','T_09_ISS','T_11_storage']
df = read_csv_from_TMAP8(file_name, x_keys) # read csv file
df[x_keys.index('time')] /= scc.day # update time unit

bz_pts = read_csv_from_TMAP8('abdou2021bz.csv', ['time_[s]','breeding_zone_[kg]'], ' ') # read csv file
tes_pts = read_csv_from_TMAP8('abdou2021tes.csv', ['time_[s]','tritium_extraction_system_[kg]'], ' ') # read csv file
sto_pts = read_csv_from_TMAP8('abdou2021sto.csv', ['time_[s]','storage_[kg]'], ' ') # read csv file
iss_pts = read_csv_from_TMAP8('abdou2021iss.csv', ['time_[s]','isotope_separation_system_[kg]'], ' ') # read csv file

# =================================== Plot =================================== #
fig,ax = plt.subplots()
ax.set_xscale('log')
ax.set_yscale('log')

linestyles = {'T_02_TES':'--',
              'T_01_BZ':':',
              'T_11_storage':'-',
              'T_09_ISS':'-.'}
for i, x_key in enumerate(x_keys[1:]):
    ax.plot(df[x_keys.index('time')],
            df[x_keys.index(x_key)],
            c='C{:d}'.format(i%10),
            label=x_key,
            ls=linestyles[x_key])

# Match the original figure bounds
ax.set_xlim(1e-1,1e4)
ax.set_ylim(1e-3,1e4)
ax.set_xlabel('Time (Days)')
# Make lighter shaded lines to reflect the original figure lines. Keep the color,
# but make them transparent
ax.plot(bz_pts[0], bz_pts[1],alpha=0.5)
ax.plot(tes_pts[0], tes_pts[1],c='C1',alpha=0.5)
ax.plot(iss_pts[0], iss_pts[1],c='C2',alpha=0.5)
ax.plot(sto_pts[0], sto_pts[1],c='C3',alpha=0.5)
ax.legend(ncols=3)
ax.set_ylabel('Tritium inventory [kg]')
fig.savefig('fuel_cycle_abdou_03.png',dpi=300)
