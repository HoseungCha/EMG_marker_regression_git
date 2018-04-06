function feat = getmovfilter(x,winsize,wininc,datawin,dispstatus)
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

% allocate memory
feat = zeros(numwin,Nsignals);

if dispstatus
    h = waitbar(0,'Computing Waveform Length features...');
end



% trg_c = 1;[],[]
% N_trg = length(temp_trg);
% trg = zeros(N_trg,1);
% for i_trg = 1 : N_trg
st = 1;
en = winsize;
for i = 1:numwin
   if dispstatus
       waitbar(i/numwin);
   end
   curwin = x(st:en,:).*repmat(datawin,1,Nsignals);
   feat(i,:) = mean(curwin,1);
%    feat(i,:) = sum(abs(diff(curwin,2)));
   
%    if (st <= temp_trg(i_trg)) && (temp_trg(i_trg) <= en)
%        if(trg(i_trg)==0) % 윈도우가 첫음 걸렸을 때의 동기화만 넣어줌
%             trg(i_trg) = i;
%        end
% %        trg_c = trg_c +1;
%    end
   
   
   st = st + wininc;
   en = en + wininc;
end
% end

if dispstatus
    close(h)
end