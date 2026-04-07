!include fuel_cycle_abdou_base.i

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
    variable = T_06_CPS
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
    variable = T_10_exhaust
  []
  [I11t]
    type = ODETimeDerivative
    variable = T_11_storage
  []
  [I1] # Breeding Zone
    type = ParsedODEKernel
    expression = '-(tritium_burn_rate * TBR + (1 - TES_efficiency)*T_02_TES/residence2 - T_01_BZ/residence1
                    - T_01_BZ*epsilon1/residence1 - T_01_BZ*tdecay)'
    variable = 'T_01_BZ'
    coupled_variables = 'T_02_TES'
    postprocessors = 'TBR tritium_burn_rate TES_efficiency residence1 residence2 tdecay epsilon1'
  []
  [I2] #Tritium Extraction System
    type = ParsedODEKernel
    expression = '-((1 - BZ_HX_leak_fraction)*T_01_BZ/residence1 - T_02_TES/residence2
                     - T_02_TES*epsilon2/residence2 - T_02_TES*tdecay)'
    variable = 'T_02_TES'
    coupled_variables = 'T_01_BZ'
    postprocessors = 'BZ_HX_leak_fraction residence1 residence2 tdecay epsilon2'
  []
  [I3] #First Wall
    type = ParsedODEKernel
    expression = '-(P_FW_leak_fraction*tritium_burn_rate /tritium_burn_fraction / tritium_fueling_efficiency
                    + HX_FW_leak_fraction * (1 - HX_CPS_leak_fraction) * (1 - HX_EXO_leak_fraction)
                    * T_05_HX/residence5 + CPS_FW_leak_fraction * (1 - CPS_efficiency) * T_06_CPS/residence6
                    - T_03_FW/residence3 - T_03_FW*epsilon3/residence3 - T_03_FW*tdecay)'
    variable = 'T_03_FW'
    coupled_variables = 'T_05_HX T_06_CPS'
    postprocessors = 'P_FW_leak_fraction tritium_burn_rate tritium_burn_fraction tritium_fueling_efficiency
                      HX_FW_leak_fraction HX_CPS_leak_fraction HX_EXO_leak_fraction residence5
                      CPS_FW_leak_fraction CPS_efficiency residence6 residence3 tdecay epsilon3'
  []
  [I4] #Divertor
    type = ParsedODEKernel
    expression = '-(P_DIV_leak_fraction * tritium_burn_rate/tritium_burn_fraction / tritium_fueling_efficiency
                    + (1-HX_FW_leak_fraction)* (1-HX_CPS_leak_fraction)*(1-HX_EXO_leak_fraction)
                    * T_05_HX/residence5 + (1-CPS_FW_leak_fraction)*(1 - CPS_efficiency) * T_06_CPS/residence6
                      - T_04_DIV*epsilon4/residence4 - T_04_DIV/residence4 - T_04_DIV*tdecay)'
    variable = 'T_04_DIV'
    coupled_variables = 'T_06_CPS T_05_HX'
    postprocessors = 'P_DIV_leak_fraction tritium_burn_rate tritium_burn_fraction
                     tritium_fueling_efficiency HX_FW_leak_fraction HX_CPS_leak_fraction
                     HX_EXO_leak_fraction residence5 CPS_FW_leak_fraction CPS_efficiency
                     residence6 residence4 tdecay epsilon4'
  []
  [I5] #Heat eXchanger
    type = ParsedODEKernel
    expression = '-(BZ_HX_leak_fraction * T_01_BZ/residence1 + T_03_FW/residence3 + T_04_DIV/residence4
                  - T_05_HX/residence5 - T_05_HX*epsilon5/residence5 -T_05_HX*tdecay)'
    variable = 'T_05_HX'
    coupled_variables = 'T_01_BZ T_03_FW T_04_DIV'
    postprocessors = 'BZ_HX_leak_fraction residence1 residence3 residence4 residence5 tdecay
                      epsilon5'
  []
  [I6] #Coolant Purification System
    type = ParsedODEKernel
    expression = '-(HX_CPS_leak_fraction * (1 - HX_EXO_leak_fraction)*T_05_HX/residence5
                    - T_06_CPS/residence6 - T_06_CPS*epsilon6/residence6 - T_06_CPS*tdecay)'
    variable = 'T_06_CPS'
    coupled_variables = 'T_05_HX'
    postprocessors = 'HX_CPS_leak_fraction HX_EXO_leak_fraction residence5 residence6 tdecay
                      epsilon6'
  []
  [I7] #Vacuum Pump
    type = ParsedODEKernel
    expression = '-((1-tritium_burn_fraction*tritium_fueling_efficiency - P_FW_leak_fraction
                    - P_DIV_leak_fraction)* tritium_burn_rate/(tritium_burn_fraction
                    * tritium_fueling_efficiency) - T_07_vacuum/residence7
                    - T_07_vacuum*epsilon7/residence7 - T_07_vacuum*tdecay)'
    variable = 'T_07_vacuum'
    postprocessors = 'tritium_burn_rate tritium_fueling_efficiency P_FW_leak_fraction
                      P_DIV_leak_fraction tritium_burn_fraction residence7 tdecay epsilon7'
  []
  [I8] #Fuel clean-up
    type = ParsedODEKernel
    expression = '-(T_07_vacuum/residence7 - T_08_FCU/residence8 - T_08_FCU*epsilon8/residence8
                    - T_08_FCU*tdecay)'
    variable = 'T_08_FCU'
    postprocessors = 'residence7 residence8 tdecay epsilon8'
    coupled_variables = 'T_07_vacuum'
  []
  [I9] #Isotope Separation System
    type = ParsedODEKernel
    expression = '-((1-FCU_STO_fraction)*T_08_FCU/residence8 + T_10_exhaust/residence10
                    + TES_efficiency*T_02_TES/residence2 + CPS_efficiency*T_06_CPS/residence6
                    - T_09_ISS/residence9 - T_09_ISS*epsilon9/residence9 - T_09_ISS*tdecay)'
    variable = 'T_09_ISS'
    coupled_variables = 'T_08_FCU T_10_exhaust T_02_TES T_06_CPS'
    postprocessors = 'FCU_STO_fraction residence8 residence10 TES_efficiency residence2
                      CPS_efficiency residence6 residence9 tdecay epsilon9'
  []
  [I10] #Exhaust and Water Detritiation System (EXO)
    type = ParsedODEKernel
    expression = '-(HX_EXO_leak_fraction * T_05_HX/residence5 + ISS_EXO_leak_fraction*T_09_ISS/residence9
                    - T_10_exhaust/residence10 - T_10_exhaust*epsilon10/residence10 - T_10_exhaust*tdecay)'
    variable = 'T_10_exhaust'
    coupled_variables = 'T_05_HX T_09_ISS'
    postprocessors = 'HX_EXO_leak_fraction residence5 ISS_EXO_leak_fraction residence9 residence10
                      tdecay epsilon10'
  []
  [I11] #Storage and Management (STO)
    type = ParsedODEKernel
    expression = '-(FCU_STO_fraction * T_08_FCU/residence8 + (1-ISS_EXO_leak_fraction)*T_09_ISS/residence9
                    - tritium_burn_rate/tritium_burn_fraction/tritium_fueling_efficiency
                    - T_11_storage*tdecay)'
    variable = 'T_11_storage'
    coupled_variables = 'T_08_FCU T_09_ISS'
    postprocessors = 'FCU_STO_fraction residence8 ISS_EXO_leak_fraction residence9 tritium_burn_rate
                      tritium_burn_fraction tritium_fueling_efficiency tdecay'
  []
[]
Outputs/csv/file_base=fuel_cycle_out
