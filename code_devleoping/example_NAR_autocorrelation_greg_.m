close all, clear all, clc, plt=0
T = simplenar_dataset;
t = cell2mat(T);
[ O N ] = size(t) % [ 1 100 ]
MSE00 = var(t',1) % 0.0633
zt = zscore(t',1)';

plt=plt+1,figure(plt)
subplot(211)
plot(t)
title('SIMPLENAR SERIES')
subplot(212)
plot(zt)
title('STANDARDIZED SERIES')

rng('default')
n = randn(1,N);
L = floor(0.95*(2*N-1)) % 189
for i = 1:100
autocorrn = nncorr( n,n, N-1, 'biased');
sortabsautocorrn = sort(abs(autocorrn));
thresh95(i) = sortabsautocorrn(L);
end
sigthresh95 = mean(thresh95) % 0.2194

autocorrt = nncorr(zt,zt,N-1,'biased');
siglag95 = -1+ find(abs(autocorrt(N:2*N-1))>=sigthresh95)
% [ 0 1 2 3 4 5 7 8 9 10 12 13 14
% 15 17 18 19 20 22 23 24 25 27 28 29 30
% 32 33 34 35 37 38 39 40 42 44 45 47 49
% 50 52 54 55 57 59 62 64 67 69 72 74 ]

plt = plt+1, figure(plt)
hold on
plot(0:N-1, -sigthresh95*ones(1,N),'b--')
plot(0:N-1, zeros(1,N),'k')
plot(0:N-1, sigthresh95*ones(1,N),'b--')
plot(0:N-1, autocorrt(N:2*N-1))
plot(siglag95,autocorrt(N+siglag95),'ro')
title('SIGNIFICANT SIMPLENAR AUTOCORRELATIONS')

% For NARNET choose an adequate positive subset of siglag95
net = narnet(1:2,10); % default
[Xo,Xoi,Aoi,To] = preparets(net,{},{},T);
[ net tr Yo Eo Xof Aof] = train(net,Xo,To,Xoi,Aoi);
view(net)
% Yo = net(Xo,Xoi,Aoi);
% Eo = gsubtract(To,Yo);
NMSEo = mse(Eo)/MSE00 % NMSEo = 1.151e-8

to = cell2mat(To);
yo = cell2mat(Yo);
plt = plt+1, figure(plt)
hold on
plot(3:N, to, 'bo')
plot(3:N, yo, 'r.')
legend('target','output')
axis([ -1 101 0 1.25 ])
title('SIMPLENAR SERIES MODEL')

% P.S. Find the significant AUTO and CROSSCORRELATION delays of the SIMPLESERIES_DATASET for use with NARXNET