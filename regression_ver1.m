clear; close all;
% tight subplot ����
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end

% EMG feature �ҷ�����
fname = fullfile(pwd,'DB_EMG_feat','EMG_feature.mat');
load(fname);

% ������ �ľ�
[N_sub, N_trl,N_comb ] = size(feat.RMS);
N_ch = size(feat.RMS{1},2);
Name_feat = fieldnames(feat);
N_marker = 28;
% Feat ��ġ��
F = struct2cell(feat);
N_F = length(F);

% ������ ���� ���ҵ� ��Ŀ ������ �ٽ� ��ġ��
mark_n = cell(N_sub, N_trl, N_marker);
for i_sub = 1 : N_sub
    load(fullfile(pwd,'DB_mark_norm',sprintf('sub_%d',i_sub)));
    mark_n(i_sub,:,:) = mark_norm;
end

% GRNN regression
% �м�1: �켱 ���� �����ڳ����� �׽�Ʈ
for i_mark = 1
for i_feat = 1
for i_comb = 1    
for i_sub = 1 : N_sub
   temp = F{i_feat}(i_sub,:,i_comb);
   temp(:)
   
   temp2 = mark_n(i_sub,:,i_mark)
   temp2(:)
   
    
    
    
end
end
end
end