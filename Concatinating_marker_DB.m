% �� ������,Trial ���� �Ǿ��ִ� ��Ŀ���� ��ġ�� �ڵ�
clc; close all; clear ;
% ���� ����
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};
N_sub = 21;
N_trl = 15;
N_mark = 28;    
N_trg = 26;
%trigger path
path_trg = fullfile(cd,'DB_v2','trg_win_10Hz');
%baseline range
load(fullfile(cd,'DB_v2','basline_of_markers'));
% load('E:\OneDrive - �Ѿ���б�\����\EMG_maker_regression\�ڵ�\DB_v2\emg_feat_set_10Hz\EMG_feat_znormalized.mat')

for i_mark = 1 : N_mark
%     path_emg = fullfile(cd,'DB_v2','emg_win',sprintf('comb_%d',i_comb));
    path_mark = fullfile(cd,'DB_v2','mark_win_10Hz_Time Alignment',sprintf('mark_%d',i_mark));
    marker_set = cell(N_sub,N_trl);
    for i_sub = 1 : N_sub
        for i_trl = 1 : N_trl
            % window�� ���е� ������ �ҷ�����
            fname = sprintf('sub_%03d_trl_%03d_raw',i_sub,i_trl);
            
            % ��Ŀ �ҷ�����
            load(fullfile(path_mark,fname));
            
            % Ʈ���� �ҷ�����
            fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            load(fullfile(path_trg,fname));
            len_win = trg_w(27); % �߶���� ������ ������ ���
            
            mark_median = zeros(len_win,6);
%             mark_mean = zeros(len_win,6);
            for i_win = 1 : len_win
                mark_median(i_win,:)= median(mark_win{i_win},1);
%                 mark_mean(i_win,:)= mean(mark_win{i_win},1);
            end

            % polyfit
            mark_fit = zeros(len_win,6);
            for i_markType = 1 : 6
                p = polyfit(1:len_win,mark_median(:,i_markType)',3); % 3�� polyfit
                mark_fit(:,i_markType) = polyval(p,1:len_win);
            end
            
            mark_base_corr = mark_median - mark_fit;
            
            % zscore normaliztion
%             mark_n = zscore(mark_base_corr);
            
            % Calibration session���� Nomalization
            Max = max(mark_base_corr(1 : trg_w(6),:));
            Min = min(mark_base_corr(1 : trg_w(6),:));
            mark_n = (mark_base_corr-Min)./(Max-Min);
%             mark_n = (mark_base_corr-Min)./(Max-Min);

%             mark_n(mark_n>1) = 1;
%             mark_n(mark_n<0) = 0;

%             
%             up_cut = baseline_range(:,i_mark)/2;
%             dow_cut = -1*baseline_range(:,i_mark)/2;
%             
%             for i_markType = 6
%                 temp_data = mark_base_corr(:,i_markType);
%                 
%                 idx_up = temp_data>up_cut(i_markType)==1;
%                 idx_down =temp_data<dow_cut(i_markType)==1;
%                 idx_neutral = 1* ~(idx_up+idx_down);
% %                 figure;
% %                 plot(zscore(temp_data))
% %                 hold on;
% %                 plot(idx_up);
% %                 plot((-1)*idx_down)
% %                 plot((0.5)*~(idx_up+idx_down))
%             end
%             mark_base_corr(logical(idx_neutral),:) = 0;
%             mark_n = mark_base_corr;
%             hold on
%             plot(feat{i_sub, i_trl}(:,1))


%               [Outl_m,lower,upper,center] = isoutlier(mark_base_corr);
%             
%             % �ΰ� ��� outlier�� �ƴѰ� (��:0) --> Label{i_sub,i_trl,i_mark}ing by 1
% %             l1 = ~Outl_m.*~Outl_e*1;
%             l1 = ~Outl_m;
%             l2 = Outl_m.*(mark_base_corr>upper)*2;
%             % ��Ŀ ���� lower ���� ���� ���--> Label{i_sub,i_trl,i_mark}ing by 3
% %             l3 = Outl_m.*Outl_e.*(temp_a<lower)*3;
%             l3 = Outl_m.*(mark_base_corr<lower)*3;
%             figure;
%             plot(mark_base_corr(:,6))
%             hold on;
%             plot(l2(:,6));
%             hold on;
%             plot(l3(:,6));
              
            
            % ����
            marker_set{i_sub,i_trl} = mark_n;
            
        end
    end
    disp([i_mark]);
    fname = sprintf('mark_%d',i_mark); %���� �̸� ����
    fname_path = fullfile(cd,'DB_v2','DB_markset_10Hz_basecorr_znorm',fname);
    save(fname_path,'marker_set');
end


% �� ������,Trial ���� �Ǿ��ִ� ��Ŀ���� ��ġ�� �ڵ�
% clc; close all; clear ;
% % ���� ����
% N_sub = 21;
% N_trl = 15;
% N_mark = 28;    
% 
% path_mark = fullfile(cd,'DB_v2','mark_nose_10Hz');
% path_trg = fullfile(cd,'DB_v2','trg_win_10Hz');
% marker_set_nose = cell(N_sub,N_trl);
% for i_sub = 1 : N_sub
%     for i_trl = 1 : N_trl
%         % window�� ���е� ������ �ҷ�����
%         fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
%         load(fullfile(path_mark,fname));
%         load(fullfile(path_trg,fname));
%         marker_set_nose{i_sub,i_trl} = mark_nose_w(1:trg_w(27),:);
%         disp([i_sub,i_trl]);
%     end
% end
