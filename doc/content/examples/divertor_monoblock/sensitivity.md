# Divertor Monoblock Sensitivities 

This work consists of sensitivity studies of different operating conditions performed on the [Divertor Monoblock](https://mooseframework.inl.gov/TMAP8/examples/divertor_monoblock/index.html). The original pulsed operation of the divertor monoblock model was modified according to [!cite](Hodille2021126003) towards a single-long tritium and heat flux pulse of an approximate equivalent total fluence. An initial sensitivity study on was performed on the divertor monoblock's boundary conditions under the steady pulse condition using the [Sobol Method](https://mooseframework.inl.gov/modules/stochastic_tools/examples/sobol.html) and other tools within the [Stochastic Tools Module](https://mooseframework.inl.gov/modules/stochastic_tools/). Two additional sensitivity studies were performed on select transients obtained from [!cite](ELMORSHEDY2024101616) and [!cite](Kessel01092013).

## General description of the sensitivity studies and the modified cases 

### Introduction 

!style halign=left
Many fusion components, especially those exposed to especially unique or extreme conditions, often lack sufficient operation data to evaluate their reliability, availability, maintainability, and inspectability (RAMI). As a proof-of-concept, we seek to  construct a Probabilistic Physics of Failure (PPoF) model of a tokomak divertor system to obtain failure rate metrics and lifetime metric relevant to the RAMI of a nuclear fusion reactor.

To accomplish this, sensitivity studies on the [Divertor Monoblock](https://mooseframework.inl.gov/TMAP8/examples/divertor_monoblock/index.html) model described in [!cite](Shimada2024114438) will be performed for (1) steady state conditions based on ITER data [!cite](Hodille2021126003), (2) an inadvertant shutdown transient [!cite](ELMORSHEDY2024101616), and (3) an edge-localized mode transient [!cite](Kessel01092013). The sensitivity studies will be performed using the [MOOSE](https://mooseframework.inl.gov/) Stochastic Module and its Sobol Method according to [!cite](SALTELLI2002280). The results of the sensitivity studies will be evaluated for state limits associated with heat transfer and tritium migration physics included in the [Divertor Monoblock](https://mooseframework.inl.gov/TMAP8/examples/divertor_monoblock/index.html).

First, the modifications made to the [Divertor Monoblock] model will be described. Second, the conditions the divertor monoblock was subjected to in the steady and transient scenarios will be described. Finally, the results of the sensitivities, namely the first and second order sensitivity indicies and example correlations and state frequencies will be presented.

### Divertor Monoblock modifications 

The pulsed operation of the divertor is computationally expensive, so as a first approximation, we replace the pulsed operation with a single steady pulse. We also add several postprocessors.

%Show added postprocessors

### Steady operation 


% Varied parameters: boundary conditions,

!table id=tab:steady_case
caption=Steady case varied boundary conditions

| Parameter | Samples | Nominal Value | Distribution | Deviation |
| --- | --- | --- | --- | --- |
| Incident Heat Flux | 100 | 10$^{7}$ MW/M$^2$ | Uniform | $\pm$5% |
| Incident Tritium Flux | 100 | 7.90$\times$10$^{-13}$ (normalized) | Uniform | $\pm$5% |
| Coolant Temperature | 100 | 552 K | Uniform | $\pm$5% |
| Coolant Tritium Concentration | 100 | 1.0$\times$10$^{-18}$ (normalized) | Uniform | $\pm$1% |

% parameter space figure

### Transient case: inadvertant shutdown 

!style halign=left

% Transient characteristics (modification to BCs), varied parameters and their ranges
% Transient figure

!table id=tab:inadvertant_shutdown_case
caption=Inadvertant shutdown varied parameter space.

| Parameter | Samples | Nominal Value | Distribution | Deviation |
| --- | --- | --- | --- | --- |
| Peak Duration | 1000 | 1s | Normal | $\sigma$=$\pm$5% |
| Peak Heat Flux | 1000 | 2$\times$10$^{7}$ MW/M$^2$ | Normal | $\sigma$=$\pm$5% |
| Coolant Temperature | 1000 | 552 K | Normal | $\sigma$=$\pm$5% |
| Tungsten Conductivity Factor | 1000 | 1.0 | Uniform | $\sigma$=$\pm$5% |

% Parameter space figure

### Transient case: edge-localized mode disruption 

!style halign=left
% Transient characteristics (modification to BCs), varied parameters and their ranges
% transient figure
!table id=tab:elm_transient_case
caption=Edge-localized mode transient case parameter space.

| Parameter | Samples | Nominal Value | Distribution | Deviation |
| --- | --- | --- | --- | --- |
| Peak Duration | 1000 | 1.32ms | Normal | $\sigma$=$\pm$5% |
| Peak Heat Flux | 1000 | 1147$\times$10$^{7}$ MW/M$^2$ | Normal | $\sigma$=$\pm$5% |
| Coolant Temperature | 1000 | 552 K | Normal | $\sigma$=$\pm$5% |
| Tungsten Conductivity Factor | 1000 | 1.0 | Uniform | $\sigma$=$\pm$5% |
% Paramete space figure
## Results 

### Steady operation 

% Sensitivity to inputs, pick two or three examples
% Correlation between incident heat flux and: W max temp, F_permeation

### Inadvertant shutdown 

% Sensitivity to inputs, pick two or three examples
% Correlation between incident heat flux and: W max temp, F_permeation

### Edge-localized mode disruption 

% Sensitivity to inputs, pick two or three examples
% Correlation between incident heat flux and: W max temp, F_permeation

## Complete input files 

Below are the complete input files for the various sensitivity studies. Note that none of the inputs have been optimized for computational costs.

### Steady operation 

#### Subapp input 

!listing test/tests/divertor_monoblock/steady_state_runner.i link=false

#### Controller input 

!listing test/tests/divertor_monoblock/steady_state_sobol.i link=false

### Inadvertent shutdown 

#### Subapp input

!listing test/tests/divertor_monoblock/shutdown_transient_runner.i link=false

#### Controller input

!listing test/tests/divertor_monoblock/shutdown_transient_sobol.i link=false

### Edge-localized mode disruption

#### Subapp input

!listing test/tests/divertor_monoblock/elm_transient_runner.i link=false

#### Controller input

!listing test/tests/divertor_monoblock/elm_transient_sobol.i link=false

