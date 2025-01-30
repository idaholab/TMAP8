import os
import sys

script_folder = os.path.dirname(__file__)
tmap8_term = '/tmap8'

# Assert that the tmap8 term is in the script folder path
assert tmap8_term in script_folder.lower(), f"The term '{tmap8_term}' was not found in the script folder path."

# Find the index position where the tmap8 term ends within the script folder
index = script_folder.lower().find(tmap8_term) + len(tmap8_term)

# Slice the script folder up to and including the end of the tmap8 term
tmap8_path = script_folder[:index]

# Locate MOOSE directory
MOOSE_DIR = os.getenv('MOOSE_DIR', os.path.join(tmap8_path, 'moose'))
if not os.path.exists(MOOSE_DIR):
    MOOSE_DIR = os.path.abspath(os.path.join(os.path.dirname(__name__), '..', 'moose'))
if not os.path.exists(MOOSE_DIR):
    raise Exception('Failed to locate MOOSE, specify the MOOSE_DIR environment variable.')
os.environ['MOOSE_DIR'] = MOOSE_DIR

# Append MOOSE python directory
MOOSE_PYTHON_DIR = os.path.join(MOOSE_DIR, 'python')
if MOOSE_PYTHON_DIR not in sys.path:
    sys.path.append(MOOSE_PYTHON_DIR)

import mms

def run():
    # Changes working directory to script directory (for consistent MooseDocs usage)
    os.chdir(script_folder)
    if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
        mms_input = "../../../../test/tests/ver-1dc/mms.i"
    else:                                  # if in test folder
        mms_input = "mms.i"
    df1 = mms.run_spatial(mms_input, 4, y_pp=['L2u'])
    fig = mms.ConvergencePlot(xlabel=r'$\Delta$t', ylabel='$L_2$ Error')
    fig.plot(df1, label=['L2u'], marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
    fig.save('ver-1dc-mms-spatial.png')
    return fig

if __name__ == '__main__':
    run()
