### F_recombination recombination flux
###
### Sc_             Scaled
### Int_            Integrated
### ScInt_          Scaled and integrated

# include sections of the input file shared with other inputs
### This input file is the complete input file for the divertor monoblock case.
### This case was published in:
### M. Shimada, P.-C. A. Simon, C. T. Icenhour, and G. Singh, “Toward a high-fidelity
### tritium transport modeling for retention and permeation experiments,” Fusion
### Engineering and Design, Volume 203, 2024, 114438, ISSN 0920-3796,
### https://doi.org/10.1016/j.fusengdes.2024.114438.

### This input uses the `!include` feature to incorporate other input files
### Nomenclatures
### C_mobile_j      mobile H concentration in "j" material, where j = CuCrZr, Cu, W
### C_trapped_j     trapped H concentration in "j" material, where j = CuCrZr, Cu, W
### C_total_j       total H concentration in "j" material, where j = CuCrZr, Cu, W
###
### S_empty_j       empty site concentration in "j" material, where j = CuCrZr, Cu, W
### S_trapped_j     trapped site concentration in "j" material, where j = CuCrZr, Cu, W
### S_total_j       total site H concentration in "j" material, where j = CuCrZr, Cu, W
###
### F_permeation    permeation flux
### F_recombination recombination flux
###
### Sc_             Scaled
### Int_            Integrated
### ScInt_          Scaled and integrated

!include divertor_monoblock_explicit_base.i
Variables/temperature/initial_condition = ${temperature_initial}
[Outputs]
  [exodus]
    type = Exodus
    sync_only = false
    # Output at key moments in the first two cycles, and then at the end of the simulation
    sync_times = '${fparse 1.1 * plasma_ramp_time} ${fparse plasma_ss_end - 20} ${fparse plasma_ramp_down_end - 10} ${plasma_cycle_time} ${fparse plasma_cycle_time + 1.1 * plasma_ramp_time} ${fparse plasma_cycle_time + plasma_ss_end - 20} ${fparse plasma_cycle_time + plasma_ramp_down_end - 10} ${fparse 2 * plasma_cycle_time} ${fparse 50 * plasma_cycle_time}'
  []
  csv = true
  hide = 'dt
            Int_C_mobile_W Int_C_trapped_W Int_C_total_W
            Int_C_mobile_Cu Int_C_trapped_Cu Int_C_total_Cu
            Int_C_mobile_CuCrZr Int_C_trapped_CuCrZr Int_C_total_CuCrZr'
  perf_graph = true
[]
