# FuelCycleSystemScalarKernel

!syntax description /ScalarKernels/FuelCycleSystemScalarKernel

## Overview

This object implements the time-dependent mass-transport equations for a
single variable given an arbitrary number of coupled inputs/outputs (coupled [ScalarVariables](/syntax/Variables))
and/or sources and sinks. 
This kernel tracks tritium decay. 
All parameters are defined as functors,
which should allow versatility in accepting a variety of input arguments. An example of using this
kernel for a system is available, following the [Abdou fuel cycle](/examples/fuel_cycle_Abdou) model.

Some consideration should be given to the [!param](/ScalarKernels/FuelCycleSystemScalarKernel/is_implicit) parameter. This term allows the user to select whether the solve
should be done with the current or the last accepted value for the system as the beginning parameter. Functionally this is similar to using a time-dependence for a steady-state system
as it allows the system to evolve more slowly which may avoid some issues with respect to divergence of particularly unstable systems.

Rather than using [`ParsedODEKernel`](scalarkernels/ParsedODEKernel.md) and [`ODETimeDerivative`](scalarkernels/ODETimeDerivative.md) kernels, the scalar kernels block can be simplified.

!listing test/tests/fuel_cycle_Abdou/fuel_cycle_abdou_generic.i link=false block=ScalarKernels

There is still a need to define appropriate [`Postprocessors`](/syntax/Postprocessors) to inform the scalar kernels, as these cannot be assumed for the general case.

!listing test/tests/fuel_cycle_Abdou/fuel_cycle_abdou_generic.i link=false block=Postprocessors

As a reminder, the system of variables should be defined with the [!param](/Variables/family) attribute set to `SCALAR` for each variable.

!listing test/tests/fuel_cycle_Abdou/fuel_cycle_abdou_generic.i link=false block=Variables/T_01_BZ

!syntax parameters /ScalarKernels/FuelCycleSystemScalarKernel

!syntax inputs /ScalarKernels/FuelCycleSystemScalarKernel

!syntax children /ScalarKernels/FuelCycleSystemScalarKernel
