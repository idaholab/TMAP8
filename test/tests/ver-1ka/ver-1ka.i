initial_pressure = ${units 0 Pa} # initial internal pressure
kb = ${units 1.380649e-23 J/K} # Boltzmann constant J/K - from PhysicalConstants.h
T = ${units 500 K} # Temperature
S = ${units 1e20 1/m^3/s} # Source term
V = ${units 1 m^3} # Volume
end_time = ${units 10000 s}
time_step = ${units 500 s}

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmax = 1
  ymax = 1
[]

[Variables]
  [pressure]
    family = SCALAR
    order = FIRST
    initial_condition = '${fparse initial_pressure}'
  []
[]

[ScalarKernels]
  [time]
    type = ODETimeDerivative
    variable = pressure
  []
  [source]
    type = ParsedODEKernel
    variable = pressure
    expression = '${fparse - S/V * kb * T}'
  []
[]

[Executioner]
  type = Transient
  dt = ${time_step}
  end_time = ${end_time}
  scheme = 'bdf2'
[]

[Outputs]
  file_base = 'ver-1ka_out'
  csv = true
[]