% This open loop thread is a reply to an example posted in 
% Subject: NARNET TUTORIAL ON MULTISTEP AHEAD PREDICTIONS 
% Message: 28 From: srikanta mohapatra % Date: 17 Jun, 2015 05:46:56 
% The purpose is to get a suffiently large Rsquared = 1-NMSEo (e.g. 
% 0.995) so that the closed loop configuration is adequate for post-target 
% prediction 

close all, clear all, clc , plt = 0 
tic 
t = [182 325 390 480 519 620 630 609 635 700 660 615 561.15 534 ... 
    589.9 703.45 651.02 674.62 661.42 652.66 646.34 642.4 664.34 ... 
    660.03  683.11 664.66 688.61 697.53 693.71 680.43 751.3 ]; 
T             = con2seq(t); 
[ O N ]    =  size(t)                  % [ 1 31 ] 
minmaxt = minmax(t)             %  182   751.3 
MSE00   = mean(var(t',1))      % 14169 
MSE00a = mean(var(t',0))      % 14641 
zt             = zscore(t',1)'; 
ZT           = con2seq(zt); 
minmaxzt = minmax(zt)          % [ -3.5836  1.1991] 
MSE00z   = mean(var(zt',1))   % 1 
MSE00za = mean(var(zt',0))   % 1.0333 

plt= plt+1, figure(plt) 
subplot(2,1,1) 
plot(t,'LineWidth',2) 
title('ORIGINAL SERIES') 
subplot(2,1,2) 
plot(zt,'LineWidth',2) 
title('STANDARDIZED SERIES') 

L         = floor(0.95*(2*N-1))  % 57 
rng('default') 
for i = 1:100 
    zn                       = zscore(randn(1,N)); 
    autocorrn            = nncorr(zn,zn,N-1,'biased'); 
    sortabsautocorrn = sort(abs(autocorrn)); 
    thresh95(i)          =  sortabsautocorrn(L); 
end 
minthresh95     = min(thresh95)       % 0.15362 
medthresh95    = median(thresh95) % 0.23702 
meanthresh95  = mean(thresh95)    % 0.2416 
stdthresh95      = std(thresh95)        % 0.048045 
maxthresh95    = max(thresh95)       % 0.44397 

autocorrt = nncorr( zt, zt, N-1,'biased'); 
sigthresh = find(abs(autocorrt(N+1:2*N-1))>=meanthresh95) 
% sigthresh =  1     2     3 

plt = plt+1,figure(plt) 
hold on 
plot(-meanthresh95*ones(1,N), 'k--','LineWidth',2) 
plot(zeros(1,N), 'k','LineWidth',2) 
plot(meanthresh95*ones(1,N), 'k--','LineWidth',2) 
plot(0:N-1, autocorrt(N:end),'-o','LineWidth',2) 
plot(1:3, autocorrt(N+sigthresh),'ro','LineWidth',2) 

FD       = sigthresh                  % 1:3 
NFD    = numel(FD)                 % 3 
Ntrn     = N-2*round(0.15*N)    % 21 %default 
Ntrneq = Ntrn*O                      % 21 No. of training equations 
% Nw = (NFD*O+1)*H+(H+1)*O  No. of unknown weights 
% Ntrneq >= Nw <==> H <= Hub  unknowns don't outnumber equations 
Hub = floor((Ntrneq-O)/(NFD*O+O+1))  % 4 

% The dataset is very small. For serious work should consider 
% 1. More data 2. Cross Validation w/wo TRAINBR 

% For the purpose of illustration, I will only consider 
% DIVIDETRAIN (No data division) w TRAIN 

Ntrn     = N                            % 31 
Ntrneq = Ntrn*O                    % 31 

Hub = floor((Ntrneq-O)/(NFD*O+O+1))  % 6 
Hmax  = 10  % 6 is sufficient to get R2=0.995 
dH      =1 
Hmin   = 0 
Ntrials = 10 

rng('default') 
j=0 
for h = Hmin:dH:Hmax 
    j=j+1 
    if h==0 
        neto = narnet(FD,[]); 
        Nw =  (NFD*O+1)*O 
    else 
        neto = narnet(FD,h); 
        Nw = (NFD*O+1)*h+(h+1)*O 
    end 
    Ndof                  = Ntrneq-Nw    % Ndof <=0 for H >= 6 
    neto.divideFcn   = 'dividetrain';  % No data division 
    [Xo Xoi Aoi To ]  = preparets(neto,{},{},ZT); 
    to             = cell2mat(To); 
    MSE00o   = var(to,1) 
    MSE00oa = var(to,0) 
    MSEgoal = 0.005*max(Ndof,0)*MSE00oa/Ntrneq 
    MinGrad  = MSEgoal/100 
    neto.trainParam.goal        = MSEgoal; 
    neto.trainParam.min_grad = MinGrad; 
    
    for i= 1:Ntrials 
        % Save state of RNG for duplication 
        s(i)                                = rng; 
        neto                               = configure(neto,Xo,To); 
        [neto tro Yo Eo Xof Aof ] = train(neto,Xo, To, Xoi, Aoi); 
        %         [neto tro  ]                      = trainbr(neto,Xo, To, Xoi, Aoi); 
        %         [ Yo Xof Aof ]                  = neto(Xo,Xoi,Aoi); 
        %         Eo                                  = gsubtract(To,Yo); 
        stopcrit{i,j} = tro.stop; 
        R2o(i,j)      = 1 - mse(Eo)/MSE00o; 
    end 
end 
result           =    [  (Hmin:dH:Hmax); R2o ] 
stopcrit         = stopcrit 
elapsedtime = toc   %  298.9 

% Summary of stopping criteria 
% H    'MinGrad   'Max epoch ' 'Max MU ' 
% 0-2      10 
% 3-4        7               3 
% 5           4               6 
% 6                            9                   1 
% 7                            2                    8 
% 8-10                                            10 
% 
% Summary of R^2 = 
%            0                1                 2                3                4               5 
%       0.62935      0.67502      0.81827      0.85291      0.92785      0.98435 
%       0.62935      0.67502      0.74254      0.85291      0.93345      0.99105 
%       0.62935      0.67502      0.81827      0.90668      0.93583      0.99113 
%       0.62935      0.67502      0.74257      0.88463      0.95079      0.96973 
%       0.62935      0.67502      0.73346      0.90668      0.95775      0.97432 
%       0.62935      0.67502      0.74264      0.93923      0.94946      0.98478 
%       0.62935      0.67502      0.80457      0.84294      0.93938      0.97298 
%       0.62935      0.67502       0.7886      0.89535      0.94479      0.98478 
%       0.62935      0.67502      0.81827      0.90668      0.94156      0.98775 
%       0.62935      0.71052      0.73346      0.90668       0.9293      0.98157 
% 
%             6                7            8            9           10 
%       *0.9998            1            1            1            1 
%        0.9881      0.99564        1            1            1 
%        0.98939            1            1            1            1 
%        0.99351            1            1            1            1 
%        0.98955            1            1            1            1 
%       *0.99998            1            1            1            1 
%       *0.99953            1            1            1            1 
%       *0.99741            1            1            1            1 
%        0.98631            1            1            1            1 
%       *      1                1           1            1            1 