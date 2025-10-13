# Getting Started with TMAP8

!---

# How to install TMAP8

To install TMAP8, go to [the installation page](installation.md) and follow the instructions.

Help for troubleshooting is available at the bottom of the page.

Different installation procedures are available for different operating systems (MacOS, linux, virtual, HPC) and different needs (user vs developer).

Note that if you plan on contributing to TMAP8 (code, documentation, etc.), the instructions in the [Contributing to TMAP8 page](getting_started/contributing.md) are here for you.

!---

# Run a verification case

More detailed instructions on how to run a case is available in the following hands-on part of the workshop, these instructions are only intended to quickly get users up and running:

1. Go to [the V&V page](verification_and_validation/index.md) and select a case
1. Edit input files as needed with [VSCode](development/VSCode.md) or your favorite text editor.
1. Save your input file
1. in the terminal, `cd` to the desired folder, and type `mpirun -np 1 ~/projects/TMAP8/tmap8-opt -i inputname.i`
1. To run on several processors, change `1` to the desired number of processors.

!---

# Visualize the results

All the [V&V cases](verification_and_validation/index.md) have python scripts to automatically plot the results generated as csv files, which can otherwise can be opened in Microsoft Excel. They are used to automatically generate the figures for the documentation based on the results in the gold files, so that the TMAP8 documentation always shows up-to-date results.

You should feel free to utilize them to plot the results of your simulations. Note that you will need to create a copy of the python script of interest and edit it to plot the data from the folder in which the simulation results were generated (instead of the gold file).

Some TMAP8 simulations generate `exodus` files, which can be visualized with dedicated software, such as ParaView. ParaView is a visualization software from [Kitware](https://www.kitware.com) that will help you visualize TMAP8's results. ParaView can be used in the
base operating system to view and visualize that output. Download and install ParaView from [https://www.paraview.org/download](https://www.paraview.org/download).


