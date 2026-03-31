import pandas as pd
import numpy as np
import scipy.stats as scs
import matplotlib.pyplot as plt
import os
import sys

script_folder = os.path.dirname(__file__)
os.chdir(script_folder)
os.makedirs("divertor_monoblock_sensitivity_figures", exist_ok=True)
npz_file = ""
if "TMAP8_DIR" in os.environ.keys():
    npz_file = os.path.join(
        os.environ["TMAP8_DIR"],
        "test/tests/divertor_monoblock/gold/divertor_monoblock_sensitivity/sensitivity_stats.npz",
    )
elif "/tmap8/doc" in script_folder.lower():
    npz_file = "../../../../test/tests/divertor_monoblock/gold/divertor_monoblock_sensitivity/sensitivity_stats.npz"
else:
    npz_file = "./test/tests/divertor_monoblock/gold/divertor_monoblock_sensitivity/sensitivity_stats.npz"
ssdf_keys = [
    "BCs/C_mob_W_top_flux",
    "BCs/mobile_tube",
    "BCs/temp_top",
    "BCs/temp_tube",
    "F_permeation",
    "Scaled_Tritium_Flux",
    "coolant_heat_flux",
    "max_temperature_Cu",
    "max_temperature_CuCrZr",
    "max_temperature_W",
    "total_retention",
]
a1df_keys = [
    "W_cond_factor",
    "coolant_temp",
    "peak_duration",
    "peak_value",
    "F_permeation",
    "Scaled_Tritium_Flux",
    "coolant_heat_flux",
    "max_temperature_Cu",
    "max_temperature_CuCrZr",
    "max_temperature_W",
    "time_max_T_Cu",
    "time_max_T_CuCrZr",
    "time_max_T_W",
    "total_retention",
]
a2df_keys = [
    "W_cond_factor",
    "coolant_temp",
    "peak_duration",
    "peak_value",
    "F_permeation",
    "Scaled_Tritium_Flux",
    "coolant_heat_flux",
    "max_temperature_Cu",
    "max_temperature_CuCrZr",
    "max_temperature_W",
    "time_max_T_Cu",
    "time_max_T_CuCrZr",
    "time_max_T_W",
    "total_retention",
]
## Procedure to generate npz file:
## 1. Read JSON output from full (exhaustive) version of test
## 2. All relevant information is in the ['time_steps'][0] object
##    load into a pandas dataframe. Note that the inputs are at the top level and the
##    relevant results are under 'results', so some massaging into a proper format is
##    likely to be necessary
## 3. save as an npz file with np.savez_compressed(FNAME,steady=ssdf.to_numpy(),etc.)

nparrs = np.load(npz_file)
ssdf = pd.DataFrame(nparrs["steady"], columns=ssdf_keys)
a1df = pd.DataFrame(nparrs["a1df"], columns=a1df_keys)  # transient shutdown
a2df = pd.DataFrame(nparrs["a2df"], columns=a2df_keys)  # ELMs


def pairplot(
    df,
    hue=None,
    vars=None,
    diag_kind="kde",
    kind="scatter",
    lower_kind=None,
    upper_kind=None,
    palette=None,
    alpha=0.7,
    diag_kws=None,
    plot_kws=None,
):
    cols = vars or list(df.select_dtypes(include="number").columns)
    n = len(cols)
    diag_kws, plot_kws = diag_kws or {}, plot_kws or {}
    groups = df[hue].unique() if hue else [None]
    colors = (palette or plt.rcParams["axes.prop_cycle"].by_key()["color"])[
        : len(groups)
    ]
    cmap = dict(zip(groups, colors))

    fig, axes = plt.subplots(n, n, figsize=(2.5 * n, 2.5 * n))
    fig.subplots_adjust(hspace=0.08, wspace=0.08)

    for row, cy in enumerate(cols):
        for col, cx in enumerate(cols):
            ax = axes[row, col]
            for g in groups:
                sub = df[df[hue] == g] if hue else df
                x, y, c = sub[cx].dropna(), sub[cy].dropna(), cmap[g]

                if row == col:
                    if diag_kind == "kde":
                        kde = scs.gaussian_kde(x)
                        gx = np.linspace(x.min(), x.max(), 256)
                        ax.plot(gx, kde(gx), color=c, lw=1.8, **diag_kws)
                        ax.fill_between(gx, kde(gx), alpha=0.15, color=c)
                    else:
                        ax.hist(
                            x,
                            bins="auto",
                            color=c,
                            alpha=0.5,
                            density=True,
                            edgecolor="none",
                            **diag_kws
                        )
                    ax.set_yticks([])
                else:
                    cell_kind = (lower_kind if row > col else upper_kind) or kind
                    xv, yv = sub[cx].values, sub[cy].values
                    if cell_kind == "kde":
                        xy = np.vstack([xv, yv])
                        kde = scs.gaussian_kde(xy[:, ~np.isnan(xy).any(axis=0)])
                        gx = np.linspace(xv.min(), xv.max(), 64)
                        gy = np.linspace(yv.min(), yv.max(), 64)
                        gx, gy = np.meshgrid(gx, gy)
                        z = kde(np.vstack([gx.ravel(), gy.ravel()])).reshape(64, 64)
                        ax.contourf(
                            gx,
                            gy,
                            z,
                            levels=6,
                            cmap=plt.cm.Blues if not hue else None,
                            alpha=0.8,
                            **plot_kws
                        )
                        if hue:
                            ax.contour(gx, gy, z, levels=4, colors=[c], linewidths=1.2)
                    else:
                        ax.scatter(
                            xv,
                            yv,
                            color=c,
                            alpha=alpha,
                            s=0.15,
                            linewidths=0,
                            **plot_kws
                        )
                    if cell_kind == "reg":
                        m, b = np.polyfit(
                            *zip(
                                *[(a, b) for a, b in zip(xv, yv) if not np.isnan(a + b)]
                            ),
                            1
                        )
                        xr = np.linspace(np.nanmin(xv), np.nanmax(xv), 100)
                        ax.plot(xr, m * xr + b, color=c, lw=1.5)

            # Edge-only labels
            ax.tick_params(labelsize=7)
            ax.set_xlabel(cx, fontsize=9) if row == n - 1 else ax.set_xticklabels([])
            ax.set_ylabel(cy, fontsize=9) if col == 0 else ax.set_yticklabels([])

    if hue:
        fig.legend(
            handles=[mpatches.Patch(color=cmap[g], label=g) for g in groups],
            title=hue,
            loc="upper right",
            fontsize=8,
            title_fontsize=9,
        )

    plt.tight_layout()
    return fig, axes


fig1, ax1 = pairplot(
    ssdf[["BCs/C_mob_W_top_flux", "BCs/mobile_tube", "BCs/temp_top", "BCs/temp_tube"]],
    diag_kind="kde",
    alpha=0.2,
)
fig1.savefig("divertor_monoblock_sensitivity_figures/steady_state_inputs.png", dpi=70)


fig2, ax2 = pairplot(
    a1df[["W_cond_factor", "coolant_temp", "peak_duration", "peak_value"]],
    diag_kind="kde",
    alpha=0.2,
)
fig2.savefig("divertor_monoblock_sensitivity_figures/transients_inputs.png", dpi=70)

fig3, ax3 = pairplot(
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
    alpha=0.2,
)
fig3.savefig(
    "divertor_monoblock_sensitivity_figures/shutdown_transient_results.png", dpi=70
)

fig4, ax = plt.subplots(ncols=2, sharex=True)
ax[0].scatter(ssdf["BCs/temp_top"], ssdf["max_temperature_W"], s=0.75, alpha=0.5)
ax[1].scatter(ssdf["BCs/temp_top"], ssdf["F_permeation"], s=0.75, alpha=0.5)
ax[0].set_xlabel("Max Heat Flux [W/m$^2$]")
ax[1].set_xlabel("Max Heat Flux [W/m$^2$]")
ax[0].set_ylabel("Max W Temperature [K]")
ax[1].set_ylabel("Tritium Permeation Flux (scaled)")
fig4.tight_layout()
fig4.savefig("divertor_monoblock_sensitivity_figures/steady_comparison.png", dpi=70)


fig5, ax5 = pairplot(
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
    upper_kind="scatter",
    lower_kind="kde",
)
fig5.figure.savefig(
    "divertor_monoblock_sensitivity_figures/shutdown_pairplots.png", dpi=70
)

fig6, ax6 = pairplot(
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
    upper_kind="scatter",
    lower_kind="kde",
)

fig6.figure.savefig("divertor_monoblock_sensitivity_figures/elm_pairplots.png", dpi=70)
