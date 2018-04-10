%--------------------------------------------------------------------------
% Compute SST&SSE to get R^2
%--------------------------------------------------------------------------
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
function r_square = compute_r_square(target,output)
% check if target,output fit in Samples X Features
if size(target,1)<size(target,2)
    tar = target';
    out = output';
else
    tar = target;
    out = output;
end

% get mean
test_target_mean = mean(tar,1);

% memory allocation
sst = zeros(length(tar),1);
sse = zeros(length(tar),1);
temp1 = zeros(1,3);
temp2 = zeros(1,3);
for ii= 1: length(tar)
    for j=1: 3
        temp1(1,j) = pow2(tar(ii,j)-test_target_mean(1,j));
        temp2(1,j) = pow2(out(ii,j) - tar(ii,j));
    end
    sst(ii) = sum(temp1);
    sse(ii) = sum(temp2);
end
% get SST, SSE
sst = sum(sst);
sse = sum(sse);
% get R^2
r_square = 1 - (sse / sst);
end