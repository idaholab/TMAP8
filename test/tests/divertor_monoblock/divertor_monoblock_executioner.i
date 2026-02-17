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
