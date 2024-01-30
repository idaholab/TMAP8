# Examples

Inputs which demonstrate potential applications for TMAP8 capabilities,
along with walk-through guides which should in theory allow users to 
leverage prior work.

## [Fuel Cycle](examples/fuel_cycle/index.md)

Because TMAP8 is built on MOOSE, it brings MOOSE's capacity to solve ordinary differential
equations using [ScalarKernels](syntax/ScalarKernels/index.md). These can be quite useful to
model parts of the system at high levels of abstraction while working with detailed
models of specific components. For an example, we re-create a fuel cycle model using the 
equations in [!cite](Abdou2021) to provide a high-level abstraction of a fuel cycle in a potential 
fusion power plant.

!content location=fuel_cycle
