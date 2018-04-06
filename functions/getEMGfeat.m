function [feat,trg] = getEMGfeat(x,winsize,wininc,datawin,dispstatus,temp_trg)

% 파라미터 설정
order_cc = 4;
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

% allocate feature memory
feat = zeros(numwin,4);

if dispstatus
    h = waitbar(0,'Computing Waveform Length features...');
end



% trg_c = 1;[],[]
N_trg = length(temp_trg);
trg = zeros(N_trg,1);
for i_trg = 1 : N_trg
st = 1;
en = winsize;
for i = 1:numwin
   if dispstatus
       waitbar(i/numwin);
   end
   curwin = x(st:en,:).*repmat(datawin,1,Nsignals);
   
   %평균
%    feat(i,:) = mean(curwin,1);

   % RMS 값
   F.RMS = rms(curwin);
%    Nx = length(curwin);
%     nsc = floor(Nx/10);
%     nov = floor(nsc/2);
%     nff = max(2048,2^nextpow2(nsc));
% 
%    F.Spec = spectrogram(curwin(:,3)',hamming(nsc),nov,nff);
   % WL 값
%    F.WL = sum(abs(diff(curwin,2)));
   
   % SampEN
%    for i_ch = 1 : Nsignals
%        r = 0.2*std(curwin(:,i_ch),1); %% Standard deviation 
%        F.Samp(1,i_ch) = FastSampEn(curwin(:,i_ch), 2, r, 1); %SampEn
%    end
   
   % CC
%    cur_xlpc = real(lpc(curwin,order_cc)');
%    cur_xlpc = cur_xlpc(2:(order_cc+1),:);
%    cur_CC = zeros(order_cc,Nsignals);
%    for i_sig = 1 : Nsignals
%       cur_CC(:,i_sig)=a2c(cur_xlpc(:,i_sig),order_cc,order_cc)';
%    end
%    F.CC = reshape(cur_CC,order_cc*Nsignals,1)';
   
   % Feat 합치기
   feat(i,:) = cell2mat(struct2cell(F)');
   
   % Trg가 윈도우에 속할 경우 해당 윈도으를 trg 지점으로 명시
   if (st <= temp_trg(i_trg)) && (temp_trg(i_trg) <= en)
       if(trg(i_trg)==0) % 윈도우가 첫음 걸렸을 때의 동기화만 넣어줌
        trg(i_trg) = i;
       end
%        trg_c = trg_c +1;
   end
   
   st = st + wininc;
   en = en + wininc;
end
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