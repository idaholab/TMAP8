
# Materials properties
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


[AuxKernels]
  ############################## AuxKernels for W (block = 4)
  [Scaled_mobile_W]
      variable = Sc_C_mobile_W
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_mobile_W
  []
  [Scaled_trapped_W]
      variable = Sc_C_trapped_W
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_trapped_W
  []
  [total_W]
      variable = C_total_W
      type = ParsedAux
      expression = 'C_mobile_W + C_trapped_W'
      coupled_variables = 'C_mobile_W C_trapped_W'
  []
  [Scaled_total_W]
      variable = Sc_C_total_W
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_total_W
  []
  [empty_sites_W]
      variable = S_empty_W
      type = EmptySitesAux
      N = ${N_W}
      Ct0 = ${Ct0_W}
      trap_per_free = ${trap_per_free_W}
      trapped_concentration_variables = C_trapped_W
  []
  [scaled_empty_W]
      variable = Sc_S_empty_W
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_empty_W
  []
  [trapped_sites_W]
      variable = S_trapped_W
      type = NormalizationAux
      normal_factor = 1e0
      source_variable = C_trapped_W
  []
  [scaled_trapped_W]
      variable = Sc_S_trapped_W
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_trapped_W
  []
  [total_sites_W]
      variable = S_total_W
      type = ParsedAux
      expression = 'S_trapped_W + S_empty_W'
      coupled_variables = 'S_trapped_W S_empty_W'
  []
  [scaled_total_W]
      variable = Sc_S_total_W
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_total_W
  []
  ############################## AuxKernels for Cu (block = 3)
  [Scaled_mobile_Cu]
      variable = Sc_C_mobile_Cu
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_mobile_Cu
  []
  [Scaled_trapped_Cu]
      variable = Sc_C_trapped_Cu
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_trapped_Cu
  []
  [total_Cu]
      variable = C_total_Cu
      type = ParsedAux
      expression = 'C_mobile_Cu + C_trapped_Cu'
      coupled_variables = 'C_mobile_Cu C_trapped_Cu'
  []
  [Scaled_total_Cu]
      variable = Sc_C_total_Cu
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_total_Cu
  []
  [empty_sites_Cu]
      variable = S_empty_Cu
      type = EmptySitesAux
      N = ${N_Cu}
      Ct0 = ${Ct0_Cu}
      trap_per_free = ${trap_per_free_Cu}
      trapped_concentration_variables = C_trapped_Cu
  []
  [scaled_empty_Cu]
      variable = Sc_S_empty_Cu
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_empty_Cu
  []
  [trapped_sites_Cu]
      variable = S_trapped_Cu
      type = NormalizationAux
      normal_factor = 1e0
      source_variable = C_trapped_Cu
  []
  [scaled_trapped_Cu]
      variable = Sc_S_trapped_Cu
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_trapped_Cu
  []
  [total_sites_Cu]
      variable = S_total_Cu
      type = ParsedAux
      expression = 'S_trapped_Cu + S_empty_Cu'
      coupled_variables = 'S_trapped_Cu S_empty_Cu'
  []
  [scaled_total_Cu]
      variable = Sc_S_total_Cu
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_total_Cu
  []
  ############################## AuxKernels for CuCrZr (block = 2)
  [Scaled_mobile_CuCrZr]
      variable = Sc_C_mobile_CuCrZr
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_mobile_CuCrZr
  []
  [Scaled_trapped_CuCrZr]
      variable = Sc_C_trapped_CuCrZr
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_trapped_CuCrZr
  []
  [total_CuCrZr]
      variable = C_total_CuCrZr
      type = ParsedAux
      expression = 'C_mobile_CuCrZr + C_trapped_CuCrZr'
      coupled_variables = 'C_mobile_CuCrZr C_trapped_CuCrZr'
  []
  [Scaled_total_CuCrZr]
      variable = Sc_C_total_CuCrZr
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_total_CuCrZr
  []
  [empty_sites_CuCrZr]
      variable = S_empty_CuCrZr
      type = EmptySitesAux
      N = ${N_CuCrZr}
      Ct0 = ${Ct0_CuCrZr}
      trap_per_free = ${trap_per_free_CuCrZr}
      trapped_concentration_variables = C_trapped_CuCrZr
  []
  [scaled_empty_CuCrZr]
      variable = Sc_S_empty_CuCrZr
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_empty_CuCrZr
  []
  [trapped_sites_CuCrZr]
      variable = S_trapped_CuCrZr
      type = NormalizationAux
      normal_factor = 1e0
      source_variable = C_trapped_CuCrZr
  []
  [scaled_trapped_CuCrZr]
      variable = Sc_S_trapped_CuCrZr
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_trapped_CuCrZr
  []
  [total_sites_CuCrZr]
      variable = S_total_CuCrZr
      type = ParsedAux
      expression = 'S_trapped_CuCrZr + S_empty_CuCrZr'
      coupled_variables = 'S_trapped_CuCrZr S_empty_CuCrZr'
  []
  [scaled_total_CuCrZr]
      variable = Sc_S_total_CuCrZr
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = S_total_CuCrZr
  []
  [flux_y_W]
      type = DiffusionFluxAux
      diffusivity = diffusivity_W
      variable = flux_y
      diffusion_variable = C_mobile_W
      component = y
      block = 4
  []
  [flux_y_Cu]
      type = DiffusionFluxAux
      diffusivity = diffusivity_Cu
      variable = flux_y
      diffusion_variable = C_mobile_Cu
      component = y
      block = 3
  []
  [flux_y_CuCrZr]
      type = DiffusionFluxAux
      diffusivity = diffusivity_CuCrZr
      variable = flux_y
      diffusion_variable = C_mobile_CuCrZr
      component = y
      block = 2
  []
[]


[Postprocessors]
  ############################################################ Postprocessors for W (block = 4)
  [F_recombination]
      type = SideDiffusiveFluxAverage
      boundary = 'top'
      diffusivity = ${diffusivity_fixed}
      variable = Sc_C_total_W
  []
  [F_permeation]
      type = SideDiffusiveFluxAverage
      boundary = '2to1'
      diffusivity = ${diffusivity_fixed}
      variable = Sc_C_total_CuCrZr
  []

  [Int_C_mobile_W]
      type = ElementIntegralVariablePostprocessor
      variable = C_mobile_W
      block = 4
  []
  [ScInt_C_mobile_W]
      type = ScalePostprocessor
      value =  Int_C_mobile_W
      scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_W]
      type = ElementIntegralVariablePostprocessor
      variable = C_trapped_W
      block = 4
  []
  [ScInt_C_trapped_W]
      type = ScalePostprocessor
      value = Int_C_trapped_W
      scaling_factor = ${scaling_factor}
  []
  [Int_C_total_W]
      type = ElementIntegralVariablePostprocessor
      variable = C_total_W
      block = 4
  []
  [ScInt_C_total_W]
      type = ScalePostprocessor
      value = Int_C_total_W
      scaling_factor = ${scaling_factor}
  []
  # ############################################################ Postprocessors for Cu (block = 3)
  [Int_C_mobile_Cu]
      type = ElementIntegralVariablePostprocessor
      variable = C_mobile_Cu
      block = 3
  []
  [ScInt_C_mobile_Cu]
      type = ScalePostprocessor
      value =  Int_C_mobile_Cu
      scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_Cu]
      type = ElementIntegralVariablePostprocessor
      variable = C_trapped_Cu
      block = 3
  []
  [ScInt_C_trapped_Cu]
      type = ScalePostprocessor
      value = Int_C_trapped_Cu
      scaling_factor = ${scaling_factor_2}
  []
  [Int_C_total_Cu]
      type = ElementIntegralVariablePostprocessor
      variable = C_total_Cu
      block = 3
  []
  [ScInt_C_total_Cu]
      type = ScalePostprocessor
      value = Int_C_total_Cu
      scaling_factor = ${scaling_factor}
  []
  # ############################################################ Postprocessors for CuCrZr (block = 2)
  [Int_C_mobile_CuCrZr]
      type = ElementIntegralVariablePostprocessor
      variable = C_mobile_CuCrZr
      block = 2
  []
  [ScInt_C_mobile_CuCrZr]
      type = ScalePostprocessor
      value =  Int_C_mobile_CuCrZr
      scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_CuCrZr]
      type = ElementIntegralVariablePostprocessor
      variable = C_trapped_CuCrZr
      block = 2
  []
  [ScInt_C_trapped_CuCrZr]
      type = ScalePostprocessor
      value = Int_C_trapped_CuCrZr
      scaling_factor = ${scaling_factor_2}
  []
  [Int_C_total_CuCrZr]
      type = ElementIntegralVariablePostprocessor
      variable = C_total_CuCrZr
      block = 2
  []
  [ScInt_C_total_CuCrZr]
      type = ScalePostprocessor
      value = Int_C_total_CuCrZr
      scaling_factor = ${scaling_factor}
  []
  ############################################################ Postprocessors for others
  [dt]
      type = TimestepSize
  []
  [temperature_top]
      type = PointValue
      variable = temperature
      point = '0 ${fparse block_size / 2} 0'
  []
  [temperature_tube]
      type = PointValue
      variable = temperature
      point = '0 ${radius_coolant} 0'
  []
  # limit timestep
  [timestep_max_pp] # s
    type = FunctionValuePostprocessor
    function = timestep_function
  []
[]

[VectorPostprocessors]
  [line]
      type = LineValueSampler
      start_point = '0 ${fparse block_size / 2} 0'
      end_point = '0 ${radius_coolant} 0'
      num_points = 100
      sort_by = 'y'
      variable = 'C_total_W C_total_Cu C_total_CuCrZr C_mobile_W C_mobile_Cu C_mobile_CuCrZr C_trapped_W C_trapped_Cu C_trapped_CuCrZr flux_y temperature'
      execute_on = timestep_end
  []
[]
