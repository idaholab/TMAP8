import os
import tempfile

os.environ.setdefault("MPLCONFIGDIR", tempfile.mkdtemp(prefix="matplotlib-val-2k-"))

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Changes working directory to script directory for consistent MooseDocs usage.
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)


def get_repo_relative_path(test_path):
    if "/tmap8/doc/" in script_folder.lower():
        return os.path.join("../../../../test/tests/val-2k", test_path)
    return os.path.join(".", test_path)


simulation_csv = get_repo_relative_path("gold/val-2k_out.csv")
experiment_csv = get_repo_relative_path("gold/experiment_data_natural_oxide_fig6.csv")

simulation_data = pd.read_csv(simulation_csv)
time_s = simulation_data["time"]
temperature_k = 300.0 + (3.0 / 60.0) * time_s
release_flux = (
    simulation_data["scaled_flux_surface_left"] + simulation_data["scaled_flux_surface_right"]
)

experiment_data = pd.read_csv(experiment_csv)
has_experiment = not experiment_data.empty

fig, ax = plt.subplots(figsize=(6.5, 5.5))
ax.plot(
    temperature_k,
    release_flux,
    linestyle="-",
    color="tab:blue",
    label="TMAP8 iteration 1",
)

if has_experiment:
    experiment_temperature = experiment_data["temperature (K)"]
    experiment_flux = experiment_data["release flux (D atoms/m^2/s)"]
    ax.plot(
        experiment_temperature,
        experiment_flux,
        linestyle="--",
        color="k",
        label="Experimental data",
    )

    simulated_on_experiment_grid = np.interp(experiment_temperature, temperature_k, release_flux)
    rmse = np.sqrt(np.mean((simulated_on_experiment_grid - experiment_flux) ** 2))
    rmspe = rmse * 100.0 / np.mean(experiment_flux)
    ax.text(700, 0.85 * max(release_flux.max(), experiment_flux.max()), f"RMSPE = {rmspe:.2f} %")
else:
    ax.text(
        520,
        0.85 * release_flux.max(),
        "Experimental CSV pending digitization",
    )

ax.set_xlabel("Temperature (K)")
ax.set_ylabel("Release flux (D atoms/m$^2$/s)")
ax.set_xlim(300, 1000)
ax.set_ylim(bottom=0)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.legend(loc="best")
ax.minorticks_on()

plt.savefig("val-2k_natural_oxide_iteration_1_comparison.png", bbox_inches="tight", dpi=300)
plt.close(fig)
