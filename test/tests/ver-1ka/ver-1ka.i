initial_pressure = 0 # Pa
kb = 1.380649e-23 # Boltzmann constant J/K
T = 500 # K
S = 1e20 # 1/m^3/s
V = 1 # m^3

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmax = 1
  ymax = 1
[]

[Variables]
  [v]
    family = SCALAR
    order = FIRST
    initial_condition = '${fparse initial_pressure}'
  []
[]

[ScalarKernels]
  [time]
    type = ODETimeDerivative
    variable = v
  []
  [source]
    type = ParsedODEKernel
    variable = v
    expression = '${fparse - S/V * kb * T}'
  []
[]

[Executioner]
  type = Transient
  dt = .1
  end_time = 10800
  scheme = 'bdf2'
[]

[Outputs]
  [csv]
    type = CSV
  []
[]
