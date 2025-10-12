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

# TMAP8 Theory

TMAP8's documentation provides a [theory manual](theory_manual.md) to describe the base theory used in TMAP8, focused in particular on different approaches available to model surface reactions.

However, this list is not exhaustive, and for a more comprehensive description of capabilities, theoretical concepts, and available objects, refer to:

- the publications listed in the [publications.md]
- the [verification_and_validation/index.md]
- the [syntax/index.md] page.

For the derivation of the weak form of the tritium transport system of equations in solids, refer to the appendix of [this TMAP8 publication](https://www.sciencedirect.com/science/article/pii/S0920379625000766).

!---

# TMAP8 key capabilities - fuel cycle

!row!
!col! width=50%

TMAP8 is able to perform fuel cycle calculations at the system scale.

It has been benchmarked against the fuel cycle model described by [Abdou et al. (2021)](examples/fuel_cycle_Abdou/index.md), and the model described in [Meschini et al. (2023)](examples/fuel_cycle_Meschini/index.md).

Ongoing efforts are using the multiapp system to concurrently perform component-level calculations and use the results in fuel cycle calculations to accurately model the tritium fuel cycle.

!col-end!

!col! width=50%

!media examples/figures/plot_comparison.py image_name=fuel_cycle_abdou_03.png style=width:100%;margin-left:auto;margin-right:auto;display:block;box-shadow:none;

!style halign=center
Figure from the [fuel cycle example from Abdou et al](examples/fuel_cycle_Abdou/index.md).

!col-end!
!row-end!

!---

# TMAP8 key capabilities - Stochastic tools

!row!
!col! width=50%

The integration of the [stochastic tools module](stochastic_tools/index.md) in TMAP8 supports key capabilities:

- Model calibration
- Experimental analysis
- Uncertainty quantification
- Error identification (experimental uncertainty vs. model inadequacy vs. parameter uncertainty)
- Sensitivity analysis
- Surrogate model development
- etc.

!col-end!

!col! width=50%

!media verification_and_validation/figures/comparison_val-2c.py image_name=val-2c_comparison_TMAP8_Exp_HTO_Ci.png style=width:100%;margin-left:auto;margin-right:auto;display:block;box-shadow:none;

!style halign=center
Figure from the [val-2c validation case calibration](val-2c.md).

!col-end!
!row-end!

!---

# TMAP8 key capabilities \\ pore-scale transport

!media examples/figures/pore_scale_process_illustration_2.png style=width:70%;margin-left:auto;margin-right:auto;display:block;box-shadow:none;

!style halign=center
Figure from the [pore-scale tritium transport example](examples/pore_scale_transport/index.md).

!row!
!col! width=50%

!media examples/figures/3D_microstructure_example.png style=width:90%;margin-left:auto;margin-right:auto;display:block;box-shadow:none;

!col-end!

!col! width=50%

Thanks to the [ImageFunction](ImageFunction.md) and [phase-field module](phase_field/index.md) capabilities, TMAP8 can perform mesoscale simulations of tritium transport.

It can use sequential images of real or generated microstructures and perform tritium transport on them.

This capability is detailed in the [pore-scale tritium transport example](examples/pore_scale_transport/index.md).

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
[V&V page in the TMAP8 documentation](verification_and_validation/index.md).

Later in the hands on part of this workshop, we will go through some V&V cases in more details.

!---

# TMAP8 Examples

!style halign=center
TMAP8's example cases list simulations performed with TMAP8 that highlight specific capabilities.
The example cases differ from the V&V cases in that they do not necessarily have analytical solutions or experimental data to be compared against.
In geenral, the example cases also describe how the input file relates to the simulation, making them great resources for users. Hence, these cases can serve as additional tutorial cases, or as starting point for new simulations.

Check out the TMAP8 example cases and all relevant input file and documentation on the:

!style halign=center
[TMAP8 Example documentation page](examples/index.md)

It includes examples for fuel cycle calculations, divertor monoblock modeling, and pore microstructure modeling.

!---

# Summary
