%----------------------------------------------------------------------
% Calculate Window size & Window increase 
%---------------------------------------------------------------------
%
% �Էº���  
% original_sam_rate: ���� sampling rate 
% convert_sam_rate: �ٲٷ��� �ϴ� sampling rate
% overlap: �� % overlap �Ϸ�����
% ex) 2048Hz�� 10Hz�� 50% overlap�Ϸ��� 2048,10,50 �������

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