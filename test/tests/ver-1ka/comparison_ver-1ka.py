import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('./gold/ver-1ka_out.csv')

S = 1e20 # m^-3 * s^-1
V = 1 # m^3
kb = 1.380649e-23 # Boltzmann constant (J/K)
T = 500 # K

t_csv = df['time']
v = df['v']
t = np.arange(0, 10801, 540)

expression = (S / V) * kb * T * t

plt.plot(t_csv/3600, v, linestyle='-', color='magenta', label='TMAP8', linewidth=3)
plt.plot(t/3600, expression, marker='+', linestyle='', color='black', label=r"theory", markersize=10)

plt.gca().yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))

plt.xlabel('Time (hr)')
plt.ylabel('Pressure (Pa)')
plt.legend()
plt.grid(True)
plt.savefig('ver-1ka_comparison_time.png', bbox_inches='tight')
