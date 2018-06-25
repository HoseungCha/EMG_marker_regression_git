function [window_DB,trg] = getWindows(x,winsize,wininc,datawin,dispstatus,temp_trg)

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

% allocate feature memory
window_DB = cell(numwin,1);
if dispstatus
    h = waitbar(0,'Computing Waveform Length features...');
end



% trg_c = 1;[],[]
if ~isempty(temp_trg)
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
   window_DB{i} = curwin;
   
   % Trg가 윈도우에 속할 경우 해당 윈도으를 trg 지점으로 명시
   if (st <= temp_trg(i_trg)) && (temp_trg(i_trg) <= en)
       if(trg(i_trg)==0) % 윈도우가 첫음 걸렸을 때의 동기화만 넣어줌
        trg(i_trg) = i;
       end
   end
   
   st = st + wininc;
   en = en + wininc;
end
end

else
trg = NaN;
st = 1;
en = winsize;
for i = 1:numwin
   if dispstatus
       waitbar(i/numwin);
   end
   curwin = x(st:en,:).*repmat(datawin,1,Nsignals);
   window_DB{i} = curwin;
   
   st = st + wininc;
   en = en + wininc;
end
end

if dispstatus
    close(h)
end
