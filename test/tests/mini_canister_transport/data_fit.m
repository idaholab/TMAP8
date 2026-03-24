clc
clear
close all
T = readtable("SRNL_data.csv")
Dose = [T.Dose_MGy_]
Time = [Dose*1e6/(1440*124)] % Convert from dose to days assuming 124 Gy/min dosing
H2_yield = [T.Cum_H2Yield__mol_]
gas_pressure = T.GasPressure_kPa_ * 1e3 %Pa
avg_pressure_difference = mean(diff(gas_pressure))
Partial_pressure = [gas_pressure].*[T.H2GasFraction___]/100
Partial_pressure_corrected = [gas_pressure - avg_pressure_difference].*[T.H2GasFraction___]/100
plot(Dose,Partial_pressure_corrected-Partial_pressure)


%%
figure
f1 = fit(Time,H2_yield,"poly1")
plot(f1,'b-',Time,H2_yield,'ro')
xlabel('Time (days)'); % Add label to the x-axis
ylabel('H_2 Total Mass (\mu mol)'); % Add label to the y-axis
title('SRNL As-Corroded No-Vaccum Cum. H_2 Yield');    % Add a title to the plot
legend('data', 'Linear fit', Location='northwest')

figure
f2 = fit(Time,H2_yield,"log")
plot(f2,Time,H2_yield)
xlabel('Time (days)'); % Add label to the x-axis
ylabel('H_2 Total Mass (\mu mol)'); % Add label to the y-axis
title('SRNL As-Corroded No-Vaccum Cum. H_2 Yield');    % Add a title to the plot
legend('data', 'Log fit', Location='northwest')

figure
f3 = fit(Time,H2_yield,"power1")
plot(f3,Time,H2_yield)
xlabel('Time (days)'); % Add label to the x-axis
ylabel('H_2 Total Mass (\mu mol)'); % Add label to the y-axis
title('SRNL As-Corroded No-Vaccum Cum. H_2 Yield');    % Add a title to the plot
legend('data', 'Power fit', Location='northwest')

figure
hold on
plot(f1,'b-',Time,H2_yield,'ko')
plot(f2,'r-',Time,H2_yield,'ko')
plot(f3,'g-',Time,H2_yield,'ko')
xlabel('Time (days)'); % Add label to the x-axis
ylabel('H_2 Total Mass (\mu mol)'); % Add label to the y-axis
title('SRNL As-Corroded No-Vaccum Cum. H_2 Yield');    % Add a title to the plot
legend('','Linear fit', '','Log fit','','Power fit', Location='northwest')
ylim([0,1600])

% H2_source = H2_yield / (727727.1927*Time(end)); % Divide by volume and time to get correct units for source term for RHS of PDE
% f1 = fit(Time,H2_source,"log")
% plot(f1,Time,H2_source)
% hold
% f2 = fit(Time,H2_source, "poly1")
% plot(f2,Time,H2_source)
% plot(Time,H2_source,Time,H2_yield)
% f3 = fit(Time,H2_source, "power1")
% plot(f3,Time,H2_source)
% figure