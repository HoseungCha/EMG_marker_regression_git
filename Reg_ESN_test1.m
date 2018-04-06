% EMG feature »Ì´Â ÄÚµå 

clc; close all; clear ;

for i_comb = 1 : 3
    path = fullfile(cd,'DBv2','emg_win',sprintf('comb_%d',i_comb));
    for i_sub = 1 : 21
       for i_trl = 1 : 15
           fname = sprintf('sub_%d_trl_%d',i_sub,i_trl);
           load(fullfile(path,fname));
           fname =  sprintf('sub_%d_trl_%d',i_sub,i_trl);
           load(fullfile(cd,'DBv2','trg_win',fname))
           for i_win = 1 : emg.trg_w(27)
               curwin = emg_win{i_win};
               % spectrum to image (RGB)
                Nx = length(curwin);
                N_ch = size(curwin,2);
               nsc = floor(Nx/10);
                nov = floor(nsc/90);
            %     nff = max(512,2^nextpow2(nsc));
                nff = 2^nextpow2(nsc);
                ps_ = cell(1,N_ch);
            %    tic
               for i_ch = 1 : N_ch
                   [~,~,~,ps] = spectrogram(curwin(:,i_ch)',hamming(nsc),nov,nff,2048);
               end
                imwriteemg_img{i_win}
           end
       end
    end
end