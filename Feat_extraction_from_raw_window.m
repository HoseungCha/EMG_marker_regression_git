% EMG feature 뽑는 코드
clc; close all; clear ;
% 실험 정보
N_sub = 21;
N_trl = 15;
N_trg = 26;
% N_trg = length(trg_w);

%path 이미지 저장
path_img = fullfile(cd,'DB_v2','emg_raw_img');
% 파라미터 설정
order_cc = 4;
for i_comb = 1
    
    %     for i_mark = 1 : 28
    path_emg = fullfile(cd,'DB_v2','emg_win_10Hz_Time Alignment',sprintf('comb_%d',i_comb));
    %     path_mark = fullfile(cd,'DB_v2','mark_win',sprintf('mark_%d',i_mark));
    path_trg = fullfile(cd,'DB_v2','trg_win_10Hz');
    feat = cell(N_sub,N_trl);
    for i_sub = 1 : N_sub
        for i_trl = 1 : N_trl
            % window로 구분된 데이터 불러오기
            fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            load(fullfile(path_emg,fname));
            % tigger 정보 불러오기
            load(fullfile(path_trg,fname));
            
            %             load(fullfile(path_mark,fname));
            len_win = trg_w(27);
            N_EMG_chan = size(emg_win{1},2);
            temp = zeros(len_win,28);
            for i_win = 1 : len_win
                % rms feat 뽑기
                curwin = emg_win{i_win};
                
                % RMS
                F.RMS = rms(curwin);
                % WL
                F.WL = sum(abs(diff(curwin,2)));
                % SampEN
                for i_ch = 1 : N_EMG_chan
                    r = 0.2*std(curwin(:,i_ch),1); %% Standard deviation
                    F.Samp(1,i_ch) = FastSampEn(curwin(:,i_ch), 2, r, 1); %SampEn
                end
                % CC
                cur_xlpc = real(lpc(curwin,order_cc)');
                cur_xlpc = cur_xlpc(2:(order_cc+1),:);
                cur_CC = zeros(order_cc,N_EMG_chan);
                for i_sig = 1 : N_EMG_chan
                    cur_CC(:,i_sig)=a2c(cur_xlpc(:,i_sig),order_cc,order_cc)';
                end
                F.CC = reshape(cur_CC,order_cc*N_EMG_chan,1)';
                
                %feat concatinating
                F_concat = cell2mat(struct2cell(F)');
                temp(i_win,:) = F_concat;
                temp_img = mat2im(curwin,parula(numel(curwin)));
                fname = sprintf('sub_%03d_trl_%03d_win_%03d',i_sub,i_trl,i_win);
                imwrite(temp_img,fullfile(path_img,[fname,'.png']));
                
            end
            
            %             % 2차항으로 EMG feature agumentation
            %             idx2agu = permn(1:4,2);
            %             temp_n_agu = zeros(length(temp),size(idx2agu,1));
            %             for i_aug = 1 : size(idx2agu,1)
            %                 temp_n_agu(:,i_aug) = temp(:,idx2agu(i_aug,1)).*temp(:,idx2agu(i_aug,2));
            %             end
            %             temp = [temp,temp_n_agu];
            
            % Calibration session에서 Nomalization
            Max = max(temp(1 : trg_w(6),:));
            Min = min(temp(1 : trg_w(6),:));
            feat_n = (temp-Min)./(Max-Min);
            feat_n(:,9:end) = temp(:,9:end);
            
%             feat_n(feat_n>1) = 1;
%             feat_n(feat_n<0) = 0;
%             temp(:,1:8) = zscore(temp(:,1:8));
%             feat_n = zscore(temp);
            
            
            
            feat{i_sub,i_trl} = feat_n;
            %             for i_trg = 1 : N_trg
            %             feat_rms{i_sub,i_trl,i_trg} = ...
            %                 feat_n(trg_w(i_trg):trg_w(i_trg+1)-1,:);
            %             end
            disp([i_sub,i_trl]);
        end
    end
end







function c=a2c(a,p,cp)
%Function A2C: Computation of cepstral coeficients from AR coeficients.
%
%Usage: c=a2c(a,p,cp);
%   a   - vector of AR coefficients ( without a[0] = 1 )
%   p   - order of AR  model ( number of coefficients without a[0] )
%   c   - vector of cepstral coefficients (without c[0] )
%   cp  - order of cepstral model ( number of coefficients without c[0] )

%                              Made by PP
%                             CVUT FEL K331
%                           Last change 11-02-99

for n=1:cp,

  sum=0;

  if n<p+1,
    for k=1:n-1,
      sum=sum+(n-k)*c(n-k)*a(k);
    end;
    c(n)=-a(n)-sum/n;
  else
    for k=1:p,
      sum=sum+(n-k)*c(n-k)*a(k);
    end;
    c(n)=-sum/n;
  end;

end;
end