function plot3dmtx(Markers,varargin)

%% PLOT3DMTX - plot function for 3D matrices 
%
% plot3dmtx plots an animation of a 3D matrix created from a MoCap system.
% Works as a supporting feature for CSV2MAT.
%
% SYNTAX:
%
%      plot3dmtx(Markers,PF,VFR,MF,F,CF)
%
%
% Where:
%
% Markers: 3D matrix with X-Y-Z coordinates of the captured markers.
% PF: playback speed as a positive number where 1 is equivalent to a normal
% playback speed.
% VFR: frame rate in FPS.
% MF: 'yes' for showing markers' trajectories or 'no' for the opposite.
% F: Vector with the indexes of the followed markers.
% CF: Vector with the colors of the trajectories.
%
% [Example:]
% 
% plot3dmtx(M,0.1,100,'yes',[2 14 8],['r' 'c' 'k'])
%
%
% =========================================================================
%
% This software is part of the public domain, and may therefore be
% distributed freely for any non-commercial use. Contributions,
% improvements, and especially bug fixes of the code are more than welcome.
%
% Original: main_c3d_processing -- 
%                  Processing of a c3d file: VAXD
%
% Version Control:
% March 1, 2013 - Formatted as a function
% May 14, 2014 - 3D matrix animation
% November 1, 2012 - Screen trajectories
% October 22, 2012 - Original version
%
% Sebastian Durango, Manizales (UAM)
% Juan Pablo Angel, Manizales (UAM)
%
% [V1.0], Juan Pablo Angel Lopez (jangel@autonoma.edu.co), July 2017.

%% Start of the code (all comments are in spanish)
%VideoFrameRate,mostrar_firmas,Firmas,Color_Firmas,PasoFrame

Color_FirmasB = ['k';'b';'g';'r';'c';'m';'y'];

switch nargin
    case 1
        VideoFrameRate = 100;
        PasoFrame = 8;        
        mostrar_firmas = 'no';
        Firmas = [];
        Color_Firmas = [];
    case 2
        if isempty(varargin{1}) == 1
            PasoFrame = 8;
        else
            PasoFrame = round(varargin{1}*8);
        end
        VideoFrameRate = 100;
        mostrar_firmas = 'no';
        Firmas = [];
        Color_Firmas = [];
    case 3
        if isempty(varargin{1}) == 1
            PasoFrame = 8;
        else
            PasoFrame = round(varargin{1}*8);
        end
        if isempty(varargin{2}) == 1
            VideoFrameRate = 100;
        else
            VideoFrameRate = varargin{2};
        end
        mostrar_firmas = 'no';
        Firmas = (1:1:size(Markers,2));
        Color_Firmas = Color_FirmasB;
        for color = 1:1:ceil(length(Firmas)/length(Color_FirmasB))
            Color_Firmas(:,color) = Color_FirmasB;
        end
    case 4
        if isempty(varargin{1}) == 1
            PasoFrame = 8;
        else
            PasoFrame = round(varargin{1}*8);
        end
        if isempty(varargin{2}) == 1
            VideoFrameRate = 100;
        else
            VideoFrameRate = varargin{2};
        end
        if isempty(varargin{3}) == 1
            mostrar_firmas = 'no';
        else
            mostrar_firmas = varargin{3};
        end
        Firmas = [];
        Color_Firmas = Color_FirmasB;
        for color = 1:1:ceil(length(Firmas)/length(Color_FirmasB))
            Color_Firmas(:,color) = Color_FirmasB;
        end
    case 5
        if isempty(varargin{1}) == 1
            PasoFrame = 8;
        else
            PasoFrame = round(varargin{1}*8);
        end
        if isempty(varargin{2}) == 1
            VideoFrameRate = 100;
        else
            VideoFrameRate = varargin{2};
        end
        if isempty(varargin{3}) == 1
            mostrar_firmas = 'no';
        else
            mostrar_firmas = varargin{3};
        end
        if isempty(varargin{4}) == 1
            Firmas = [];
        else
            Firmas = varargin{4};
        end
        Color_Firmas = Color_FirmasB;
        for color = 1:1:ceil(length(Firmas)/length(Color_FirmasB))
            Color_Firmas(:,color) = Color_FirmasB;
        end
    case 6
        if isempty(varargin{1}) == 1
            PasoFrame = 8;
        else
            PasoFrame = round(varargin{1}*8);
        end
        if isempty(varargin{2}) == 1
            VideoFrameRate = 100;
        else
            VideoFrameRate = varargin{2};
        end
        if isempty(varargin{3}) == 1
            mostrar_firmas = 'no';
        else
            mostrar_firmas = varargin{3};
        end
        if isempty(varargin{4}) == 1
            Firmas = [];
        else
            Firmas = varargin{4};
        end
        if isempty(varargin{5}) == 1
            Color_Firmas = Color_FirmasB;
            for color = 1:1:ceil(length(Firmas)/length(Color_FirmasB))
                Color_Firmas(:,color) = Color_FirmasB;
            end
        else
            Color_FirmasI = varargin{5};
            Color_FirmasI = reshape(Color_FirmasI,[],1);
            Color_Firmas = Color_FirmasI;
            for color = 1:1:ceil(length(Firmas)/length(Color_FirmasI))
                Color_Firmas(:,color) = Color_FirmasI;
            end
        end
    case 7
        if isempty(varargin{1}) == 1
            PasoFrame = 8;
        else
            PasoFrame = round(varargin{1}*8);
        end
        if isempty(varargin{2}) == 1
            VideoFrameRate = 100;
        else
            VideoFrameRate = varargin{2};
        end
        if isempty(varargin{3}) == 1
            mostrar_firmas = 'no';
        else
            mostrar_firmas = varargin{3};
        end
        if isempty(varargin{4}) == 1
            Firmas = [];
        else
            Firmas = varargin{4};
        end
        if isempty(varargin{5}) == 1
            Color_Firmas = Color_FirmasB;
            for color = 1:1:ceil(length(Firmas)/length(Color_FirmasB))
                Color_Firmas(:,color) = Color_FirmasB;
            end
        else
            Color_FirmasI = varargin{5};
            Color_FirmasI = reshape(Color_FirmasI,[],1);
            Color_Firmas = Color_FirmasI;
            for color = 1:1:ceil(length(Firmas)/length(Color_FirmasI))
                Color_Firmas(:,color) = Color_FirmasI;
            end
        end
        if isempty(varargin{6}) == 1
            Marker_label = 1 : size(Markers,2);
        else
            Marker_label = varargin{6};
        end
        
        
end

NombreArchivo = 'Markers';


%Parametros para vizualizacion
escala = 500;   %Escala para los ejes del sistema de coordenadas
xmin = min(min(Markers(:,:,1)));
xmax = max(max(Markers(:,:,1)));
ymin = min(min(Markers(:,:,2)));
ymax = max(max(Markers(:,:,2)));
zmin = min(min(Markers(:,:,3)));
zmax = max(max(Markers(:,:,3)));
escala_ejes = 1;    %Escala para el tamano de los ejes del plot
ejes = [xmin xmax ymin ymax zmin zmax]*escala_ejes; %Tamano de los ejes del plot
NMarkers=size(Markers,2);
%==========================================================================
%Parametros para presentacion de resultados
%PasoFrame = 8; %Paso de animacion en marcos. Numero entero.
%Marcadores en figura
mostrar_index = 'si'; %'si' - 'no'
%Registros en pantalla
mostrar_registro = 'si'; %'yes' - 'no'
%Firmas en figura
%mostrar_firmas = 'si' - 'no'
%Firmas = [a b c ...] - Nodos a firmar
%Color_Firmas = ['r' 'c' 'm' ...] Colores de firmas segun sintaxis de
%               plot (correspondencia con Firmas)
for frame = 1:PasoFrame:size(Markers,1)
    t1 = tic; %Toma registro del tiempo al iniciar el frame
    figure(1)
    plot3(Markers(frame,:,1),Markers(frame,:,2),Markers(frame,:,3),'.')
    if exist('AZ','var') && exist('EL','var')
        view(AZ,EL)
    end
    grid
    hold on
    %Firma de nodos
    if strcmpi(mostrar_firmas,'yes')
        fr_o = 1; %frame inicial para firma
        for Nfirmas = 1:length(Firmas)
             plot3(Markers(fr_o:frame,Firmas(Nfirmas),1),... %(X)
                Markers(fr_o:frame,Firmas(Nfirmas),2),... %(Y)
                Markers(fr_o:frame,Firmas(Nfirmas),3),...(Z)
                Color_Firmas(Nfirmas))%Color
             plot3(Markers(frame,Firmas(Nfirmas),1),... %(X)
                Markers(frame,Firmas(Nfirmas),2),... %(Y)
                Markers(frame,Firmas(Nfirmas),3),...(Z)
                strcat(Color_Firmas(Nfirmas),'o'))%Color Marcador
        end
    end
    %Ajuste de la ventana
    axis(ejes)
    %Indices de marcadores presentados en pantalla
    if strcmpi('si',mostrar_index)
        for MarkerIndex =  1:size(Markers,2)
            X = Markers(frame,MarkerIndex,1);
            Y = Markers(frame,MarkerIndex,2);
            Z = Markers(frame,MarkerIndex,3);
%             text(X,Y,Z,num2str(MarkerIndex))
            text(X,Y,Z,Marker_label(MarkerIndex))
            
        end
    end
    %Registros presentados en pantalla
    if strcmpi(mostrar_registro,'si')
        title(strcat(NombreArchivo,', t =',num2str(frame*1/VideoFrameRate),...
            ' s', ',Frame=',num2str(frame),', ',' ',num2str(NMarkers),' Nodes' ))
        xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]')
    end
    t2 = toc(t1); %toma registro del lapso al final del frame
    pause(PasoFrame*1/VideoFrameRate-t2); %Calcula una pausa para ajustar la simulacion
    hold off
    [AZ,EL] = view; %Ajuste del punto de vista
end
%Borrado de variables que estan asociadas al proceso
clear AZ EL frame MarkerIndex X Y Z escala NombreArchivo NMarkers ejes
clear escala_ejes xmin xmax ymin ymax zmin zmax mostrar_index mostrar_registro
clear PasoFrame t1 t2 mostrar_firmas fr_o Nfirmas Firmas Color_Firmas