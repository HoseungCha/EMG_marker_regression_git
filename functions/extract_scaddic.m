% saccade 추출 함수
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function [ch, bSaccade] = extract_scaddic(ch, bResampling, waveletTh)
    len = size(ch,1);
%     d1 = ch(1:len-1,:);
%     d2 = ch(2:len,:);
%     sq = (d2-d1).^2;
%     dist = sqrt(sq(:,1) + sq(:,2));
    N_ch = size(ch,2);
%     mean_dist = mean(dist);
%     std_dist = std(dist);
%     threshold = mean_dist+ std_dist;
    bSaccade = zeros(len,2);
    
%    wavelet_threshold = 50;
    scales = 20;
    %ch(:,1) = extract_scaddic_channel(ch(:,1),wavelet_threshold, scales);
    %ch(:,2) = extract_scaddic_channel(ch(:,2),wavelet_threshold, scales);
    for i_ch = 1 : N_ch
        [ch(:,i_ch), bSaccade(:,i_ch)] = extract_scaddic_channel(ch(:,i_ch), scales,waveletTh);
    end
%     [ch(:,1), bSaccade(:,1)] = extract_scaddic_channel(ch(:,1), scales,waveletTh);
%     [ch(:,2), bSaccade(:,2)] = extract_scaddic_channel(ch(:,2), scales,waveletTh);
%     [ch(:,3), bSaccade(:,3)] = extract_scaddic_channel(ch(:,3), scales,waveletTh);

%     lv = 8;
%     
%     [C,L] = wavedec(ch(:,1),lv,'haar');
%     ch(:,1) = wrcoef('a',C,L,'haar',lv);
%     [C,L] = wavedec(ch(:,2),lv,'haar');
%     ch(:,2) = wrcoef('a',C,L,'haar',lv);
    
%     if bResampling==1
%         new_ch = zeros(len,2);
%         pos = 1;
%         len2 = size(ch,1);
%         new_ch(pos,:) = ch(1,:);
%         pos = pos+1;
%         for i=2:len2
%             diff = ch(i,:) - new_ch(pos-1,:);
%             sq = diff.^2;
%             dist = sqrt(sq(:,1) + sq(:,2));
%             if dist>threshold
%                 nPoints2Add = round(dist/threshold) - 1;
%                 dxy = diff/(nPoints2Add+1);
%                 for j=1:nPoints2Add
%                     new_ch(pos,:) = ch(i-1,:)+dxy*j;
%                     pos = pos+1;
%                 end
%                 new_ch(pos,:) = ch(i,:);
%                 pos = pos+1;
%             else
%             end
% 
%         end
%         ch = new_ch(1:pos-1,:);
%     end
end

% function pd = extract_scaddic_channel(d,threshold, scales)
%     coefs = cwt(d,scales,'haar');
%     len = length(d);
%     diff = d(2:len,1) - d(1:len-1,1);
%     pd = zeros(len,1);
%     for i=2:len;
%         if i<=len-scales/2 && abs(coefs(i))>threshold
%             pd(i) = pd(i-1) + diff(i-1);
%         else
%             pd(i) = pd(i-1);
%         end
%     end
% end