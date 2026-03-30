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

# include sections of the input file shared with other inputs
inter_pwr = 10e6
coolant_temp = 552
elm_value = 1147e6
elm_duration = 1.32e-3
W_cond_factor = 1.0
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

C_mobile_CuCrZr_DirichletBC_Coolant = 1.0e-18 # at.fraction
C_mobile_W_init = 1.0e-20 # at.fraction
C_mobile_Cu_init = 5.0e-17 # at.fraction
C_mobile_CuCrZr_init = 1.0e-15 # at.fraction

# include sections of the input file shared with other inputs
# This input file contains the geometry and mesh for the divertor monoblock case.
# It creates the geometry and mesh based on input parameters and generates the relevant interfaces between materials.
# It cannot be run on its own and is included in the main input file for this case, namely:
# - divertor_monoblock.i
# - divertor_monoblock_physics.i
# - divertor_monoblock_physics-single-variable.i

[Mesh]
  [ccmg]
    type = ConcentricCircleMeshGenerator
    num_sectors = ${num_sectors}
    rings = '${rings_H2O} ${rings_CuCrZr} ${rings_Cu} ${rings_W}'
    radii = '${radius_coolant} ${radius_CuCrZr} ${radius_Cu}'
    has_outer_square = on
    pitch = '${fparse block_size}'
    portion = left_half
    preserve_volumes = false
    smoothing_max_it = 3
  []
  [ssbsg1]
    type = SideSetsBetweenSubdomainsGenerator
    input = ccmg
    primary_block = '4' # W
    paired_block = '3' # Cu
    new_boundary = '4to3'
  []
  [ssbsg2]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg1
    primary_block = '3' # Cu
    paired_block = '4' # W
    new_boundary = '3to4'
  []
  [ssbsg3]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg2
    primary_block = '3' # Cu
    paired_block = '2' # CuCrZr
    new_boundary = '3to2'
  []
  [ssbsg4]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg3
    primary_block = '2' # CuCrZr
    paired_block = '3' # Cu
    new_boundary = '2to3'
  []
  [ssbsg5]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg4
    primary_block = '2' # CuCrZr
    paired_block = '1' # H2O
    new_boundary = '2to1'
  []
  [bdg]
    type = BlockDeletionGenerator
    input = ssbsg5
    block = '1' # H2O
  []
[]
# This input file contains key pieces for the divertor monoblock case.
# It cannot be run on its own and is included in the main input files for all divertor monoblock
# cases, namely:
# - divertor_monoblock.i
# - divertor_monoblock_physics.i
# - divertor_monoblock_physics-single-variable.i

# Geometry and design
radius_coolant = 0.006 # depends on MOOSE PR 32524  '${units 6.0 mm -> m}'
radius_CuCrZr = 0.0075 #'${units 7.5 mm -> m}'
radius_Cu = 0.0085 # '${units 8.5 mm -> m}'
block_size = 0.028 # depends on MOOSE PR 32524 '${units 28.0 mm -> m}'
num_sectors = 36 # (-) defines mesh size
rings_H2O = 1 # (-)
rings_CuCrZr = 30 # (-)
rings_Cu = 20 # (-)
rings_W = 110 # (-)

# Operation conditions
plasma_ramp_time = '${units 100.0 s}'
plasma_ss_duration = '${units 400.0 s}'
plasma_cycle_time = '${units 1600.0 s}'
plasma_ss_end = '${fparse plasma_ramp_time + plasma_ss_duration}'
plasma_ramp_down_end = '${fparse plasma_ramp_time + plasma_ss_duration + plasma_ramp_time}'

temperature_initial = '${units 300.0 K}'
temperature_coolant_max = '${units 552.0 K}'

plasma_max_heat = '${units 1.0e7 W/m^2}' # Heat flux of 10 MW/m^2 at steady state
plasma_min_heat = '${units 0.0 W/m^2}' # no flux while the pulse is off.

# Maximum mobile flux of 7.90e-13 at the top surface (1.0e-4 [m])
# 10e24 at/m^3/s plasma flux at steady state
# 50% of it corresponds to tritium in a DT plasma
# Assuming 0.1% of incident plasma is retained in the divertor, this results in a flux of
# 5e20 at/m^3/s for tritium
# This is then normalized by the tungsten_atomic_density and leads to a flux of ~7.90e-9 m/s
# This is then distributed in the first mesh layer, which has a thickness of 1e-4 m
plasma_max_flux = '${units 7.90e-13 1/s}' # at.fraction / s
plasma_min_flux = '${units 0.0 1/s}'

# Initial conditions
C_trapping_init = 1.0e-15 # at.fraction

# Materials properties - W
tungsten_atomic_density = '${units 6.338e28 atoms/m^3}'
density_W = '${units 19300 kg/m^3}'
N_W = '${fparse tungsten_atomic_density / tungsten_atomic_density}' # usually in atoms/m^3, but here normalized by tungsten_atomic_density
Ct0_W = 1.0e-4 # at.fraction - E.A. Hodille et al 2021 Nucl. Fusion 61 1260033, trap 2 (same as trap 1)
trap_per_free_W = 1.0e0 # (-)
alpha_t = '${units 2.75e11 s}' # same for all materials
trapping_energy = '${units 0 K}' # same for all materials
alpha_r = '${units 8.4e12 s}' # same for all materials
detrapping_energy_W = '${units 11604.6 K}' # = 1.00 eV    E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 2
# detrapping_energy_W = ${units 9863.9 K} # = 0.85 eV    E.A. Hodille et al 2021 Nucl. Fusion 61 126003, trap 1
# H diffusivity in W
diffusivity_W_D0 = '${units 2.4e-7 m^2/s}'
diffusivity_W_Ea = '${units 4525.8 K}'
# H solubility in W
solubility_W_1_D0 = '${units 2.95e-5 1/Pa^0.5}' # (1.87e24)/(tungsten_atomic_density) 1/m^3/Pa^(1/2) / (1/m^3) = 1/Pa^(1/2)
solubility_W_1_Ea = '${units 12069.0 K}'
solubility_W_2_D0 = '${units 4.95e-8 1/Pa^0.5}' # (3.14e20)/(tungsten_atomic_density) 1/m^3/Pa^(1/2) / (1/m^3) = 1/Pa^(1/2)
solubility_W_2_Ea = '${units 6614.6 K}'

# Materials properties - Cu
density_Cu = '${units 8960.0 kg/m^3}'
N_Cu = 1.0e0 # usually in atoms/m^3, but here normalized by material's atomic density
Ct0_Cu = 5.0e-5 # at.fraction - R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
trap_per_free_Cu = 1.0e0 # (-)
detrapping_energy_Cu = '${units 5802.3 K}' # = 0.50eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 3
# H diffusivity in Cu
diffusivity_Cu_D0 = '${units 6.60e-7 m^2/s}'
diffusivity_Cu_Ea = '${units 4525.8 K}'
# H solubility in Cu
solubility_Cu_D0 = '${units 4.95e-5 1/Pa^0.5}' # ${fparse 3.14e24 / tungsten_atomic_density} 1/m^3/Pa^(1/2) / (1/m^3) = 1/Pa^(1/2)
solubility_Cu_Ea = '${units 6614.6 K}'

# Materials properties - CuCrZr
density_CuCrZr = '${units 8900.0 kg/m^3}'
specific_heat_CuCrZr = '${units 390.0 J/kg/K}'
N_CuCrZr = 1.0e0 # usually in atoms/m^3, but here normalized by material's atomic density
Ct0_CuCrZr = 5.0e-5 # at.fraction - R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
# Ct0_CuCrZr = 4.0e-2 # at.fraction - R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 5
trap_per_free_CuCrZr = 1.0e0 # (-)
detrapping_energy_CuCrZr = '${units 5802.3 K}' # = 0.50eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 4
# detrapping_energy_CuCrZr = ${units 9631.8 K} # = 0.83 eV  R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038, trap 5
# H diffusivity in CuCrZr
diffusivity_CuCrZr_D0 = '${units 3.90e-7 m^2/s}'
diffusivity_CuCrZr_Ea = '${units 4873.9 K}'
# H solubility in CuCrZr
solubility_CuCrZr_D0 = '${units 6.75e-6 1/Pa^0.5}' # ${fparse 4.28e23 / tungsten_atomic_density} 1/m^3/Pa^(1/2) / (1/m^3) = 1/Pa^(1/2)
solubility_CuCrZr_Ea = '${units 4525.8 K}'

# For postprocessor scaling
diffusivity_fixed = '${units 5.01e-24 g/m^2}' # (3.01604928)/(6.02e23)/[gram(T)/m^2]
# diffusivity_fixed = ${units 5.508e-19 g/m^2}  # (1.0e3)*(1.0e3)/(6.02e23)/(3.01604928) [gram(T)/m^2] alternative
scaling_factor = '${units 3.491e10 g/m^2}' # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]
scaling_factor_2 = '${units 3.44e10 g/m^2}' # (1.0e3)*(1.0e3)*(${tungsten_atomic_density})/(6.02e23)/(3.01604928) [gram(T)/m^2]

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
    expression = 'if(t_in_cycle < ${plasma_ramp_time}, t_in_cycle/${plasma_ramp_time},
                        if(t_in_cycle < ${plasma_ss_end}, 1,
                        if(t_in_cycle < ${plasma_ramp_down_end}, 1 - (t_in_cycle-${plasma_ss_end})/${plasma_ramp_time}, 0.0)))'
  []
  [mobile_flux_bc_function]
    type = ParsedFunction
    symbol_values = 'pulse_time_function'
    symbol_names = 'pulse_time_function'
    expression = "if(t<2e2, (${inter_pwr}*7.9e-13/1e7),
if(t<(2e2+${elm_duration}*1/3),
(${inter_pwr}*7.9e-13/1e7)+(t-2e2)/(${elm_duration}*1/3)*((${elm_value}*7.9e-13/1e7)-(${inter_pwr}*7.9e-13/1e7)),
if(t<(2e2+(${elm_duration}*1/3)+(${elm_duration}*2/3)),
(${elm_value}*7.9e-13/1e7)-(t-2e2-(${elm_duration}*1/3))/(${elm_duration}*2/3)*((${elm_value}*7.9e-13/1e7)-(${inter_pwr}*7.9e-13/1e7)), (${inter_pwr}*7.9e-13/1e7))))"
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
    expression = "${coolant_temp}"
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

  [temp_ss]
    type = ParsedFunction
    expression = "-1.59786e4*x^2  -1.11629611e4*x + 4.84297313e2 + 1.9491599e6*y^2 + 1.55723201e4*y "
                 "- 7.312884e5*x*y"
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
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-6
  end_time = 2.01e2
  automatic_scaling = true
  line_search = 'none'
  dtmin = 1e-6
  nl_max_its = 36
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 125
    optimal_iterations = 15
    iteration_window = 1
    growth_factor = 2.0
    cutback_factor = 0.8
    timestep_limiting_postprocessor = timestep_max_pp

    time_t = '0 2e2 2.01e2'
    time_dt = '100 0.0001 100'
  []
  error_on_dtmin = False
[]
# This input file contains key pieces for the divertor monoblock case that includes multiple
# variables.
# It cannot be run on its own and is included in the main input files for two cases, namely:
# - divertor_monoblock.i
# - divertor_monoblock_physics.i

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

    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [F_permeation]
    type = SideDiffusiveFluxAverage
    boundary = '2to1'
    diffusivity = ${diffusivity_fixed}
    variable = Sc_C_total_CuCrZr
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []

  [Int_C_mobile_W]
    type = ElementIntegralVariablePostprocessor
    variable = C_mobile_W
    block = 4
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [ScInt_C_mobile_W]
    type = ScalePostprocessor
    value = Int_C_mobile_W
    scaling_factor = ${scaling_factor}
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [Int_C_trapped_W]
    type = ElementIntegralVariablePostprocessor
    variable = C_trapped_W
    block = 4
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
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
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
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
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [ScInt_C_mobile_Cu]
    type = ScalePostprocessor
    value = Int_C_mobile_Cu
    scaling_factor = ${scaling_factor}
  []
  [Int_C_trapped_Cu]
    type = ElementIntegralVariablePostprocessor
    variable = C_trapped_Cu
    block = 3
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [ScInt_C_trapped_Cu]
    type = ScalePostprocessor
    value = Int_C_trapped_Cu
    scaling_factor = ${scaling_factor_2}
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [Int_C_total_Cu]
    type = ElementIntegralVariablePostprocessor
    variable = C_total_Cu
    block = 3
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [ScInt_C_total_Cu]
    type = ScalePostprocessor
    value = Int_C_total_Cu
    scaling_factor = ${scaling_factor}
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  # ############################################################ Postprocessors for CuCrZr (block = 2)
  [Int_C_mobile_CuCrZr]
    type = ElementIntegralVariablePostprocessor
    variable = C_mobile_CuCrZr
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [ScInt_C_mobile_CuCrZr]
    type = ScalePostprocessor
    value = Int_C_mobile_CuCrZr
    scaling_factor = ${scaling_factor}
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [Int_C_trapped_CuCrZr]
    type = ElementIntegralVariablePostprocessor
    variable = C_trapped_CuCrZr
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [ScInt_C_trapped_CuCrZr]
    type = ScalePostprocessor
    value = Int_C_trapped_CuCrZr
    scaling_factor = ${scaling_factor_2}
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [Int_C_total_CuCrZr]
    type = ElementIntegralVariablePostprocessor
    variable = C_total_CuCrZr
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [ScInt_C_total_CuCrZr]
    type = ScalePostprocessor
    value = Int_C_total_CuCrZr
    scaling_factor = ${scaling_factor}
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  ############################################################ Postprocessors for others
  [dt]
    type = TimestepSize
  []
  [temperature_top]
    type = PointValue
    variable = temperature
    point = '0 ${fparse block_size / 2} 0'
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [temperature_tube]
    type = PointValue
    variable = temperature
    point = '0 ${radius_coolant} 0'
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  # Limit timestep
  [timestep_max_pp]
    # s
    type = FunctionValuePostprocessor
    function = timestep_function
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [unused_parameters]
    type = ParsedPostprocessor
    expression = '${plasma_max_flux} + ${plasma_min_flux} + ${temperature_initial} + ${temperature_coolant_max} + ${num_sectors}
 + ${rings_H2O} + ${rings_CuCrZr} + ${rings_Cu} + ${rings_W}'
    enable = False
    outputs = ''
  []

  [Tritium_SideFluxIntegral]
    type = SideDiffusiveFluxIntegral
    boundary = '2to1'
    diffusivity = diffusivity_CuCrZr_nonAD
    variable = Sc_C_total_CuCrZr
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [Scaled_Tritium_Flux]
    type = ParsedPostprocessor
    expression = '5.01e-24 * Tritium_SideFluxIntegral'
    pp_names = Tritium_SideFluxIntegral
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [coolant_heat_flux]
    # units of W/m2
    type = SideDiffusiveFluxAverage
    boundary = '2to1'
    diffusivity = thermal_conductivity_CuCrZr
    variable = temperature
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_temperature_W]
    type = ElementExtremeValue
    block = 4
    variable = 'temperature'
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_temperature_Cu]
    type = ElementExtremeValue
    block = 3
    variable = 'temperature'
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_temperature_CuCrZr]
    type = ElementExtremeValue
    block = 2
    variable = 'temperature'
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [avg_temperature_W]
    type = ElementAverageValue
    variable = temperature
    block = 4
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [avg_temperature_Cu]
    type = ElementAverageValue
    variable = temperature
    block = 3
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [avg_temperature_CuCrZr]
    type = ElementAverageValue
    variable = temperature
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_concentration_W]
    type = ElementExtremeValue
    variable = 'C_total_W'
    value_type = max
    block = 4
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_concentration_Cu]
    type = ElementExtremeValue
    variable = 'C_total_Cu'
    value_type = max
    block = 3
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [max_concentration_CuCrZr]
    type = ElementExtremeValue
    variable = 'C_total_CuCrZr'
    value_type = max
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [area_W]
    type = VolumePostprocessor
    block = 4
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [area_Cu]
    type = VolumePostprocessor
    block = 3
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [area_CuCrZr]
    type = VolumePostprocessor
    block = 2
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [total_retention]
    type = SumPostprocessor
    values = 'ScInt_C_total_W ScInt_C_total_Cu ScInt_C_total_CuCrZr'
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  ### TIME MAXIMA
  [time_max_T_W]
    type = TimeExtremeValue
    postprocessor = max_temperature_W
    output_type = extreme_value
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [time_max_T_Cu]
    type = TimeExtremeValue
    postprocessor = max_temperature_Cu
    output_type = extreme_value
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
  []
  [time_max_T_CuCrZr]
    type = TimeExtremeValue
    postprocessor = max_temperature_CuCrZr
    output_type = extreme_value
    value_type = max
    execute_on = 'MULTIAPP_FIXED_POINT_END FINAL'
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
    execute_on = 'NONE'
  []
[]
[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Variables]
  [temperature]
    order = FIRST
    family = LAGRANGE
  []
  ######################### Variables for W (block = 4)
  [C_mobile_W]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${C_mobile_W_init}
    block = 4
  []
  [C_trapped_W]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${C_trapping_init}
    block = 4
  []
  ######################### Variables for Cu (block = 3)
  [C_mobile_Cu]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${C_mobile_Cu_init}
    block = 3
  []
  [C_trapped_Cu]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${C_trapping_init}
    block = 3
  []
  ######################### Variables for CuCrZr (block = 2)
  [C_mobile_CuCrZr]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${C_mobile_CuCrZr_init}
    block = 2
  []
  [C_trapped_CuCrZr]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${C_trapping_init}
    block = 2
  []
[]

[Kernels]
  ############################## Kernels for W (block = 4)
  [diff_W]
    type = ADMatDiffusion
    variable = C_mobile_W
    diffusivity = diffusivity_W
    block = 4
    extra_vector_tags = ref
  []
  [time_diff_W]
    type = ADTimeDerivative
    variable = C_mobile_W
    block = 4
    extra_vector_tags = ref
  []
  [coupled_time_W]
    type = ScaledCoupledTimeDerivative
    variable = C_mobile_W
    v = C_trapped_W
    block = 4
    extra_vector_tags = ref
  []
  [heat_conduction_W]
    type = HeatConduction
    variable = temperature
    diffusion_coefficient = thermal_conductivity_W
    block = 4
    extra_vector_tags = ref
  []
  [time_heat_conduction_W]
    type = SpecificHeatConductionTimeDerivative
    variable = temperature
    specific_heat = specific_heat_W
    density = density_W
    block = 4
    extra_vector_tags = ref
  []
  ############################## Kernels for Cu (block = 3)
  [diff_Cu]
    type = ADMatDiffusion
    variable = C_mobile_Cu
    diffusivity = diffusivity_Cu
    block = 3
    extra_vector_tags = ref
  []
  [time_diff_Cu]
    type = ADTimeDerivative
    variable = C_mobile_Cu
    block = 3
    extra_vector_tags = ref
  []
  [coupled_time_Cu]
    type = ScaledCoupledTimeDerivative
    variable = C_mobile_Cu
    v = C_trapped_Cu
    block = 3
    extra_vector_tags = ref
  []
  [heat_conduction_Cu]
    type = HeatConduction
    variable = temperature
    diffusion_coefficient = thermal_conductivity_Cu
    block = 3
    extra_vector_tags = ref
  []
  [time_heat_conduction_Cu]
    type = SpecificHeatConductionTimeDerivative
    variable = temperature
    specific_heat = specific_heat_Cu
    density = density_Cu
    block = 3
    extra_vector_tags = ref
  []
  ############################## Kernels for CuCrZr (block = 2)
  [diff_CuCrZr]
    type = ADMatDiffusion
    variable = C_mobile_CuCrZr
    diffusivity = diffusivity_CuCrZr
    block = 2
    extra_vector_tags = ref
  []
  [time_diff_CuCrZr]
    type = ADTimeDerivative
    variable = C_mobile_CuCrZr
    block = 2
    extra_vector_tags = ref
  []
  [coupled_time_CuCrZr]
    type = ScaledCoupledTimeDerivative
    variable = C_mobile_CuCrZr
    v = C_trapped_CuCrZr
    block = 2
    extra_vector_tags = ref
  []
  [heat_conduction_CuCrZr]
    type = HeatConduction
    variable = temperature
    diffusion_coefficient = thermal_conductivity_CuCrZr
    block = 2
    extra_vector_tags = ref
  []
  [time_heat_conduction_CuCrZr]
    type = SpecificHeatConductionTimeDerivative
    variable = temperature
    specific_heat = specific_heat_CuCrZr
    density = density_CuCrZr
    block = 2
    extra_vector_tags = ref
  []
[]

[InterfaceKernels]
  [tied_4to3]
    type = ADPenaltyInterfaceDiffusion
    variable = C_mobile_W
    neighbor_var = C_mobile_Cu
    penalty = 0.05 #  it will not converge with > 0.1, but it creates negative C_mobile _Cu with << 0.1
    # jump_prop_name = solubility_ratio_4to3
    jump_prop_name = solubility_ratio
    boundary = '4to3'
  []
  [tied_3to2]
    type = ADPenaltyInterfaceDiffusion
    variable = C_mobile_Cu
    neighbor_var = C_mobile_CuCrZr
    penalty = 0.05 #  it will not converge with > 0.1, but it creates negative C_mobile _Cu with << 0.1
    # jump_prop_name = solubility_ratio_3to2
    jump_prop_name = solubility_ratio
    boundary = '3to2'
  []
[]

[NodalKernels]
  ############################## NodalKernels for W (block = 4)
  [time_W]
    type = TimeDerivativeNodalKernel
    variable = C_trapped_W
  []
  [trapping_W]
    type = TrappingNodalKernel
    variable = C_trapped_W
    temperature = temperature
    alpha_t = ${alpha_t}
    N = ${N_W}
    Ct0 = ${Ct0_W}
    trapping_energy = ${trapping_energy}
    trap_per_free = ${trap_per_free_W}
    mobile_concentration = 'C_mobile_W'
    extra_vector_tags = ref
  []
  [release_W]
    type = ReleasingNodalKernel
    alpha_r = ${alpha_r}
    temperature = temperature
    detrapping_energy = ${detrapping_energy_W}
    variable = C_trapped_W
  []
  ############################## NodalKernels for Cu (block = 3)
  [time_Cu]
    type = TimeDerivativeNodalKernel
    variable = C_trapped_Cu
  []
  [trapping_Cu]
    type = TrappingNodalKernel
    variable = C_trapped_Cu
    temperature = temperature
    alpha_t = ${alpha_t}
    N = ${N_Cu}
    Ct0 = ${Ct0_Cu}
    trapping_energy = ${trapping_energy}
    trap_per_free = ${trap_per_free_Cu}
    mobile_concentration = 'C_mobile_Cu'
    extra_vector_tags = ref
  []
  [release_Cu]
    type = ReleasingNodalKernel
    alpha_r = ${alpha_r}
    temperature = temperature
    detrapping_energy = ${detrapping_energy_Cu}
    variable = C_trapped_Cu
  []
  ############################## NodalKernels for CuCrZr (block = 2)
  [time_CuCrZr]
    type = TimeDerivativeNodalKernel
    variable = C_trapped_CuCrZr
  []
  [trapping_CuCrZr]
    type = TrappingNodalKernel
    variable = C_trapped_CuCrZr
    temperature = temperature
    alpha_t = ${alpha_t}
    N = ${N_CuCrZr}
    Ct0 = ${Ct0_CuCrZr}
    trapping_energy = ${trapping_energy}
    trap_per_free = ${trap_per_free_CuCrZr}
    mobile_concentration = 'C_mobile_CuCrZr'
    extra_vector_tags = ref
  []
  [release_CuCrZr]
    type = ReleasingNodalKernel
    alpha_r = ${alpha_r}
    temperature = temperature
    detrapping_energy = ${detrapping_energy_CuCrZr}
    variable = C_trapped_CuCrZr
  []
[]

[BCs]
  [C_mob_W_top_flux]
    type = FunctionNeumannBC
    variable = C_mobile_W
    boundary = 'top'
    function = mobile_flux_bc_function
  []
  [mobile_tube]
    type = DirichletBC
    variable = C_mobile_CuCrZr
    value = ${C_mobile_CuCrZr_DirichletBC_Coolant}
    boundary = '2to1'
  []
  [temperature_top]
    type = FunctionNeumannBC
    variable = temperature
    boundary = 'top'
    function = temperature_flux_bc_function
  []
  [temperature_tube]
    type = FunctionDirichletBC
    variable = temperature
    boundary = '2to1'
    function = temperature_inner_func
  []
[]

[Materials]
  ############################## Materials for W (block = 4)
  [diffusivity_W]
    type = ADParsedMaterial
    property_name = diffusivity_W
    coupled_variables = 'temperature'
    block = 4
    expression = '${diffusivity_W_D0}*exp(-${diffusivity_W_Ea}/temperature)'
    outputs = all
  []
  [solubility_W]
    type = ADParsedMaterial
    property_name = solubility_W
    coupled_variables = 'temperature'
    block = 4
    expression = '${solubility_W_1_D0}*exp(-${solubility_W_1_Ea}/temperature) + ${solubility_W_2_D0}*exp(-${solubility_W_2_Ea}/temperature)'
    outputs = all
  []
  [converter_to_regular_W]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_W'
    reg_props_out = 'diffusivity_W_nonAD'
    block = 4
  []
  [heat_transfer_W]
    type = GenericConstantMaterial
    prop_names = 'density_W'
    prop_values = '${density_W}'
    block = 4
  []
  [specific_heat_W]
    type = ParsedMaterial
    property_name = specific_heat_W
    coupled_variables = 'temperature'
    block = 4
    expression = '1.16e2 + 7.11e-2 * temperature - 6.58e-5 * temperature^2 + 3.24e-8 * temperature^3 -5.45e-12 * temperature^4' # [J/kg-K]
    outputs = all
  []
  [thermal_conductivity_W]
    type = ParsedMaterial
    property_name = thermal_conductivity_W
    coupled_variables = 'temperature'
    block = 4
    expression = '${W_cond_factor}*(2.41e2 - 2.90e-1 * temperature + 2.54e-4 * temperature^2 - 1.03e-7 * temperature^3 + 1.52e-11 * temperature^4)'
    outputs = all
  []
  ############################## Materials for Cu (block = 3)
  [diffusivity_Cu]
    type = ADParsedMaterial
    property_name = diffusivity_Cu
    coupled_variables = 'temperature'
    block = 3
    expression = '${diffusivity_Cu_D0}*exp(-${diffusivity_Cu_Ea}/temperature)'
    outputs = all
  []
  [solubility_Cu]
    type = ADParsedMaterial
    property_name = solubility_Cu
    coupled_variables = 'temperature'
    block = 3
    expression = '${solubility_Cu_D0}*exp(-${solubility_Cu_Ea}/temperature)'
    outputs = all
  []
  [converter_to_regular_Cu]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_Cu'
    reg_props_out = 'diffusivity_Cu_nonAD'
    block = 3
  []
  [heat_transfer_Cu]
    type = GenericConstantMaterial
    prop_names = 'density_Cu'
    prop_values = '${density_Cu}'
    block = 3
  []
  [specific_heat_Cu]
    type = ParsedMaterial
    property_name = specific_heat_Cu
    coupled_variables = 'temperature'
    block = 3
    expression = '3.16e2 + 3.18e-1 * temperature - 3.49e-4 * temperature^2 + 1.66e-7 * temperature^3' # [J/kg-K]
    outputs = all
  []
  [thermal_conductivity_Cu]
    type = ParsedMaterial
    property_name = thermal_conductivity_Cu
    coupled_variables = 'temperature'
    block = 3
    # expression = '-3.9e-8 * temperature^3 + 3.8e-5 * temperature^2 - 7.9e-2 * temperature + 4.0e2'    # ~ 401.0  [ W/m-K] from R. Delaporte-Mathurin et al 2021 Nucl. Fusion 61 036038,
    expression = '4.21e2 - 6.85e-2 * temperature' # [W/m-K]
    outputs = all
  []
  ############################## Materials for CuCrZr (block = 2)
  [diffusivity_CuCrZr]
    type = ADParsedMaterial
    property_name = diffusivity_CuCrZr
    coupled_variables = 'temperature'
    block = 2
    expression = '${diffusivity_CuCrZr_D0}*exp(-${diffusivity_CuCrZr_Ea}/temperature)'
    outputs = all
  []
  [solubility_CuCrZr]
    type = ADParsedMaterial
    property_name = solubility_CuCrZr
    coupled_variables = 'temperature'
    block = 2
    expression = '${solubility_CuCrZr_D0}*exp(-${solubility_CuCrZr_Ea}/temperature)'
    outputs = all
  []
  [converter_to_regular_CuCrZr]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_CuCrZr'
    reg_props_out = 'diffusivity_CuCrZr_nonAD'
    block = 2
  []
  [heat_transfer_CuCrZr]
    type = GenericConstantMaterial
    prop_names = 'density_CuCrZr specific_heat_CuCrZr'
    prop_values = '${density_CuCrZr} ${specific_heat_CuCrZr}'
    block = 2
  []
  [thermal_conductivity_CuCrZr]
    type = ParsedMaterial
    property_name = thermal_conductivity_CuCrZr
    coupled_variables = 'temperature'
    block = 2
    expression = '3.87e2 - 1.28e-1 * temperature' # [W/m-K]
    outputs = all
  []
  ############################## Materials for others
  [interface_jump_4to3]
    type = SolubilityRatioMaterial
    solubility_primary = solubility_W
    solubility_secondary = solubility_Cu
    boundary = '4to3'
    concentration_primary = C_mobile_W
    concentration_secondary = C_mobile_Cu
  []
  [interface_jump_3to2]
    type = SolubilityRatioMaterial
    solubility_primary = solubility_Cu
    solubility_secondary = solubility_CuCrZr
    boundary = '3to2'
    concentration_primary = C_mobile_Cu
    concentration_secondary = C_mobile_CuCrZr
  []
[]
# 1e-6                                                   # Relative independent parameter tolerance
# 1e-7                                                 # Absolute tolerance
# 50 ITER shots (3.0e4 s plasma, 2.0e4 SSP)                                 # Total simulation time
# Minimum time step for convergence, time step size is reduced upon non-convergence, but dtmin is an absolute limit. Passing this will result in an error
# Maximum number of iterations for convergence

[Outputs]
  # Control outputs, include exodus and csv.
  execute_on = 'none'
[]

# ~ 173.0 [ W/m-K]

[ICs]
  [t_ic]
    type = FunctionIC
    function = temp_ss
    variable = temperature
  []
[]
