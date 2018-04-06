%장원두 박사님이 만드신 saccade detection(wavelet 함수) 
% 함수 버전으로 만들기 (from Ho-Seung CHa, Phd Student, CoNE lab.)
function d_sacc = wavel_based_saccade_detection (d,waveletTh)

%%%%%%%%%%%%%%%%%%%%saccade detection%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~, bSaccade] = extract_scaddic(d, 0, waveletTh);
d_tmp_d = diff(d);
d_tmp_d = [ zeros(1,size(d_tmp_d,2)); d_tmp_d];
% d_tmp_d = [0 0; eog(2:end,:) - eog(1:end-1,:)]; %1차 차분

[N_dat, N_ch] = size(d_tmp_d);
% 이전값 초기화
prev = 0; 
% eog_sacc 메모리 allocation
d_sacc = zeros(N_dat,N_ch);
for i = 1 : N_ch  %for each channel
    for j=1:N_dat
        if  bSaccade(j,i)==1
            v = prev+d_tmp_d(j,i);
%             v=1;
            d_sacc(j,i) = v;
            prev = v;
        else
%             prev = 0;
            d_sacc(j,i) = prev;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end