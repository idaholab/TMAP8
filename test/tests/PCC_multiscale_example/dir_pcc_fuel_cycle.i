# This input file re-creates the deuterium-tritium fuel cycle model
# described by Meschini et al (2023).
# "Modeling and analysis of the tritium fuel cycle for ARC- and STEP-class D-T
#   fusion power plants." S Meschini & S E Ferry & R Delaporte-Mathurin
#   & D G Whyte Nucl. Fusion 63 (2023) https://doi.org/10.1088/1741-4326/acf3fc
#
# Unit system: fuel-cycle inventories are kg of tritium and time is seconds. PCC DIR coupling
# converts kg of T2 holdup to Pa using the MOOSE units system and SI gas constants.

# The mesh is completely ignored, but TMAP/MOOSE will complain without it. If high-fidelity
# models of specific components are required, the scalar variables can be coupled to
# "Field" variables which can vary spatially across the mesh, or could be co-ordinated
# with sub-apps.

pulse_time = '${units 1800 s}'
initial_inventory = '${units 0.803 kg}' # 1.14 kg}
accuracy_time = '${units 94608000 s}' # 864000 s}
time_interval_middle = '${units 1e6 s}'
simulation_time = '${units 94608000 s}' # 3 years

# Modeling parameters
resident_time_1 = '${units 4500 s}'
resident_time_2 = '${units 86400 s}'
resident_time_3 = '${units 1000 s}'
resident_time_4 = '${units 1000 s}'
resident_time_5 = '${units 1000 s}'
resident_time_6 = '${units 3600 s}'
resident_time_7 = '${units 600 s}'
resident_time_8 = '${units 360 s}'
resident_time_9 = '${units 14040 s}'
# TPM (I11) two-parameter residence time, fitted from a standalone permeation run at 5 Pa upstream
# (membrane_5_Pa_flux.csv) to the DELAYED first-order form
# J_back = J_inf*(1 - exp(-(t-tau0)/tau1)) for t > tau0 (see fit_residence_time.py): the membrane
# releases nothing for the transport delay tau0 = 11.69 s, then rises first-order with tau1 = 18.08 s
# (R^2 = 0.9998). Implemented like fuel_cycle_two_parameter_TEdata.i: a logistic time-gate
# residence_time_smooth_factor_11 (0 -> 1 around tau0) multiplies the membrane release term, while the
# residence constant (residence11) is tau1. The PCC enhancement of the TPM acts ONLY through this
# residence time (eta_2 is unchanged). Only tau1 sets the steady-state inventory; tau0 delays the
# early release (g -> 1 at steady state, recovering the tau1-only behavior).
resident_time_11_tau0 = '${units 14.8844 s}' # PCC-fitted TPM transport delay tau0
resident_time_11_tau1 = '${units 10.6776 s}' # PCC-fitted TPM first-order rise time tau1 (was 100 s)
Delta_time_unit = '${units 0.01 s}'        # logistic-gate sharpness (matches the TE-data example)
epsilon_low = 0 # -
epsilon = 1e-4 # -
f_5to1 = 0.33 # -
f_5to3 = 0.33 # -
f_5to6 = 1e-4 # -
f_9to6 = 0.1 # -
f_Pto3 = 1e-4 # -
f_Pto4 = 1e-4 # -
# f_DIR_VP / f_DIR_FCU removed: the DIR fractions are now CALCULATED from the membrane permeation
# (DIR_fraction_VP/FCU = flux_to_storage / DIR feed flux), not fixed inputs.
eta_2 = 0.95 # - # in-p
TBR_value = 1.067 # -
AF_value = 0.7 # - # in-p +- 0.3
t_decay = '${units 1.73e-9 1/s}'
TBE_value = 0.02 # - # in-p
tritium_burn_rate_value = 8.99e-7 # -

# --- PCC-enhanced DIR coupling: upstream-pressure bridge parameters (parent side) ---
# The two DIR systems (VP = I7, FCU = I8) are PCC-membrane-enhanced. Their inventories
# (T_07_vacuum, T_08_FCU, kg of tritium held as T2 gas) set the upstream T2 partial pressure of a
# membrane component sub-app (ideal gas, P = N/M_T2 * R*T_feed / V). Each sub-app returns the steady
# permeation rate (kg/s) recovered to storage; the DIR fraction = flux_to_storage / input_flux.
# V_VP / V_FCU are documented placeholder plenum volumes -- calibrate to the device.
M_T2_molar = '${units 6.032e-3 kg/mol}'          # T2 molar mass (plenum holdup is T2 gas)
T_feed     = '${units 773 K}'                    # plenum gas temperature (matches the membrane)
V_VP       = '${units 1600.0 m^3}'                  # VP DIR membrane plenum volume (TUNING PARAMETER)
V_FCU      = '${units 100.0 m^3}'                  # FCU DIR membrane plenum volume (TUNING PARAMETER)
R_gas      = '${units 8.31446261815324 J/mol/K}' # ideal gas constant
FCU_membrane_area = '${units 4e-1 m^2}'
VP_membrane_area = '${units 1e0 m^2}'

[Mesh]
  type = GeneratedMesh
  dim = 1
  xmin = 0
  xmax = 1
  nx = 1
[]

# One variable for each inventory of tritium is generated. All variables
# are defined as "SCALAR", meaning that they are a single value and are
# disconnected from any specific geometry

[Variables]
  [T_01_BZ]
    family = SCALAR
  []
  [T_02_TES]
    family = SCALAR
  []
  [T_03_FW]
    family = SCALAR
  []
  [T_04_DIV]
    family = SCALAR
  []
  [T_05_HX]
    family = SCALAR
  []
  [T_06_DS] # Detritiation system
    family = SCALAR
  []
  [T_07_vacuum]
    family = SCALAR
  []
  [T_08_FCU]
    family = SCALAR
  []
  [T_09_ISS]
    family = SCALAR
  []
  [T_10_storage]
    family = SCALAR
    initial_condition = ${initial_inventory}
  []
  [T_11_membrane] #  Tritium separation membrane
    family = SCALAR
  []
[]

# Tritium burn fraction is going to be small. Much
# will be lost to the scrape-off-layer (SOL) and
# recycled.

# TES - tritium extraction system pulls tritium from
# the blanket

# CPS - Coolant purification system pulls tritium from
# the coolant (CPS is signored in ARC reactor)
# Ignored in ARC due to liquid FLiBe

# An ODE is defined in TMAP8 such that all of the terms must
# be on the left hand side. The terms can be split
# across multiple "ScalarKernels", which are additive,
# so that we have one ODETimeDerivative for each tritium
# inventory and a ParsedODEKernel for the rest of the
# terms. These equations should reflect those described
# in Appendix A of the paper (A.1-A.13), with negation
# on the ParsedODEKernels due to moving the terms to the
# left hand side.

[ScalarKernels]
  [I1t]
    type = ODETimeDerivative
    variable = T_01_BZ
  []
  [I2t]
    type = ODETimeDerivative
    variable = T_02_TES
  []
  [I3t]
    type = ODETimeDerivative
    variable = T_03_FW
  []
  [I4t]
    type = ODETimeDerivative
    variable = T_04_DIV
  []
  [I5t]
    type = ODETimeDerivative
    variable = T_05_HX
  []
  [I6t]
    type = ODETimeDerivative
    variable = T_06_DS
  []
  [I7t]
    type = ODETimeDerivative
    variable = T_07_vacuum
  []
  [I8t]
    type = ODETimeDerivative
    variable = T_08_FCU
  []
  [I9t]
    type = ODETimeDerivative
    variable = T_09_ISS
  []
  [I10t]
    type = ODETimeDerivative
    variable = T_10_storage
  []
  [I11t]
    type = ODETimeDerivative
    variable = T_11_membrane
  []
  [I1] # Breeding Zone
    type = ParsedODEKernel
    expression = '-(breeder_pulse + T_03_FW / residence3 + T_04_DIV / residence4 + HX_BZ_leak_fraction * T_05_HX / residence5 - T_01_BZ / residence1 - T_01_BZ * epsilon1 / residence1 - T_01_BZ * tdecay)'
    variable = 'T_01_BZ'
    coupled_variables = 'T_03_FW T_04_DIV T_05_HX'
    postprocessors = 'breeder_pulse HX_BZ_leak_fraction residence1 residence3 residence4 residence5 tdecay epsilon1'
  []
  [I2] #Tritium Extraction System
    type = ParsedODEKernel
    expression = '-(T_01_BZ / residence1 - T_02_TES / residence2 - T_02_TES * epsilon2 / residence2 - T_02_TES * tdecay)'
    variable = 'T_02_TES'
    coupled_variables = 'T_01_BZ'
    postprocessors = 'residence1 residence2 tdecay epsilon2'
  []
  [I3] #First Wall
    type = ParsedODEKernel
    expression = '-(P_FW_leak_fraction * burn_pulse + HX_FW_leak_fraction * T_05_HX / residence5
                    - T_03_FW / residence3 - T_03_FW * epsilon3 / residence3 - T_03_FW * tdecay)'
    variable = 'T_03_FW'
    coupled_variables = 'T_05_HX'
    postprocessors = 'P_FW_leak_fraction HX_FW_leak_fraction burn_pulse residence5 residence3 tdecay epsilon3'
  []
  # TBE = tritium_burn_fraction * tritium_fueling_efficiency
  [I4] #Divertor
    type = ParsedODEKernel
    expression = '-(P_DIV_leak_fraction * burn_pulse + (1 - HX_BZ_leak_fraction - HX_DS_leak_fraction - HX_FW_leak_fraction) * T_05_HX / residence5
                  - T_04_DIV * epsilon4 / residence4 - T_04_DIV / residence4 - T_04_DIV * tdecay)'
    variable = 'T_04_DIV'
    coupled_variables = 'T_05_HX'
    postprocessors = 'P_DIV_leak_fraction HX_BZ_leak_fraction HX_DS_leak_fraction HX_FW_leak_fraction burn_pulse residence5 residence4 tdecay epsilon4'
  []
  [I5] #Heat eXchanger
    type = ParsedODEKernel
    expression = '-((1 - TES_efficiency) * T_02_TES / residence2 - T_05_HX / residence5 - T_05_HX * epsilon5 / residence5 - T_05_HX * tdecay)'
    variable = 'T_05_HX'
    coupled_variables = 'T_02_TES'
    postprocessors = 'TES_efficiency residence2 residence5 tdecay epsilon5'
  []
  [I6] #Detritiation system
    type = ParsedODEKernel
    expression = '-(HX_DS_leak_fraction * T_05_HX / residence5 + ISS_DS_leak_fraction * T_09_ISS / residence9 - T_06_DS / residence6 - T_06_DS * epsilon6 / residence6 - T_06_DS * tdecay)'
    variable = 'T_06_DS'
    coupled_variables = 'T_05_HX T_09_ISS'
    postprocessors = 'HX_DS_leak_fraction ISS_DS_leak_fraction residence5 residence9 residence6 tdecay epsilon6'
  []
  [I7] #Vacuum Pump
    type = ParsedODEKernel
    expression = '-((1 - TBE - P_FW_leak_fraction - P_DIV_leak_fraction) * burn_pulse
                  - T_07_vacuum / residence7 - T_07_vacuum * epsilon7 / residence7 - T_07_vacuum * tdecay)'
    variable = 'T_07_vacuum'
    postprocessors = 'TBE burn_pulse P_FW_leak_fraction P_DIV_leak_fraction residence7 tdecay epsilon7'
  []
  [I8] #Fuel clean-up
    type = ParsedODEKernel
    expression = '-((1 - DIR_fraction_VP) * T_07_vacuum / residence7 - T_08_FCU / residence8 - T_08_FCU * epsilon8 / residence8 - T_08_FCU * tdecay)'
    variable = 'T_08_FCU'
    coupled_variables = 'T_07_vacuum'
    postprocessors = 'DIR_fraction_VP residence7 residence8 tdecay epsilon8'
  []
  [I9] #Isotope Separation System
    type = ParsedODEKernel
    expression = '-(T_06_DS / residence6 + (1 - DIR_fraction_FCU) * T_08_FCU / residence8 - T_09_ISS / residence9 - T_09_ISS * epsilon9 / residence9 - T_09_ISS*tdecay)'
    variable = 'T_09_ISS'
    coupled_variables = 'T_06_DS T_08_FCU'
    postprocessors = 'DIR_fraction_FCU residence6 residence8 residence9 tdecay epsilon9'
  []
  [I10] #Storage and Management (STO)
    type = ParsedODEKernel
    expression = '-((1 - ISS_DS_leak_fraction) * T_09_ISS / residence9 + DIR_fraction_VP * T_07_vacuum / residence7  + DIR_fraction_FCU * T_08_FCU / residence8 + T_11_membrane / residence11 * residence_time_smooth_factor_11 - burn_pulse - T_10_storage * tdecay)'
    variable = 'T_10_storage'
    coupled_variables = 'T_09_ISS T_07_vacuum T_08_FCU T_11_membrane'
    postprocessors = 'ISS_DS_leak_fraction DIR_fraction_VP DIR_fraction_FCU burn_pulse residence9 residence8 residence7 residence11 residence_time_smooth_factor_11 tdecay AF'
  []
  [I11] #Tritium Separation Membrane (TSM)
    type = ParsedODEKernel
    expression = '-(TES_efficiency * T_02_TES/residence2 - T_11_membrane / residence11 * residence_time_smooth_factor_11 - T_11_membrane * epsilon11 / residence11 - T_11_membrane * tdecay)'
    variable = 'T_11_membrane'
    coupled_variables = 'T_02_TES'
    postprocessors = 'TES_efficiency residence2 residence11 residence_time_smooth_factor_11 tdecay epsilon11'
  []
[]

[Functions]
  [breeder_pulse_function]
    type = ParsedFunction
    symbol_names = 'AF tritium_burn_rate TBR'
    symbol_values = 'AF tritium_burn_rate TBR'
    # expression = 'if(t % ${pulse_time} < AF * ${pulse_time}, tritium_burn_rate * TBR, 0)'
    # expression = 'AF * tritium_burn_rate * TBR'
    expression = 'if(t > ${accuracy_time}, AF * tritium_burn_rate * TBR,
                  if(t % ${pulse_time} < AF * ${pulse_time}, tritium_burn_rate * TBR, 0))'
  []
  [burn_pulse_function]
    type = ParsedFunction
    symbol_names = 'AF tritium_burn_rate TBE'
    symbol_values = 'AF tritium_burn_rate TBE'
    # expression = 'if(t % ${pulse_time} < AF * ${pulse_time}, tritium_burn_rate / TBE, 0)'
    # expression = 'AF * tritium_burn_rate / TBE'
    expression = 'if(t > ${accuracy_time}, AF * tritium_burn_rate / TBE,
                  if(t % ${pulse_time} < AF * ${pulse_time}, tritium_burn_rate / TBE, 0))'
  []
  [dt_function]
    type = ParsedFunction
    symbol_names = 'AF'
    symbol_values = 'AF'
    # expression = 'if(t % ${pulse_time} < 1, 1,
    #               if(t % ${pulse_time} < AF * ${pulse_time} - 1, AF * ${pulse_time} - t % ${pulse_time} - 1,
    #               if(t % ${pulse_time} < AF * ${pulse_time}, 2,
    #               if(t % ${pulse_time} < ${pulse_time} - 1, ${pulse_time} - t % ${pulse_time} - 1,
    #               if(t % ${pulse_time} < ${pulse_time}, 2, 2)))))'
    # expression = 'if(t % ${pulse_time} < AF * ${pulse_time}, AF * ${pulse_time} - t % ${pulse_time} + 0.1,
    #               if(t % ${pulse_time} < ${pulse_time}, ${pulse_time} - t % ${pulse_time} + 0.1, 2))'
    expression = 'if(t > ${accuracy_time}, ${time_interval_middle},
                  if(t % ${pulse_time} < AF * ${pulse_time}, AF * ${pulse_time} - t % ${pulse_time} + 0.1,
                  if(t % ${pulse_time} < ${pulse_time}, ${pulse_time} - t % ${pulse_time} + 0.1, 2)))'
  []
[]

# These postprocessors define the constants referenced in
# the equations above. The value of any of these constants
# could be informed by more detailed models (using sub-apps
# and transfers), but it is important that the postprocessor
# is evaluated before the executioner attempts to solve the
# ODE, which is not the default behavior.
[Postprocessors]
  [burn_pulse]
    type = FunctionValuePostprocessor
    function = burn_pulse_function
    execute_on = 'initial timestep_end'
  []
  [breeder_pulse]
    type = FunctionValuePostprocessor
    function = breeder_pulse_function
    execute_on = 'initial timestep_end'
  []
  [HX_BZ_leak_fraction] #f_{5-1}
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${f_5to1}
  []
  [HX_FW_leak_fraction] #f_{5-3}
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${f_5to3}
  []
  [HX_DS_leak_fraction] #f_{5-6}
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${f_5to6}
  []
  [ISS_DS_leak_fraction] #f_{9-6}
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${f_9to6}
  []
  [P_DIV_leak_fraction] #f_{P-4}
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${f_Pto4}
  []
  [P_FW_leak_fraction] #f_{P-3}
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${f_Pto3}
  []
  [TES_efficiency] #eta_2 from Abdou et al. 2020
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${eta_2}
  []
  [TBR]
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${TBR_value} # for t_d = 2 yrs
  []
  # --- PCC-enhanced DIR fractions: now CALCULATED from the membrane permeation, not fixed ---
  # DIR_fraction = membrane flux to storage / DIR feed flow, clamped to [0,1] (computed at
  # TIMESTEP_BEGIN from the start-of-step inventory and the freshly transferred sub-app flux, then
  # held constant through the ODE solve like the original constant fraction).
  [DIR_fraction_VP]
    type = ParsedPostprocessor
    pp_names = 'flux_to_storage_VP T_07_now'
    expression = 'if(T_07_now > 1e-30, min(max(flux_to_storage_VP / (T_07_now / ${resident_time_7}), 0), 1), 0)'
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [DIR_fraction_FCU]
    type = ParsedPostprocessor
    pp_names = 'flux_to_storage_FCU T_08_now'
    expression = 'if(T_08_now > 1e-30, min(max(flux_to_storage_FCU / (T_08_now / ${resident_time_8}), 0), 1), 0)'
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  # --- PCC DIR coupling postprocessors (VP and FCU membranes) ---
  # T_*_now read on TIMESTEP_END so the down-transfer at the next step's TIMESTEP_BEGIN (inside
  # execMultiApps, before execute(TIMESTEP_BEGIN)) sees the start-of-step inventory; also on
  # TIMESTEP_BEGIN so the DIR_fraction can use the same value.
  [T_07_now] # VP (vacuum pump) inventory [kg]
    type = ScalarVariable
    variable = T_07_vacuum
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []
  [T_08_now] # FCU (fuel clean-up) inventory [kg]
    type = ScalarVariable
    variable = T_08_FCU
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []
  [pressure_VP] # VP membrane upstream T2 partial pressure [Pa] from the VP inventory via ideal gas
    type = ParsedPostprocessor
    pp_names = 'T_07_now'
    expression = 'max(T_07_now, 0) / ${M_T2_molar} * ${R_gas} * ${T_feed} / ${V_VP}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [pressure_FCU] # FCU membrane upstream T2 partial pressure [Pa]
    type = ParsedPostprocessor
    pp_names = 'T_08_now'
    expression = 'max(T_08_now, 0) / ${M_T2_molar} * ${R_gas} * ${T_feed} / ${V_FCU}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [flux_to_storage_VP] # tritium permeated to storage by the VP membrane [kg/s] (from the sub-app)
    type = Receiver
    default = 0
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [flux_to_storage_FCU] # tritium permeated to storage by the FCU membrane [kg/s] (from the sub-app)
    type = Receiver
    default = 0
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [AF]
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${AF_value} # (0.75 from Meschini)
  []
  [tdecay]
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${t_decay} # (from Meschini) 1.7828336471961835e-9 (from Abdou)
  []
  [TBE]
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${TBE_value} # (0.005 - 0.1) Meschini
  []
  [tritium_burn_rate]
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${tritium_burn_rate_value} # (5.3125e-6 from Abdou) (9.3e-7 Kg/s from Meschini paper) (8.99e-7 Kg/s from Meschini matlab)
  []
  [epsilon1] #BZ
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon}
  []
  [epsilon2] #TES
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon}
  []
  [epsilon3] #FW
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon_low}
  []
  [epsilon4] #DIV
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon_low}
  []
  [epsilon5] #HX
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon}
  []
  [epsilon6] #DS
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon}
  []
  [epsilon7] #Vac
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon}
  []
  [epsilon8] #FCU
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon}
  []
  [epsilon9] #ISS
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon}
  []
  [epsilon11] #TSM
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${epsilon}
  []
  [residence1] #BZ
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_1} # s 1.25 h, (Meschini) and (Ferrero et al) T_BZ = 3 g,  864000 # s 10 days
    # value = 1 h - 240 h
  []
  [residence2] #TES
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_2} # s Meschini
    #value = 1 h - 240 h Riva
  []
  [residence3] #FW
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_3} # s Riva
  []
  [residence4] #DIV
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_4} # s Riva
  []
  [residence5] #HX
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_5} # s Abdou 2021 paper chosen for analysis
  []
  [residence6] #DS
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_6} # s Meschini
  []
  [residence7] #Vac
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_7} # s
  []
  [residence8] #FCU
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_8} # 0.1625 h 3600 # s 1 h Meschini
    # value = 0.1 - 1 h  Meschini
    #value = 5 h Coleman
    #value = 8640 Abdou
    #value = 86400 Abdou
  []
  [residence9] #ISS
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_9} # s 6.3375 h Meschini
    #value = 0.9 - 11 h # (for four hour overall residence time in inner loop)
  []
  [residence11] #TSM (first-order rise constant tau1)
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_11_tau1} # PCC-fitted tau1
  []
  # Logistic time-gate for the TPM two-parameter residence time: ~0 for t < tau0, ~1 for t > tau0,
  # so the membrane release to storage is delayed by the transport delay tau0 (see I10/I11).
  [residence_time_smooth_factor_11]
    type = ParsedPostprocessor
    use_t = true
    expression = '1 / (1 + exp(- (t - ${resident_time_11_tau0}) / (${Delta_time_unit} * ${resident_time_11_tau0})))'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
  []
  # These postprocessors exist to sum up the tritium inventory
  #  across the entirety of the system
  [T_BZ]
    type = ScalarVariable
    variable = T_01_BZ
    execute_on = TIMESTEP_END
  []
  [T_TES]
    type = ScalarVariable
    variable = T_02_TES
    execute_on = TIMESTEP_END
  []
  [T_FW]
    type = ScalarVariable
    variable = T_03_FW
    execute_on = TIMESTEP_END
  []
  [T_DIV]
    type = ScalarVariable
    variable = T_04_DIV
    execute_on = TIMESTEP_END
  []
  [T_HX]
    type = ScalarVariable
    variable = T_05_HX
    execute_on = TIMESTEP_END
  []
  [T_DS]
    type = ScalarVariable
    variable = T_06_DS
    execute_on = TIMESTEP_END
  []
  [T_VAC]
    type = ScalarVariable
    variable = T_07_vacuum
    execute_on = TIMESTEP_END
  []
  [T_FCU]
    type = ScalarVariable
    variable = T_08_FCU
    execute_on = TIMESTEP_END
  []
  [T_ISS]
    type = ScalarVariable
    variable = T_09_ISS
    execute_on = TIMESTEP_END
  []
  [T_STO]
    type = ScalarVariable
    variable = T_10_storage
    execute_on = TIMESTEP_END
  []
  [T_TSM]
    type = ScalarVariable
    variable = T_11_membrane
    execute_on = TIMESTEP_END
  []
  [total_tritium]
    type = SumPostprocessor
    values = 'T_BZ T_TES T_FW T_DIV T_HX T_DS T_VAC T_FCU T_ISS T_STO T_TSM'
  []
[]
[UserObjects]
  [terminator]
    type = Terminator
    expression = 'T_STO < 0'
    fail_mode = 'HARD'
    message = 'Tritium in storage has been depleted'
  []
  [terminator2]
    type = Terminator
    expression = 'total_tritium < 0'
    fail_mode = 'HARD'
    message = 'Tritium in system has been depleted'
  []
[]

[MultiApps]
  # Two PCC membrane component sub-apps, one per DIR stream (re-solved to steady each fuel-cycle
  # step). Driven by the VP / FCU upstream pressures; return the permeated flow to storage.
  [vp_membrane] # vacuum-pump DIR membrane (active area 6e-2 m^2)
    type = FullSolveMultiApp
    input_files = 'dir_pcc_membrane_sub.i'
    execute_on = 'TIMESTEP_BEGIN'
    max_procs_per_app = 1
    ignore_solve_not_converge = true
    cli_args = 'A_membrane=${VP_membrane_area};Outputs/csv/enable=false'
  []
  [fcu_membrane] # fuel-clean-up DIR membrane (active area 3e-2 m^2)
    type = FullSolveMultiApp
    input_files = 'dir_pcc_membrane_sub.i'
    execute_on = 'TIMESTEP_BEGIN'
    max_procs_per_app = 1
    ignore_solve_not_converge = true
    cli_args = 'A_membrane=${FCU_membrane_area};Outputs/csv/enable=false'
  []
[]

[Transfers]
  # VP membrane: upstream pressure down, permeation-to-storage up
  [push_pressure_VP]
    type = MultiAppPostprocessorTransfer
    to_multi_app = vp_membrane
    from_postprocessor = pressure_VP
    to_postprocessor = received_pressure
    execute_on = 'TIMESTEP_BEGIN'
  []
  [pull_flux_VP]
    type = MultiAppPostprocessorTransfer
    from_multi_app = vp_membrane
    from_postprocessor = permeation_rate_kg_per_s
    to_postprocessor = flux_to_storage_VP
    reduction_type = average
    execute_on = 'TIMESTEP_BEGIN'
  []
  # FCU membrane: upstream pressure down, permeation-to-storage up
  [push_pressure_FCU]
    type = MultiAppPostprocessorTransfer
    to_multi_app = fcu_membrane
    from_postprocessor = pressure_FCU
    to_postprocessor = received_pressure
    execute_on = 'TIMESTEP_BEGIN'
  []
  [pull_flux_FCU]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fcu_membrane
    from_postprocessor = permeation_rate_kg_per_s
    to_postprocessor = flux_to_storage_FCU
    reduction_type = average
    execute_on = 'TIMESTEP_BEGIN'
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  dtmin = 1
  end_time = ${simulation_time} # 30 years - 946080000, 2 years - 31536000, 3 years - 94608000
  [TimeStepper]
    type = FunctionDT
    function = dt_function
  []
  solve_type = 'PJFNK'
  nl_rel_tol = 1e-08
  nl_abs_tol = 1e-14
[]

[Outputs]
  hide = "AF breeder_pulse burn_pulse HX_BZ_leak_fraction HX_FW_leak_fraction HX_DS_leak_fraction "
         "ISS_DS_leak_fraction P_DIV_leak_fraction P_FW_leak_fraction TES_efficiency TBR "
         "T_BZ T_DS T_DIV T_TSM T_FCU T_FW T_HX T_ISS T_STO T_TES "
         "T_VAC epsilon1 epsilon11 epsilon2 epsilon3 epsilon4 epsilon5 epsilon6 epsilon7 epsilon8 "
         "epsilon9 residence1 residence11 residence2 residence3 residence4 residence5 residence6 "
         "residence7 residence8 residence9 tdecay TBE tritium_burn_rate T_07_now T_08_now"
  file_base = 'dir_pcc_fuel_cycle_2rt_10Pa_out2'
  csv = true
  console = false
[]
