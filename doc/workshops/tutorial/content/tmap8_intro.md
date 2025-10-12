# Introduction to TMAP8

!media figures/TMAP8_logo_blue.png style=display:block;box-shadow:none;margin-left:auto;margin-right:auto;width:30%;

!---

# TMAP8 vs Legacy TMAP (TMAP4, TMAP7)

- TMAP8 directly inherits all of MOOSE's features

  - Easy to use and customize
  - Takes advantage of high performance computing by default
  - Developed and supported by full time INL staff - long-term support
  - Massively parallel computation
  - Multiphysics solve capability
  - Multiscale solve capability - multiple applications can perform computation for a problem simultaneously
  - Provides high-level interface to implement customized physics, geometries, boundary conditions, and material models

    - Enables 2D and 3D simulations

  - The capabilities/physics in TMAP4 are added to TMAP8
  - The addition of TMAP7 capabilities are in progress


!---

# TMAP8 Verification & Validation (V&V)

!style halign=center

Verification is the process of ensuring that a computational model accurately represents the underlying mathematical model and its solution.
Verification can be satisfied by comparing modeling predictions against analytical solutions for simple cases, or leveraging the method of manufactured solutions (MMS), which is supported in MOOSE.

Validation, on the other hand, is the process of determining the extent to which a model accurately represents the real world for its intended uses, which requires comparison against experimental data.

TMAP8's V&V case suite now surpasses TMAP4's and TMAP7's, and continues to grow. It is a ressource for users wanting to learn more about TMAP8's accuracy, and for users wanting to use them as starting point for their simulations.

Check out the TMAP8 V&V cases and all relevant input files and documentation on the:

!style halign=center
[V&V page in the TMAP8 documentation](https://mooseframework.inl.gov/TMAP8/verification_and_validation/index.html).

!---

# TMAP8 Examples

!style halign=center
TMAP8's example cases list simulations performed with TMAP8 that highlight specific capabilities.
The example cases differ from the V&V cases in that they do not necessarily have analytical solutions or experimental data to be compared against.
In geenral, the example cases also describe how the input file relates to the simulation, making them great resources for users. Hence, these cases can serve as additional tutorial cases, or as starting point for new simulations.

Check out the TMAP8 example cases and all relevant input file and documentation on the:

!style halign=center
[TMAP8 Example documentation page](https://mooseframework.inl.gov/TMAP8/examples/index.html)

!---

# Summary:
