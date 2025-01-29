[exact_u]
  type = ParsedFunction
  expression = 't*cos(x)'
[]
[forcing_u]
  type = ParsedFunction
  expression = '(1/2)*N*frac1*cos(x) + (1/2)*N*frac2*cos(x) + (1/2)*N*frac3*cos(x) + t*cos(x) + cos(x)'
  symbol_names = 'N frac1 frac2 frac3'
  symbol_values = '${N} ${frac1} ${frac2} ${frac3}'
[]
[exact_t1]
  type = ParsedFunction
  expression = '(1/2)*N*frac1*t*cos(x) + (1/2)*N*frac1'
  symbol_names = 'frac1 N'
  symbol_values = '${frac1} ${N}'
[]
[forcing_t1]
  type = ParsedFunction
  expression = '(1/2)*N*frac1*cos(x) + alphar*((1/2)*N*frac1*t*cos(x) + (1/2)*N*frac1)*exp(-epsilon_1/temperature) - alphat*t*(-1/2*N*frac1*t*cos(x) + (1/2)*N*frac1)*cos(x)/N'
  symbol_names = 'alphar alphat N frac1 temperature epsilon_1'
  symbol_values = '${alphar} ${alphat} ${N} ${frac1} ${temperature} ${epsilon_1}'
[]
[exact_t2]
  type = ParsedFunction
  expression = '(1/2)*N*frac2*t*cos(x) + (1/2)*N*frac2'
  symbol_names = 'frac2 N'
  symbol_values = '${frac2} ${N}'
[]
[forcing_t2]
  type = ParsedFunction
  expression = '(1/2)*N*frac2*cos(x) + alphar*((1/2)*N*frac2*t*cos(x) + (1/2)*N*frac2)*exp(-epsilon_2/temperature) - alphat*t*(-1/2*N*frac2*t*cos(x) + (1/2)*N*frac2)*cos(x)/N'
  symbol_names = 'alphar alphat N frac2 temperature epsilon_2'
  symbol_values = '${alphar} ${alphat} ${N} ${frac2} ${temperature} ${epsilon_2}'
[]
[exact_t3]
  type = ParsedFunction
  expression = '(1/2)*N*frac3*t*cos(x) + (1/2)*N*frac3'
  symbol_names = 'frac3 N'
  symbol_values = '${frac3} ${N}'
[]
[forcing_t3]
  type = ParsedFunction
  expression = '(1/2)*N*frac3*cos(x) + alphar*((1/2)*N*frac3*t*cos(x) + (1/2)*N*frac3)*exp(-epsilon_3/temperature) - alphat*t*(-1/2*N*frac3*t*cos(x) + (1/2)*N*frac3)*cos(x)/N'
  symbol_names = 'alphar alphat N frac3 temperature epsilon_3'
  symbol_values = '${alphar} ${alphat} ${N} ${frac3} ${temperature} ${epsilon_3}'
[]
