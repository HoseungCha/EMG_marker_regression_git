%% 1. Importing data

S = load('magdata');
X = con2seq(S.u);
T = con2seq(S.y);
%% 2. Data preparation

N = 300; % Multi-step ahead prediction
% Input and target series are divided in two groups of data:
% 1st group: used to train the network
inputSeries  = X(1:end-N);
targetSeries = T(1:end-N);
% 2nd group: this is the new data used for simulation. inputSeriesVal will 
% be used for predicting new targets. targetSeriesVal will be used for
% network validation after prediction
inputSeriesVal  = X(end-N+1:end);
targetSeriesVal = T(end-N+1:end); % This is generally not available
%% 3. Network Architecture

delay = 3;
neuronsHiddenLayer = 10;
% Network Creation
net = narxnet(1:delay,1:delay,neuronsHiddenLayer);
%% 4. Training the network

[Xs,Xi,Ai,Ts] = preparets(net,inputSeries,{},targetSeries); 
net = train(net,Xs,Ts,Xi,Ai);
view(net)
Y = net(Xs,Xi,Ai); 
% Performance for the series-parallel implementation, only 
% one-step-ahead prediction
perf = perform(net,Ts,Y);
%% 5. Multi-step ahead prediction

[Xs1,Xio,Aio] = preparets(net,inputSeries(1:end-delay),{},targetSeries(1:end-delay));
[Y1,Xfo,Afo] = net(Xs1,Xio,Aio);
[netc,Xic,Aic] = closeloop(net,Xfo,Afo);
[yPred,Xfc,Afc] = netc(inputSeriesVal,Xic,Aic);
multiStepPerformance = perform(net,yPred,targetSeriesVal);
view(netc)
figure;
plot([cell2mat(targetSeries),nan(1,N);
      nan(1,length(targetSeries)),cell2mat(yPred);
      nan(1,length(targetSeries)),cell2mat(targetSeriesVal)]')
legend('Original Targets','Network Predictions','Expected Outputs')