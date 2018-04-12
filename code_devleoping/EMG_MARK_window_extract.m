% EMG feature 뽑는 코드
clc; close all; clear ;
% 실험 정보
N_sub = 21;
N_trl = 15;
N_trg = 26;
% N_trg = length(trg_w);

%path 이미지 저장
path_img = fullfile(cd,'DB_v2','emg_raw_img');
path_trg = fullfile(cd,'DB_v2','trg_win_10Hz');
% 파라미터 설정
for i_comb = 1:3
    for i_mark  = 1 : 28
        path_emg = fullfile(cd,'DB_v2','emg_win_10Hz_Time Alignment',sprintf('comb_%d',i_comb));
        path_marker = fullfile(cd,'DB_v2','mark_win_10Hz_Time Alignment',...
            sprintf('mark_%d',i_mark));
        %     path_mark = fullfile(cd,'DB_v2','mark_win',sprintf('mark_%d',i_mark));
        
        feat = cell(N_sub,N_trl);
        for i_sub = 1 : N_sub
            for i_trl = 1 : N_trl
                % tigger 정보 불러오기
                fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
                load(fullfile(path_trg,fname));
                len_win = trg_w(27);
                
                % window로 구분된 데이터 불러오기
                fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
                load(fullfile(path_emg,fname));
                emg_win = emg_win(1:len_win);
                save(fullfile(path_emg,fname),'emg_win');
                
                fname = sprintf('sub_%03d_trl_%03d_d1',i_sub,i_trl);
                load(fullfile(path_marker,fname));
                mark_win = mark_win(1:len_win);
                save(fullfile(path_marker,fname),'mark_win');
                
                fname = sprintf('sub_%03d_trl_%03d_d2',i_sub,i_trl);
                load(fullfile(path_marker,fname));
                mark_win = mark_win(1:len_win);
                save(fullfile(path_marker,fname),'mark_win');
                
                fname = sprintf('sub_%03d_trl_%03d_raw',i_sub,i_trl);
                load(fullfile(path_marker,fname));
                mark_win = mark_win(1:len_win);
                save(fullfile(path_marker,fname),'mark_win');
                
                
            end
        end
        i_mark
    end
end





