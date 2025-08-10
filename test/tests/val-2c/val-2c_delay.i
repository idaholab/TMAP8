# This input file utilizes val_2c_base and adds specific parameter values and capabilities to inject T2 with a delay

!include val-2c_delay.params
!include val-2c_base.i

[Functions]
  [injection_window]
    type = ParsedFunction
    expression = 'if(t<${time_injection_T2_start}, 0., if(t<${time_injection_T2_end}, ${injection_rate_T2}, 0.))'
  []
[]

[Kernels]
  [t2_inflow]
    type = MaskedBodyForce
    variable = t2_enclosure_concentration
    value = '1'
    function = 'injection_window'
    mask = '1'
    block = 1
  []
[]
