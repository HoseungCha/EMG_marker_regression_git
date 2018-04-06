clear; close all;
% tight subplot ����
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end

% EMG feature �ҷ�����
fname = fullfile(cd,'DB_EMG_feat','EMG_feature.mat');
load(fname);

% ������ �ľ�
[N_sub, N_trl,N_comb ] = size(feat.RMS);
N_ch = size(feat.RMS{1},2);
Name_feat = fieldnames(feat);

% Feat ��ġ��
F = struct2cell(feat);
N_F = length(F);

% �׸����� ������ check
for i_feat = 1 : N_F
for i_sub = 1 : N_sub
    for i_trl = 1 : N_trl
       figure(i_trl);
       p_c = 1;
       for i_comb = 1 : N_comb
           for i_ch = 1 : N_ch
               % data ��������
               temp = F{i_feat}{i_sub,i_trl,i_comb}(:,i_ch);
               subplot(N_comb*N_ch,1,p_c);
               plot(temp)
               p_c = p_c + 1;
           end
       end
       % �׸� ����
       h = gcf;
       h.Position = [1921 41 1920 962];
       c = getframe(h);
       close(h)
       name_img = sprintf('feat_%d_sub_%d_dat_%d.jpg',i_feat,i_sub,i_trl);
       imwrite(c.cdata,fullfile(cd,'DB_EMG_feat',name_img));
    end
end
end