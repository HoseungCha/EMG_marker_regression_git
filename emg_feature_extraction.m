clc; clear all; close all;
addpath(genpath(fullfile(cd,'functions')));

%% EMG Data Read
load('EMG_Data_15people(4-18).mat')

%% EMG Trigger Read
load('EMG_trigger_15people(4-18).mat')

%% ���� ����
para.N_trial = 15; %% ���� Ƚ��
para.N_sub = 13; %% ������ ��
para.N_comb = 3; %% ���� ���ռ�
para.N_bi_channel = 4; %% bipolar ���� ����
para.rc_matrix = [1,2;1,3;2,3]; %% ������ ���� ����  
para.lc_matrix = [10,9;10,8;9,8]; %% ���� ���� ����
para.original_sam_rate=2048; %% ���� ���ø� rate
para.convert_sam_rate=10; %% �ٲٷ��� ���ø� rate
para.overlap=50; %% ������ 
cd.Right_Frontalis = [];
cd.Left_Frontalis = [];
cd.Left_Zygomaticus = [];
cd.Right_Zygomaticus = [];

%% Bandpassfilter Parameters
fp.SF2use = 2048;
fp.Fn = fp.SF2use/2;
fp.filter_order = 4;
fp.BPF_cutoff_Freq = [20 450];
[fp.bB,fp.bA] = butter(fp.filter_order, fp.BPF_cutoff_Freq/fp.Fn,'bandpass');

%% Notchfilter Parameters
fp.NOF_Freq = [59.5 60.5];
[fp.nB, fp.nA] = butter(fp.filter_order, fp.NOF_Freq/fp.Fn, 'stop');

for i_comb = 1:para.N_comb %% ���� ���� ����� ��
    
    for i_sub = 1:para.N_sub %% ������ ��
        
        for i_trial = 1:para.N_trial %% ���� Ƚ��
            
            da.raw_emg_data = emg_data{i_sub,i_trial};
            
            %% Bipolar ������ ���
            cd.Right_Zygomaticus = da.raw_emg_data(para.rc_matrix(i_comb,1),:) - da.raw_emg_data(para.rc_matrix(i_comb,2),:); 
            cd.Right_Frontalis = da.raw_emg_data(4,:) - da.raw_emg_data(5,:);
            cd.Left_Frontalis = da.raw_emg_data(6,:) - da.raw_emg_data(7,:);
            cd.Left_Zygomaticus = da.raw_emg_data(para.lc_matrix(i_comb,1),:) - da.raw_emg_data(para.lc_matrix(i_comb,2),:); 
            
            da.bi_raw_emg_data = [cd.Right_Zygomaticus;cd.Right_Frontalis;cd.Left_Frontalis;cd.Left_Zygomaticus]';

            %% Filtering
            da.filtered_data = filter(fp.bB,fp.bA,double(da.bi_raw_emg_data)); %% bandpassfilter
            da.filtered_data = filter(fp.nB,fp.nA,da.filtered_data); %%notchfilter
            
            %% Trigger�� �°� data cut (start:camera onset / end:'����,28')
            idx_trig = EMG_trigger{i_sub,i_trial};
           
            da.trig_filtered_data = da.filtered_data(idx_trig(1):idx_trig(28),:);
            
            %% Window size
            [winsize, wininc] = calculate_window (para.original_sam_rate,para.convert_sam_rate, para.overlap);
            
            %% Feature Extraction(RMS,SampEN, WL, CC4)
            N_window = floor((length(da.trig_filtered_data) - winsize)/wininc)+1; %% window ����

            temp.RMS = zeros(N_window,para.N_bi_channel); %% memory allocation
            temp.SampEn = zeros(N_window,para.N_bi_channel);
            temp.win_trigger = zeros(N_window,1);
            
            for i_channel = 1: para.N_bi_channel %% bipolar ä�κ� RMS,SampEn extraction
                st=1; en=winsize;
                for i_window = 1:N_window
                    temp.RMS(i_window,i_channel) = rms(da.trig_filtered_data(st:en,i_channel)); %% RMS
                    
                    r = 0.2*std(da.trig_filtered_data(st:en,i_channel),1); %% Standard deviation 
                    temp.SampEn(i_window,i_channel) = FastSampEn(da.trig_filtered_data(st:en,i_channel), 2, r, 1); %SampEn
                    
                    temp.win_trigger(i_window) = st;
                    st=st+wininc; en=en+wininc;                
                end
            end %% bipolar ä�κ� feature extraction  
            
            
            %% Waveform
            temp.WL = getwlfeat(da.trig_filtered_data,winsize,wininc);
            
            %% CC4
            temp.CC4 = getCCfeat(da.trig_filtered_data,4,winsize,wininc);
            
            %% Window-trigger Ȯ��
            w_idx_trig = idx_trig(2:27) - idx_trig(1)+1;            
%             for i = 1:length(w_idx_trig)
%                 temp.idx= length(find(temp.win_trigger(:)<=w_idx_trig(i)));
%                 temp.window_trigger(i,1) = temp.idx;
%             end
            
            
            %% Feature 
            feat.RMS{i_sub,i_trial,i_comb} = temp.RMS;
            feat.SampEn{i_sub,i_trial,i_comb} = temp.SampEn;
            feat.WL{i_sub,i_trial,i_comb} = temp.WL;
            feat.CC4{i_sub,i_trial,i_comb} = temp.CC4;
%             feat.window_trigger{i_sub,i_trial,i_comb} = temp.window_trigger;
            
            clear temp; 
            
        end %% ���� Ƚ��
        sprintf('%d trial complete',i_trial)
        

    end  %% ������ ��   
    sprintf('%d people complete',i_sub)
    

end %% ���� ���� ����� ��
sprintf('%d combination complete',i_comb)

save('EMG_feature.mat','feat','-v7.3');


