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
      pitch = ${fparse block_size}
      portion = left_half
      preserve_volumes = false
      smoothing_max_it = 3
  []
  [ssbsg1]
      type = SideSetsBetweenSubdomainsGenerator
      input = ccmg
      primary_block = '4'     # W
      paired_block = '3'      # Cu
      new_boundary = '4to3'
  []
  [ssbsg2]
      type = SideSetsBetweenSubdomainsGenerator
      input = ssbsg1
      primary_block = '3'     # Cu
      paired_block = '4'      # W
      new_boundary = '3to4'
  []
  [ssbsg3]
      type = SideSetsBetweenSubdomainsGenerator
      input = ssbsg2
      primary_block = '3'     # Cu
      paired_block = '2'      # CuCrZr
      new_boundary = '3to2'
  []
  [ssbsg4]
      type = SideSetsBetweenSubdomainsGenerator
      input = ssbsg3
      primary_block = '2'     # CuCrZr
      paired_block = '3'      # Cu
      new_boundary = '2to3'
  []
  [ssbsg5]
      type = SideSetsBetweenSubdomainsGenerator
      input = ssbsg4
      primary_block = '2'     # CuCrZr
      paired_block = '1'      # H2O
      new_boundary = '2to1'
  []
  [bdg]
      type = BlockDeletionGenerator
      input = ssbsg5
      block = '1'             # H2O
  []
[]
