clear;
% 4
% Ʈ���� ����
Trg_Inform = {"����",1,1;"�����(������)",1,2;"�����(����)",1,3;"���",1,4;"�� ���� ����",1,5;"Inner brow raiser",1,6;"Outer brow raiser",1,7;"Brow lowerer",2,1;"cheek raiser",2,2;"Nose winkler",2,3;"Upper lip raiser",2,4;"Lip corner puller",2,5;"Cheek puffer",2,6;"Dimpler",2,7;"Lip corner depressor",3,1;"Lower lip depressor",3,2;"Chin raiser",3,3;"Lip puckerer",3,4;"Lip stretcher",3,5;"Lip funneler",3,6;"Lup tightener",3,7;"Jaw drop",4,1;"Mouth stretch",4,2;"Lip suck",4,3;"Eyes closed",4,4;"���� �ٿø���",4,5;"����",4,6;"����",4,7;"����",4,1;"����",4,2;"����",4,3;"����",4,4;"����",4,5;"�ð�",4,6;"�Ʒ�",4,7;"�˶�",5,1;"����",5,2;"����",5,3;"����",5,4;"����",5,5;"����",5,6;"��ȭ",5,7;"����",6,1;"����",6,2;"�߰�",6,3;"���",6,4};
Trg_name = Trg_Inform(:,1);
Trg_idx = cell2mat(Trg_Inform(:,2:3));% 128 �������� ����

N_trial = 15; %% ���� Ƚ��
N_sub = 3; %% ������ ��

addpath(genpath(fullfile(cd,'functions')));
% read file path of data
[Sname,Spath] = read_names_of_file_in_folder('E:\OneDrive - �Ѿ���б�\����\EMG_maker_regression\�ڵ�\DB');
N_subject = length(Sname);
Trg_all = cell(N_subject,N_trial);
for i_sub= 1 : N_subject
    sub_name = Sname{i_sub}(end-2:end);

%     [c_fname,c_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*csv');
   
    [b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');
%      N_trial = length(b_fname);
    
    for i_data=1: N_trial
        %% CSV Read
        OUT =  pop_biosig([Spath{i_sub},'\',num2str(i_data),'.bdf']);
        % event (����ȭ) ����
        event = cell2mat(permute(struct2cell(OUT.event),[1 3 2])');
        event(:,1) = event(:,1) - 1024; % 1024 ī�޶� ����ȭ
        event(:,1) = event(:,1)/128; % 128 �������� ������ ������ ������.
        
        % ������ȣ �������� Ȯ���ϰ� ������ ��� ����
        for i = 1: length(event(:,1))
            if event(i,1) - floor(event(i,1)) ~= 0 % �ݿø��ؼ� ���� �� 0�� �ȳ����� (�� ������ �ƴϸ�)
                if event(i,1) ~= 0.5    % ���� ����ȭ�� 0.5��. 0.5�� �ƴϸ�
                    event(i,1) = event(i,1) - 0.5; % ������ȣ�� �������Ƿ� 0.5 ����;
                end
            end
        end
        % ������ȣ �κ��� ����
        idx_speech_onst = find(event(:,1)==0.5);
        event(idx_speech_onst,:) = [];
        % -�� (���ʿ���) ����ȭ ��ȣ ����
        idx_useless = find(event(:,1)<0);
        event(idx_useless,:) = [];
        % ī�޶� onset ������ ���� (���� ��� ���� ���� ��ħ)
        Onset = find(event(:,1)==0);
        Onset_lat = event(Onset,2);
        event(Onset,:) = [];
        % ������� 2�� �� ������ ����
        try
        temp = reshape(event(:,2),[2, 46]);
        catch % �߸� ���� ������ ����ó��
            keyboard;
            if i_sub == 1 && i_data == 9
               event(88,:) = [];
               temp = reshape(event(:,2),[2, 46]);
            end
            if i_sub == 9 && i_data == 2
               temp = reshape(event(:,2),[2, 84/2]);
            end
        end
        % Onset ������ �ι� �������� ��� ����
        if length(Onset_lat)>1
            Onset_lat = Onset_lat(1);
        end
        % ������ ����
        Trg_all{i_sub,i_data} = [Onset_lat; temp(1,:)']; 
    end  
    sprintf('%dst people complete',i_sub)
end
Trg_name =['CameraOnset';Trg_name(:)];
save('EMG_trg','Sname','Trg_name','Trg_all');

