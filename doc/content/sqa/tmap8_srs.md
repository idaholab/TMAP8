!template load file=sqa/app_srs.md.template app=TMAP8App category=tmap8

!template! item key=system-scope
!! system-scope-begin

TMAP8 is an application for performing system-level, engineering scale (i.e., at the scale of centimeters and meters), and microstructure-scale (i.e., at the scale of microns) mass and thermal transport calculations related to tritium migration. These models often include highly coupled
systems of equations related to heat conduction, scalar transport, thermal hydraulics, mechanics, amongst others. Material models are also included to support these simulations, and they themselves are often dependent on simulation variables: temperature,
irradiation flux, etc. While many models within TMAP8 are performed
at the system-level or engineering scale, the [syntax/MultiApps/index.md]
can be leveraged to allow for multiscale coupling to the micro- and nano-scale species behavior. This allows for not higher fidelity modeling.

!! system-scope-finish
!template-end!

!template! item key=system-purpose
!! system-purpose-begin
The purpose of TMAP8 is to simulate tritium transport and inventory at different length scales in a variety of materials and designs. TMAP8's main goal is to bring together the combined multiphysics capabilities of the [!ac](MOOSE) ecosystem to provide an open platform for future research, safety assessment, and design studies of tritium transport.
!! system-purpose-finish
!template-end!

!template! item key=assumptions-and-dependencies
{{app}} has no constraints on hardware and software beyond those of the MOOSE framework and modules listed in their respective SRS documents, which are accessible through the links at the beginning of this document.

{{app}} provides access to a number of code objects that perform computations such as material behavior and boundary conditions. These objects each make their own physics-based assumptions, such as the units of the inputs and outputs. Those assumptions are described in the documentation for those individual objects.
!template-end!

!template! item key=user-characteristics
{{app}} has three main classes of users:

- +{{app}} Developers+: These are the core developers of {{app}}. They are responsible for designing, implementing, and maintaining the software, while following and enforcing its software development standards.
- +Developers+: These are scientists or engineers that modify or add capabilities to {{app}} for their own purposes, which may include research or extending its capabilities. They will typically have a background in tritium transport and material science, and in modeling and simulation techniques, but may have more limited background in code development using the C++ language. In many cases, these developers will be encouraged to contribute code back to {{app}}.
- +Analysts+: These are users that run {{app}} to run simulations, but do not develop code. The primary interface of these users with {{app}} is the input files that define their simulations. These users may interact with developers of the system requesting new features and reporting bugs found.
!template-end!

!template! item key=information-management
{{app}} as well as the core MOOSE framework in its entirety will be made publicly available on an appropriate repository hosting site. Day-to-day backups and security services will be provided by the hosting service. More information about backups of the public repository on [!ac](INL)-hosted services can be found on the following page: [sqa/github_backup.md]
!template-end!

!template! item key=policies-and-regulations
!include framework_srs.md start=policies-and-regulations-begin end=policies-and-regulations-finish
!template-end!

!template! item key=packaging
No special requirements are needed for packaging or shipping any media containing the [!ac](MOOSE) and {{app}} source code. However, some [!ac](MOOSE)-based applications that use the {{app}} code may be export-controlled, in which case all export control restrictions must be adhered to when packaging and shipping media.
!template-end!

!template item key=reliability
The regression test suite will cover at least 90% of all lines of code at all times. Known
regressions will be recorded and tracked (see [#maintainability]) to an independent and
satisfactory resolution.
