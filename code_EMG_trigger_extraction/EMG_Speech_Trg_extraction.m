% 음성 onset 부분 추출하는 코드
% developed by Ph.D student, Ho-Seung Cha in CoNE Lab.
% 참고: 9번 피험자의 2번 trial은 단어 20개의 모든 trigger가 들어오지 않음.
% 단어 인스트럭션은 있으나 speech 트리거가 없는 경우는 NaN 값으로 처리
% 결과: Trg_speech{i_sub,i_trl}. 행: 단어 종류, 열 1: 단어 인스트럭션 trigger시점
% 열2: Speech onset trigger
clear;
addpath(genpath(fullfile(cd,'functions')));

% 우선 표정과 단어 부분 onset을 가져옴.
load(fullfile(cd,'EMG_trigger_ext_code','EMG_trg'));

% 실험 정보
N_trial = 15; %% 실험 횟수

% 트리거 정보
Trg_Inform = {"웃음",1,1;"비웃음(오른쪽)",1,2;"비웃음(왼쪽)",1,3;"놀람",1,4;"눈 세게 감기",1,5;"Inner brow raiser",1,6;"Outer brow raiser",1,7;"Brow lowerer",2,1;"cheek raiser",2,2;"Nose winkler",2,3;"Upper lip raiser",2,4;"Lip corner puller",2,5;"Cheek puffer",2,6;"Dimpler",2,7;"Lip corner depressor",3,1;"Lower lip depressor",3,2;"Chin raiser",3,3;"Lip puckerer",3,4;"Lip stretcher",3,5;"Lip funneler",3,6;"Lup tightener",3,7;"Jaw drop",4,1;"Mouth stretch",4,2;"Lip suck",4,3;"Eyes closed",4,4;"눈썹 다올리기",4,5;"교통",4,6;"날씨",4,7;"내일",4,1;"메일",4,2;"문자",4,3;"사진",4,4;"선택",4,5;"시간",4,6;"아래",4,7;"알람",5,1;"오늘",5,2;"우측",5,3;"위쪽",5,4;"음악",5,5;"일정",5,6;"전화",5,7;"좌측",6,1;"지도",6,2;"추가",6,3;"취소",6,4};
Trg_name = Trg_Inform(:,1);
% Trg_idx = cell2mat(Trg_Inform(:,2:3));% 128 곱해져서 나옴



% read file path of data
[Sname,Spath] = read_names_of_file_in_folder('E:\OneDrive - 한양대학교\연구\EMG_maker_regression\코드\DB');
% DB 피험자 수 
N_subject = length(Sname);
% memory allocation
Trg_speech = cell(N_subject,N_trial);
for i_sub= 1 : N_subject
    % 피험자의 DB path 받기
    sub_name = Sname{i_sub}(end-2:end);
    [b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');
    
    % Trial 별로 데이터 받기
    for i_trl=1: N_trial
        

        % Read BDF
        OUT =  pop_biosig([Spath{i_sub},'\',num2str(i_trl),'.bdf']);
        
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
        
        % 단어 부분의 Trigger 부분만 추출
        tmp_trg = Trg_all{i_sub,i_trl};
        tmp_trg(1) = []; % 카메라 onset trigger없앰
        tmp_trg(1:26) = []; % 표정 부분의 trigger는 없앰
        %  단어 부분의 Trigger가 event에 어느 idx에 있는지 확인
        idx_words = find(countmember(event(:,2),tmp_trg)==1);
        % speech onset trigger 가 event에 어느 idx 에 있는지 확인
        idx_speech = find(event(:,1)==0.5 ==1);
        % 단어 인스트럭션 trigger후, epcch onset trigger중 맨처음 값만 가져옴
        idx_speech_of_word = zeros(length(idx_words),1); % memory allocation
        for i_words = 1 : length(idx_words) 
            for i_speech = 1 : length(idx_speech)
                if i_words == length(idx_words)  %20번이 최대 이므로, 21번 째 단어와 비교는 필요없음
                    if (idx_words(i_words)<idx_speech(i_speech))
                        if idx_speech_of_word(i_words)==0
                            idx_speech_of_word(i_words) = idx_speech(i_speech);
                        end
                    end
                else
                    %단어 간 trigger 사이에 있는 제일 처음 등장하는 speech onset trigger만 저장
                    if (idx_words(i_words)<idx_speech(i_speech))&&...
                            (idx_words(i_words+1)>idx_speech(i_speech))
                        if idx_speech_of_word(i_words)==0
                            idx_speech_of_word(i_words) = idx_speech(i_speech);
                        end
                    end
                end
            end
        end
        % 단어와 speech onset(첫번째 부분)의 idx를 합침
        idx_wordnspeech_onst = [idx_words,idx_speech_of_word];
        % speech onset이 없을 경우, NaN값으로 치환
        idx_wordnspeech_onst(idx_wordnspeech_onst==0) = NaN;
        
        % lat_wordnspecch
        lat_wordnspecch = zeros(length(idx_words) ,2);
        for i= 1: numel(idx_wordnspeech_onst)
            try
            lat_wordnspecch(i) = event(idx_wordnspeech_onst(i),2);
            catch ex
                % 값이 없을 때는 NaN값을 넣어줌
                lat_wordnspecch(i) = NaN;
            end
        end
        % 데이터 저장
        Trg_speech{i_sub,i_trl} = lat_wordnspecch; 
    end  
    sprintf('it''s been done of %dth person',i_sub)
end
% 데이터 저장
Trg_speech_name = Trg_name(27:end);
save('Trg_speech','Sname','Trg_speech_name','Trg_speech');

