 close all, clear all, clc 
 plt=0; 
%  load narxcorr 

 [ X, T ] = simplenarx_dataset; 
 x = zscore(cell2mat(X)); 
 t = zscore(cell2mat(T)); 

 % GEH2: Use the biased zscore format zscore( a,1) 
  
 [ I   N ] = size(x) % 100 
 [ O N ] = size(t) % 100 

 inputDelays = 1:2; 
 feedbackDelays = 1:2; 
 hiddenLayerSize = 10; 

%  net.divideFcn = 'divideblock'; 
  
% GEH3: ERROR: net not defined yet 

 neto = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open'); 
 neto.divideFcn = 'divideblock'; % Inserted to override the default 
 view(neto) 
 [ Xo,Xoi,Aoi,To ] = preparets(neto,X,{},T); 
 to = cell2mat( To ); 
 xo = cell2mat( Xo ); 
 plt = plt+1; figure(plt), hold on 
 plot( 3:N, to, 'LineWidth', 2 ); 
 % 
 rng( 'default' ) 
 [ neto tro Yo Eo Aof Xof ] = train( neto, Xo, To, Xoi, Aoi ); 
 % [ Yo Xof Aof ] = net( Xo, Xoi, Aoi ) 
 % Eo = gsubtract( To, Yo ) 
 view( neto ); 
 NMSEo = mse( Eo ) /var( to,1 ) %  2.0326e-09 
 yo = cell2mat( Yo ); 
 plot( 3:N, yo, 'ro', 'LineWidth', 2 ); 
 % axis( [ 0 102 0 1.3 ] ) 
 legend( 'TARGET', 'OUTPUT' ) 
 title( 'OPENLOOP NARXNET RESULTS' ) 
 % 
 % 7. Now, the output feedback loop is closed and tested so that predictions can 
 % eventually be extended beyond the time of the known target, T. 

  [ netc Xci Aci ] = closeloop(neto,Xoi,Aoi); 
  view(netc); 
  [Xc,Xci,Aci,Tc] = preparets(netc,X,{},T); 
  [ Yc Xcf Acf ] = netc(Xc,Xci,Aci); 
  Ec = gsubtract(Tc,Yc); 
  yc = cell2mat(Yc); 
  tc = to; 
  NMSEc = mse(Ec) /var(tc,1) %  2.2583e-09 

 % To extend the prediction beyond the end of the known series, empty cells are 
 % used as inputs and the final delay states Xcf and Acf are used as initial conditions. and are used 
  
  % [ Yc Xcf Acf ] = netc( Xc, Xci, Aci ); 
   Xc2 = cell(1,98); 

% GEH4: ERROR 

   Xc2 = cell(0,N); 
    
   [ Yc2, Xcf2, Acf2 ] = netc( Xc2, Xcf, Acf ); 
   yc2 = cell2mat(Yc2); 
    
 plt = plt+1; figure(plt), hold on 
 plot( 3:N, tc, 'LineWidth', 2 ) 
 plot( 3:N, yc, 'ro', 'LineWidth', 2 ) 
 plot( N+1:2*N, yc2, 'g--', 'LineWidth', 2 ) 
 plot( N+1:2*N, yc2, 'ko', 'LineWidth', 2 ) 
 % axis( [ 0 2*N+2 0 1.3 ] ) 
 legend( 'TARGET', 'OUTPUT' , 'TARGETLESS PREDICTION') 
 title( 'CLOSED LOOP NARXNET RESULTS' ) 