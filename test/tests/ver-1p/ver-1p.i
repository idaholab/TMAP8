# Reference:
#   T. F. Fuerst, M. D. Eklund, J. A. Leland, A. A. Riet, C. N. Taylor,
#   "Parametric Study of the Vacuum Permeator for the Tritium Extraction
#   eXperiment," Fusion Science and Technology 79 (2023) 1224-1234.
#   DOI: 10.1080/15361055.2023.2196237
#
# Radial transport:
#   bulk PbLi -> PbLi/V partition -> cylindrical V diffusion
#   -> recombination -> vacuum
#
# Assumptions:
#   - steady state and isothermal operation
#   - zero pressure on the vacuum side
#
# Nominal geometry / hydraulics at T = 673.15 K and Re = 1e5:
#   L = 5.00 m, r_i = 4.75 mm, r_o = 5.00 mm, u = 1.78 m/s.
#   Q, nu, Sc, Sh, K_T, rho, mu, and mdot are computed
#
# ============================================================================

# -----------------------------------------------------------------------------
# Inputs
# -----------------------------------------------------------------------------
T = 673.15                   # 400 C [K]
R = 8.31446261815324         # gas constant [J/(mol K)]
C_in = 1.0                 # dissolved H-isotope concentration [mol/m^3 PbLi]
Re = 1e5                     # Reynolds number

L_tube = 5.00                # active permeator length [m]
r_i = 0.00475                # inner radius [m]
r_o = 0.00500                # outer radius [m]
N_segments = 20              # Axial discretization
PI = 3.14159265358979323846

# ============================================================
# Nominal properties
# ============================================================

D_L = ${fparse 8.30e-9*exp(-7.37e3/(R*T))}

rho_PbLi = ${fparse 10520.35 - 1.19051*T}

M_PbLi_atom = 0.1731558   # kg/mol
C_PbLi_atoms = ${fparse rho_PbLi/M_PbLi_atom}

K_L_table_base = 4.32e-7  # Pa^-0.5, Table II in the paper

K_L = ${fparse K_L_table_base*C_PbLi_atoms}

D_S = ${fparse 2.90e-8*exp(-4.2e3/(R*T))}
K_S = ${fparse 0.138*exp(29.0e3/(R*T))}

K_R = 3.1582e-9
area_ratio = ${fparse r_o/r_i}
K_R_inner = ${fparse area_ratio*K_R}

# -----------------------------------------------------------------------------
# Properties from inputs
# -----------------------------------------------------------------------------
u_PbLi = 1.78                # [m/s]
D_h = ${fparse 2.0*r_i}      # hydraulic diameter [m]
A_flow = ${fparse PI*r_i^2}  # flow area [m^2]
Q_PbLi = ${fparse u_PbLi*A_flow}      # [m^3/s]
nu_PbLi = ${fparse u_PbLi*D_h/Re}     # [m^2/s]
Sc = ${fparse nu_PbLi/D_L}

# -----------------------------------------------------------------------------
# PbLi mass transfer from Sherwood correlations
# -----------------------------------------------------------------------------
#   Sh  = 0.023 Re^0.83 Sc^(1/3)
#   K_T = Sh D_L / (2 r_i)
Sh = ${fparse 0.023*Re^0.83*Sc^(1.0/3.0)}
K_T = ${fparse Sh*D_L/D_h}                 # [m/s]

# -----------------------------------------------------------------------------
# Radial equations
# -----------------------------------------------------------------------------
#
# Liquid flux on the inner area:
#   J_i = K_T (C_bulk - C_L2)
#
# Interface partition:
#   C_S1 = (K_S/K_L) C_L2
#
# Cylindrical diffusion expressed on the inner area:
#   J_i = D_S (C_S1 - C_S2) / (r_i ln(r_o/r_i))
#
# Recombination occurs on the outer vacuum surface:
#   J_o = K_R C_S2^2
#
# Conservation of permeation rate requires
#   2*pi*r_i*J_i = 2*pi*r_o*J_o,
#
# so the equivalent recombination flux on the inner area is
#   J_i = (r_o/r_i) K_R C_S2^2 = K_R_inner C_S2^2.
#
# Define a = K_S/K_L and
#   b = a/K_T + r_i ln(r_o/r_i)/D_S.
#
# Then the physical positive root is
#   C_S2(C) =
#     2*a*C / [1 + sqrt(1 + 4*b*K_R_inner*a*C)].

partition_ratio = ${fparse K_S/K_L}
R_mem = ${fparse r_i*log(r_o/r_i)/D_S}
radial_B = ${fparse partition_ratio/K_T+R_mem}

# -----------------------------------------------------------------------------
# Control volumes (axial direction)
# -----------------------------------------------------------------------------
delta_z = ${fparse L_tube/N_segments}
A_segment = ${fparse 2.0*PI*r_i*delta_z}  # inner permeating area/node [m^2]
A_total = ${fparse 2.0*PI*r_i*L_tube}     # total inner area [m^2]
segment_factor = ${fparse A_segment/Q_PbLi}  # [s/m]

# Pressure drop
f_Darcy = ${fparse 0.3164/(Re^0.25)}
delta_p_straight = ${fparse f_Darcy*(L_tube/D_h)*rho_PbLi*u_PbLi^2/2.0}


# -----------------------------------------------------------------------------
# Mesh (Needed just to run the model)
# -----------------------------------------------------------------------------
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1
[]

# -----------------------------------------------------------------------------
# Unknowns (concentrations at the axial direction)
# -----------------------------------------------------------------------------
# C01 is the concentration at z=0.25 m, ..., C20 at z=5.00 m.
[Variables]
  [C01]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C02]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C03]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C04]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C05]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C06]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C07]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C08]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C09]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C10]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C11]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C12]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C13]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C14]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C15]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C16]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C17]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C18]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C19]
    family = SCALAR
    initial_condition = ${C_in}
  []

  [C20]
    family = SCALAR
    initial_condition = ${C_in}
  []
[]

# -----------------------------------------------------------------------------
# Steady state mass balance
# -----------------------------------------------------------------------------
# For each segment i:
#   Q*C_up = Q*C_down + J(C_up)*A_segment
# or
#   C_down - C_up + segment_factor*J(C_up) = 0
#
# The radial flux J(C_up)
[ScalarKernels]
  [segment_01]
    type = ParsedODEKernel
    variable = C01
    expression = 'C01 - C0 + segment_factor*K_R_inner*(2.0*a*C0/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C0)))^2'
    constant_names = 'C0 segment_factor K_R_inner a b'
    constant_expressions = '${C_in} ${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_02]
    type = ParsedODEKernel
    variable = C02
    coupled_variables = 'C01'
    expression = 'C02 - C01 + segment_factor*K_R_inner*(2.0*a*C01/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C01)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_03]
    type = ParsedODEKernel
    variable = C03
    coupled_variables = 'C02'
    expression = 'C03 - C02 + segment_factor*K_R_inner*(2.0*a*C02/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C02)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_04]
    type = ParsedODEKernel
    variable = C04
    coupled_variables = 'C03'
    expression = 'C04 - C03 + segment_factor*K_R_inner*(2.0*a*C03/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C03)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_05]
    type = ParsedODEKernel
    variable = C05
    coupled_variables = 'C04'
    expression = 'C05 - C04 + segment_factor*K_R_inner*(2.0*a*C04/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C04)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_06]
    type = ParsedODEKernel
    variable = C06
    coupled_variables = 'C05'
    expression = 'C06 - C05 + segment_factor*K_R_inner*(2.0*a*C05/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C05)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_07]
    type = ParsedODEKernel
    variable = C07
    coupled_variables = 'C06'
    expression = 'C07 - C06 + segment_factor*K_R_inner*(2.0*a*C06/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C06)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_08]
    type = ParsedODEKernel
    variable = C08
    coupled_variables = 'C07'
    expression = 'C08 - C07 + segment_factor*K_R_inner*(2.0*a*C07/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C07)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_09]
    type = ParsedODEKernel
    variable = C09
    coupled_variables = 'C08'
    expression = 'C09 - C08 + segment_factor*K_R_inner*(2.0*a*C08/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C08)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_10]
    type = ParsedODEKernel
    variable = C10
    coupled_variables = 'C09'
    expression = 'C10 - C09 + segment_factor*K_R_inner*(2.0*a*C09/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C09)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_11]
    type = ParsedODEKernel
    variable = C11
    coupled_variables = 'C10'
    expression = 'C11 - C10 + segment_factor*K_R_inner*(2.0*a*C10/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C10)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_12]
    type = ParsedODEKernel
    variable = C12
    coupled_variables = 'C11'
    expression = 'C12 - C11 + segment_factor*K_R_inner*(2.0*a*C11/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C11)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_13]
    type = ParsedODEKernel
    variable = C13
    coupled_variables = 'C12'
    expression = 'C13 - C12 + segment_factor*K_R_inner*(2.0*a*C12/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C12)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_14]
    type = ParsedODEKernel
    variable = C14
    coupled_variables = 'C13'
    expression = 'C14 - C13 + segment_factor*K_R_inner*(2.0*a*C13/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C13)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_15]
    type = ParsedODEKernel
    variable = C15
    coupled_variables = 'C14'
    expression = 'C15 - C14 + segment_factor*K_R_inner*(2.0*a*C14/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C14)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_16]
    type = ParsedODEKernel
    variable = C16
    coupled_variables = 'C15'
    expression = 'C16 - C15 + segment_factor*K_R_inner*(2.0*a*C15/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C15)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_17]
    type = ParsedODEKernel
    variable = C17
    coupled_variables = 'C16'
    expression = 'C17 - C16 + segment_factor*K_R_inner*(2.0*a*C16/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C16)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_18]
    type = ParsedODEKernel
    variable = C18
    coupled_variables = 'C17'
    expression = 'C18 - C17 + segment_factor*K_R_inner*(2.0*a*C17/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C17)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_19]
    type = ParsedODEKernel
    variable = C19
    coupled_variables = 'C18'
    expression = 'C19 - C18 + segment_factor*K_R_inner*(2.0*a*C18/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C18)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []

  [segment_20]
    type = ParsedODEKernel
    variable = C20
    coupled_variables = 'C19'
    expression = 'C20 - C19 + segment_factor*K_R_inner*(2.0*a*C19/(1.0+sqrt(1.0+4.0*b*K_R_inner*a*C19)))^2'
    constant_names = 'segment_factor K_R_inner a b'
    constant_expressions = '${segment_factor} ${K_R_inner} ${partition_ratio} ${radial_B}'
    evalerror_behavior = error
  []
[]

# -----------------------------------------------------------------------------
# Postprocessor
# -----------------------------------------------------------------------------
[Postprocessors]
  [C00_inlet]
    type = ConstantPostprocessor
    value = ${C_in}
    execute_on = 'initial timestep_end'
  []

  [C01_pp]
    type = ScalarVariable
    variable = C01
    execute_on = 'initial timestep_end'
  []

  [C02_pp]
    type = ScalarVariable
    variable = C02
    execute_on = 'initial timestep_end'
  []

  [C03_pp]
    type = ScalarVariable
    variable = C03
    execute_on = 'initial timestep_end'
  []

  [C04_pp]
    type = ScalarVariable
    variable = C04
    execute_on = 'initial timestep_end'
  []

  [C05_pp]
    type = ScalarVariable
    variable = C05
    execute_on = 'initial timestep_end'
  []

  [C06_pp]
    type = ScalarVariable
    variable = C06
    execute_on = 'initial timestep_end'
  []

  [C07_pp]
    type = ScalarVariable
    variable = C07
    execute_on = 'initial timestep_end'
  []

  [C08_pp]
    type = ScalarVariable
    variable = C08
    execute_on = 'initial timestep_end'
  []

  [C09_pp]
    type = ScalarVariable
    variable = C09
    execute_on = 'initial timestep_end'
  []

  [C10_pp]
    type = ScalarVariable
    variable = C10
    execute_on = 'initial timestep_end'
  []

  [C11_pp]
    type = ScalarVariable
    variable = C11
    execute_on = 'initial timestep_end'
  []

  [C12_pp]
    type = ScalarVariable
    variable = C12
    execute_on = 'initial timestep_end'
  []

  [C13_pp]
    type = ScalarVariable
    variable = C13
    execute_on = 'initial timestep_end'
  []

  [C14_pp]
    type = ScalarVariable
    variable = C14
    execute_on = 'initial timestep_end'
  []

  [C15_pp]
    type = ScalarVariable
    variable = C15
    execute_on = 'initial timestep_end'
  []

  [C16_pp]
    type = ScalarVariable
    variable = C16
    execute_on = 'initial timestep_end'
  []

  [C17_pp]
    type = ScalarVariable
    variable = C17
    execute_on = 'initial timestep_end'
  []

  [C18_pp]
    type = ScalarVariable
    variable = C18
    execute_on = 'initial timestep_end'
  []

  [C19_pp]
    type = ScalarVariable
    variable = C19
    execute_on = 'initial timestep_end'
  []

  [C20_pp]
    type = ScalarVariable
    variable = C20
    execute_on = 'initial timestep_end'
  []

  [pressure_drop_straight_Pa]
    type = ConstantPostprocessor
    value = ${delta_p_straight}
    execute_on = 'initial timestep_end'
  []

  [extraction_efficiency]
    type = ParsedPostprocessor
    expression = '1.0-Cout/Cin'
    pp_names = 'C20_pp'
    pp_symbols = 'Cout'
    constant_names = 'Cin'
    constant_expressions = '${C_in}'
    execute_on = 'timestep_end'
  []

  [average_permeation_flux_mol_m2_s]
    type = ParsedPostprocessor
    expression = 'Q*(Cin-Cout)/A'
    pp_names = 'C20_pp'
    pp_symbols = 'Cout'
    constant_names = 'Q Cin A'
    constant_expressions = '${Q_PbLi} ${C_in} ${A_total}'
    execute_on = 'timestep_end'
  []

[]



[Executioner]
  type = Steady
  solve_type = NEWTON
  nl_abs_tol = 1e-25
  nl_rel_tol = 1e-8
  nl_max_its = 100
[]

[Outputs]
  console = true

  [csv]
    type = CSV
    file_base = ver-1p_out
    precision = 16
    scientific_notation = true
  []
[]
