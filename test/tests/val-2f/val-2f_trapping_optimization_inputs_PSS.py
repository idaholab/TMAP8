import os, json, numpy as np, matplotlib.pyplot as plt
from matplotlib import gridspec
from scipy.stats import norm

# -------------------------------------------------------------- #
# eV → K conversion helper
# -------------------------------------------------------------- #
def ev_to_K(e_ev):
    kB, q_e = 1.380649e-23, 1.602176634e-19
    return e_ev / (kB / q_e)

# -------------------------------------------------------------- #
# 1.  Detect dimensions
# -------------------------------------------------------------- #
# Set working directory to script directory
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Path to JSON file
if "/tmap8/doc/" in script_folder.lower():
    JSON_FILE = "../../../../test/tests/val-2f/val-2f_pss_results/val-2f_pss_main_out.json"
else:
    JSON_FILE = "./val-2f_pss_results/val-2f_pss_main_out.json"

with open(JSON_FILE) as f:
    data = json.load(f)

time_steps   = data["time_steps"]
NUM_ITER     = len(time_steps) - 1                                  # skip step‑0
DIM          = len(time_steps[1]["adaptive_MC"]["inputs"])          # 27
PAR_PROCS    = len(time_steps[1]["adaptive_MC"]["inputs"][0])       # 600

print(f"{NUM_ITER} iterations × {PAR_PROCS} procs  |  {DIM} parameters")

# -------------------------------------------------------------- #
# 2.  Parameter list + reference μ, σ
# -------------------------------------------------------------- #
param = [
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
assert len(param) == DIM, "Parameter list must match JSON order!"

corresponding_ave = [
    7.28,
    0.28794285714285717,
    22.5,
    -0.04875,
    1.0e13,
    6.18e-3,
    ev_to_K(1.15),
    9.0e26,
    6.9e25,
    0.24,
    ev_to_K(1.35),
    4.2e26,
    7.0e25,
    0.24,
    ev_to_K(1.65),
    2.5e26,
    6.0e25,
    0.30,
    ev_to_K(1.85),
    5.0e26,
    4.7e25,
    0.30,
    ev_to_K(2.05),
    1.0e26,
    2.0e25,
    ev_to_K(1.04),
    2.4e4
]

corresponding_std = [
    0.7,
    0.07616723812286558,
    1.0,
    0.05,
    1.0e13 * 10 / 100,
    6.18e-3 * 10 / 100,
    ev_to_K(1.15) * 10 / 100,
    9.0e26 * 10 / 100,
    6.9e25 * 10 / 100,
    0.24 * 10 / 100,
    ev_to_K(1.35) * 10 / 100,
    4.2e26 * 10 / 100,
    7.0e25 * 10 / 100,
    0.24 * 10 / 100,
    ev_to_K(1.65) * 10 / 100,
    2.5e26 * 10 / 100,
    6.0e25 * 10 / 100,
    0.30 * 10 / 100,
    ev_to_K(1.85) * 10 / 100,
    5.0e26 * 10 / 100,
    4.7e25 * 10 / 100,
    0.30 * 10 / 100,
    ev_to_K(2.05) * 10 / 100,
    1.0e26 * 10 / 100,
    2.0e25 * 10 / 100,
    ev_to_K(1.04) * 10 / 100,
    2.4e4 * 10 / 100
]

μ, σ = np.array(corresponding_ave), np.array(corresponding_std)

# -------------------------------------------------------------- #
# 3.  Scan objective, keep best parameter vector
# -------------------------------------------------------------- #
metric = np.zeros((NUM_ITER, PAR_PROCS))

for k in range(1, NUM_ITER + 1):
    metric[k-1] = np.asarray(time_steps[k]["adaptive_MC"]["output_required"])

best_iter, best_proc = np.unravel_index(metric.argmax(), metric.shape)
step_inputs = np.asarray(time_steps[best_iter + 1]["adaptive_MC"]["inputs"])  # shape (27,100)
x_best = step_inputs[:, best_proc]                                            # length 27

print("Best objective =", metric[best_iter, best_proc],
      "at (iter,proc) =", (best_iter, best_proc))

# -------------------------------------------------------------- #
# 4.  Family index lists
# -------------------------------------------------------------- #
idx_diff_recomb   = [i for i,p in enumerate(param)
                     if p.startswith("diffusion") or p.startswith("recombination")]
idx_K_nmax_Ea_tr  = [i for i,p in enumerate(param)
                     if p.startswith("K_") or p.startswith("nmax_") or p.startswith("Ea_")
                        or "trap_density" in p or p == "A0"]
idx_detrap_energy = [i for i,p in enumerate(param)
                     if p.startswith("detrapping_energy")]

# -------------------------------------------------------------- #
# 5.  Plot helper
# -------------------------------------------------------------- #
palette = plt.rcParams["axes.prop_cycle"].by_key()["color"] * 5

def style_family(name):
    if   name.startswith("K_"):            return {'ls':'-',  'lw':2.4}
    elif name.startswith("nmax_"):         return {'ls':'--', 'lw':1.8}
    elif name.startswith("Ea_"):           return {'ls':':',  'lw':1.8}
    elif "trap_density" in name:           return {'ls':(0,(3,1,1,1)), 'lw':2.0}
    elif name == "A0":                     return {'ls':'-.',  'lw':2.0}
    return {'ls':'-', 'lw':1.5}

def plot_family(indices, title, filename, fancy=False):
    fig, ax = plt.subplots(figsize=(6.5,5.5))
    ax.plot(np.linspace(-4,4,1000), norm.pdf(np.linspace(-4,4,1000)), 'k-')

    z = [(x_best[i]-μ[i])/σ[i] for i in indices]
    pad = 0.1*(max(z)-min(z)+1e-12)
    ax.set_xlim(min(-4, min(z)-pad), max(4, max(z)+pad))

    y_min, y_max = 0.0, 0.7
    for i, z_i in zip(indices, z):
        style = style_family(param[i]) if fancy else {'ls':'-', 'lw':1.5}
        ax.plot([z_i,z_i], [y_min, y_max], color=palette[i], label=param[i], **style)

    ax.set_ylim(y_min,y_max)
    ax.set_xlabel('parameters'); ax.set_ylabel('frequency')
    ax.set_xticks([-3,-2,-1,0,1,2,3],
                  [r"$\mu-3\sigma$", r"$\mu-2\sigma$", r"$\mu-1\sigma$",
                   r"$\mu$", r"$\mu+1\sigma$", r"$\mu+2\sigma$", r"$\mu+3\sigma$"])
    ax.grid(True, which='major', ls='--', color='0.65', alpha=0.3)
    ax.minorticks_on()
    ax.legend(loc='upper left', frameon=False, fontsize=7.5)
    ax.set_title(title, fontsize=12)
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    plt.close(fig)

# -------------------------------------------------------------- #
# 6.  Generate figures
# -------------------------------------------------------------- #
plot_family(idx_diff_recomb,
            "Diffusion & Recombination",
            "val-2f_trapping_inputs_diff_recomb.png")

plot_family(idx_K_nmax_Ea_tr,
            "K, nmax, Ea, Trap Density",
            "val-2f_trapping_inputs_K_nmax_Ea_trap.png",
            fancy=True)

plot_family(idx_detrap_energy,
            "Detrapping Energies",
            "val-2f_trapping_inputs_detrapping_energy.png")

# -------------------------------------------------------------- #
# 7. Print best parameters with names
# -------------------------------------------------------------- #
print("\nBest parameter values (normalized and actual):\n")
for i, name in enumerate(param):
    norm_val = (x_best[i] - μ[i]) / σ[i]
    print(f"{name:35s} = {x_best[i]:.15e} (normalized: {norm_val:+.2f}σ)")
