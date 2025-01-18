# Pore-Scale Simulations of Tritium Transport Using TMAP8

This example demonstrates TMAP8's capability to (1) generate pore structures from input images,
and (2) perform pore-scale simulations of tritium transport on these pore structures based on the model described in [!cite](Simon2022).
[!cite](Simon2022) provides additional context and details about this example, including a description of the calibration efforts.
Note that this approach can be extended to three-dimensional microstructures.

This example, as stated in [!cite](Simon2022), showcases how TMAP8 can simulate complex geometries and help investigate the effects of pore microstructure on tritium absorption.

## General Description of the Simulation Case and Corresponding Input Files

### Introduction

!style halign=left
The sections below describe the simulation details and explain how they translate into the example TMAP8 input files.
Not every part of the input file is explained here.
If the interested reader has more questions about this example case and how to modify this input file to adapt it to a different case,
feel free to reach out to the TMAP8 development team on the [TMAP8 GitHub discussion page](https://github.com/idaholab/TMAP8/discussions).

In this example, TMAP8 is used to simulate tritium transport at the pore scale in ceramic breeder materials.
The model tracks tritium in three different forms: freely moving in solid solution in the ceramic material ($T_s$), trapped in the ceramic material ($T_t$), or in gaseous form in pores and outside the ceramic ($T_2$).
This example is based on the simulations presented in Section V of [!cite](Simon2022).

This example is divided into the two steps required to reproduce the results presented in Section V of [!cite](Simon2022).
First, it describes the simulation used to input an image and automatically generate a usable pore microstructure.
Second, it shows how this microstructure can be imported to perform tritium transport calculations on pore microstructure.
This process is illustrated in [fig:pore_scale_process_illustration].

!media figures/pore_scale_process_illustration.png
  id=fig:pore_scale_process_illustration
  caption= Illustration of the process for pore scale simulation of tritium transport in TMAP8 based on a microstructure image. Step 1 takes an image and creates a corresponding microstructure, and step 2 performs tritium transport calculations on this microstructure (figures are reproduced from [!cite](Simon2022)).
  style=display:block;margin-left:auto;margin-right:auto;width:75%

!alert note title=TMAP8 can also automatically generate microstructures, or import other simulation results
TMAP8 can also automatically generate microstructures using the [initial condition](ICs/index.md) system, as [MOOSE] is equipped with the user-friendly, built-in [MeshGenerators system](Mesh/index.md) for creating meshes based on simple geometries. It can also import EBSD data or import microstructures generated via other means.

### Generating the pore microstructure based on an image

!style halign=left
In this first step, we use the following input file to import the image and create the smooth microstructure:

!listing test/tests/pore_scale_transport/2D_microstructure_reader_smoothing_base.i

This section describes this input file, what it does, and how to run it to replicate the results from [!cite](Simon2022).
Note that the input file also contains extensive comments meant to help users.

#### Import the pore microstructure image

!style halign=left
[fig:initial_image_closed] and [fig:initial_image_open] show the initial images used to generate the microstructures from Fig. 5 in [!cite](Simon2022).
Although both samples have a density of 80%, they exhibit very different pore interconnectivities, which was demonstrated to affect tritium absorption [!citep](Simon2022).

!media examples/figures/2D_pore_structure_closed.png
  id=fig:initial_image_closed
  caption= Initial image used to generate the microstructure with closed pores. This corresponds to the original image to generate Fig. 5.a in [!cite](Simon2022).
  style=display:block;margin-left:auto;margin-right:auto;width:40%;border-style:solid

!media examples/figures/2D_pore_structure_open.png
  id=fig:initial_image_open
  caption= Initial image used to generate the microstructure with open pores. This corresponds to the original image to generate Fig. 5.b in [!cite](Simon2022).
  style=display:block;margin-left:auto;margin-right:auto;width:40%

TMAP8 can import these images using the [ImageFunction](ImageFunction.md) object and, using a threshold, attribute different contrast values to given phases.
Here, the bright areas are identified as ceramic material, while dark areas are identified as pores.

The size of the microstructure is not directly provided by the images in [fig:initial_image_closed] and [fig:initial_image_open].
Users can scale, crop, and adjust the image to the desired size.
In this example, the sample being 4.5 mm in radius, the domain size is set to 5.425 mm $\times$ 5.425 mm.

!listing test/tests/pore_scale_transport/2D_microstructure_reader_smoothing_base.i link=false block=Mesh

!listing test/tests/pore_scale_transport/2D_microstructure_reader_smoothing_base.i link=false block=Functions

#### Perform a phase field simulation to smooth the interfaces

!style halign=left
The rest of the input file is set up as a [phase field](phase_field/index.md) simulation to smoothen the interface between the pore and the ceramic material.
As discussed in [!cite](Simon2022), using a phase field approach with a continuous interface enables TMAP8 to model arbitrarily complex geometries that cannot be easily meshed.
Since TMAP8 inherits the [phase field module](phase_field/index.md) from [MOOSE], it can perform phase field simulations.

In this case, we use a two-phase model with arbitrary parameter values to quickly obtain, from the pore structures illustrated in [fig:initial_image_closed] and [fig:initial_image_open], corresponding microstructures with the desired interface width, i.e., $l$=50 $\mu$m in this case.
The simulation time is selected to be large enough to obtain a smooth interface, while staying small enough to prevent significant changes in the microstructure.

#### Run simulations

To run the input file to reproduce the microstructures shown in Fig. 5 in [!cite](Simon2022), users need to first [install TMAP8](installation.md). Then, to generate the microstructure with closed pores, run:

```
cd ~/projects/TMAP8/test/tests/pore_scale_transport/
mpirun -np 4 ~/projects/TMAP8/tmap8-opt -i 2D_microstructure_reader_smoothing_base.i pore_structure_closed.params
```

and to generate the microstructure with open pores, run:

```
cd ~/projects/TMAP8/test/tests/pore_scale_transport/
mpirun -np 4 ~/projects/TMAP8/tmap8-opt -i 2D_microstructure_reader_smoothing_base.i pore_structure_open.params
```

Note that the [pore_structure_closed.params](pore_structure_closed.params) and [pore_structure_open.params](pore_structure_open.params) files complement the base input file [2D_microstructure_reader_smoothing_base.i](2D_microstructure_reader_smoothing_base.i) by providing input and output names.


#### Resulting smooth pore microstructures

!style halign=left
[fig:pore_microstructures] shows the smooth pore microstructures obtained with the simulation described above.
These pore structures correspond to the ones shown in Fig. 5 in [!cite](Simon2022) and can be found in `~/projects/TMAP8/test/tests/pore_scale_transport/` as `pore_structure_close/pore_structure_close.e` and `pore_structure_open/pore_structure_open.e` once the simulations are completed. These can be viewed in a visualization software such as [ParaView](https://www.paraview.org/).

!media examples/figures/Pore_Microstructures.png
  id=fig:pore_microstructures
  caption=Smooth pore microstructures obtained with the simulation described above. This corresponds Fig. 5 in [!cite](Simon2022).
  style=display:block;margin-left:auto;margin-right:auto;width:50%

### Model tritium transport on pore-scale microstructures

!style halign=left
In this second step, we use the following input file to import the smooth microstructures from [fig:pore_microstructures] and model pore scale tritium transport during absorption:

!listing test/tests/pore_scale_transport/2D_absorption_base.i

This section describes this input file, what it does, and how to run it. Note that the input file also contains extensive comments meant to help users.

#### Background and Governing Equations

!style halign=left
In this step, we model tritium transport in the pores, surface reactions at the ceramics interface, and diffusion, trapping, and detrapping within the ceramics.

The evolution of tritium concentration in solid solution within the ceramic material, $c_s$ (mol⋅μm$^{-3}$), is governed by the following equation:

\begin{equation} \label{eq:cs}
\frac{\partial c_s}{\partial t} = \nabla \cdot (h_c D_c \nabla c_s) - \frac{\partial c_t}{\partial t} + 2(K_{gs} - K_{sg}) h_s
\end{equation}

where $t$ is time (s), $D_c$ is the diffusion coefficient of tritium in the ceramic material ($\mu$m$^2$/s), $c_t$ is the concentration of trapped tritium (mol/$\mu$m$^{3}$), $K_{gs}$ and $K_{sg}$ are the reaction rates at the surface (mol/$\mu$m$^{3}$/s), and $h_c$ and $h_s$ are dimensionless interpolation functions that delimit the ceramic material and pore surface, respectively (see the next section below).

The concentration of trapped tritium is governed by:

\begin{equation} \label{eq:ct}
\frac{\partial c_t}{\partial t} = K_T c_s (c_t^0 - c_t) - K_D c_t
\end{equation}

where $K_T$ is the rate constant for trapping ($\mu$m$^3$/s/mol), $c_t^0$ is the density of available trapping sites (mol/$\mu$m$^{3}$), and $K_D$ is the rate constant for detrapping (1/s).

The evolution of tritium concentration in pores and outside the ceramic ($c_2$) is defined by:

\begin{equation} \label{eq:c2}
\frac{\partial c_2}{\partial t} = \nabla \cdot (h_p D_p \nabla c_2) + (K_{sg} - K_{gs}) h_s
\end{equation}

where $D_p$ is the diffusion coefficient of $T_2$ in the pores ($\mu$m$^2$/s) and $h_p$ is a dimensionless interpolation function that delimits the pore.

These concentration variables are defined in the input file as:

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=Variables

The equations are encoded into the input file as [kernels](Kernels/index.md), which each implement a specific term from the equations

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=Kernels


#### Reaction Rates

!style halign=left
The reaction rates for tritium dissociation and formation on the ceramic surface are:

\begin{equation} \label{eq:Kgs}
K_{gs} = k_{gs} c_2 (1 - \theta)^2,
\end{equation}
and
\begin{equation} \label{eq:Ksg}
K_{sg} = k_{sg} c_s^2,
\end{equation}

where $k_{gs}$ (1/s) and $k_{sg}$ ($\mu$m$^3$/s/mol) are reaction rate constants, and $\theta$ is the fraction of available sites for $T_s$, defined as:

\begin{equation} \label{eq:theta}
\theta = \frac{c_s + c_t}{\theta_0 c_t^0},
\end{equation}

where $\theta_0 \geq 1$ is a dimensionless multiplier that ensures the concentration of available sites for tritium exceeds the concentration of trapping sites.

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=Materials/ReactionRateSurface_sXYg_ref Materials/ReactionRateSurface_gXYs_ref

#### Interpolation Functions

!style halign=left
The microstructure is defined by a dimensionless order parameter $\eta$, which equals 1 in the pores, 0 in the ceramic, and varies continuously at the pore surface.
This is commonly used in [phase field modeling](phase_field/index.md) to describe continuous microstructures.
The interpolation functions, which help ensure that diffusion coefficients (or other material properties) are restricted to the appropriate domains, are defined as:

\begin{equation} \label{eq:hc}
h_c = (1 - \eta)^2
\end{equation}

for the ceramic material,

\begin{equation} \label{eq:hp}
h_p = \eta^2
\end{equation}

for the pore area, and

\begin{equation} \label{eq:hs}
h_s = 16 \eta^2 (1 - \eta)^2
\end{equation}

to describe the interface between the ceramic material and the pore.

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=Materials/hmatAD Materials/hporeAD Materials/hsurfaceAD

#### Dimensionless Modeling

!style halign=left
To improve convergence, the model is rendered dimensionless using characteristic time $t_c=1$ s, length $l_c=1$ μm, and quantity $n_c=10^{-18}$ mol.

#### Calibration Against Experimental Data

!style halign=left
In [!cite](Simon2022), the one-dimensional version of this case is used to calibrate the model against experimental data.
In this example, like in Section V of [!cite](Simon2022), we use this calibrated model on the two-dimensional microstructure.

The resulting model parameter values are summarized in [tab:model_parameters].

!table id=tab:model_parameters
  caption=Calibrated model’s parameter values from [!cite](Simon2022).
| Model Parameter | Calibrated Value       | Units                                     |
|-----------------|------------------------|-------------------------------------------|
| $D_c$           | $1.65 \times 10^6$     | $\mu$m$^2\cdot$s$^{-1}$                   |
| $D_p$           | $2.25 \times 10^8$     | $\mu$m$^2\cdot$s$^{-1}$                   |
| $K_D$           | $4.06$                 | s$^{-1}$                                  |
| $K_T$           | $8.33 \times 10^{16}$  | $\mu$m$^{3} \cdot$s$^{-1}\cdot$mol$^{-1}$ |
| $c_t^0$         | $3.47 \times 10^{-18}$ | mol$\cdot \mu$m$^{-3}$                    |
| $\theta^0$      | $4.31$                 | (-)                                       |
| $k_{sg}$        | $1.55 \times 10^{15}$  | $\mu$m$^3\cdot$s$^{-1}\cdot$mol$^{-1}$    |
| $k_{gs}$        | $34.69$                | s$^{-1}$                                  |


### Numerical Method, boundary conditions, and initial condition

!style halign=left
As shown in [fig:pore_microstructures], the simulated domain represents a quarter of the sample, whose radius is 4.5 mm.

The same numerical methods as described in [!cite](Simon2022) are used here.
The numerical methods, including time step, time adaptivity, time integration method, preconditioning, and others are defined in the `Preconditioning` and `Executioner` blocks, as:

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=Preconditioning


!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=Executioner

Concerning boundary conditions, we apply no-flux boundary conditions except for $c_2$ on the right-hand and top sides, which is fixed as a Dirichlet condition according to:

\begin{equation} \label{eq:BC}
c_{s,BC,pore} = \frac{P}{RT}
\end{equation}

where $P$ is the tritium pressure (Pa), $R$ is the gas constant from [PhysicalConstants](PhysicalConstants.md), and $T$ is the temperature (K).

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=BCs

As initial conditions, the ceramic initially contains no tritium, and the pore is filled with $T_2$ with the value from [eq:BC].

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=ICs

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=Functions

#### Run simulations

To run the input file to reproduce the absorption results shown in Fig. 6 in [!cite](Simon2022), users need to first run the previous simulations from the first step. As a result, TMAP8 will have generated `pore_structure_open/pore_structure_open.e` and `pore_structure_close/pore_structure_close.e`. Then, to model tritium transport in the microstructure with closed pores, run:

```
~/projects/TMAP8/test/tests/pore_scale_transport/
mpirun -np 4 ~/projects/TMAP8/tmap8-opt -i 2D_absorption_base.i pore_structure_closed_absorption.params
```

and to model tritium transport in the microstructure with open pores, run:

```
~/projects/TMAP8/test/tests/pore_scale_transport/
mpirun -np 4 ~/projects/TMAP8/tmap8-opt -i 2D_absorption_base.i pore_structure_open_absorption.params
```

Note that [pore_structure_closed_absorption.params](pore_structure_closed_absorption.params) and [pore_structure_open_absorption.params](pore_structure_open_absorption.params) complement the base input file [2D_absorption_base.i](2D_absorption_base.i) by providing input and output names.

### Results and Discussion

!style halign=left
Figure 6 in [!cite](Simon2022) shows the tritium absorption profiles for samples with different pore interconnectivities. The results indicate that higher pore interconnectivity leads to faster tritium transport, which is the type of insight that one-dimensional simulations cannot provide.

These outputs are obtained via the postprocessor blocks:

!listing test/tests/pore_scale_transport/2D_absorption_base.i link=false block=Postprocessors

Note that these simulations are not run to generate  Fig. 6 from [!cite](Simon2022) on-the-fly in the documentation like it is custom to do in other [examples](examples/tmap_index.md) and [V&V](verification_and_validation/index.md) cases due to the significant time these simulations can take when using a fine mesh. However, using the instructions and details provided above, users can replicate the results presented in [!cite](Simon2022). If any challenge arise or if you have a question while working through this example case, feel free to reach out to the TMAP8 development team on the [TMAP8 GitHub discussion page](https://github.com/idaholab/TMAP8/discussions).

## Complete input file

Below are the complete input files, which can be run reliably with approximately 4 processor cores. Note that this input file has not been optimized to reduce computational costs.

Input file used to import the image and create the smooth microstructure:

!listing test/tests/pore_scale_transport/2D_microstructure_reader_smoothing_base.i

Input file utilizing the smooth microstructure and modeling pore scale tritium transport during absorption:

!listing test/tests/pore_scale_transport/2D_absorption_base.i

!bibtex bibliography
