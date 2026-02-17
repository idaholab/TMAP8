# geometry and design
radius_coolant = ${units 6.0 mm -> m}
radius_CuCrZr = ${units 7.5 mm -> m}
radius_Cu = ${units 8.5 mm -> m}
block_size = ${units 28 mm -> m}
num_sectors = 36 # (-) defines mesh size

# operation conditions
temperature_initial = ${units 300.0 K}
temperature_coolant_max = ${units 552.0 K}



plasma_ramp_time = 100.0 #s
plasma_ss_duration = 400.0 #s
plasma_cycle_time = 1600.0 #s (3.0e4 s plasma, 2.0e4 SSP)

plasma_ss_end = ${fparse plasma_ramp_time + plasma_ss_duration} #s
plasma_ramp_down_end = ${fparse plasma_ramp_time + plasma_ss_duration + plasma_ramp_time} #s

plasma_max_heat = 1.0e7 #W/m^2 # Heat flux of 10MW/m^2 at steady state
plasma_min_heat = 0.0 # W/m^2 # no flux while the pulse is off.

### Maximum mobile flux of 7.90e-13 at the top surface (1.0e-4 [m])
### 1.80e23/m^2-s = (5.0e23/m^2-s) *(1-0.999) = (7.90e-13)*(${tungsten_atomic_density})/(1.0e-4)  at steady state
plasma_max_flux = 7.90e-13
plasma_min_flux = 0.0

# Materials properties
tungsten_atomic_density = ${units 6.338e28 m^-3}
density_W = 19300                # [g/m^3]
density_Cu = 8960.0               # [g/m^3]
density_CuCrZr = 8900.0 # [g/m^3]
specific_heat_CuCrZr = 390.0     # [ W/m-K], [J/kg-K]

diffusivity_fixed = 5.01e-24   # (3.01604928)/(6.02e23)/[gram(T)/m^2]
# diffusivity_fixed = 5.508e-19   # (1.0e3)*(1.0e3)/(6.02e23)/(3.01604928) [gram(T)/m^2] alternative

N_W = ${units 1.0e0 m^-3}       # = ${tungsten_atomic_density} #/m^3 (W lattice density)
Ct0_W = ${units 1.0e-4 m^-3}  # E.A. Hodille et al 2021 Nucl. Fusion 61 1260033, trap 2
# Ct0 = ${units 1.0e-4 m^-3}   # E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 1
trap_per_free_W = 1.0e0

N_Cu = ${units 1.0e0 m^-3}     # = ${tungsten_atomic_density} #/m^3 (W lattice density)
Ct0_Cu = ${units 5.0e-5 m^-3}    # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
trap_per_free_Cu = 1.0e0

N_CuCrZr = ${units 1.0e0 m^-3}     # = ${tungsten_atomic_density} #/m^3 (W lattice density)
Ct0_CuCrZr = ${units 5.0e-5 m^-3}  # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
# Ct0 = ${units 4.0e-2 m^-3} # R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 5
trap_per_free_CuCrZr = 1.0e0

scaling_factor = 3.491e10    # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
scaling_factor_2 = 3.44e10   # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]


[Functions]
    [t_in_cycle]
        type = ParsedFunction
        expression = 't % ${plasma_cycle_time}'
    []
    # pulse between 0 and 1 following the plasma operation
    [pulse_time_function]
        type = ParsedFunction
        symbol_values = 't_in_cycle'
        symbol_names = 't_in_cycle'
        expression =   'if(t_in_cycle < ${plasma_ramp_time}, t_in_cycle/${plasma_ramp_time},
                        if(t_in_cycle < ${plasma_ss_end}, 1,
                        if(t_in_cycle < ${plasma_ramp_down_end}, 1 - (t_in_cycle-${plasma_ss_end})/${plasma_ramp_time}, 0.0)))'
    []
    [mobile_flux_bc_function]
        type = ParsedFunction
        symbol_values = 'pulse_time_function'
        symbol_names = 'pulse_time_function'
        expression = '(${plasma_max_flux} - ${plasma_min_flux}) * pulse_time_function + ${plasma_min_flux}'
    []
    [temperature_flux_bc_function]
        type = ParsedFunction
        symbol_values = 'pulse_time_function'
        symbol_names = 'pulse_time_function'
        expression = '(${plasma_max_heat} - ${plasma_min_heat}) * pulse_time_function + ${plasma_min_heat}'
    []
    [temperature_inner_func]
        type = ParsedFunction
        symbol_values = 'pulse_time_function'
        symbol_names = 'pulse_time_function'
        expression = '(${temperature_coolant_max} - ${temperature_initial}) * pulse_time_function + ${temperature_initial}'
    []
    [timestep_function]
        type = ParsedFunction
        symbol_values = 't_in_cycle'
        symbol_names = 't_in_cycle'
        expression = 'if(t_in_cycle < ${fparse 0.1 * plasma_ramp_time}   ,  20,
                      if(t_in_cycle < ${fparse 0.9 * plasma_ramp_time}   ,  40,
                      if(t_in_cycle < ${fparse 1.1 * plasma_ramp_time}   ,  20,
                      if(t_in_cycle < ${fparse plasma_ss_end - 20}       ,  40,
                      if(t_in_cycle < ${plasma_ss_end}                   ,  20,
                      if(t_in_cycle < ${fparse plasma_ramp_down_end - 10},   4,
                      if(t_in_cycle < ${fparse plasma_ramp_down_end + 10},  20,
                      if(t_in_cycle < ${fparse plasma_cycle_time - 100}  , 200,
                      if(t_in_cycle < ${plasma_cycle_time}               ,  40,  2)))))))))'
    []
[]

[AuxVariables]
  [flux_y]
      order = FIRST
      family = MONOMIAL
  []
  ############################## AuxVariables for W (block = 4)
  [Sc_C_mobile_W]
      block = 4
  []
  [Sc_C_trapped_W]
      block = 4
  []
  [C_total_W]
      block = 4
  []
  [Sc_C_total_W]
      block = 4
  []
  [S_empty_W]
      block = 4
  []
  [Sc_S_empty_W]
      block = 4
  []
  [S_trapped_W]
      block = 4
  []
  [Sc_S_trapped_W]
      block = 4
  []
  [S_total_W]
      block = 4
  []
  [Sc_S_total_W]
      block = 4
  []
  ############################## AuxVariables for Cu (block = 3)
  [Sc_C_mobile_Cu]
      block = 3
  []
  [Sc_C_trapped_Cu]
      block = 3
  []
  [C_total_Cu]
      block = 3
  []
  [Sc_C_total_Cu]
      block = 3
  []
  [S_empty_Cu]
      block = 3
  []
  [Sc_S_empty_Cu]
      block = 3
  []
  [S_trapped_Cu]
      block = 3
  []
  [Sc_S_trapped_Cu]
      block = 3
  []
  [S_total_Cu]
      block = 3
  []
  [Sc_S_total_Cu]
      block = 3
  []
  ############################## AuxVariables for CuCrZr (block = 2)
  [Sc_C_mobile_CuCrZr]
      block = 2
  []
  [Sc_C_trapped_CuCrZr]
      block = 2
  []
  [C_total_CuCrZr]
      block = 2
  []
  [Sc_C_total_CuCrZr]
      block = 2
  []
  [S_empty_CuCrZr]
      block = 2
  []
  [Sc_S_empty_CuCrZr]
      block = 2
  []
  [S_trapped_CuCrZr]
      block = 2
  []
  [Sc_S_trapped_CuCrZr]
      block = 2
  []
  [S_total_CuCrZr]
      block = 2
  []
  [Sc_S_total_CuCrZr]
      block = 2
  []
[]

[Preconditioning]
    [smp]
        type = SMP
        full = true
    []
[]

[Executioner]
    type = Transient
    scheme = bdf2
    solve_type = NEWTON
    petsc_options_iname = '-pc_type -pc_factor_shift_type'
    petsc_options_value = 'lu NONZERO'
    nl_rel_tol  = 1e-6 # 1e-8 works for 1 cycle
    nl_abs_tol  = 1e-7 # 1e-11 works for 1 cycle
    end_time = ${fparse 50 * plasma_cycle_time} # 50 ITER shots
    automatic_scaling = true
    line_search = 'none'
    dtmin = 1e-4
    nl_max_its = 18
    [TimeStepper]
        type = IterationAdaptiveDT
        dt = 20
        optimal_iterations = 15
        iteration_window = 1
        growth_factor = 1.2
        cutback_factor = 0.8
        timestep_limiting_postprocessor = timestep_max_pp
    []
[]

[Outputs]
    [exodus]
        type = Exodus
        sync_only = false
        # output at key moments in the first two cycles, and then at the end of the simulation
        sync_times = '${fparse 1.1 * plasma_ramp_time} ${fparse plasma_ss_end - 20} ${fparse plasma_ramp_down_end - 10} ${plasma_cycle_time} ${fparse plasma_cycle_time + 1.1 * plasma_ramp_time} ${fparse plasma_cycle_time + plasma_ss_end - 20} ${fparse plasma_cycle_time + plasma_ramp_down_end - 10} ${fparse 2 * plasma_cycle_time} ${fparse 50 * plasma_cycle_time}'
    []
    csv = true
    hide = 'dt
            Int_C_mobile_W Int_C_trapped_W Int_C_total_W
            Int_C_mobile_Cu Int_C_trapped_Cu Int_C_total_Cu
            Int_C_mobile_CuCrZr Int_C_trapped_CuCrZr Int_C_total_CuCrZr'
    perf_graph = true
[]

