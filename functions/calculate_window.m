%----------------------------------------------------------------------
% Calculate Window size & Window increase 
%---------------------------------------------------------------------
%
% 입력변수  
% original_sam_rate: 원래 sampling rate 
% convert_sam_rate: 바꾸려고 하는 sampling rate
% overlap: 몇 % overlap 하려는지
% ex) 2048Hz를 10Hz로 50% overlap하려면 2048,10,50 넣으면됨

function [winsize,wininc] = calculate_window (original_sam_rate,convert_sam_rate, overlap)

    wininc = floor(original_sam_rate / ((convert_sam_rate-1) * (100/overlap-1) +1));
    winsize = floor(100 / overlap * wininc);

end