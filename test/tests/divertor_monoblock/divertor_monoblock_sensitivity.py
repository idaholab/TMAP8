import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import os
import sys

script_folder = os.path.dirname(__file__)
os.chdir(script_folder)
os.makedirs("divertor_monoblock_sensitivity_figures", exist_ok=True)
hdf5_file = ""
if "TMAP8_DIR" in os.environ.keys():
    hdf5_file = os.path.join(
        os.environ["TMAP8_DIR"],
        "test/tests/divertor_monoblock/gold/divertor_monoblock_sensitivity/sensitivity_stats.hdf5",
    )
elif "/tmap8/doc" in script_folder.lower():
    hdf5_file = "../../../../test/tests/divertor_monoblock/gold/divertor_monoblock_sensitivity/sensitivity_stats.hdf5"
else:
    hdf5_file = "./test/tests/divertor_monoblock/gold/divertor_monoblock_sensitivity/sensitivity_stats.hdf5"
ssdf = pd.read_hdf(hdf5_file, key="steady")
a1df = pd.read_hdf(hdf5_file, key="transient_shutdown")
a2df = pd.read_hdf(hdf5_file, key="elms")


fig1 = sns.pairplot(
    ssdf[["BCs/C_mob_W_top_flux", "BCs/mobile_tube", "BCs/temp_top", "BCs/temp_tube"]],
    diag_kind="kde",
    diag_kws={"fill": False},
    plot_kws={"size": 0.1, "alpha": 0.2},
)
fig1.savefig("divertor_monoblock_sensitivity_figures/steady_state_inputs.png", dpi=300)


fig2 = sns.pairplot(
    a1df[["W_cond_factor", "coolant_temp", "peak_duration", "peak_value"]],
    diag_kind="kde",
    diag_kws={"fill": False},
    plot_kws={"alpha": 0.2, "size": 0.1},
)
fig2.savefig("divertor_monoblock_sensitivity_figures/transients_inputs.png", dpi=300)

fig3 = sns.pairplot(
    a1df[
        [
            "F_permeation",
            "total_retention",
            "time_max_T_W",
            "time_max_T_Cu",
            "time_max_T_CuCrZr",
        ]
    ],
    diag_kind="kde",
    diag_kws={"fill": False},
    plot_kws={"alpha": 0.2, "size": 0.1},
)
fig3.savefig(
    "divertor_monoblock_sensitivity_figures/shutdown_transient_results.png", dpi=300
)

fig4, ax = plt.subplots(ncols=2, sharex=True)
ax[0].scatter(ssdf["BCs/temp_top"], ssdf["max_temperature_W"], s=0.75, alpha=0.5)
ax[1].scatter(ssdf["BCs/temp_top"], ssdf["F_permeation"], s=0.75, alpha=0.5)
ax[0].set_xlabel("Max Heat Flux [W/m$^2$]")
ax[1].set_xlabel("Max Heat Flux [W/m$^2$]")
ax[0].set_ylabel("Max W Temperature [K]")
ax[1].set_ylabel("Tritium Permeation Flux (scaled)")
fig4.tight_layout()
fig4.savefig("divertor_monoblock_sensitivity/steady_comparison.png", dpi=300)


fig5 = sns.PairGrid(
    a1df[
        [
            x
            for x in a1df.keys()
            if "F_perm" not in x
            and "time" not in x
            and "total_retention" not in x
            and "max_temperature_W" not in x
            and x != "max_temperature_Cu"
        ]
    ],
    diag_sharey=False,
)

fig5.map_upper(sns.scatterplot, size=0.1, alpha=0.2)
fig5.map_lower(sns.kdeplot)
fig5.map_diag(sns.kdeplot)
fig5.figure.savefig("divertor_monoblock_sensitivity/shutdown_pairplots.png", dpi=300)

fig6 = sns.PairGrid(
    a2df[
        [
            x
            for x in a2df.keys()
            if "F_perm" not in x
            and "time" not in x
            and "total_retention" not in x
            and "max_temperature_W" not in x
            and x != "max_temperature_Cu"
        ]
    ],
    diag_sharey=False,
)

fig6.map_upper(sns.scatterplot, size=0.1, alpha=0.2)
fig6.map_lower(sns.kdeplot)
fig6.map_diag(sns.kdeplot)
fig6.figure.savefig("divertor_monoblock_sensitivity/elm_pairplots.png", dpi=300)
