# ver-1fc

# Conduction in composite structure with constant surface temperatures

The third heat transfer problem (after [ver-1fa](ver-1fa.md) and [ver-1fb](ver-1fb.md)) studies heat transfer through a composite with constant surface temperatures.
The composite is a 40 cm thick layer of Copper (Cu) followed by a 40 cm layer of iron (Fe) [!cite](ambrosek2008verification).
The temperature of both layers is initially 0 K, but at time t = 0, the outside face of the Cu is held at 600 K while the outside face of the Fe is maintained at 0 K.
The thermal conductivity of Cu and Fe are set to 401 W/m/K and 80.2 W/m/K, respectively. The TMAP7 documentation does not specify the materials density $\rho$ or the specific heat $C_p$, but the TMAP7 input file list $\rho C_p = 3.4392 \times 10^6$ J$\cdot$m$^{-3}\cdot$K$^{-1}$ for Cu and $3.5179 \times 10^6$ J$\cdot$m$^{-3}\cdot$K$^{-1}$ for Fe [!cite](ambrosek2008verification). To match these values, TMAP8 uses $\rho = 8940.0$ kg/m$^{3}$ and $C_p =  384.70$ J$\cdot$kg$^{-1}\cdot$K$^{-1}$ for Cu and $\rho = 7860.0$ kg/m$^{3}$ and $C_p = 447.57$ J$\cdot$kg$^{-1}\cdot$K$^{-1}$ for Fe.

This case provides both a verification (comparison against analytical solution) and a benchmarking (code-to-code comparison) exercise. The steady state solution (called ver-1fcs in [!cite](ambrosek2008verification)) is compared again an analytical solution, and the transient solution is compared against ABAQUS. ABAQUS is a heat transfer program that has been validated for both transient and steady state solutions. The ABAQUS code was setup and run by R. G. Ambrosek and presented in [!cite](ambrosek2008verification).

!alert warning title=Typo in [!cite](ambrosek2008verification) - confusion between ABAQUS and TMAP7 results
In [!cite](longhurst1992verification), Table 11 for TMAP7 and ABAQUS transient results and Table 13 for TMAP7 and ABAQUS steady-state results identify, even though it should be different. Given the nature of the data, it corresponds to transient conditions and has been used as such for comparison below. As a result, no ABAQUS and TMAP7 data was used in the steady state case, only TMAP8 predictions and the analytical solution.
Another issue is that the column labels for ABAQUS and TMAP7 are reversed in Table 11 and Table 13, casting doubt on which results correspond to ABAQUS and which results correspond to TMAP7. In this benchmarking exercise, we therefore refer to these results as `ABAQUS or TMAP7 (1)` and `ABAQUS or TMAP7 (2)`. Since they are close, we still consider the benchmarking exercise successful.

## Steady State solution

The steady-state solution for this problem was compared to the analytical solution in addition to the ABAQUS prediction [!cite](ambrosek2008verification).
To solve for the steady state solution for this problem, the heat flux is given by
\begin{equation} \label{eq:solution_analytical_heat_flux}
q''=\frac{T_{SA} - T_{SB}}{\frac{L_A}{k_A} + \frac{L_B}{k_B}},
\end{equation}
where

    $Tsi$ is the temperature of surface $i$, left ($T_{SA}=600$ K) and right ($T_{SB}=0$ K),

    $Li$ is Length of segment $i$ ($L_A=L_B=40$ cm),

    $ki$ is thermal conductivity of segment $i$ ($k_A = 401$ W/m/K, $k_B = 80.2$ W/m/K).

At steady state, the flux in and out of any section of the slab are equal.
The temperature at the interface ($T_I$) can be found by setting the flux through A equal to the flux
through B, which leads to:
\begin{equation} \label{eq:solution_analytical_steady_state}
\frac{T_{SA} - T_{I}}{\frac{L_A}{k_A}} = \frac{T_{I} - T_{SB}}{\frac{L_B}{k_B}}.
\end{equation}
The interface temperature at steady state is therefore equal to $T_I = 500$ K. The temperature profile
for conduction in steady state, with constant physical properties, is linear. The temperature
profile of A and B can therefore be found through linear interpolation.

With TMAP8, the steady state solution can be obtained in different ways: It can be derived by using the [steady state solve](source/executioners/Steady.md) or by running a transient solution until steady state is reached.
Ref. [!cite](ambrosek2008verification) indicates that the steady state solution was obtained by running the transient solution until $t=10,000$ s, which is what is reproduced with TMAP8 here.
TMAP8 predictions were found to be identical to the analytical solution, as shown in
[ver-1fc_comparison_temperature_steady_state].

!media figures/ver-1fc_comparison_temperature_steady_state.png
    style=width:60%;margin-bottom:2%
    id=ver-1fc_comparison_temperature_steady_state
    caption=Comparison of temperature profiles from the analytical solution and TMAP8 in composite structure at steady state ($t = 10000$ s).

## Transient solution

For the transient case, TMAP8 predictions are compared against ABAQUS predictions [!cite](ambrosek2008verification). This is therefore a benchmarking case.

The transient solution was compared at a constant time and at constant distance. The constant time
comparison between ABAQUS and TMAP8 was made at time $t = 150$ s. The constant time
values are shown in [ver-1fc_comparison_temperature_transient_t150], and the comparison is satisfactory.

!media figures/ver-1fc_comparison_temperature_transient_t150.png
    style=width:60%;margin-bottom:2%
    id=ver-1fc_comparison_temperature_transient_t150
    caption=Comparison of temperature distribution from TMAP8, TMAP7, and ABAQUS in composite structure at $t = 150$ s.

The constant distance values were compared at $x = 0.09$ m, at 5 second intervals from time
$t = 0$ s to $t = 150$ s. These results can be seen in [ver-1fc_comparison_temperature_transient_x0.09], and the comparison is satisfactory.

!media figures/ver-1fc_comparison_temperature_transient_x0.09.png
    style=width:60%;margin-bottom:2%
    id=ver-1fc_comparison_temperature_transient_x0.09
    caption=Comparison of temperature distribution from TMAP8, TMAP7, and ABAQUS in composite structure at $x = 0.09$ m.

!bibtex bibliography
