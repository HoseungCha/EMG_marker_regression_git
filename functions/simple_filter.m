%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------
function filtered_data=simple_filter(rawdata,b,Vriable)
%% Band pass filter
filtered_data=zeros(size(rawdata,1),size(rawdata,2));
for ch=1:size(rawdata,2)
    X = rawdata(:,ch);
    Y = filtfilt(b, Vriable, X);
    filtered_data(:,ch) = Y;
end
end