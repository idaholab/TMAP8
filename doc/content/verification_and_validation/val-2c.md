# val-2c

# Test Cell Release Experiment

## Case Description

This validation problem is taken from [!cite](Holland1986) and was part of the validation suite of TMAP4 [!cite](longhurst1992verification) and TMAP7 [!cite](ambrosek2008verification).
Whenever tritium is released into a fusion reactor test cell, it is crucial to clean it up to prevent exposure.
This case models an experiment conducted at Los Alamos National Laboratory at the tritium systems test assembly (TSTA) to study the behavior of tritium once released in a test cell and the efficacy of the emergency tritium cleanup system (ETCS).

The experimental set up, described in greater detail in [!cite](Holland1986), can be summarized as such:
the inner walls of an enclosure of volume $V$ was covered with an aluminum foil and then covered in paint with an average thickness $l$, which is then in contact with the enclosure air.
A given amount, T$_2^0$, of tritium, T$_2$, is injected in the enclosure, which initially contained ambient air.
This represents the tritium release.
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
It is expected that species will initially permeate into the paint and later get released as the purge gas cleans up the enclosure air.

The objectives of this case are to determine the time evolution of T$_2$ and HTO concentrations in the enclosure, match the experimental data published in [!cite](Holland1986), and display this comparison with the appropriate error checking (see [val-2c_comparison_T2] and [val-2c_comparison_HTO]).

## Model Description

To model the case described above, TMAP8 simulates a one-dimensional domain with one block to represent the air in the enclosure, and another block to represent the paint.
In each block, the simulation tracks the local concentration of T$_2$, HT, HTO, and H$_2$O.
Note that this case can easily be extended to a two- or three-dimensional case, but, consistent with previous analyses, we will maintain the one-dimensional configuration here.

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
\frac{d c_{\text{T}_2}}{dt} = \nabla D^e \nabla c_{\text{T}_2},
\end{equation}
\begin{equation} \label{eq:paint:HT}
\frac{d c_{\text{HT}}}{dt} = \nabla D^e \nabla c_{\text{HT}},
\end{equation}
\begin{equation} \label{eq:paint:HTO}
\frac{d c_{\text{HTO}}}{dt} = \nabla D^w \nabla c_{\text{HTO}},
\end{equation}
and
\begin{equation} \label{eq:paint:H2O}
\frac{d c_{\text{H}_2\text{O}}}{dt} = \nabla D^w \nabla  c_{\text{H}_2\text{O}}.
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
The second approach assumes that the tritium inventory is being injected into the enclosure at a linear rate during a period of time $t_injection$ until the entire tritium inventory is injected.
The results of these two approaches are presented and discussed below.


## Case and Model Parameters

The case and model parameters used in both approaches in TMAP8 are listed in [val-2c_parameters]. Some of the parameters are directly leveraged from [!cite](Holland1986,longhurst1992verification,ambrosek2008verification), but others were adapted to better match the experimental data.


!table id=val-2c_parameters caption=Case and model parameters values used in both approaches in TMAP8 with $R$, the gas constant, and $N_A$, Avogadro's number, as defined in [PhysicalConstants](source/utils/PhysicalConstants.md). When values are the same for both approaches, they are noted as identical. Model parameters that have been adapted from [!cite](longhurst1992verification) show a corrective factor in bold. Units are converted in the input file.
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

## Results and discussion

[val-2c_comparison_T2] and [val-2c_comparison_HTO] show the comparison of the TMAP8 calculations (both with immediately injected and delayed injected T$_2$) against the experimental data for T$_2$ and HTO concentration in the enclosure over time.
There is reasonable agreement between the TMAP8 predictions and the experimental data.
In the case of immediate T$_2$ injection,  the root mean square percentage errors are equal to RMSPE = 58.98 % for T$_2$ and RMSPE = 139.10 % for HTO, respectively.
When accounting for a delay in T$_2$ injection, the TMAP8 predictions best match the experimental data, in particular the position of the peak HTO concentration. The RMSPE values decrease to RMSPE = 58.05 % for T$_2$ and RMSPE = 74.77 % for HTO, respectively.
Note that the model parameters listed in [val-2c_parameters] are somewhat different from [!cite](Holland1986,longhurst1992verification,ambrosek2008verification) to better match the experimental data.
In particular, [!cite](longhurst1992verification,ambrosek2008verification) did not validate the TMAP predictions against T$_2$ concentration, which we do here in [val-2c_comparison_T2].
This affects some of the model parameters.

The agreement between modeling predictions and experimental data could be further improved by adjusting the model parameters.
It is also possible to perform this optimization with [MOOSE's stochastic tools module](https://mooseframework.inl.gov/modules/stochastic_tools/index.html).

!media comparison_val-2c.py
       image_name=val-2c_comparison_TMAP8_Exp_T2_Ci.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2c_comparison_T2
       caption=Comparison of TMAP8 calculations against the experimental data for T$_2$ concentration in the enclosure over time. TMAP8 matches the experimental data well, with an improvement when T$_2$ is injected over a given period rather than immediately.

!media comparison_val-2c.py
       image_name=val-2c_comparison_TMAP8_Exp_HTO_Ci.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=val-2c_comparison_HTO
       caption=Comparison of TMAP8 calculations against the experimental data for HTO concentration in the enclosure over time. TMAP8 matches the experimental data well, with an improvement when T$_2$ is injected over a given period rather than immediately.

## Input files

!style halign=left
The input files for this case can be found at [/val-2c_immediate_injection.i] and [/val-2c_delay.i]. Note that both input files utilize a common base file [/val-2c_base.i] with the line `!include val-2c_base.i`. The base input file contains all the features and TMAP8 objects common to both cases, reducing duplication, and this allows the immediate injection and delayed injection inputs to focus on what is specific to each case. Note that both input files are also used as TMAP8 tests, outlined at [/val-2c/tests].

!bibtex bibliography
