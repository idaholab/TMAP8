# ver-1ha

# Equilibrating Enclosures

## Problem set up

This verification problem models two species '$T_2$' (gaseous tritium) and '$D_2$' (gaseous deuterium) equilibrating in pressure between two enclosures. It recreates the ver-1hb case in [!cite](ambrosek2008verification). Enclosure 1 is pre-charged with tritium and enclosure 2 is pre-charged with deuterium. The gases flow between the two enclosures until the $T_2$ and $D_2$ partial pressures in the two enclosures equalibrate. The pressure change rates for this system for gas $T_2$ are given by
\begin{equation} \label{eq:dt_P1_T}
\frac{dP^1_{T_2}}{dt} = \frac{Q}{V} (P^2_{T_2} - P^1_{T_2}),
\end{equation}
\begin{equation} \label{eq:dt_P2_T}
\frac{dP^2_{T_2}}{dt} = \frac{Q}{V} (P^2_{T_2} - P^1_{T_2}),
\end{equation}
and for gas $D_2$ are given by
\begin{equation} \label{eq:dt_P1_D}
\frac{dP^1_{D_2}}{dt} = \frac{Q}{V} (P^2_{D_2} - P^1_{D_2}),
\end{equation}
\begin{equation} \label{eq:dt_P2_D}
\frac{dP^2_{D_2}}{dt} = \frac{Q}{V} (P^2_{D_2} - P^1_{D_2}),
\end{equation}
where Q is the volumetric flow rate (m$^3$s$^-1$)

As gas flows through the system, the number of atoms of the gas entering the second and third enclosures is greater than the number exiting. The difference in pressures between two neighboring enclosures determines the net rate of gas flowing into the enclosure. The rate of change of the pressure of gas in the second and third enclosures is given as
\begin{equation} \label{eq:dt_P2}
\frac{P_2}{dt} = \frac{Q (P_1-P_2)}{V_2},
\end{equation}
\begin{equation} \label{eq:dt_P3}
\frac{P_3}{dt} = \frac{Q (P_2-P_3)}{V_3}.
\end{equation}

We solve these time evolution equations for $P_2$ and $P_3$ using TMAP8 with $t$ the time and with the initial condition set to $P_2 = P_3 = 0$. We use $V_2 = V_3 = 1$ m$^3$, $P_1 = 1.0$ Pa, and $Q = 0.1$ m$^3$/s.

## Analytical solution

The analytical solution to the equations [eq:dt_P2] and [eq:dt_P3] is
\begin{equation} \label{eq:P2}
P_2 = P_1 \left[ 1 - \exp\left(-\frac{Q}{V_2}t\right) \right],
\end{equation}
and, if $V_2 = V_3$,
\begin{equation} \label{eq:P3_equal_vol}
P_3 = P_1 \left[ 1 - \left(1 + \frac{Q}{V_2}t \right)\exp\left(-\frac{Q}{V_2}t\right) \right].
\end{equation}
If $V_2$ and $V_3$ are not equal,
\begin{equation} \label{eq:P3_unequal_vol}
P_3 = P_1 \left[ 1 - \frac{V_2}{V_2-V_3} \exp\left(-\frac{Q}{V_2}t\right) + \frac{V_3}{V_2-V_3} \exp\left(-\frac{Q}{V_3}t\right) \right].
\end{equation}

In this analytical verification we use the equal volume solution [eq:P3_equal_vol], with the same values for the other parameters as used in the TMAP8 solution. Note that the TMAP4 verification case provides the initial value of $P_1$, but plots the solutions as gas concentrations instead, and also only plots the solution up to 20 s [!cite](longhurst1992verification). The pressure calculations from TMAP8 and the analytical solutions are converted to concentration using the ideal gas law as
\begin{equation}
 C_i = \frac{P_i N_a}{RT},
\end{equation}
where $C_i$ is the concentration in atoms/m$^3$, $N_a$ is Avogadro's constant, $R$ is the gas constant, and $T = 303$ K is the temperature of the system [!cite](longhurst1992verification). The values of $N_a$ and $R$ are taken from the [Physical Constants](https://mooseframework.inl.gov/tmap8/source/utils/PhysicalConstants.html).

## Results and comparison against analytical solution

The comparison of TMAP8 results against the analytical solution is shown in [ver-1ha_comparison_conc] and [ver-1ha_comparison_pressure]. The match between TMAP8's predictions and the analytical solution is satisfactory, with root mean square percentage errors (RMSPE) of 0.06 % for both the 2$^{\text{nd}}$ and 3$^{\text{rd}}$ enclosures. The RMSPE value is the same for the concentration and pressure comparisons.

!media comparison_ver-1ha.py
       image_name=ver-1ha_comparison_conc.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1ha_comparison_conc
       caption=Comparison of concentration of species $T_2$ for the second and third enclosures in a series outflow predicted by TMAP8 and provided by the analytical solution. The RMSPE is the root mean square percent error between the analytical solution and TMAP8 predictions. This recreates the verification figure from TMAP4.

!media comparison_ver-1ha.py
       image_name=ver-1ha_comparison_pressure.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-1ha_comparison_pressure
       caption=Comparison of pressure of species $T_2$ for the second and third enclosures in a series outflow predicted by TMAP8 and provided by the analytical solution. The RMSPE is the root mean square percent error between the analytical solution and TMAP8 predictions. This recreates the verification figure from TMAP7.

## Input files

!style halign=left
The input file for this case can be found at [/ver-1ha.i], which is also used as test in TMAP8 at [/ver-1ha/tests].

!bibtex bibliography
