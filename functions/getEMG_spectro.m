function [window_DB,spect_img] = getEMG_spectro(x,winsize,wininc,datawin,dispstatus)

% 파라미터 설정
if isempty(winsize)
    winsize = size(x,1);
end
if isempty(wininc)
    wininc = winsize;
end
if isempty(datawin)
    datawin = ones(winsize,1);
end
if isempty(datawin)
    dispstatus = 0;
end

datasize = size(x,1);
Nsignals = size(x,2);
numwin = floor((datasize - winsize)/wininc)+1;

% allocate spect_imgure memory
% spect_img = zeros(numwin,4);
window_DB = cell(numwin,1);
spect_img = cell(numwin,1);
if dispstatus
    h = waitbar(0,'Computing Waveform Length spect_imgures...');
end



st = 1;
en = winsize;
for i = 1:numwin
   if dispstatus
       waitbar(i/numwin);
   end
   curwin = x(st:en,:).*repmat(datawin,1,Nsignals);
   

   % spectrum to image (RGB)
   Nx = length(curwin);
    nsc = floor(Nx/5);
    nov = floor(nsc/10*9);
%     nff = max(512,2^nextpow2(nsc));
    nff = 2^nextpow2(nsc);
    ps_ = cell(1,Nsignals);
%    tic
   window_DB{i} = curwin;
   for i_ch = 1 : Nsignals
       [~,~,~,ps] = spectrogram(curwin(:,i_ch)',hamming(nsc),nov,nff,2048);
       ps_{i_ch} = 10*log10(abs(ps)+eps);
   end
   spect_img{i} = mat2im(cell2mat(ps_),parula(numel(ps)));
%    toc;
%    disp(i);
%    imshow(spect_img{i})
   

   
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