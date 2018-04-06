% DB_extraction_matin���� ���� Normalized DB(EMG, ��Ŀ) �����ͷ� �׸��� �׸� ��
% �󺧸� �ϴ� �ڵ�, ���� �����ľ� �ڵ�

clear; close all; clc

addpath(genpath(fullfile(cd,'functions')));
% read file path of data
Name_path = fullfile(cd,'DB_norm');

% ���� ����
N_subject = 21;
N_trial = 15;
N_marker = 28;
load(fullfile(cd,'EMG_trigger_ext_code','EMG_trg.mat'),'Trg_name'); % EMG trigger ����
load(fullfile(cd,'MarkerPosition_ext_code','marker_set.mat'),'Labels');

Name_trg = Trg_name; clear Trg_name;
Name_trg(1) = []; % ī�޶� onset �κ��� �����
Name_mark = Labels; clear Labels;
% �Ķ����
% Th_wavlet = 0.2;
% th_percent = 0.2;
Label = cell(N_subject,N_trial,N_marker);

Num_label = cell(N_marker,1);
for i_mark = 1 : N_marker
% for i_mark = 14
    total.l1=0;
    total.l2=0;
    total.l3=0;
    total.l=0;
    for i_sub= 1 : N_subject
        load(fullfile(Name_path,sprintf('sub_%d',i_sub)));
        for i_trl = 1 : N_trial
            
            %             temp = cam.d{i_trl, i_mark}(:,6);
            temp_a = zscore(cam.d{i_trl,i_mark}(:,6));
            temp_b = zscore(emg.d{i_trl, 3}(:,1));
            
            [Outl_m,lower,upper,center] = isoutlier(temp_a);
            Outl_e = isoutlier(temp_b);
            
            % �ΰ� ��� outlier�� �ƴѰ� (��:0) --> Label{i_sub,i_trl,i_mark}ing by 1
            l1 = ~Outl_m.*~Outl_e*1;
            
            % �ΰ� ��� outlier�� ��  --> 2 or 3
            % ��Ŀ ���� upper ���� ���� ��� --> Label{i_sub,i_trl,i_mark}ing by 2
            l2 = Outl_m.*Outl_e.*(temp_a>upper)*2;
            % ��Ŀ ���� lower ���� ���� ���--> Label{i_sub,i_trl,i_mark}ing by 3
            l3 = Outl_m.*Outl_e.*(temp_a<lower)*3;
            Label{i_sub,i_trl}.l =l1+l2+l3;
            
            N_l1 = length(find((l1>0)==1));
            N_l2 = length(find((l2>0)==1));
            N_l3 = length(find((l3>0)==1));
            N_l = length(find(l1+l2+l3>0)==1);
            
            total.l1 = total.l1 + N_l1;
            total.l2 = total.l2 + N_l2;
            total.l3 = total.l3 + N_l3;
            
            total.l = total.l + N_l;
            
            Num_label{i_mark} = total;
            %             figure;
            %             plot(temp_a);hold on;
            %             plot(temp_b); hold on;
            %             plot(Label{i_sub,i_trl,i_mark}.l1+Label{i_sub,i_trl,i_mark}.l2+Label{i_sub,i_trl,i_mark}.l3); hold on;
            %             a = gcf;
            %             a.Position = [-1919 41 1920 962];
            
            
        end
    end
    disp(i_mark);
end

for i=1:length(Num_label)
   l_(i,1) =  Num_label{i}.l1;
   l_(i,2) = Num_label{i}.l2;
   l_(i,3) = Num_label{i}.l3;
end
%


% save('marker_set.mat','marker_set','Label{i_sub,i_trl,i_mark}s','Sname','-v7.3');


