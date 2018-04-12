% NARX를 이용해 regression 하는 함수
% NARX는 입력 뿐만 아니라 출력은 feedback 하여, 미래의 data를 예측 하는 함수임
clc; close all; clear ;

% 실험 정보
N_mark = 28;
N_sub = 21;
Idx_sub = 1 : N_sub;
Idx_trl = 1 : 15;
Idx_sub4train = 1 : 10;
% Idx_sub4train(10) = [];
Idx_trl4train = 1 : 10;
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};
delay = 1;
% neuronsHiddenLayer = [30 30];
% % 마커 코 부분 추출
% fpath = fullfile(cd,'DB_v2','DB_markset','mark_nose');
% load(fpath);
    
% EMG/marker delay 조절
N_delay = 5;
Idx_sub_4testing = 3;
Idx_use_mark_type = 1:3;
Idx_use_emg_feat = 1:4;
dim_pca = 4;

% validation 조정
val_subject_indepe = 1;

for i_mark = 12
    if(i_mark==2)
        continue;
    end
    
    % 마커 추출
%     fpath = fullfile(cd,'DB_v2','DB_markset_10Hz_p',sprintf('mark_%d',i_mark));% 나름잘됨
    fpath = fullfile(cd,'DB_v2','DB_markset_10Hz_basecorr_norm_0-1',sprintf('mark_%d',i_mark));
    load(fpath);
    
    % EMG feat 추출
%     fpath = fullfile(cd,'DB_v2','emg_feat_set_10Hz','EMG_feat_normalized');
    fpath = fullfile(cd,'DB_v2','emg_feat_set_10Hz','EMG_feat_normalized');
    load(fpath);
    
    %% train DB 추출
    %Xtrain
    if val_subject_indepe==1
        Xtr_ = feat(Idx_sub4train,:);
        Ttr_ = marker_set(Idx_sub4train,:);
        Idx_sub4test = find(countmember(Idx_sub,Idx_sub4train)==0);
        Xte_ = feat(Idx_sub4test,:);
        Tte_ = marker_set(Idx_sub4test,:);
    else
        Ttr_ = marker_set(Idx_sub_4testing,Idx_trl4train);
        Xtr_ = feat(Idx_sub_4testing,Idx_trl4train);
        Idx_trl4test = find(countmember(Idx_trl,Idx_trl4train)==0);
        Xte_ = feat(Idx_sub_4testing,Idx_trl4test);
        Tte_ = marker_set(Idx_sub_4testing,Idx_trl4test);
    end

%     Xtr = cellfun(@(x) x,Xtr_,'UniformOutput', false); % transe pose
    Xtr = cellfun(@(x) x(1:end-N_delay+1,Idx_use_emg_feat),Xtr_,'UniformOutput', false); % 1:4번 채널만
    Xtr = Xtr(:);   
    
    %% Target of train
    Ttr = cellfun(@(x) x(N_delay:end,Idx_use_mark_type),Ttr_,'UniformOutput', false); % 6번채널만 regression
%     Ttr = cellfun(@(x) x,Ttr,'UniformOutput', false); % transe pose
    Ttr = Ttr(:);

    
    %% cat --> EMG, marker 합치기
%     [Ztr,mu_tr,sigma_tr] = zscore([cell2mat(Xtr),cell2mat(Ttr)],0,1);
    Ztr = [cell2mat(Xtr),cell2mat(Ttr)];
%     Ztr = zscore(Ztr,0,1);
    N_emg_feat = size(Xtr{1},2);
    % Training using PCA
    
    [coeff_tr,~,latent_tr,~,explained] = pca(Ztr);
    %             [V_tr,D_tr] = eig(cov(Ztr'));
    %             % sorting by eigen value
    %             [~,i_sorted] = sort(diag(D_tr),'descend');
    %             V_tr(:,i_sorted(1:dim_pca))
    Y = coeff_tr(:,1:dim_pca); % EMG부분만 모델 사용
    Yg = Y(1:N_emg_feat,:); % measurement matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Cv = cov(Ztr(:,1:N_emg_feat)); % measurement noise%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %regul paramters
    cv = 0.2;
    Cv = (1-cv)*Cv+cv*diag(Cv).*eye(length(diag(Cv)));
    
    %% get sytem matrix from training set
    Xtr = cellfun(@(x) x(:,Idx_use_emg_feat),Xtr_,'UniformOutput', false); % transe pose
    Ttr = cellfun(@(x) x(:,Idx_use_mark_type),Ttr_,'UniformOutput', false); % 6번채널만 regression

    % E[b(t + 1)bT (t)]= F E[b(t)bT (t)]
    temp_v = zeros(dim_pca);
    temp_vt = zeros(dim_pca);
    num_count = 0;
    for i = 1 : numel(Xtr)
        b_train = Y'*[Xtr{i},Ttr{i}]'; % encoding using PCA
        for k = 1 : length(Xtr{i})-1
            num_count = num_count + 1;
            temp_v = temp_v + b_train(:,k)*b_train(:,k)';
            temp_vt = temp_vt + b_train(:,k+1)*b_train(:,k)';
        end
    end
    v_mean = temp_v/num_count;
    vt_mean = temp_vt/num_count;
    F = vt_mean*inv(v_mean); % system matrix%%%%%%%%%%%%%%%%%%%%%%
%     F_order_2 = 
    
    %% process  noise (w(t) = b(t + 1) ? Fb(t))
    w = zeros(dim_pca,length(temp_v));
    num_count = 0;
    for i = 1 : numel(Xtr)
        b_train = Y'*[Xtr{i},Ttr{i}]'; % encoding using PCA
        for k = 1 : length(Xtr{i})-1
            num_count = num_count + 1;
            w(:,num_count) = b_train(:,k+1)-F*b_train(:,k);
        end
    end
    Cw = cov(w');% process noise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %regul paramters
    cw = 0.23;
    Cw = (1-cv)*Cw+cv*diag(Cw).*eye(length(diag(Cw)));
    
    
    %% test DB 추출
    Xte = cellfun(@(x) x(:,Idx_use_emg_feat),Xte_,'UniformOutput', false); % 1:4번 채널만
    Xte = cellfun(@(x) x,Xte,'UniformOutput', false); % transe pose

    %% Target of test

    Tte = cellfun(@(x) x(:,Idx_use_mark_type),Tte_,'UniformOutput', false); % 6번채널만 regression
    Tte = cellfun(@(x) x,Tte,'UniformOutput', false); % transe pose
    
    %% initialization
    % Process error matrix
    sigma_model = 1;
    C = diag(ones(dim_pca,1));
    
    %% kalmann filter estimation
    for i = 1 : numel(Xte)
        
        % Test data PCA encoding(Measurement)
        g = Xte{i}';
        b = Yg'*g;
        Nsamples = length(b);
        
        % for display 
        xk_hat_disp = zeros(dim_pca,Nsamples);
        
        for k = 1 : Nsamples
            % currunt input
            xk_prev =  b(:,k);
            
            % prediction          
            % x(t|t ? 1) = F?x(t ? 1|t ? 1)
            % C(t|t ? 1) = FC(t ? 1|t ? 1)FT + Cw
            xk_prior = F * xk_prev; % F system matrix
            C_prior = F*C*F' + Cw;
            
            % updating
            %C(t|t) = (C?1(t|t ? 1) + HTC?1)-1
            %x_hat(t|t) = C(t|t)C?1(t|t ? 1)?x(t|t ? 1) + HTC?1g(t)
            C = inv(inv(C_prior) + Yg'*inv(Cv)*Yg);
            xk_hat = C * (inv(C_prior)*xk_prior + Yg'*inv(Cv)*g(:,k));
            
            % for next step
            xk_prev = xk_hat;
            
            % 결과 저장용
            xk_hat_disp(:,k) = xk_hat;
        end
        
        % 결과(PCA값) 디코딩
        z_norm = Y*xk_hat_disp;
%         g_pred = z_norm.*repmat(sigma_tr',[1,Nsamples]) +repmat(mu_tr',[1,Nsamples]);
        % 실제 marker값과 비교
        marker = Tte{i}';
        
        for i_plot=1:3
            figure(i_plot);
            plot(1:Nsamples,marker(i_plot,:)',...
            1:Nsamples,z_norm(N_emg_feat+i_plot,:)');
        end
        
    end

end
