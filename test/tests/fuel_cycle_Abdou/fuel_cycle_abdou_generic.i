!include fuel_cycle_abdou_base.i

[ScalarKernels]
  [I1] # Breeding Zone
    type = FuelCycleSystemScalarKernel
    TBR = TBR
    burn_rate = tritium_burn_rate
    inputs = 'T_02_TES '
    input_fractions = TES_frac # expression = '(1 - TES_efficiency)/residence2'
    residence_time = residence1
    leakage_rate = epsilon1
    variable = 'T_01_BZ'
  []
  [I2] #Tritium Extraction System
    type = FuelCycleSystemScalarKernel
    inputs = 'T_01_BZ'
    input_fractions = BZ_TES_frac
    residence_time = residence2
    leakage_rate = epsilon2
    variable = 'T_02_TES'
  []
  [I3] #First Wall
    type = FuelCycleSystemScalarKernel
    variable = 'T_03_FW'
    other_sources = 'plasma_FW_flux'
    inputs = 'T_05_HX T_06_CPS'
    input_fractions = 'HX_FW_flux HX_CPS_flux'
    residence_time = residence3
    leakage_rate = epsilon3
  []
  [I4] #Divertor
    type = FuelCycleSystemScalarKernel
    other_sources = 'plasma_div_flux'
    inputs = 'T_05_HX T_06_CPS'
    input_fractions = 'HX_div_flux CPS_div_flux'
    residence_time = residence4
    leakage_rate = epsilon4
    variable = 'T_04_DIV'
  []
  [I5] #Heat eXchanger
    type = FuelCycleSystemScalarKernel
    inputs = 'T_01_BZ T_03_FW T_04_DIV'
    input_fractions = 'BZ_HX_flux FW_HX_flux div_HX_flux'
    variable = 'T_05_HX'
    residence_time = 'residence5'
    leakage_rate = epsilon5
  []
  [I6] #Coolant Purification System
    type = FuelCycleSystemScalarKernel
    inputs = 'T_05_HX'
    input_fractions = 'CPS_HX_flux'
    leakage_rate = epsilon6
    residence_time = residence6
    variable = 'T_06_CPS'
  []
  [I7] #Vacuum Pump
    type = FuelCycleSystemScalarKernel
    other_sources = Vacuum_pump_breeding
    variable = 'T_07_vacuum'
    leakage_rate = epsilon7
    residence_time = residence7
  []
  [I8] #Fuel clean-up
    type = FuelCycleSystemScalarKernel
    inputs = 'T_07_vacuum'
    input_fractions = 'VAC_FCX_flux'
    leakage_rate = epsilon8
    residence_time = residence8
    variable = 'T_08_FCU'
  []
  [I9] #Isotope Separation System
    type = FuelCycleSystemScalarKernel
    inputs = 'T_02_TES T_06_CPS T_08_FCU T_10_exhaust'
    input_fractions = 'TES_ISS_flux CPS_ISS_flux FCU_ISS_flux EXH_ISS_flux'
    leakage_rate = epsilon9
    residence_time = residence9
    variable = 'T_09_ISS'
  []
  [I10] #Exhaust and Water Detritiation System (EXO)
    type = FuelCycleSystemScalarKernel
    inputs = 'T_05_HX T_09_ISS'
    input_fractions = 'HX_EXO_flux ISS_EXO_flux'
    variable = 'T_10_exhaust'
    leakage_rate = epsilon10
    residence_time = residence10
  []
  [I11] #Storage and Management (STO)
    type = FuelCycleSystemScalarKernel
    inputs = 'T_08_FCU T_09_ISS'
    input_fractions = 'FCU_STO_flux ISS_STO_flux'
    other_sinks = 'device_T_consumption'
    variable = 'T_11_storage'
    disable_residence_time = true
  []
[]

[Postprocessors]
  [TES_frac]
    type = ParsedPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    pp_names = 'TES_efficiency residence2'
    expression = '(1 - TES_efficiency)/residence2'
  []
  [BZ_TES_frac]
    type = ParsedPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    pp_names = 'BZ_HX_leak_fraction residence2'
    expression = '(1 - BZ_HX_leak_fraction)/residence2'
  []
  [plasma_FW_flux]
    type = ParsedPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    expression = 'P_FW_leak_fraction*tritium_burn_rate /tritium_burn_fraction / tritium_fueling_efficiency'
    pp_names = 'P_FW_leak_fraction tritium_burn_rate tritium_burn_fraction tritium_fueling_efficiency'
  []
  [HX_FW_flux]
    type = ParsedPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    expression = 'HX_FW_leak_fraction * (1 - HX_CPS_leak_fraction) * (1 - HX_EXO_leak_fraction)/residence5'
    pp_names = 'HX_FW_leak_fraction HX_CPS_leak_fraction HX_EXO_leak_fraction residence5'
  []
  [HX_CPS_flux]
    type = ParsedPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    expression = 'CPS_FW_leak_fraction * (1 - CPS_efficiency) /residence6'
    pp_names = 'CPS_FW_leak_fraction CPS_efficiency residence6'
  []
  [CPS_HX_flux]
    type = ParsedPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    expression = 'HX_CPS_leak_fraction * (1 - HX_EXO_leak_fraction)/residence5'
    pp_names = 'HX_CPS_leak_fraction HX_EXO_leak_fraction residence5'
  []
  [plasma_div_flux]
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    type = ParsedPostprocessor
    expression = 'P_DIV_leak_fraction * tritium_burn_rate/tritium_burn_fraction / tritium_fueling_efficiency'
    pp_names = 'P_DIV_leak_fraction tritium_burn_rate tritium_burn_fraction tritium_fueling_efficiency'
  []
  [HX_div_flux]
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    type = ParsedPostprocessor
    expression = '(1-HX_FW_leak_fraction)* (1-HX_CPS_leak_fraction)*(1-HX_EXO_leak_fraction)/residence5'
    pp_names = 'HX_FW_leak_fraction HX_CPS_leak_fraction HX_EXO_leak_fraction residence5'
  []
  [CPS_div_flux]
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    type = ParsedPostprocessor
    expression = '(1-CPS_FW_leak_fraction)*(1 - CPS_efficiency) /residence6'
    pp_names = 'CPS_FW_leak_fraction CPS_efficiency residence6'
  []
  [BZ_HX_flux]
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    type = ParsedPostprocessor
    expression = 'BZ_HX_leak_fraction/residence1'
    pp_names = 'BZ_HX_leak_fraction residence1'
  []
  [FW_HX_flux]
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    type = ParsedPostprocessor
    expression = '1/residence3'
    pp_names = 'residence3'
  []
  [div_HX_flux]
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    type = ParsedPostprocessor
    expression = '1/residence4'
    pp_names = 'residence4'
  []
  [Vacuum_pump_breeding]
    type = ParsedPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    expression = '(1-tritium_burn_fraction*tritium_fueling_efficiency - P_FW_leak_fraction
                    - P_DIV_leak_fraction) * tritium_burn_rate/(tritium_burn_fraction
                    * tritium_fueling_efficiency)'
    pp_names = 'tritium_burn_fraction tritium_fueling_efficiency P_FW_leak_fraction
     P_DIV_leak_fraction tritium_burn_rate'
  []
  [VAC_FCX_flux]
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    type = ParsedPostprocessor
    expression = '1/residence7'
    pp_names = 'residence7'
  []
  [TES_ISS_flux]
    type = ParsedPostprocessor
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    expression = 'TES_efficiency/residence2 '
    pp_names = 'TES_efficiency residence2'
  []
  [FCU_ISS_flux]
    type = ParsedPostprocessor
    pp_names = 'FCU_STO_fraction residence8'
    expression = '(1-FCU_STO_fraction)/residence8'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
  []
  [CPS_ISS_flux]
    type = ParsedPostprocessor
    expression = 'CPS_efficiency/residence6'
    pp_names = 'CPS_efficiency residence6'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
  []
  [EXH_ISS_flux]
    type = ParsedPostprocessor
    expression = '1/residence10'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    pp_names = 'residence10'
  []
  [HX_EXO_flux]
    type = ParsedPostprocessor
    expression = 'HX_EXO_leak_fraction/residence5'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    pp_names = 'HX_EXO_leak_fraction residence5'
  []
  [ISS_EXO_flux]
    type = ParsedPostprocessor
    expression = 'ISS_EXO_leak_fraction/residence9'
    pp_names = 'ISS_EXO_leak_fraction residence9'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
  []
  [FCU_STO_flux]
    type = ParsedPostprocessor
    expression = 'FCU_STO_fraction /residence8'
    pp_names = 'FCU_STO_fraction residence8'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
  []
  [ISS_STO_flux]
    type = ParsedPostprocessor
    expression = '(1-ISS_EXO_leak_fraction)/residence9'
    pp_names = 'ISS_EXO_leak_fraction residence9'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
  []
  [device_T_consumption]
    type = ParsedPostprocessor
    expression = 'tritium_burn_rate/tritium_burn_fraction/tritium_fueling_efficiency'
    execute_on = 'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR'
    pp_names = 'tritium_burn_rate tritium_burn_fraction tritium_fueling_efficiency'
  []
[]

Outputs/csv/hide := "BZ_HX_leak_fraction CPS_FW_leak_fraction CPS_efficiency FCU_STO_fraction
          HX_CPS_leak_fraction HX_EXO_leak_fraction HX_FW_leak_fraction ISS_EXO_leak_fraction
          P_DIV_leak_fraction P_FW_leak_fraction TBR TES_efficiency T_BZ T_CPS T_DIV T_EXO
          T_FCU T_FW T_HX T_ISS T_STO T_TES T_VAC epsilon1 epsilon10 epsilon11 epsilon2 epsilon3
          epsilon4 epsilon5 epsilon6 epsilon7 epsilon8 epsilon9 residence1 residence10 residence2
          residence3 residence4 residence5 residence6 residence7 residence8 residence9 tdecay
          tritium_burn_fraction tritium_burn_rate tritium_fueling_efficiency BZ_TES_frac CPS_HX_flux
          CPS_ISS_flux CPS_div_flux EXH_ISS_flux FCU_ISS_flux FCU_STO_flux FW_HX_flux HX_CPS_flux
          HX_EXO_flux HX_FW_flux HX_div_flux ISS_EXO_flux ISS_STO_flux TES_ISS_flux TES_frac VAC_FCX_flux
          Vacuum_pump_breeding device_T_consumption div_HX_flux plasma_FW_flux plasma_div_flux BZ_HX_flux"
