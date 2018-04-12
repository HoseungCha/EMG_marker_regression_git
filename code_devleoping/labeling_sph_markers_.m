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
Label = cell(N_subject,N_trial);

Num_label = cell(N_marker,1);

% for i_mark = 14
% total.l1=0;
% total.l2=0;
% total.l3=0;
% total.l=0;
for i_sub= 1 : N_subject
    load(fullfile(Name_path,sprintf('sub_%d',i_sub)));
    for i_trl = 1 : N_trial
        N_len = length(emg.d{i_trl, 3}(:,1));
        Label{i_sub,i_trl} = zeros(N_len,N_marker);
        for i_mark = 1 : N_marker
            %             temp = cam.d{i_trl, i_mark}(:,6);
            temp_a = zscore(cam.d{i_trl,i_mark}(:,6));
            temp_b = zscore(emg.d{i_trl, 3}(:,1));
            
            [Outl_m,lower,upper,center] = isoutlier(temp_a);
            Outl_e = isoutlier(temp_b);
            
            % �ΰ� ��� outlier�� �ƴѰ� (��:0) --> Label{i_sub,i_trl,i_mark}ing by 1
%             l1 = ~Outl_m.*~Outl_e*1;
            l1 = ~Outl_m;
            
            % �ΰ� ��� outlier�� ��  --> 2 or 3
            % ��Ŀ ���� upper ���� ���� ��� --> Label{i_sub,i_trl,i_mark}ing by 2
%             l2 = Outl_m.*Outl_e.*(temp_a>upper)*2;
            l2 = Outl_m.*(temp_a>upper)*2;
            % ��Ŀ ���� lower ���� ���� ���--> Label{i_sub,i_trl,i_mark}ing by 3
%             l3 = Outl_m.*Outl_e.*(temp_a<lower)*3;
            l3 = Outl_m.*(temp_a<lower)*3;
            
            Label{i_sub,i_trl}(:,i_mark) =l1+l2+l3;
            if ~isempty(find((l1+l2+l3)==4, 1))
               keyboard; 
            end
        end
        
    end
end
