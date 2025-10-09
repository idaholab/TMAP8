# Base Theory for TMAP8

This page introduces some of the basic theoretical concepts used in TMAP8.
However, this list is not exhaustive, and users should refer to the publications listed in the [publications.md] (including [!cite](Simon2025)),
the [verification_and_validation/index.md], and the [syntax/index.md] page for a more comprehensive description of capabilities, theoretical concepts, and available objects.

## Surface Reactions

At surfaces, atoms and molecules go through dissociations and recombinations, which are captured in TMAP8.
There are two main dissociation/recombination conditions that TMAP7 offered, namely `ratedep` and `surfdep`.
These cases are both reproduced in TMAP8 in a more general way, and are detailed below:

### Ratedep conditions

!style halign=left
The `ratedep` condition applies when dissociation and recombination reaction kinetics govern the surface reactions [!cite](ambrosek2008verification).
`ratedep` assumes that the generation and release rate of molecules is the product of two or more atom concentrations at the surface and a recombination rate coefficient.
Once formed, molecules immediately leave the surface.

Note that in TMAP8, just like in TMAP7, atoms in the nodes closest to the surface contribute to recombination processes.
Atoms deeper in the mesh do not directly contribute to recombinations.
However, if the size of the nodes in the mesh is larger than the size of the lattice, which it usually is, atoms from lattice layers deeper in the materials also contribute to recombinations, as opposed to having only surface atoms contribute.

Under the `ratedep` assumptions, the net flux of atoms of species $s$ into the surface is given by

\begin{equation} \label{eq:flux_rate_dep_net}
J_s = \sum_{m}a_{ms} J_m
\end{equation}

where $m$ denotes different molecules, $a_{ms}$ is the number of atoms of species $s$ in a molecule $m$, and $J_m$ is the flux for a given molecule, defined as

\begin{equation} \label{eq:flux_rate_dep_molecule}
J_m = K_{d_m} P_m - \sum_{i,j} K_{r_m} C_i C_j
\end{equation}

where $K_{d_m}$ is the dissociation rate, $P_m$ is the partial pressure, and $K_{r_m}$ is the recombination rate for molecule $m$.
$C_i$ is the concentration of atomic or complex species “i”.
Note that in TMAP8, additional terms can be added if a molecule contains more than two atoms, which was not possible in TMAP7.
For example, generating H$_2$O was the result of a two step process, first generating OH, and then H$_2$O.
In TMAP8, however, it is possible to either follow TMAP7's approach, or directly account for the reaction between an arbitrary number of atomic of complex species.

The following V&V cases, among others, utilize the `ratedep` conditions: [ver-1ia](ver-1ia.md), [ver-1ib](ver-1ib.md), and [val-2e](val-2e.md).

For example, [ver-1ia](ver-1ia.md) considers the following reaction and model:

!include /ver-1ia.md start=When two species react on a surface to form a third end=This case uses equal starting pressures

### Surfdep conditions

!style halign=left
The `surfdep` condition applies when recombination is limited by surface energy.
Following the  `surfdep` model, the production rate to form surface species proceeds as the product of random lateral jumps,
but release is thermally activated and involves the surface binding energy explicitly.
Inversely, the transition from molecules to single atoms is modeled as a two step process, where molecules are first absorbed by the surface, and then dissociates.

When using the `surfdep` approach, the molecular flux across the surface $J_m$ is then given by
\begin{equation} \label{eq:flux_surface_dep_net}
J_m = \frac{P_m}{\sqrt{2 \pi M k T}} \exp\left( -\frac{E_x}{k_B T} \right) - C_m \nu_0 \exp\left( -\frac{E_x-E_c}{k_BT} \right)
\end{equation}

where $M$ is the molecular mass,
$E_x$ is the barrier energy for molecular entry to the surface (assumed positive),
and $E_c$ is the surface binding energy of molecule $m$,
and $\nu_0$ is the Debye frequency ($\sim$ 10$^{13}$ s$^{-1}$ for tungsten).

The following V&V cases, among others, utilize the `surfdep` conditions: [ver-1ic](ver-1ic.md) and [ver-1id](ver-1id.md).

For example, [ver-1ic](ver-1ic.md) considers the following reaction and model:

!include /ver-1ic.md start=The problem considers the reaction between end=This case uses equal starting pressures

## Surface Equilibrium

!style halign=left
Both conditions described capture dissociation and recombination reactions, including their kinetics.
However, when the kinetics of the dissociation/recombination processes are much faster than other timescales in the systems, e.g., diffusion, capturing them would likely reduce the required time step and hence increase computational costs without significantly affecting the long term results.
In that case, it is reasonable to assume that the surface reactions are at quasi-steady state, and set the surface concentrations to their equilibrium values.

In TMAP4 and TMAP7, this is coined the `lawdep` condition.
While TMAP8 does not use this terminology, it supports this quasi-steady state assumption through the [InterfaceSorption.md] and/or [EquilibriumBC.md] capabilities, which enable both Sievert's and Henry's law.
Sievert's law applies when diatomic gases dissociate into individual atoms during dissolution, and thermodynamic equilibrium is reached.
Henry's law applies when no dissociation/recombination reactions take place at the interface, and equilibrium is reached.

!alert note title=InterfaceKernels vs. Boundary Conditions
Boundary conditions are applied to the boundary of the modeled domain, when the other side of the interface is not being modeled.
For example, the TMAP8 boundary condition applying a sorption law at the boundary is [EquilibriumBC.md].
Interface kernels, however, are applied at interfaces between two subdomains, such as two different materials with different solubilities.
In the case of a sorption law, it also imposes conservation of mass at the interface, as detailed in [InterfaceSorption.md].
Learn more about InterfaceKernels in the [InterfaceKernels/index.md] page.

The following V&V cases, among others, use the quasi-steady-state approximation for surface equilibrium:

- [ver-1ie](ver-1ie.md) and [ver-1if](ver-1if.md),
- [ver-1kb](ver-1kb.md), [ver-1kc-1](ver-1kc-1.md), [ver-1kc-2](ver-1kc-2.md), and [ver-1kd](ver-1kd.md),
- [val-2c](val-2c.md).


!bibtex bibliography
