# SolubilityRatioMaterial

!syntax description /Materials/SolubilityRatioMaterial

## Overview

The SolubilityRatioMaterial object is used to calculate the jump in specie concentration across a
material interface, given the solubility values for those materials and specie concentration on
either side of the interface. Solubilities for the "primary" and "secondary" sides can be provided
via the [syntax/Materials/index.md] using automatic differentiation (a.k.a. an
`ADMaterialProperty`).

The solubility ratio jump is calculated using the following relationship:

!equation
J = \frac{c_p}{S_p} - \frac{c_s}{S_s}

where $J$ is the calculated solubility ratio jump (available as an `InterfaceMaterial` property,
named the `solubility_ratio`), $c_i$ is the specie concentration on the $i$th side of the
interface, and $S_i$ is the solubility on the $i$th side of the interface. The $p$ subscript
corresponds to the primary side and $s$ corresponds to the secondary side. The ratio jump material
property can then be used in `InterfaceKernels`, such as [ADPenaltyInterfaceDiffusion](PenaltyInterfaceDiffusion.md),
to solve for the appropriate concentrations on either side of the interface.

## Example Input File Syntax

!listing test/tests/val-2b/val-2b.i block=Materials/interface_jump

!syntax parameters /Materials/SolubilityRatioMaterial

!syntax inputs /Materials/SolubilityRatioMaterial

!syntax children /Materials/SolubilityRatioMaterial
