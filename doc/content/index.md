!config navigation breadcrumbs=False scrollspy=False

# TMAP8

TMAP8 is a MOOSE-based implementation of the Tritium Migration Analysis
Program. It performs system-level mass and thermal transport calculations
related to tritium migration.

## Scaling id=scaling

Dimensions in TMAP simulations can have dramatically different scales,
e.g. number densities can be of order Avogadro's number while length and time
scales are closer to unity when using SI units. Morever, multiple species,
whether different chemical species or the same chemical species in different
phases (e.g. solute vs. trapped), can have significantly different concentration
levels. In order to have robust nonlinear and linear solves, we often have to
perform scaling operations to bring different quantities closer to order unity.

One example of scaling is exemplified by the `trap_per_free` parameter that is
present in the [TrappingNodalKernel.md] object (as well as other objects in
TMAP8). Trapping concentrations may be larger than solute concentrations for a
given chemical specie. However, for a good multiphysics multivariable solve, we
want the numerical concentrations of the two species to be about the same. If
for instance, the concentration of the trapped specie is roughly 1000 times
larger than the mobile specie, we can specify `trapped_per_free = 1000`. This is
effectively changing the concentration of the trapped specie from being measured
in #/volume to k#/volume where 'k' indicates kilo. After this transformation,
the numerical concentrations of the trapped and mobile species are on the same
order of magnitude.
