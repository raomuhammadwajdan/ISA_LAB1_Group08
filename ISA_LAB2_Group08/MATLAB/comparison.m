fs=10000 %% sampling frequency
f1=500;  %% first sinewave freq (in band)
f2=4500; %% second sinnewave freq (out band)

N=3; %% filter order
nb=14; %% number of bits

T=1/500; %% maximum period
tt=0:1/fs:10*T; %% time samples

x1=sin(2*pi*f1*tt); %% first sinewave
x2=sin(2*pi*f2*tt); %% second sinewave

x=(x1+x2)/2; %% input signal

M = dlmread('results_unoptimized.txt'); %Use a better name that M
M2 = 2 * (M - min(M))/(max(M) - min(M)) -1; 
Y = dlmread('results_version_1.txt'); %Use a better name that Y
Y2 = 2 * (Y - min(Y))/(max(Y) - min(Y)) -1; 
X = dlmread('results_version_2.txt'); %Use a better name that X
X2 = 2 * (M - min(M))/(max(M) - min(M)) -1; 
E = dlmread('results_version_3_5-3.txt'); %Use a better name that E
E2 = 2 * (M - min(M))/(max(M) - min(M)) -1; 
F = dlmread('results_version_3_3-2.txt'); %Use a better name that E
F2 = 2 * (M - min(M))/(max(M) - min(M)) -1; 

Error_average_version2 =100 - (sum(Y)/sum(X) * 100);
Error_average_version3_5_3 =100 - (sum(E)/sum(Y) * 100);
Error_average_version3_3_2 =100 - (sum(Y)/sum(F) * 100);

%%average_version2 =immse(X,Y);
%%average_version3 =immse(Y,E);
%% plots
figure
plot(tt,M, 'k--+');
hold on
plot(tt, Y, 'c--o');
hold on
plot(tt, X, 'r--x');
hold on
plot(tt, E, 'b--^');
hold on
plot(tt, F, 'g--');
hold on

legend('unopt', 'ver1', 'ver2', 'ver3 5:3', 'ver3 3:2')
title('IIR filter results comparison')
%% Normalized plots
figure
plot(tt,M2, 'k--+');
hold on
plot(tt, Y2, 'c--o');
hold on
plot(tt, X2, 'r--x');
hold on
plot(tt, E2, 'b--^');
hold on
plot(tt, F2, 'g--');
hold on

legend('unopt', 'ver1', 'ver2', 'ver3 5:3', 'ver3 3:2')