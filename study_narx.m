load magdata
y = con2seq(y);
u = con2seq(u);

ytr = y(1:3000);
yte = y(3001:end);

utr = u(1:3000);
ute = u(3001:end);

d1 = [1:2];
d2 = [1:2];
narx_net = narxnet(d1,d2,10);
narx_net.divideFcn = '';
narx_net.trainParam.min_grad = 1e-10;
[p,Pi,Ai,t] = preparets(narx_net,utr,{},ytr);

narx_net = train(narx_net,p,t,Pi);

narx_net_closed = closeloop(narx_net);


% y1 = y(1700:2600);
% u1 = u(1700:2600);

[p1,Pi1,Ai1,t1] = preparets(narx_net,ute,{},yte);
yp1 = narx_net(p1,Pi1,Ai1);
TS = size(t1,2);
figure;
plot(1:TS,cell2mat(t1),'b',1:TS,cell2mat(yp1),'r')

[p1,Pi1,Ai1,t1] = preparets(narx_net_closed,ute,{},yte);
yp1 = narx_net_closed(p1,Pi1,Ai1);
TS = size(t1,2);
figure;
plot(1:TS,cell2mat(t1),'b',1:TS,cell2mat(yp1),'r')


close all, clear all, clc
 [ X, T ]              = simplenarx_dataset;
 N                     = length(T)
 neto                  = narxnet;
 [ Xo, Xoi, Aoi, To ]  = preparets( neto, X, {}, T );
 to = cell2mat( To );
 MSE00o                = mean(var(to',1)) % Normalization Reference
 rng('default')                         % Added for reproducibility
 [ neto, tro, Yo, Eo, Xof, Aof ] = train( neto, Xo, To, Xoi, Aoi );
 % [ Yo Xof Aof ] = net(Xo,Xoi,Aoi); Eo  = gsubtract(To,Yo);
 NMSEo = mse(Eo)/MSE00o 
 R2o   = 1 - NMSEo           % Rsquared (see Wikipedia )
 yo = cell2mat(Yo);
 figure(1), hold on
 plot( 3:N, to, 'LineWidth', 2)
 plot( 3:N, yo, 'ro', 'LineWidth', 2)
 legend( ' TARGET ', ' OUTPUT ' )
 title( ' NARXNET EXAMPLE ' )