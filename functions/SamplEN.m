function f = SamplEN(curwin,dim)
    N_sig = size(curwin,2);
    f = zeros(1,N_sig);
    R = 0.2*std(curwin);
    for i_sig = 1 : N_sig
       f(i_sig) = sampleEntropy(curwin(:,i_sig), dim, R(i_sig),1); %%   SampEn = sampleEntropy(INPUT, M, R, TAU)
    end
end