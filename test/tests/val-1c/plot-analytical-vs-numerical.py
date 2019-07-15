#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt

numerical_data = np.loadtxt("val-1c_csv.csv",delimiter=',',skiprows=1)

analytical_data = np.loadtxt("analytical.csv",delimiter=',',skiprows=1)

numerical_time = numerical_data[1:,0]
analytical_time = analytical_data[:,0]

plt.plot(numerical_time,numerical_data[1:,1],
         label='numerical, x = 0',color='blue',linestyle='-')
plt.plot(numerical_time,numerical_data[1:,2],
         label='numerical, x = 10',color='red',linestyle='-')
plt.plot(numerical_time,numerical_data[1:,3],
         label='numerical, x = 12',color='green',linestyle='-')
plt.plot(analytical_time,analytical_data[:,1],
         label='analytical, x = 0',color='blue',linestyle='--')
plt.plot(analytical_time,analytical_data[:,2],
         label='analytical, x = 10',color='red',linestyle='--')
plt.plot(analytical_time,analytical_data[:,3],
         label='analytical, x = 12',color='green',linestyle='--')
plt.legend()
plt.show()
