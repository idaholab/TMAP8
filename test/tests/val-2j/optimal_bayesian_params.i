# Bayesian-optimized parameters using 8-parameter optimization.
# These values override the reference parameters in val-2j.i.

alpha_t = '${units 2.210226e+07 1/s}'
epsilon_t = '${fparse ${units 0.817421 eV -> J} / ${kB_J}}'
alpha_r = '${units 2.143938e+05 1/s}'
epsilon_r = '${fparse ${units 1.082378 eV -> J} / ${kB_J}}'
D0 = '${units 4.499236e-06 m^2/s -> mum^2/s}'
E_d = '${fparse ${units 1.008663 eV -> J} / ${kB_J}}'
alpha_anneal = '${units 8.264733e+01 1/s}'
E_anneal = '${fparse ${units 1.270004 eV -> J} / ${kB_J}}'
