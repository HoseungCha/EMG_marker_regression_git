clear;
% 4
% 트리거 정보
Trg_Inform = {"웃음",1,1;"비웃음(오른쪽)",1,2;"비웃음(왼쪽)",1,3;"놀람",1,4;"눈 세게 감기",1,5;"Inner brow raiser",1,6;"Outer brow raiser",1,7;"Brow lowerer",2,1;"cheek raiser",2,2;"Nose winkler",2,3;"Upper lip raiser",2,4;"Lip corner puller",2,5;"Cheek puffer",2,6;"Dimpler",2,7;"Lip corner depressor",3,1;"Lower lip depressor",3,2;"Chin raiser",3,3;"Lip puckerer",3,4;"Lip stretcher",3,5;"Lip funneler",3,6;"Lup tightener",3,7;"Jaw drop",4,1;"Mouth stretch",4,2;"Lip suck",4,3;"Eyes closed",4,4;"눈썹 다올리기",4,5;"교통",4,6;"날씨",4,7;"내일",4,1;"메일",4,2;"문자",4,3;"사진",4,4;"선택",4,5;"시간",4,6;"아래",4,7;"알람",5,1;"오늘",5,2;"우측",5,3;"위쪽",5,4;"음악",5,5;"일정",5,6;"전화",5,7;"좌측",6,1;"지도",6,2;"추가",6,3;"취소",6,4};
Trg_name = Trg_Inform(:,1);
Trg_idx = cell2mat(Trg_Inform(:,2:3));% 128 곱해져서 나옴

N_trial = 15; %% 실험 횟수
N_sub = 3; %% 피험자 수

addpath(genpath(fullfile(cd,'functions')));
% read file path of data
[Sname,Spath] = read_names_of_file_in_folder('E:\OneDrive - 한양대학교\연구\EMG_maker_regression\코드\DB');
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
        % event (동기화) 정리
        event = cell2mat(permute(struct2cell(OUT.event),[1 3 2])');
        event(:,1) = event(:,1) - 1024; % 1024 카메라 동기화
        event(:,1) = event(:,1)/128; % 128 곱해져서 나오기 때문에 나눠줌.
        
        % 음성신호 섞였는지 확인하고 섞였을 경우 뺴줌
        for i = 1: length(event(:,1))
            if event(i,1) - floor(event(i,1)) ~= 0 % 반올림해서 뺐을 때 0이 안나오면 (즉 정수가 아니면)
                if event(i,1) ~= 0.5    % 음성 동기화는 0.5임. 0.5가 아니면
                    event(i,1) = event(i,1) - 0.5; % 음성신호가 섞였으므로 0.5 빼줌;
                end
            end
        end
        % 음성신호 부분은 없앰
        idx_speech_onst = find(event(:,1)==0.5);
        event(idx_speech_onst,:) = [];
        % -값 (불필요한) 동기화 신호 없앰
        idx_useless = find(event(:,1)<0);
        event(idx_useless,:) = [];
        % 카메라 onset 시점도 빼줌 (나중 결과 내기 전에 합침)
        Onset = find(event(:,1)==0);
        Onset_lat = event(Onset,2);
        event(Onset,:) = [];
        % 순서대로 2쌍 씩 데이터 정리
        try
        temp = reshape(event(:,2),[2, 46]);
        catch % 잘못 받음 데이터 예외처리
            keyboard;
            if i_sub == 1 && i_data == 9
               event(88,:) = [];
               temp = reshape(event(:,2),[2, 46]);
            end
            if i_sub == 9 && i_data == 2
               temp = reshape(event(:,2),[2, 84/2]);
            end
        end
        % Onset 시점이 두번 찍혀있을 경우 뺴줌
        if length(Onset_lat)>1
            Onset_lat = Onset_lat(1);
        end
        % 데이터 저장
        Trg_all{i_sub,i_data} = [Onset_lat; temp(1,:)']; 
    end  
    sprintf('%dst people complete',i_sub)
end
Trg_name =['CameraOnset';Trg_name(:)];
save('EMG_trg','Sname','Trg_name','Trg_all');

