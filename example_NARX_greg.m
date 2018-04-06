% 1. I don't recommend using ntstool for complicated problems until you are more experienced. The command line script it generates offers so many options that it  obscures the most important choices. The alternative is to first use the abbreviated scripts in the help and doc documentation that take advantage of default options and use MATLAB example data that can be obtained from the help and doc commands 
%   
%  help nndatasets 
%  doc nndatasets 
%   
%  This will not only prepare you better with basics, it will make it  easier for us to 
%  help if you have difficulties. 
%   
%  2. When you only have one series, the appropriate function to use is NARNET. First obtain and compare the documentation and simple code examples obtained from the commands 
%   
%  help narnet 
%  doc narnet 
%   
%  Second, notice that different notation is used. I prefer the notation in doc narnet  because it does not use lower case for cell variables. However, instead of using  the "s" subscript to indicate variables used in the open loop "s"eries. I prefer to  use the more obvious notations "o"  and OL for open loop along with "c" and CL  for closed loop. 
%   
%  Third, the explanation in doc ERRONEOUSLY states that 0 is an allowable 
%  output feedback delay. IT IS NOT! In particular: 
%   
%  It is only allowable in the OL configuration because the program considers it as  an external input. However, it is not allowable in the CL configuration. So, I see  no good reason for using it. 
%   
%  3. The examples use the default datadivison option DIVIDERAND which creates random nonuniform timesteps within the training, validation and test subsets. This is great for regression and classification. For timeseries prediction, however, it can be DISASTEROUS! 
%   
%  There are a variety of ways to obtain uniform timesteps within the subsets using other datadivision options. I favor DIVIDEBLOCK which yields the indexing 
%   
%           [ 1:Ntrn, Ntrn+1:Ntrn+Nval, Ntrn+Nval+1:N]   
%     
%  where N = Ntrn+Nval+Ntst. The default percentages are 0.7/0.15/0.15. 
%   
%  4. The example in doc yields a scale dependent value for the performance 
%  which is repeatable only if the initial state of the random number generator is 
%  known. 
%   
%  5. I prefer the following version that 
%   (a) Explicitly shows 
%         i. The size of the input and target matrices 
%         ii. The min and max values of input and target 
%         iii. The corresponding min and max values of the standardized 
%              (i.e., zero-mean/unit-variance) values for outlier detection 
%         iv.The average target variance that will be used as the reference 
%             mean-square-error 
%  (b) Shows the most general form of the syntax on the LHS of training and 
%        output equations. However, some may not be valid for versions older 
%        than R2014a. 
%  (c) Specifies the initial random number state so that the example can be 
%       duplicated exactly 
%  (d) Uses a scale independent normalization for the mean-square-error 
%        performance value that indicates the fraction of the target variance that is 
%        not modelled by the net. 
%  6. Before using your own data, it is STRONGLY RECOMMENDED to practice 
%       on MATLAB example data obtained from 
%       
%       help nndatasets 
%       doc nndatasets 
% 
% That will make it easier for us to help if you have problems. 
% 7. Finally, the example below assumes that the default feedback delay (FD) and number of hidden node (H) parameters are sufficient. In general, they will not be. My approach to this difficulty is 
%    a. Choose FD from a subset of the delays corresponding to statistically 
%        significant values of the target autocorrelation function (e.g., NNCORR). 
%    b. Given a trial value of FD, use a double for-loop search 
% 
%         for h = Hmin:dH:Hmax % Number of hidden nodes 
%              ... 
%             for i = 1:Ntrials          % Random initial weights 
%             ... 
%             end 
%         end 
%    c. Many examples of this approach have been posted in the NEWSGROUP 
%    and ANSWERS. Include the name of the correlation function NNCORR as 
%    a search word. 

 close all, clear all, clc , plt = 0; 
 T = simplenar_dataset; 
 [ I N ] =  size(T)              % [ 1 100 ] 
 d = 2, FD = 1:d; H = 10   % MATLAB defaults 
 neto                 = narnet( FD, H ); 
 neto.divideFcn = 'divideblock'; 
 view(neto) 
 [ Xo, Xoi, Aoi, To ] = preparets( neto, {}, {}, T ); 
 to = cell2mat( To );  zto = zscore(to,1); 
 varto1 = mean(var(to',1))  % 0.061307 
 minmaxto = minmax([ to ; zto ]) 
 %minmaxto =   0.23911      0.99991 
 %                    -1.9763       1.0963 
%No outliers 

 plt = plt+1; figure(plt), hold on 
 plot( d+1:N, to, 'LineWidth', 2 ) 

 rng( 'default' ) 
 [ neto tro Yo Eo Aof Xof ] = train( neto, Xo, To, Xoi, Aoi ); 
 [ Yo Xof Aof ] = neto( Xo, Xoi, Aoi ) 
 Eo = gsubtract( To, Yo ) 
 view( neto ) 
 NMSEo = mse( Eo ) /varto1 % 6.6721e-09 

%  tro = tro    % No semicolon. Reveals the OL training record 

 yo = cell2mat( Yo ); 
 plot( d+1:N, yo, 'ro', 'LineWidth', 2 ) 
 axis( [ 0 102 0 1.3 ] ) 
 legend( 'TARGET', 'OUTPUT' ) 
 title( 'OPENLOOP NARNET RESULTS' ) 
% 
%  7. Now, the output feedback loop is closed and tested so that predictions can 
%  eventually be extended beyond the time of the known target, T. 

  [ netc Xci Aci ] = closeloop( neto, Xoi, Aoi ); 
  view( netc ) 
  [ Xc, Xci, Aci, Tc ] = preparets( netc, {}, {}, T ); 
   isequal( Tc, To ) ,  tc = to ;           % 1 
  [ Yc Xcf Acf ] = netc( Xc, Xci, Aci ); 
  Ec = gsubtract( Tc, Yc ); 
  yc = cell2mat( Yc ); 
  NMSEc = mse(Ec) /var(tc,1) %3.2807e-07 

%  Although the performance is a factor of 50 worse, it is still excellent. If it were 
%  significantly degraded (e.g., below ~ 0.005), netc would be trained starting with the weights obtained in the openloop stage (NOTE: This is not mentioned in either the help or doc documentation). 
%   
%  8. The removedelay function is included in both documentations. However, I 
%  see no good reason for using it here. For example, when used with the default output feedback delay 1:2, it yields invalid zero and/or negative values. 
%   
%  IS THIS A BUG THAT NEEDS TO BE FIXED ? 
%   
%  9. To extend the prediction beyond the end of the known series, empty cells are used as inputs and the final delay states Xcf and Acf are used as initial conditions. 
  
  [ Yc Xcf Acf ] = netc( Xc, Xci, Aci ); 
   Xc2 = cell(1,N); 
   [ Yc2 Xcf2 Acf2 ] = netc( Xc2, Xcf, Acf ); 
   yc2 = cell2mat(Yc2); 
    
 plt = plt+1; figure(plt), hold on 
 plot( d+1:N, tc, 'LineWidth', 2 ) 
 plot( d+1:N, yc, 'o', 'LineWidth', 2 ) 
 plot( N+1:2*N, yc2, 'ro', 'LineWidth', 2 ) 
 plot( N+1:2*N, yc2, 'r', 'LineWidth', 2 ) 
 axis( [ 0 2*N+2 0 1.3 ] ) 
 legend( 'TARGET', 'OUTPUT' , 'TARGETLESS PREDICTION') 
 title( 'CLOSED LOOP NARNET RESULTS' ) 