[ICs]
    ca_IC = '${fparse ${units 1 muPa -> Pa} * ${Na} / ( ${R} * ${T} ) }'
    cb_IC = '${fparse ${units 1 muPa -> Pa} * ${Na} / ( ${R} * ${T} ) }'
    [ca_same_conc_IC]
        type = ConstantIC
        variable = c_a
        value = '${units ${ca_IC} at/m^3 -> at/mum^3 }'
    []
    [cb_same_conc_IC]
        type = ConstantIC
        variable = c_b
        value = '${units ${cb_IC} at/m^3 -> at/mum^3 }'
    []
[]