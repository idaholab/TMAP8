# val-2c

# Test Cell Release Experiment

## Case Description

This validation problem is taken from [!cite](Holland1986) and was part of the validation suite of TMAP4 [!cite](longhurst1992verification) and TMAP7 [!cite](ambrosek2008verification). It has been updated and extended in [!cite](Simon2025).
Whenever tritium is released into a fusion reactor test cell, it is crucial to clean it up to prevent exposure.
This case models an experiment conducted at Los Alamos National Laboratory at the tritium systems test assembly (TSTA) to study the behavior of tritium once released in a test cell and the efficacy of the emergency tritium cleanup system (ETCS).

The experimental set up, described in greater detail in [!cite](Holland1986), can be summarized as such:
the inner walls of an enclosure of volume $V$ are covered with an aluminum foil and then covered in paint with an average thickness $l$, which is then in contact with the enclosure air.
A given amount, T$_2^0$, of tritium, T$_2$, is injected in the enclosure, which initially contained ambient air, representing tritium release.
A flow rate $f$ through the enclosure represents the air replacement time expected for large test cells.
The purge gas is ambient air with 20% relative humidity.
A fraction of that amount is diverted through the measurement system to determine the concentrations of chemical species within the enclosure.

Several phenomena are taking place and need to be captured in the model to determine the concentrations of elemental tritium (i.e., T$_2$ and HT), tritiated water (i.e., HTO), and water (i.e., H$_2$O).
First, The following chemical reactions occur inside the enclosure:
\begin{equation} \label{eq:chemical_reaction_T2}
\text{T}_2 + \text{H}_2\text{O} \longleftrightarrow{} \text{HTO} + \text{HT}
\end{equation}
\begin{equation} \label{eq:chemical_reaction_HT}
\text{HT} + \text{H}_2\text{O} \longleftrightarrow{} \text{HTO} + \text{H}_2
\end{equation}
mostly as a consequence of the tritium reactivity. The reaction rates of these reactions are $K_1$ and $K_2$, respectively, where
\begin{equation} \label{eq:chemical_reaction_K_1}
K_1 = 2 K^0 c_{\text{T}_2} \left( 2 c_{\text{T}_2} + c_{\text{HT}} + c_{\text{HTO}} \right)
\end{equation}
and
\begin{equation} \label{eq:chemical_reaction_K_2}
K_2 = K^0 c_{\text{HT}} \left( 2 c_{\text{T}_2} + c_{\text{HT}} + c_{\text{HTO}} \right).
\end{equation}
Here, $c_i$ represents the concentration of species $i$, and $K^0$ is a constant.

Second, the different species will permeate in the paint.
The elemental tritium species, T$_2$ and HT, have a given solubility $K_S^e$ and diffusivity $D^e$, while the tritiated water, HTO, and water, H$_2$O, have a solubility $K_S^w$ and diffusivity $D^w$.
It is expected that the species will initially permeate into the paint and later get released as the purge gas cleans up the enclosure air.

The objectives of this case are to determine the time evolution of T$_2$ and HTO concentrations in the enclosure, match the experimental data published in [!cite](Holland1986), and display this comparison with the appropriate error checking (see [val-2c_comparison_T2] and [val-2c_comparison_HTO]).

## Model Description

To model the case described above, TMAP8 simulates a one-dimensional domain with one block to represent the air in the enclosure, and another block to represent the paint.
In each block, the simulation tracks the local concentration of T$_2$, HT, HTO, and H$_2$O.
Note that this case can easily be extended to a two- or three-dimensional case, but consistent with previous analyses, we will maintain the one-dimensional configuration here.

In the enclosure, to capture the purge gas and the chemical reactions, the concentrations evolve as
\begin{equation} \label{eq:enclosure:T2}
\frac{d c_{\text{T}_2}}{dt} = - K_1 - \frac{f}{V}c_{\text{T}_2},
\end{equation}
\begin{equation} \label{eq:enclosure:HT}
\frac{d c_{\text{HT}}}{dt} = K_1 - K_2 - \frac{f}{V}c_{\text{HT}},
\end{equation}
\begin{equation} \label{eq:enclosure:HTO}
\frac{d c_{\text{HTO}}}{dt} = K_1 + K_2 - \frac{f}{V}c_{\text{HTO}},
\end{equation}
and
\begin{equation} \label{eq:enclosure:H2O}
\frac{d c_{\text{H}_2\text{O}}}{dt} = - K_1 - K_2 + \frac{f}{V} \left(c_{\text{H}_2\text{O}}^0 - c_{\text{H}_2\text{O}} \right),
\end{equation}
where $c_{\text{H}_2\text{O}}^0$ is the concentration of H$_2$O in the incoming purge gas.

In the paint, TMAP8 captures species diffusion through
\begin{equation} \label{eq:paint:T2}
\frac{d c_{\text{T}_2}}{dt} = \nabla \cdot D^e \nabla c_{\text{T}_2},
\end{equation}
\begin{equation} \label{eq:paint:HT}
\frac{d c_{\text{HT}}}{dt} = \nabla \cdot D^e \nabla c_{\text{HT}},
\end{equation}
\begin{equation} \label{eq:paint:HTO}
\frac{d c_{\text{HTO}}}{dt} = \nabla \cdot D^w \nabla c_{\text{HTO}},
\end{equation}
and
\begin{equation} \label{eq:paint:H2O}
\frac{d c_{\text{H}_2\text{O}}}{dt} = \nabla \cdot D^w \nabla  c_{\text{H}_2\text{O}}.
\end{equation}

At the interface between the enclosure air and the paint, sorption is captured in TMAP8 with Henry's law thanks to the  [InterfaceSorption.md] object:
\begin{equation} \label{eq:sorption}
c_{i,enclosure} = K_S c_{i,paint} R T,
\end{equation}
where $c_{i,enclosure}$ and $c_{i,paint}$ are the concentrations of species $i$ in the enclosure and in the paint, respectively, and $K_S$ is the solubility (either $K_S^e$ or $K_S^w$).
The boundary conditions are set to "no flux" since no permeation happens at the interface between the paint and the aluminum foil and the only flux leaving the enclosure is already captured by the purge gas [!citep](Holland1986).

One of the assumptions made in the original paper and TMAP4 V&V case is that the tritium is immediately added to the enclosure [!citep](Holland1986,longhurst1992verification).
However, this leads to an early HTO peak concentration, which does not exactly match the experimental data.
In [!cite](ambrosek2008verification), TMAP7 introduces a new enclosure to account for a slower injection of tritium.
Here, we model this case with two different approaches.
The first approach, like [!citep](Holland1986,longhurst1992verification), assumes that the entire tritium inventory is immediately injected in the enclosure at the beginning of the experiment.
The second approach assumes that the tritium inventory is being injected into the enclosure at a linear rate during a period of time $t_{injection}$ until the entire tritium inventory is injected.
The results of these two approaches are presented and discussed below.


## Case and Model Parameters

The case and model parameters used in both approaches in TMAP8 are listed in [val-2c_parameters]. Some of the parameters are directly leveraged from [!cite](Holland1986,longhurst1992verification,ambrosek2008verification), but others were adapted, originally by hand (see [val-2c_parameters]) and then using a rigorous calibration study (see [val-2c_parameters_calibrated]), to better match the experimental data.

!table id=val-2c_parameters caption=Case and model parameters values used in both immediate and delayed injection approaches in TMAP8 with $R$, the gas constant, and $N_A$, Avogadro's number, as defined in [PhysicalConstants](source/utils/TMAP8PhysicalConstants.md). When values are the same for both approaches, they are noted as identical. Model parameters that have been adapted from [!cite](longhurst1992verification) show a corrective factor in bold. Units are converted in the input file.
| Parameter                  | Immediate injection approach                                 | Delayed injection approach                                   | Unit       | Reference                                       |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ---------- | ----------------------------------------------- |
| $V$                        | 0.96                                                         | Identical                                                    | m$^3$      | [!cite](Holland1986)                            |
| $l$                        | 0.16 (between 0.1 and 0.2)                                   | Identical                                                    | mm         | [!cite](Holland1986)                            |
| T$_2^0$                    | 10                                                           | Identical                                                    | Ci/m$^{3}$ | [!cite](Holland1986)                            |
| $c_{\text{H}_2\text{O}}^0$ | 714                                                          | Identical                                                    | Pa         | [!cite](longhurst1992verification)              |
| $f$                        | 0.54                                                         | Identical                                                    | m$^3$/hr   | [!cite](Holland1986)                            |
| $T$                        | 303                                                          | Identical                                                    | K          | [!cite](Holland1986)                            |
| Total time                 | 180000                                                       | Identical                                                    | s          | [!cite](Holland1986)                            |
| $K^0$                      | $\boldsymbol{1.5} \times 2.0 \times 10^{-10}$                | $\boldsymbol{2.8} \times 2.0 \times 10^{-10}$                | m$^3$/Ci/s | Adapted from [!cite](longhurst1992verification) |
| $D^e$                      | 4.0 $\times 10^{-12}$                                        | Identical                                                    | m$^2$/s    | [!cite](Holland1986)                            |
| $D^w$                      | 1.0 $\times 10^{-14}$                                        | Identical                                                    | m$^2$/s    | [!cite](Holland1986)                            |
| $K_S^e$                    | $\boldsymbol{5.0 \times 10^{-2}} \times 4.0 \times 10^{19}$ | $\boldsymbol{1.0 \times 10^{-3}} \times 4.0 \times 10^{19}$ | 1/m$^3$/Pa | Adapted from [!cite](longhurst1992verification) |
| $K_S^w$                    | $\boldsymbol{3.5 \times 10^{-4}} \times 6.0 \times 10^{24}$ | $\boldsymbol{3.0 \times 10^{-4}} \times 6.0 \times 10^{24}$ | 1/m$^3$/Pa | Adapted from [!cite](longhurst1992verification) |
| $t_{injection}$            | N/A                                                          | 3                                                            | hr         |                                                 |

The calibration study was performed using [MOOSE's stochastic tools module](modules/stochastic_tools/index.md), and in particular the [Parallel Subset Simulation](samplers/ParallelSubsetSimulation.md) (PSS) approach.
The inputs and methodology provided here do not correspond to the full PSS study, but a scaled down version of it to minimize the computational costs.
For this PSS study, we used 5 subsets with a subset probability of 0.1 (default) and 1000 samples per subset for a total of 5000 simulations, which were performed in parallel on 5 processors.
For a full PSS study, it is common to use 10 subsets with 10000 samples per subset.

To calibrate the model against both the T$_2$ and HTO concentrations in the enclosure over time, we performed a multi-objective optimization study.
The penalties for the difference between the experimental $c_{i}^{exp}$ data and the modeling prediction $c_{i}^{mod}$ is given by

\begin{equation} \label{eq:optimization_penalty_HTO}
\delta_{\text{HTO}} = (\log(c_{\text{HTO}}^{exp}) - \log(c_{\text{HTO}}^{mod}))^2 c_{\text{HTO}}^{exp} \times 10^{5}
\end{equation}

for HTO, and

\begin{equation} \label{eq:optimization_penalty_T2}
\delta_{\text{T}_2} = (\log(c_{\text{T}_2}^{exp}) - \log(c_{\text{T}_2}^{mod}))^2
\end{equation}

for T$_2$. The metric to be optimized is then defined as the time integral of

\begin{equation} \label{eq:optimization_metric}
g = \frac{\delta_{\text{HTO}}^2+8000}{30 \delta_{\text{HTO}}^4+400 \delta_{\text{HTO}}^2+1} + \frac{\delta_{\text{T}_2}^2+45000}{0.1 \delta_{\text{T}_2}^4+50 \delta_{\text{T}_2}^2+1}.
\end{equation}

Notably, the integral difference is defined in logarithmic space to give equal weight to all data points in the logarithmic scale during the optimization process.
The complexity of the optimization metric is due to the large difference in scale for each species, as well as the discrete nature of the T$_2$ measurements compared to the almost continuous nature of the HTO measurements. These differences make it challenging to optimize the fits of both species.

The comparison between the original and calibrated values of selected model parameters is summarized in [val-2c_parameters_calibrated].

!table id=val-2c_parameters_calibrated caption=Calibrated model parameters values for the delayed injection case in val-2c..
| Parameter       | Non-calibrated values (see [val-2c_parameters])             | Calibrated values using [Parallel Subset Simulation](https://mooseframework.inl.gov/source/samplers/ParallelSubsetSimulation.html) | Unit       |
| --------------- | ----------------------------------------------------------- | ----------------------- | ---------- |
| $K^0$           | $\boldsymbol{2.8} \times 2.0 \times 10^{-10}$               | 2.833 $\times 10^{-11}$ | m$^3$/Ci/s |
| $D^e$           | 4.0 $\times 10^{-12}$                                       | 3.864 $\times 10^{-12}$ | m$^2$/s    |
| $D^w$           | 1.0 $\times 10^{-14}$                                       | 1.737 $\times 10^{-14}$ | m$^2$/s    |
| $K_S^e$         | $\boldsymbol{1.0 \times 10^{-3}} \times 4.0 \times 10^{19}$ | 2.514 $\times 10^{16}$  | 1/m$^3$/Pa |
| $K_S^w$         | $\boldsymbol{3.0 \times 10^{-4}} \times 6.0 \times 10^{24}$ | 9.862 $\times 10^{20}$  | 1/m$^3$/Pa |
| $t_{injection}$ | 10800                                                       | 9536                    | s          |

## Results and Discussion

!alert note title=Update from [!cite](Simon2025)
The results presented here are updated results from those presented in [!cite](Simon2025). First, the initial time step was reduced from dt=60 s in [!cite](Simon2025) to dt=1 s in the current case. This slightly affects the results for both the immediate and delayed injection cases. However, the results are qualitatively unchanged and conclusions remain valid. Second, the calibration approach was updated since [!cite](Simon2025) with an updated multi-objective function, and new results. This improves the previous calibration results from [!cite](Simon2025).

[val-2c_comparison_T2] and [val-2c_comparison_HTO] show the comparison of the TMAP8 calculations (both with immediately injected and delayed injected T$_2$) against the experimental data for T$_2$ and HTO concentration in the enclosure over time.
There is reasonable agreement between the TMAP8 predictions and the experimental data.
In the case of immediate T$_2$ injection, the root mean square percentage errors (RMSPE) are equal to RMSPE = 58.68% for T$_2$ and RMSPE = 146.23% for HTO, respectively.
When accounting for a delay in T$_2$ injection, the TMAP8 predictions best match the experimental data, in particular the position of the peak HTO concentration. The RMSPE values decrease to RMSPE = 89.50% for T$_2$ and RMSPE = 75.66% for HTO, respectively.
Note that the model parameters listed in [val-2c_parameters] are somewhat different from [!cite](Holland1986,longhurst1992verification,ambrosek2008verification) to better match the experimental data.
In particular, [!cite](longhurst1992verification,ambrosek2008verification) did not validate the TMAP predictions against T$_2$ concentration, which we do here in [val-2c_comparison_T2] and in [!cite](Simon2025).
This affects some of the model parameters.

!media comparison_val-2c.py
       image_name=val-2c_comparison_TMAP8_Exp_T2_Ci.png
       style=width:70%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2c_comparison_T2
       caption=Comparison of TMAP8 calculations against the experimental data for T$_2$ concentration in the enclosure over time. TMAP8 matches the experimental data well, with an improvement when T$_2$ is injected over a given period rather than immediately. Calibration of the delayed injection model delivers further improvements.

!media comparison_val-2c.py
       image_name=val-2c_comparison_TMAP8_Exp_HTO_Ci.png
       style=width:70%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2c_comparison_HTO
       caption=Comparison of TMAP8 calculations against the experimental data for HTO concentration in the enclosure over time. Calibration of the delayed injection model delivers further improvements, with more accurate simulation results when T$_2$ is injected over a given period rather than immediately.

As shown in the red curve in [val-2c_comparison_T2] and [val-2c_comparison_HTO], using [MOOSE's stochastic tools module](modules/stochastic_tools/index.md) notably increased the agreement between the modeling predictions and experimental data for both the T$_2$ and HTO concentrations.
The RMSPE for T$_2$ decreases from 89.50% to 30.18% and the RMSPE for HTO decreases from 75.66% to 67.07%.
Note that although the calibration approach is similar to the one presented in [!cite](Simon2025), the results presented here include more simulations and the quality of the calibration is increased here (RMSPE values are further decreased here).

[val-2c_calibration_input] and [val-2c_calibration_output] show the evolution of the model parameter values and of the optimization metric (time integral of $g$ defined in [eq:optimization_metric]) as a function of the number of simulation. The calibrated model corresponds to the highest value.

!media comparison_val-2c.py
       image_name=val-2c_pss_inputs.png
       style=width:80%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2c_calibration_input
       caption=Evolution of the model parameter values as a function of the number of simulations.

!media comparison_val-2c.py
       image_name=val-2c_pss_output.png
       style=width:70%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2c_calibration_output
       caption=Evolution of the optimization metric (time integral of $g$ defined in [eq:optimization_metric]) as a function of the number of simulations. The calibrated model corresponds to the highest value.

[val-2c_calibration_input_normal_range] and [val-2c_calibration_input_uniform_range] show the value of the calibrated parameters and the range of the data that was explored in the [Parallel Subset Simulation](samplers/ParallelSubsetSimulation.md) study.
[val-2c_calibration_input_normal_range] shows the parameters that followed a normal distribution, and [val-2c_calibration_input_uniform_range] shows those that followed a uniform distribution in log scale.
In both cases, the calibrated parameters are not on the extremes of the distribution, suggesting that the ranges were properly defined.

!media comparison_val-2c.py
       image_name=val-2c_pss_inputs_normal_calibrated.png
       style=width:70%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2c_calibration_input_normal_range
       caption=Calibrated parameter values compared to the normalized normal distribution used in the [Parallel Subset Simulation](samplers/ParallelSubsetSimulation.md) study. None of the parameters are at the extremes of the distribution.

!media comparison_val-2c.py
       image_name=val-2c_pss_inputs_uniform_calibrated.png
       style=width:70%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2c_calibration_input_uniform_range
       caption=Calibrated parameter values compared to the normal distribution in the log scale used in the [Parallel Subset Simulation](samplers/ParallelSubsetSimulation.md) study. None of the parameters are at the extremes of the distributions.

## Input files

!style halign=left
The input files for this case can be found at [/val-2c_immediate_injection.i] and [/val-2c_delay.i]. Note that both input files utilize a common base file [/val-2c_base.i] with the line `!include val-2c_base.i`. The base input file contains all the features and TMAP8 objects common to both cases, reducing duplication, and this allows the immediate injection and delayed injection inputs to focus on what is specific to each case. Note that both input files are also used as TMAP8 tests, outlined at [/val-2c/tests].

!alert tip title=Input file include syntax information
To learn more about the `!include` feature, refer to the [application_usage/input_syntax.md] page.

For the calibration study, additional input files are provided.

- [/val-2c_base_pss.i] provides key functions and postprocessor blocks necessary for the PSS study, including calculations of the multi-objective optimization metric (i.e., the time integral of $g$ defined in [eq:optimization_metric]).
- [/val-2c_delay_pss.i] includes both [/val-2c_base_pss.i] and [/val-2c_delay.i] to generate the needed full input file for the simulation.
- [/val-2c_pss_main.i] is the main input file for the PSS study. It defines what model parameters to vary and how, defines what approach to use, and initiates simulations using [/val-2c_delay_pss.i].

To run the PSS study in the terminal, users can perform:

```
cd ~/projects/TMAP8/test/tests/val-2c/
mpirun -np 5 ~/projects/TMAP8/tmap8-opt -i val-2c_pss_main.i
```

Note that this study is time consuming since a large number of simulations are being run.
Modifying the PSS parameters can reduce the computational cost.

Although a very short PSS study is simulated as a test in [/val-2c/tests] to ensure these files run properly, the full calibration study is not performed regularly in tests to limit computational costs within the TMAP8 testing suite. The gold files [/gold/val-2c_pss_results/val-2c_pss_main_out.json] and [/gold/calibrated_parameter_values.txt] are, therefore, not continuously tested, and the calibrated model parameters used in [/val-2c/tests] are not continuously updated.

!bibtex bibliography
