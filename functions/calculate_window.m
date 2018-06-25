%----------------------------------------------------------------------
% Calculate Window size & Window increase 
%---------------------------------------------------------------------
%
% 입력변수  
% original_sam_rate: 원래 sampling rate 
% convert_sam_rate: 바꾸려고 하는 sampling rate
% overlap: 몇 % overlap 하려는지
% ex) 2048Hz를 10Hz로 50% overlap하려면 2048,10,50 넣으면됨

function [winsize,wininc] = calculate_window(sr_org,sr2convert,overlap,...
    proportion_of_winic_4_winsize)

    if overlap == 0
        wininc = floor(sr_org / ((sr2convert-1)+1));
    else
        wininc = floor(sr_org / ((sr2convert-1) * (100/overlap-1) +1));
    end
    
%     winsize = floor(100 / overlap * wininc);
    winsize = floor(wininc * proportion_of_winic_4_winsize);
    if isnan(winsize)
        wininc = winsize;
    end
end