import numpy as np
import subprocess

# number of processors
n_proc = 4

filename = 'val-flibe.i'
search_strings = ["T = '${units ",'p_bnd = ','    file_base = ']
command_to_run = "mpirun -np "+str(n_proc)+" ~/projects/TMAP8/tmap8-opt -i val-flibe.i"

# Experimental data pressure and Temperature series
p_exp = np.array([1210,538,315,171,1210,538,315,1210,538,1210])
T_exp = np.array([700,700,700,700,650,650,650,600,600,550])


def run_terminal_command(command):
    subprocess.run([command], shell=True, check=True)

def substitute_row(filename, search_string, replacement):
    # Read the contents of the file
    with open(filename, 'r') as file:
        lines = file.readlines()
    # Search for the row and substitute it
    for i, line in enumerate(lines):
        if search_string in line:
            lines[i] = replacement + '\n'  # Add a newline character for consistency
    # Write the modified contents back to the file
    with open(filename, 'w') as file:
        file.writelines(lines)




# Names of output files for each case
output_fname = np.array([])
for p,T in zip(p_exp,T_exp):
    output_fname = np.append(output_fname, 'val-flibe_'+str(p)+'_'+str(T))



for T,p,outName in zip(T_exp,p_exp,output_fname):
    replacemens = ["T = '${units "+str(T)+" degC -> K}' # temperature", 'p_bnd = '+str(p)+' # pressure', "    file_base = '"+outName+"'"]
    substitute_row(filename, search_strings[0], replacemens[0])
    substitute_row(filename, search_strings[1], replacemens[1])
    substitute_row(filename, search_strings[2], replacemens[2])
    # Run input file with new BCs
    run_terminal_command(command_to_run)
    print('########## Run at',p,'Pa and',T,'degC completed. ##########')
