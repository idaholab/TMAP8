# Introduction to TMAP8

!media figures/TMAP8_logo_blue.png style=display:block;box-shadow:none;margin-left:auto;margin-right:auto;width:30%;

!---

# TMAP8 inherited features from MOOSE

TMAP8 directly inherits all of MOOSE's features, including:

- Easy to use and customize
- Takes advantage of high performance computing by default
- Developed and supported by INL staff and the community - long-term support
- Massively parallel computation
- Multiphysics solve capability
- Multiscale solve capability - multiple applications can perform computations for a problem simultaneously
- Provides high-level interface to implement customized physics, geometries, boundary conditions, and material models
- Enables 2D and 3D simulations
- Open source and available on [GitHub](https://github.com/idaholab/TMAP8).

!---

# TMAP8 features

!row!
!col! width=50%

!media figures/TMAP8_features.png style=width:100%;margin-left:auto;margin-right:auto;display:block;box-shadow:none;

!col-end!

!col! width=50%

- The TMAP4/7 capabilities and physics are available in TMAP8.
- TMAP4 and TMAP7, although widely used, have limitations that TMAP8 overcomes.
- TMAP8 enables high fidelity, multi-scale, 0D to 3D, multispecies, multiphysics simulations of tritium transport, and offers massively parallel capabilities.
- TMAP8 is open source, Nuclear Quality Assurance level 1 (NQA-1) compliant, offers user support and a licensing approach (LGPL-2.1) selected for collaboration.

!col-end!
!row-end!

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

Later in the hands on part of this workshop, we will go through some V&V cases in more details.

!---

# TMAP8 Examples

!style halign=center
TMAP8's example cases list simulations performed with TMAP8 that highlight specific capabilities.
The example cases differ from the V&V cases in that they do not necessarily have analytical solutions or experimental data to be compared against.
In geenral, the example cases also describe how the input file relates to the simulation, making them great resources for users. Hence, these cases can serve as additional tutorial cases, or as starting point for new simulations.

Check out the TMAP8 example cases and all relevant input file and documentation on the:

!style halign=center
[TMAP8 Example documentation page](https://mooseframework.inl.gov/TMAP8/examples/index.html)

It includes examples for fuel cycle calculations, divertor monoblock modeling, and pore microstructure modeling.

!---

# Summary:
