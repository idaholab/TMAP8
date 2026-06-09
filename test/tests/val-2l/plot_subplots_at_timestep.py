import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import os

def subplot_bar_profile(timestep, data_dir='csv_data'):
    # Load the data
    gas_path = os.path.join(data_dir, f"verification_RZ_solution_profile_gas_{timestep:04d}.csv")
    steel_path = os.path.join(data_dir, f"verification_RZ_solution_profile_steel_{timestep:04d}.csv")

    gas_df = pd.read_csv(gas_path, skipinitialspace=True)
    steel_df = pd.read_csv(steel_path, skipinitialspace=True)
    total_df = pd.read_csv(os.path.join(data_dir,"verification_RZ.csv"), skipinitialspace = True)

    # Replace Correct Data point for gas concentration at interface due to bug in vpp
    # print('Testing Gas')
    # print(gas_df['H_mobile_gas'].iloc[-1])
    # print("Did Value Change???")
    # gas_df.iloc[-1, gas_df.columns.get_loc('H_mobile_gas')] = corrective_df.iloc[timestep-1,corrective_df.columns.get_loc('Mobile_gas_interface')]
    # print(gas_df['H_mobile_gas'].iloc[-1])

    # print('Testing Steel')
    # print(steel_df['H_mobile_steel'].iloc[-1])
    # print("Did Value Change???")
    # steel_df.iloc[-1, steel_df.columns.get_loc('H_mobile_steel')] = corrective_df.iloc[timestep-1,corrective_df.columns.get_loc('Mobile_steel_edge_air')]
    # print(steel_df['H_mobile_steel'].iloc[-1])

    time = total_df['time']

    # Get spatial coordinates
    gas_x = gas_df['x']
    # print(type(gas_x))
    steel_x = steel_df['x']
    # print(gas_x)
    # print(steel_x)

    # Extract variable names
    gas_var = gas_df.columns[0]
    steel_var = steel_df.columns[0]
    # print(gas_var)
    # print(steel_var)

    # Extract variable values
    gas_values = gas_df[gas_var]
    steel_values = steel_df[steel_var]
    # print(gas_values)
    # print(steel_values)

    # Plotting
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), sharex=False)

    # Gas phase plot
    ax1.plot(gas_x, gas_values, color='blue')
    ax1.set_xlim(gas_x.min(), gas_x.max())
    ax1.set_ylim(gas_values.min()*0.995, gas_values.max()*1.005)
    ax1.set_ylabel(r'Molecular H$_2$ Concentration in Gas ($\mu$mol/mm$^3$)')
    ax1.set_title(f'Timestep {timestep} at Time: {time[timestep-1]:01.2f} days')
    ax1.grid(True)

    # Steel phase plot
    ax2.plot(steel_x, steel_values, color='green')
    ax2.set_xlim(steel_x.min(), steel_x.max())
    ax2.set_ylim(steel_values.min(), steel_values.max())
    ax2.set_ylabel(r'Atomic H Concentration in Steel ($\mu$mol/mm^3)')
    ax2.set_xlabel('Distance from Canister Center (mm)')
    # ax2.set_title(f'Steel - Timestep {timestep}')
    ax2.grid(True)

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Plot gas and steel concentration profiles for a given timestep.")
    parser.add_argument("timestep", type=int, help="Timestep number (e.g., 1 for _0001.csv)")
    parser.add_argument("--data_dir", type=str, default="csv_data", help="Directory containing the CSV files")

    args = parser.parse_args()
    subplot_bar_profile(args.timestep, data_dir=args.data_dir)
