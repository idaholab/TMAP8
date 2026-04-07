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
