clear; close all;
% tight subplot 적용
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end

% EMG feature 불러오기
fname = fullfile(cd,'DB_EMG_feat','EMG_feature.mat');
load(fname);

% 데이터 파악
[N_sub, N_trl,N_comb ] = size(feat.RMS);
N_ch = size(feat.RMS{1},2);
Name_feat = fieldnames(feat);

% Feat 합치기
F = struct2cell(feat);
N_F = length(F);

% 그림으로 데이터 check
for i_feat = 1 : N_F
for i_sub = 1 : N_sub
    for i_trl = 1 : N_trl
       figure(i_trl);
       p_c = 1;
       for i_comb = 1 : N_comb
           for i_ch = 1 : N_ch
               % data 가져오기
               temp = F{i_feat}{i_sub,i_trl,i_comb}(:,i_ch);
               subplot(N_comb*N_ch,1,p_c);
               plot(temp)
               p_c = p_c + 1;
           end
       end
       % 그림 설정
       h = gcf;
       h.Position = [1921 41 1920 962];
       c = getframe(h);
       close(h)
       name_img = sprintf('feat_%d_sub_%d_dat_%d.jpg',i_feat,i_sub,i_trl);
       imwrite(c.cdata,fullfile(cd,'DB_EMG_feat',name_img));
    end
end
end