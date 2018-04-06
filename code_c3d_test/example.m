%----------------------------------------------------------------------
% c3d --> mat --> c3d
% mat(random) --> c3d
%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------
clear;
clc;
%% 
acq = btkReadAcquisition('01.c3d');
markers = btkGetMarkers(acq);
temp = struct2cell(markers);
markers_value = cat(2,temp{:});

% % parmerter?
% afn = btkGetAnalogFrameNumber(acq)
% an = btkGetAnalogNumber(acq)
% af = btkGetAnalogFrequency(acq)
% an = btkGetAnalogNumber(acq)
% ar = btkGetAnalogResolution(acq)
% [analogs, analogsInfo] = btkGetAnalogs(acq)
% ratio = btkGetAnalogSampleNumberPerFrame(acq)
% av = btkGetAnalogsValues(acq)
% [analysis, analysisInfo] = btkGetAnalysis(acq)
% [forces, forcesInfo] = btkGetForces(acq)
% pfn = btkGetPointFrameNumber(acq)
% v = btkGetScalarsValues(acq)

% get parameters of C3D data for chekcing it works
N_marker = 28;
N_frame =  btkGetAnalogFrameNumber(acq);
acq4save =  btkCloneAcquisition(acq);

% get marker_value from csv
% markers_value= rand(N_marker*3,N_frame);
btkSetFrameNumber(acq4save, N_frame) % 
btkSetMarkersValues(acq4save, markers_value);  % set marker values
btkWriteAcquisition(acq4save, '01_recon.c3d');

% check new file
acq4check = btkReadAcquisition('01_recon.c3d');
markers4check = btkGetMarkers(acq4check);



% get parameters of CSV data ( 가정: changes of number of frame )
N_marker = 28;
N_frame = 10000;
acq4new =  btkCloneAcquisition(acq4save); % c3d의 나머지 parameters들을 가져옴

% new marker values (we need to get those values from csv file)
markers_value_new= rand(N_frame,N_marker*3); 
btkSetFrameNumber(acq4new, N_frame) % set number of frame
btkSetMarkersValues(acq4new, markers_value_new);  % set marker values
btkWriteAcquisition(acq4new, '01_new.c3d');

% check file
acq4check = btkReadAcquisition('01_new.c3d');
markers4check_new = btkGetMarkers(acq4check);
