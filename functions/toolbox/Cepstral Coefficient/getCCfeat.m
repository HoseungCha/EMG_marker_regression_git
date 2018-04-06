%
% GETARFEAT Gets the AR feature (autoregressive).
%
% feat = getarfeat(x,order,winsize,wininc,datawin,dispstatus)
%
% Author Adrian Chan
%
% This function computes the AR feature of the signals in x,
% which are stored in columns.
%
% The signals in x are divided into multiple windows of size
% winsize and the windows are space wininc apart.
%
% AR model determined using the Levinson-Durbin algorithm.
%
% Inputs
%    x: 		columns of signals
%    order:     order of AR model
%    winsize:	window size (length of x)
%    wininc:	spacing of the windows (winsize)
%    datawin:   window for data (e.g. Hamming, default rectangular)
%               must have dimensions of (winsize,1)
%    dispstatus:zero for no waitbar (default)
%
% Outputs
%    feat:     AR value in a 2 dimensional matrix
%              dim1 window
%              dim2 feature
%                   (AR coefficients from the next signal is to the right of the previous signal)
%
% Modifications
% 05/01/14 AC Change feat output so that dim1 is window and dim2 is feature
% 06/06/23 AC First created.
% combined with computation of cepstral coefficent by Ho-Seung Cha PhD student in Hanyang
% Univ. hoseungcha@gmail.com

function CC = getCCfeat(x,order,winsize,wininc,datawin,dispstatus)

if nargin < 6
    if nargin < 5
        if nargin < 4
            if nargin < 3
                winsize = size(x,1);
            end
            wininc = winsize;
        end
        datawin = ones(winsize,1);
    end
    dispstatus = 0;
end

datasize = size(x,1);
Nsignals = size(x,2);
numwin = floor((datasize - winsize)/wininc)+1;

% allocate memory
CC = zeros(numwin,Nsignals*order);

if dispstatus
    h = waitbar(0,'Computing AR features...');
end

st = 1;
en = winsize;

for i = 1:numwin
   if dispstatus
       waitbar(i/numwin);
   end
   curwin = x(st:en,:).*repmat(datawin,1,Nsignals);

   cur_xlpc = real(lpc(curwin,order)');
   cur_xlpc = cur_xlpc(2:(order+1),:);
   cur_CC = zeros(order,Nsignals);
   for i_sig = 1 : Nsignals
      cur_CC(:,i_sig)=a2c(cur_xlpc(:,i_sig),order,order)';
   end
   CC(i,:) = reshape(cur_CC,order*Nsignals,1)';
   
   st = st + wininc;
   en = en + wininc;
end

if dispstatus
    close(h)
end

function c=a2c(a,p,cp)
%Function A2C: Computation of cepstral coeficients from AR coeficients.
%
%Usage: c=a2c(a,p,cp);
%   a   - vector of AR coefficients ( without a[0] = 1 )
%   p   - order of AR  model ( number of coefficients without a[0] )
%   c   - vector of cepstral coefficients (without c[0] )
%   cp  - order of cepstral model ( number of coefficients without c[0] )

%                              Made by PP
%                             CVUT FEL K331
%                           Last change 11-02-99

for n=1:cp,

  sum=0;

  if n<p+1,
    for k=1:n-1,
      sum=sum+(n-k)*c(n-k)*a(k);
    end;
    c(n)=-a(n)-sum/n;
  else
    for k=1:p,
      sum=sum+(n-k)*c(n-k)*a(k);
    end;
    c(n)=-sum/n;
  end;

end;