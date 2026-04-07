### This is the driver input file for the divertor monoblock case published in:
### M. Shimada, P.-C. A. Simon, C. T. Icenhour, and G. Singh, “Toward a high-fidelity
### tritium transport modeling for retention and permeation experiments,” Fusion
### Engineering and Design, Volume 203, 2024, 114438, ISSN 0920-3796,
### https://doi.org/10.1016/j.fusengdes.2024.114438.

### This input uses the `!include` feature to incorporate other input files

!include divertor_monoblock_explicit_base.i
!include divertor_monoblock_output_base.i

Variables/temperature/initial_condition = ${temperature_initial}
