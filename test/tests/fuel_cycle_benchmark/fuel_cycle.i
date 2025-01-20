# This input file re-creates the deuterium-tritium fuel cycle model
# described by Meschini et al (2023).
# "Modeling and analysis of the tritium fuel cycle for ARC- and STEP-class D-T
#   fusion power plants." S Meschini & S E Ferry & R Delaporte-Mathurin
#   & D G Whyte Nucl. Fusion 63 (2023) https://doi.org/10.1088/1741-4326/acf3fc

# The mesh is completely ignored, but TMAP/MOOSE will complain without it. If high-fidelity
# models of specific components are required, the scalar variables can be coupled to
# "Field" variables which can vary spatially across the mesh, or could be co-ordinated
# with sub-apps.

pulse_time = '${units 1800 s}'
initial_inventory = '${units 1.14 kg}'
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
resident_time_8 = '${units 585 s}'
resident_time_9 = '${units 22815 s}'
resident_time_11 = '${units 100 s}'
epsilon_low = 0 # -
epsilon = 1e-4 # -
f_5to1 = 0.33 # -
f_5to3 = 0.33 # -
f_5to6 = 1e-4 # -
f_9to6 = 0.1 # -
f_Pto3 = 1e-4 # -
f_Pto4 = 1e-4 # -
f_DIR = 0.5 # -
eta_2 = 0.7 # -
TBR_value = 1.067 # -
AF_value = 0.75 # -
t_decay = '${units 1.73e-9 1/s}'
TBE_value = 0.025 # -
tritium_burn_rate_value = 8.99e-7 # -

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
    expression = '-((1 - DIR_fraction) * T_07_vacuum / residence7 - T_08_FCU / residence8 - T_08_FCU * epsilon8 / residence8 - T_08_FCU * tdecay)'
    variable = 'T_08_FCU'
    coupled_variables = 'T_07_vacuum'
    postprocessors = 'DIR_fraction residence7 residence8 tdecay epsilon8'
  []
  [I9] #Isotope Separation System
    type = ParsedODEKernel
    expression = '-(T_06_DS / residence6 + T_08_FCU / residence8 - T_09_ISS / residence9 - T_09_ISS * epsilon9 / residence9 - T_09_ISS*tdecay)'
    variable = 'T_09_ISS'
    coupled_variables = 'T_06_DS T_08_FCU'
    postprocessors = 'residence6 residence8 residence9 tdecay epsilon9'
  []
  [I10] #Storage and Management (STO)
    type = ParsedODEKernel
    expression = '-((1 - ISS_DS_leak_fraction) * T_09_ISS / residence9 + DIR_fraction * T_07_vacuum / residence7 + T_11_membrane / residence11 - burn_pulse - T_10_storage * tdecay)'
    variable = 'T_10_storage'
    coupled_variables = 'T_09_ISS T_07_vacuum T_11_membrane'
    postprocessors = 'ISS_DS_leak_fraction DIR_fraction burn_pulse residence9 residence7 residence11 tdecay AF'
  []
  [I11] #Tritium Separation Membrane (TSM)
    type = ParsedODEKernel
    expression = '-(TES_efficiency * T_02_TES/residence2 - T_11_membrane / residence11 - T_11_membrane * epsilon11 / residence11 - T_11_membrane * tdecay)'
    variable = 'T_11_membrane'
    coupled_variables = 'T_02_TES'
    postprocessors = 'TES_efficiency residence2 residence11 tdecay epsilon11'
  []
[]

[Functions]
  [breeder_pulse_function]
    type = ParsedFunction
    symbol_names = 'AF tritium_burn_rate TBR'
    symbol_values = 'AF tritium_burn_rate TBR'
    expression = 'if(t > ${accuracy_time}, AF * tritium_burn_rate * TBR,
                  if(t % ${pulse_time} < AF * ${pulse_time}, tritium_burn_rate * TBR, 0))'
  []
  [burn_pulse_function]
    type = ParsedFunction
    symbol_names = 'AF tritium_burn_rate TBE'
    symbol_values = 'AF tritium_burn_rate TBE'
    expression = 'if(t > ${accuracy_time}, AF * tritium_burn_rate / TBE,
                  if(t % ${pulse_time} < AF * ${pulse_time}, tritium_burn_rate / TBE, 0))'
  []
  [dt_function]
    type = ParsedFunction
    symbol_names = 'AF'
    symbol_values = 'AF'
    expression = 'if(t > ${accuracy_time}, ${time_interval_middle},
                  if(t % ${pulse_time} < AF * ${pulse_time}, AF * ${pulse_time} - t % ${pulse_time} + 0.01,
                  if(t % ${pulse_time} < ${pulse_time}, ${pulse_time} - t % ${pulse_time} + 0.01, 2)))'
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
  [DIR_fraction] #f_DIR
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${f_DIR} # (0.1 - 0.9)
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
  [residence11] #TSM
    type = ConstantPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    value = ${resident_time_11} # (from Meschini) 1958.25 # s (1899.50 m / 0.97 m/s = 1958.25) (from Papa et al. 2021)
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

[Executioner]
  type = Transient
  start_time = 0
  dtmin = 1
  end_time = ${simulation_time}
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
         "DIR_fraction T_BZ T_DS T_DIV T_TSM T_FCU T_FW T_HX T_ISS T_STO T_TES T_VAC epsilon1 "
         "epsilon11 epsilon2 epsilon3 epsilon4 epsilon5 epsilon6 epsilon7 epsilon8 epsilon9 "
         "residence1 residence11 residence2 residence3 residence4 residence5 residence6 residence7 "
         "residence8 residence9 tdecay TBE tritium_burn_rate"
  file_base = 'fuel_cycle_out'
  csv = true
  console = false
[]
