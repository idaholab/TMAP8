# Examples

Inputs which demonstrate potential applications for TMAP8 capabilities,
along with walk-through guides which should in theory allow users to
leverage prior work.

## [Fuel Cycle](examples/fuel_cycle/index.md)

Because TMAP8 is built on MOOSE, it brings MOOSE's capacity to solve ordinary differential
equations using [ScalarKernels](syntax/ScalarKernels/index.md). These can be quite useful to
model parts of the system at high levels of abstraction while working with detailed
models of specific components. As an example, we re-create a fuel cycle model using the
equations in [!cite](Abdou2021) to provide a high-level abstraction of a fuel cycle in a potential
fusion power plant.

!content location=fuel_cycle


## [Divertor Monoblock](examples/divertor_monoblock/index.md)

TMAP8 is used to model tritium transport in a divertor monoblock to elucidate the effects of pulsed operation (up to fifty 1600-second plasma discharge and cool-down cycles) on the tritium in-vessel inventory source term and ex-vessel release term (i.e., tritium retention and permeation) for safety analysis. This example reproduces the results presented in [!cite](Shimada2024114438).
