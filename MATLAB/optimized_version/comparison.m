fs=10000 %% sampling frequency
f1=500;  %% first sinewave freq (in band)
f2=4500; %% second sinnewave freq (out band)


T=1/500; %% maximum period
tt=0:1/fs:10*T; %% time samples

x1=sin(2*pi*f1*tt); %% first sinewave
x2=sin(2*pi*f2*tt); %% second sinewave

x=(x1+x2)/2; %% input signal

Y = dlmread('results_optimized.txt');
Y2 = 2 * (Y - min(Y))/(max(Y) - min(Y)) -1; 
M = dlmread('results_unoptimized.txt'); 
M2 = 2 * (M - min(M))/(max(M) - min(M)) -1; 

%% plots
figure
plot(tt,M2, 'r--+');
hold on
plot(tt, Y2, 'c--o');
hold on

legend('opt', 'unopt')
hold off