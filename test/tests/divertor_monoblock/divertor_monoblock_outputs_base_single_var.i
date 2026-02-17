
[AuxKernels]
  ############################## AuxKernels for W (block = 4)
  [Scaled_mobile_W]
      variable = Sc_C_mobile_W
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_mobile
  []
  [Scaled_trapped_W]
      variable = Sc_C_trapped_W
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_trapped
  []
  [total_W]
      variable = C_total_W
      type = ParsedAux
      expression = 'C_mobile + C_trapped'
      coupled_variables = 'C_mobile C_trapped'
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
      trapped_concentration_variables = C_trapped
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
      source_variable = C_trapped
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
      source_variable = C_mobile
  []
  [Scaled_trapped_Cu]
      variable = Sc_C_trapped_Cu
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_trapped
  []
  [total_Cu]
      variable = C_total_Cu
      type = ParsedAux
      expression = 'C_mobile + C_trapped'
      coupled_variables = 'C_mobile C_trapped'
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
      trapped_concentration_variables = C_trapped
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
      source_variable = C_trapped
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
      source_variable = C_mobile
  []
  [Scaled_trapped_CuCrZr]
      variable = Sc_C_trapped_CuCrZr
      type = NormalizationAux
      normal_factor = ${tungsten_atomic_density}
      source_variable = C_trapped
  []
  [total_CuCrZr]
      variable = C_total_CuCrZr
      type = ParsedAux
      expression = 'C_mobile + C_trapped'
      coupled_variables = 'C_mobile C_trapped'
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
      trapped_concentration_variables = C_trapped
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
      source_variable = C_trapped
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
      diffusivity = diffusivity
      variable = flux_y
      diffusion_variable = C_mobile
      component = y
      block = 4
  []
  [flux_y_Cu]
      type = DiffusionFluxAux
      diffusivity = diffusivity
      variable = flux_y
      diffusion_variable = C_mobile
      component = y
      block = 3
  []
  [flux_y_CuCrZr]
      type = DiffusionFluxAux
      diffusivity = diffusivity
      variable = flux_y
      diffusion_variable = C_mobile
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
      variable = C_mobile
      block = 4
  []
  [ScInt_C_mobile_W]
      type = ScalePostprocessor
      value =  Int_C_mobile_W
      scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_W]
      type = ElementIntegralVariablePostprocessor
      variable = C_trapped
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
      variable = C_mobile
      block = 3
  []
  [ScInt_C_mobile_Cu]
      type = ScalePostprocessor
      value =  Int_C_mobile_Cu
      scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_Cu]
      type = ElementIntegralVariablePostprocessor
      variable = C_trapped
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
      variable = C_mobile
      block = 2
  []
  [ScInt_C_mobile_CuCrZr]
      type = ScalePostprocessor
      value =  Int_C_mobile_CuCrZr
      scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_CuCrZr]
      type = ElementIntegralVariablePostprocessor
      variable = C_trapped
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
      variable = 'C_total_W C_total_Cu C_total_CuCrZr C_mobile C_trapped flux_y temperature'
      execute_on = timestep_end
  []
[]
