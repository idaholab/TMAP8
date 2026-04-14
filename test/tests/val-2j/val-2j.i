# Validation Problem val-2j
# Tritium TDS from neutron-irradiated Li2TiO3 solid breeder
# Reference: Kobayashi et al., J. Nucl. Mater. 458 (2015) 22-28
# (O-)-center trapping model with first-order defect annihilation during TDS heating.
# (F+)-center trapping is excluded because its detrapping is too fast relative to
# diffusion (release near 580 K coincides with diffusion-controlled release; see Kobayashi p.26).

# ============ Physical Constants ============
kB_J = '${units 1.380649e-23 J/K}'   # Boltzmann constant in J/K

# ============ Diffusion Parameters (Eq. 11) ============
D0 = '${units 6.9e-7 m^2/s -> mum^2/s}'  # diffusivity pre-exponential
E_d = '${fparse ${units 1.07 eV -> J} / ${kB_J}}'  # diffusion activation energy (K)

# ============ O--center (hydroxyl) Trapping Parameters (Eq. 13, 21) ============
alpha_t = '${units 4.2e8 1/s}'   # trapping prefactor (Eq. 21)
epsilon_t = '${fparse ${units 1.04 eV -> J} / ${kB_J}}'  # trapping energy (K) (Eq. 21)
alpha_r = '${units 4.1e6 1/s}'   # detrapping prefactor (Eq. 13)
epsilon_r = '${fparse ${units 1.19 eV -> J} / ${kB_J}}'  # detrapping energy (K) (Eq. 13)

# ============ Defect Annihilation Parameters (Eqs. 16-18) ============
alpha_anneal = '${units 1.0e2 1/s}'  # annihilation prefactor (Eq. 18)
E_anneal = '${fparse ${units 0.9 eV -> J} / ${kB_J}}'  # annihilation energy (K) (Eq. 18)

!include val-2j_base.i

[Postprocessors]
  [total_mobile]
    type = ElementIntegralVariablePostprocessor
    variable = mobile
  []
  [total_trapped]
    type = ElementIntegralVariablePostprocessor
    variable = trapped
  []
[]

[Outputs]
  exodus = true
  csv = true
[]
