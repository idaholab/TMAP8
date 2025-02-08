#!/usr/bin/env python3

import mms
import sympy

u = 'cos(x) * t'
trapping1 = '(N*frac1/2+N*frac1/2 * cos(x) * t)'
empty1 = f'(N*frac1 - {trapping1})'
trapping2 = '(N*frac2/2+N*frac2/2 * cos(x) * t)'
empty2 = f'(N*frac2 - {trapping2})'
trapping3 = '(N*frac3/2+N*frac3/2 * cos(x) * t)'
empty3 = f'(N*frac3 - {trapping3})'

f_u, e_u = mms.evaluate('diff(u,t) - D*div(grad(u)) + diff(trapping1,t) + diff(trapping2,t) + diff(trapping3,t)', u, variable='u', trapping1=trapping1, trapping2=trapping2, trapping3=trapping3, scalars=['D', 'N', 'frac1', 'frac2', 'frac3'])
f_t1, e_t1 = mms.evaluate('diff(trapping1, t) - alphat / N * (empty1*u) + alphar * trapping1 * exp(-epsilon_1/temperature)', trapping1, variable='trapping1', empty1=empty1, u=u, scalars=['alphar', 'alphat', 'N', 'frac1', 'epsilon_1', 'temperature'])
f_t2, e_t2 = mms.evaluate('diff(trapping2, t) - alphat / N * (empty2*u) + alphar * trapping2 * exp(-epsilon_2/temperature)', trapping2, variable='trapping2', empty2=empty2, u=u, scalars=['alphar', 'alphat', 'N', 'frac2', 'epsilon_2', 'temperature'])
f_t3, e_t3 = mms.evaluate('diff(trapping3, t) - alphat / N * (empty3*u) + alphar * trapping3 * exp(-epsilon_3/temperature)', trapping3, variable='trapping3', empty3=empty3, u=u, scalars=['alphar', 'alphat', 'N', 'frac3', 'epsilon_3', 'temperature'])
mms.print_hit(e_u, 'exact_u')
mms.print_hit(f_u, 'forcing_u', N='${N}', frac1='${frac1}', frac2='${frac2}', frac3='${frac3}')
mms.print_hit(e_t1, 'exact_t1', frac1='${frac1}', N='${N}')
mms.print_hit(f_t1, 'forcing_t1', alphar='${alphar}', alphat='${alphat}', N='${N}', frac1='${frac1}', temperature='${temperature}', epsilon_1='${epsilon_1}')
mms.print_hit(e_t2, 'exact_t2',  frac2='${frac2}', N='${N}')
mms.print_hit(f_t2, 'forcing_t2', alphar='${alphar}', alphat='${alphat}', N='${N}', frac2='${frac2}', temperature='${temperature}', epsilon_2='${epsilon_2}')
mms.print_hit(e_t3, 'exact_t3', frac3='${frac3}', N='${N}')
mms.print_hit(f_t3, 'forcing_t3', alphar='${alphar}', alphat='${alphat}', N='${N}', frac3='${frac3}', temperature='${temperature}', epsilon_3='${epsilon_3}')
