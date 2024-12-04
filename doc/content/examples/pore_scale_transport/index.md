# Pore scale transport

TMAP8 is used to model tritium transport in pore microstructures. This example corresponds to the simulation presented in Section V of [!cite](Simon2022).

## General description of the simulation case and corresponding input file

### Introduction

!style halign=left
UNDER CONSTRUCTION

The sections below describe the simulation details and explain how they translate into the example TMAP8 input files.
Not every part of the input file is explained here.
If the interested reader has more questions about this example case and how to modify this input file to adapt it to a different case,
feel free to reach out to the TMAP8 development team on the [TMAP8 GitHub discussion page](https://github.com/idaholab/TMAP8/discussions).


### Generating the pore microstructure based on an image

!style halign=left
UNDER CONSTRUCTION


[fig:initial_image] shows the initial image,

!media examples/figures/.png
  id=fig:initial_image
  caption=. This corresponds to Fig. X in Ref. [!cite](Simon2022).
  style=display:block;margin-left:auto;margin-right:auto;width:50%

[MOOSE] is equipped with a set of user-friendly, built-in mesh generators for creating meshes based on simple geometries (e.g., a monoblock).

!listing test/tests/pore_scale_transport/2D_microstructure_reader_smoothing_base.i link=false block=Mesh

THIS DOCUMENTATION IS UNDER CONSTRUCTION.

## Complete input file

Below are the complete input files, which can be run reliably with approximately 4 processor cores. Note that this input file has not been optimized to reduce computational costs.

Input file used to import the image and create the smooth microstructure:
!listing test/tests/pore_scale_transport/2D_microstructure_reader_smoothing_base.i

Input file utilizing the smooth microstructure and performing pore scale tritium transport during absorption:
!listing test/tests/pore_scale_transport/2D_absorption_base.i

!bibtex bibliography
