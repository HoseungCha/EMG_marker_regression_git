function [Markers,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(FileName)

%% CSV2MAT - Getting 3D data from a csv file
%
% csv2mat processes '.csv' files exported from Optitrack's Motive to get 
% MoCap data as markers' cloud, markers' labels, time vector, total number 
% of markers, total number of frames and the frame rate of the MoCap file.
%
% This script runs with files exported from Motive 2.0.0 and Matlab
% R2015b. Its functioning with other versions is not assured.
%
% For running this function, you must place it inside any folder included
% to the Matlab Path or in the same folder of your '.csv' file.
%
% [Markers,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(FileName)
%
% Input parameters:
% FileName: '.csv' file name without extension.
%
% Output parameters:
%
% Markers: 3D matrix with MoCap data. Its columns are equivalent to the
% captured markers, its rows to the captured frames and its dimmension to
% the X,Y,Z spatial axis.
% Labels: array with the name of each marker. This labels are sorted in the
% same order of the columns of the Markers matrix.
% Time: vector containing the elapsed time for each frame, starting from
% zero to the duration of the capture.
% NMarkers: is the total number of captured markers. It's the same as the
% columns number of the Markers matrix.
% NFrames: is the total number of captured frames. It's the same as the
% rows number of the Markers matrix .
% FrameRate: is the framerate of the MoCap system.
%
% [Example:]
% 
% [Markers,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat('MyMoCap')
%
% =========================================================================
%
% This software is part of the public domain, and may therefore be
% distributed freely for any non-commercial use. Contributions,
% improvements, and especially bug fixes of the code are more than welcome.
%
% [V0.1], Juan Pablo Angel Lopez (jangel@autonoma.edu.co), July 2017.

% % % % % % % % % %% 확장자 사용할때
% % % % % % % % % FullFile = textread([FileName '.csv'],'%s','delimiter',','); %#ok<*DTXTRD>
% % % % % % % % % DataStart = length(textread([FileName '.csv'],'%s','delimiter',',',...
% % % % % % % % %     'headerlines',1));
% % % % % % % % % NoMarkers = length(textread([FileName '.csv'],'%s','delimiter',',',...
% % % % % % % % %     'headerlines',3));
% % % % % % % % % Data = textread([FileName '.csv'],'%f','delimiter',',','headerlines',7);
% % % % % % % % % % DataL = textread('Sentadilla.csv','%s','delimiter',',','headerlines',3);

%% 확장자 사용 안할때 
FullFile = textread([FileName],'%s','delimiter',','); %#ok<*DTXTRD>
DataStart = length(textread([FileName],'%s','delimiter',',',...
    'headerlines',1));
NoMarkers = length(textread([FileName],'%s','delimiter',',',...
    'headerlines',3));
Data = textread([FileName],'%f','delimiter',',','headerlines',7);

Header = FullFile(1:length(FullFile)-DataStart);
FrameRate = str2double(Header(6));
MarkersL = FullFile(length(FullFile)-DataStart+3:length(FullFile)-NoMarkers);


%% Markers 갯수 확인
NMarkers = length(MarkersL)/3;
c = 1;
for i=1:(NMarkers*3+2):length(Data)
    TFrames(c) = Data(i); 
    c = c+1;
end

%% Frame수 확인
NFrames = length(TFrames);
c = 1;
for i=2:(NMarkers*3+2):length(Data)
    Time(c) = Data(i); 
    c = c+1;
end

%% Coordinate Data 확인
Markers = zeros(NFrames,NMarkers,3);
Data3D = zeros((NMarkers*3)+2,NFrames);

for i=1:length(Data)
    Data3D(i) = Data(i); 
end

Data3D = Data3D';

for f=1:NFrames
    c = 1;
    for x=3:3:(NMarkers*3)+2
        Markers(f,c,1) = Data3D(f,x);
        Markers(f,c,3) = Data3D(f,x+1);
        Markers(f,c,2) = -1*Data3D(f,x+2); %%z에 -넣어야됨?
        c = c+1;
    end
end

DataL = textread([FileName],'%s','delimiter',',','headerlines',3);
% DataL = textread([FileName '.csv'],'%s','delimiter',',','headerlines',3);
DataL = DataL(3:(NMarkers*3)+2);

c = 1;
for l=1:3:length(DataL)
    Labels(c,1) = DataL(l); 
    c = c+1;
end
Labels=strrep(Labels,'MarkerSet:','');
Labels=strrep(Labels,'MarkerSet_','');