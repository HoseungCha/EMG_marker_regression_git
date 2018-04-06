% ���� onset �κ� �����ϴ� �ڵ�
% developed by Ph.D student, Ho-Seung Cha in CoNE Lab.
% ����: 9�� �������� 2�� trial�� �ܾ� 20���� ��� trigger�� ������ ����.
% �ܾ� �ν�Ʈ������ ������ speech Ʈ���Ű� ���� ���� NaN ������ ó��
% ���: Trg_speech{i_sub,i_trl}. ��: �ܾ� ����, �� 1: �ܾ� �ν�Ʈ���� trigger����
% ��2: Speech onset trigger
clear;
addpath(genpath(fullfile(cd,'functions')));

% �켱 ǥ���� �ܾ� �κ� onset�� ������.
load(fullfile(cd,'EMG_trigger_ext_code','EMG_trg'));

% ���� ����
N_trial = 15; %% ���� Ƚ��

% Ʈ���� ����
Trg_Inform = {"����",1,1;"�����(������)",1,2;"�����(����)",1,3;"���",1,4;"�� ���� ����",1,5;"Inner brow raiser",1,6;"Outer brow raiser",1,7;"Brow lowerer",2,1;"cheek raiser",2,2;"Nose winkler",2,3;"Upper lip raiser",2,4;"Lip corner puller",2,5;"Cheek puffer",2,6;"Dimpler",2,7;"Lip corner depressor",3,1;"Lower lip depressor",3,2;"Chin raiser",3,3;"Lip puckerer",3,4;"Lip stretcher",3,5;"Lip funneler",3,6;"Lup tightener",3,7;"Jaw drop",4,1;"Mouth stretch",4,2;"Lip suck",4,3;"Eyes closed",4,4;"���� �ٿø���",4,5;"����",4,6;"����",4,7;"����",4,1;"����",4,2;"����",4,3;"����",4,4;"����",4,5;"�ð�",4,6;"�Ʒ�",4,7;"�˶�",5,1;"����",5,2;"����",5,3;"����",5,4;"����",5,5;"����",5,6;"��ȭ",5,7;"����",6,1;"����",6,2;"�߰�",6,3;"���",6,4};
Trg_name = Trg_Inform(:,1);
% Trg_idx = cell2mat(Trg_Inform(:,2:3));% 128 �������� ����



% read file path of data
[Sname,Spath] = read_names_of_file_in_folder('E:\OneDrive - �Ѿ���б�\����\EMG_maker_regression\�ڵ�\DB');
% DB ������ �� 
N_subject = length(Sname);
% memory allocation
Trg_speech = cell(N_subject,N_trial);
for i_sub= 1 : N_subject
    % �������� DB path �ޱ�
    sub_name = Sname{i_sub}(end-2:end);
    [b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');
    
    % Trial ���� ������ �ޱ�
    for i_trl=1: N_trial
        

        % Read BDF
        OUT =  pop_biosig([Spath{i_sub},'\',num2str(i_trl),'.bdf']);
        
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
        
        % �ܾ� �κ��� Trigger �κи� ����
        tmp_trg = Trg_all{i_sub,i_trl};
        tmp_trg(1) = []; % ī�޶� onset trigger����
        tmp_trg(1:26) = []; % ǥ�� �κ��� trigger�� ����
        %  �ܾ� �κ��� Trigger�� event�� ��� idx�� �ִ��� Ȯ��
        idx_words = find(countmember(event(:,2),tmp_trg)==1);
        % speech onset trigger �� event�� ��� idx �� �ִ��� Ȯ��
        idx_speech = find(event(:,1)==0.5 ==1);
        % �ܾ� �ν�Ʈ���� trigger��, epcch onset trigger�� ��ó�� ���� ������
        idx_speech_of_word = zeros(length(idx_words),1); % memory allocation
        for i_words = 1 : length(idx_words) 
            for i_speech = 1 : length(idx_speech)
                if i_words == length(idx_words)  %20���� �ִ� �̹Ƿ�, 21�� ° �ܾ�� �񱳴� �ʿ����
                    if (idx_words(i_words)<idx_speech(i_speech))
                        if idx_speech_of_word(i_words)==0
                            idx_speech_of_word(i_words) = idx_speech(i_speech);
                        end
                    end
                else
                    %�ܾ� �� trigger ���̿� �ִ� ���� ó�� �����ϴ� speech onset trigger�� ����
                    if (idx_words(i_words)<idx_speech(i_speech))&&...
                            (idx_words(i_words+1)>idx_speech(i_speech))
                        if idx_speech_of_word(i_words)==0
                            idx_speech_of_word(i_words) = idx_speech(i_speech);
                        end
                    end
                end
            end
        end
        % �ܾ�� speech onset(ù��° �κ�)�� idx�� ��ħ
        idx_wordnspeech_onst = [idx_words,idx_speech_of_word];
        % speech onset�� ���� ���, NaN������ ġȯ
        idx_wordnspeech_onst(idx_wordnspeech_onst==0) = NaN;
        
        % lat_wordnspecch
        lat_wordnspecch = zeros(length(idx_words) ,2);
        for i= 1: numel(idx_wordnspeech_onst)
            try
            lat_wordnspecch(i) = event(idx_wordnspeech_onst(i),2);
            catch ex
                % ���� ���� ���� NaN���� �־���
                lat_wordnspecch(i) = NaN;
            end
        end
        % ������ ����
        Trg_speech{i_sub,i_trl} = lat_wordnspecch; 
    end  
    sprintf('it''s been done of %dth person',i_sub)
end
% ������ ����
Trg_speech_name = Trg_name(27:end);
save('Trg_speech','Sname','Trg_speech_name','Trg_speech');

