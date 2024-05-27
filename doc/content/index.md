!config navigation breadcrumbs=False scrollspy=False

&nbsp;

!media figures/TMAP8_logo_blue.png dark_src=figures/TMAP8_logo_white.png style=display:block;margin-left:auto;margin-right:auto;width:30%;

# Tritium Migration Analysis Program, Version 8 class=center style=font-weight:200;font-size:200%

!style halign=center
TMAP8 is an application for performing system-level mass and thermal transport
calculations related to tritium migration. It is based on the
[MOOSE framework](https://mooseframework.inl.gov), and builds on the framework
and modules for many of its capabilities.

!row!
!col! small=12 medium=4 large=4 icon=get_app
## [Getting Started](getting_started/installation.md) class=center style=font-weight:200;font-size:150%;

!style halign=center
Quickly learn how to obtain the TMAP8 source code, compile an executable, and
run simulations with these instructions.
!col-end!

!col! small=12 medium=4 large=4 icon=settings

## [Code Reference](syntax/index.md) class=center style=font-weight:200;font-size:150%;

!style halign=center
TMAP8 provides capabilities that can be applied to a wide variety of problems.
The Code Reference provides detailed documentation of specific code features.
General user notes on TMAP8 can also be found [here](getting_started/user_notes.md).
!col-end!

!col! small=12 medium=4 large=4 icon=assessment
## [Verification & Validation](verification_and_validation/index.md) class=center style=font-weight:200;font-size:150%;

!style halign=center
Several problems originally developed for the TMAP4 and TMAP7 codes have been used for the
verification of TMAP8. These V&V cases can be found here.
!col-end!
!row-end!

## TMAP8 is built on MOOSE style=clear:both;

!style halign=left
TMAP8 is based on [MOOSE], an extremely flexible framework and simulation environment
that permits the solution of coupled physics problems of varying size and dimensionality.
These can be solved using computer hardware appropriate for the model size, ranging from
laptops and workstations to large high performance computers.

!media large_media/framework/inl_blue.png style=float:right;width:20%;margin-left:30px;

Code reliability is a central principle in code development, and this project
employs a well-defined development and testing strategy.  Code changes are only
merged into the repository after both a manual code review and the automated
regression test system have been completed.  The testing process and status of
TMAP8 is available at [civet.inl.gov](https://civet.inl.gov/repo/530/).

TMAP8 and MOOSE are developed at Idaho National Laboratory by a team of
computer scientists and engineers and is supported by various funding agencies,
including the [United States Department of Energy](http://energy.gov).  Development
of these codes is ongoing at [INL](https://www.inl.gov) and by collaborators
throughout the world.
