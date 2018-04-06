function [vxx,vy] = my_voronoi2(varargin)
%VORONOI Voronoi diagram.

[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(2,4,nargs));

x = args{1}(:);
y = args{2}(:);
c_w = args{3}(:);

%  if nargs == 2,
%      tri = delaunay(x,y);
%      ls = '';
%  else 
%      arg3 = args{3};
%      if nargs == 3,
%          ls = '';
%      else
%          arg4 = args{4};
%          ls = arg4;
%      end 
%      if isempty(arg3),
%          tri = delaunay(x,y);
%      elseif ischar(arg3),
%          tri = delaunay(x,y); 
%          ls = arg3;
%      elseif iscellstr(arg3),
%          tri = delaunay(x,y,arg3);
%      else
%          tri = arg3;
%      end
%  end

tri = delaunay(x,y);
%tri = tri([3,4,6,7,8,10,11,12,13,14,15,16,17,19,20,21],:);
ls = 'k';
% re-orient the triangles so that they are all clockwise
xt = x(tri); 
yt = y(tri);
%Because of the way indexing works, the shape of xt is the same as the
%shape of tri, EXCEPT when tri is a single row, in which case xt can be a
%column vector instead of a row vector.
if size(xt,2) == 1 
    xt = xt';
    yt = yt';
end
ot = xt(:,1).*(yt(:,2)-yt(:,3)) + ...
    xt(:,2).*(yt(:,3)-yt(:,1)) + ...
    xt(:,3).*(yt(:,1)-yt(:,2));
bt = find(ot<0);
tri(bt,[1 2]) = tri(bt,[2 1]);

% Compute centers of triangles
c = circle(tri,x,y);

% Create matrix T where i and j are endpoints of edge of triangle T(i,j)
n = numel(x);
t = repmat((1:size(tri,1))',1,3);
T = sparse(tri,tri(:,[3 1 2]),t,n,n); 

% i and j are endpoints of internal edge in triangle E(i,j)
E = (T & T').*T; 
% i and j are endpoints of external edge in triangle F(i,j)
F = xor(T, T').*T;

% v and vv are triangles that share an edge
[i,j,v] = find(triu(E));
[i,j,vv] = find(triu(E'));
% Internal edges
vx = [c(v,1) c(vv,1)]';
vy = [c(v,2) c(vv,2)]';

%%% Compute lines-to-infinity
% i and j are endpoints of the edges of triangles in z
[i,j,z] = find(F);
% Counter-clockwise components of lines between endpoints
dx = x(j) - x(i);
dy = y(j) - y(i);

% Calculate scaling factor for length of line-to-infinity
% Distance across range of data
rx = max(x)-min(x); 
ry = max(y)-min(y);
% Distance from vertex to center of data
cx = (max(x)+min(x))/2 - c(z,1); 
cy = (max(y)+min(y))/2 - c(z,2);
% Sum of these two distances
nm = sqrt(rx.*rx + ry.*ry) + sqrt(cx.*cx + cy.*cy);
% Compute scaling factor
scale = nm./sqrt((dx.*dx+dy.*dy));
    
% Lines from voronoi vertex to "infinite" endpoint
% We know it's in correct direction because compononents are CCW
ex = [c(z,1) c(z,1)-dy.*scale]';
ey = [c(z,2) c(z,2)+dx.*scale]';
% Combine with internal edges
vx = [vx ex];
vy = [vy ey];

classes = length(unique(c_w));
idxs = [];solidLines = [];
for class = 1:classes
	indices = find(c_w==class);
	fLin = @(xC,m,b) m*xC+b;
	if length(indices)>1,
		%Prots = zeros(length(find(triu(ones(length(indices),length(indices)))>0))-length(indices),2);
		% find every possibility for 2 Prototypes of the same class
		Prots = [];
		for count1 = 1:length(indices)-1
			for count2 = count1+1:length(indices)
				Prots = [Prots;indices(count1),indices(count2)];
			end
		end
		% share 2 Prototypes of the same class an edge ?
		for rows = 1:size(Prots,1)
			between = mean([x(Prots(rows,1)),y(Prots(rows,1));x(Prots(rows,2)),y(Prots(rows,2))]);
			
			for col = 1:size(vx,2)
				P1 = [vx(1,col),vy(1,col)];
				P2 = [vx(2,col),vy(2,col)];
				[m,b] = genLine(P1,P2);
				
				%dist_splicesites (j,2) = round ((dist2)*1e2)*1e-2;
				%dist_nonsplicesites (:,2) - i) < eps ('single')
				if (round(between(2)*1e4)*1e-4 == round(fLin(between(1),m,b)*1e4)*1e-4),
					idxs = [idxs,col];
                else
                    solidLines = [solidLines,col];
				end
			end
		end
	end
end
vx2 = vx;vy2 = vy;
vx(:,idxs) = [];
vy(:,idxs) = [];
% vx2(:,solidLines) = [];
% vy2(:,solidLines) = [];
%vx = vx(:,idxs);
%vy = vy(:,idxs);

%vx = vx(:,[2,3,5,6,7,8,10,11,12,13,14,15,16,17,20,21,22,24,25,26,27,29,30,32,33]);
%vy = vy(:,[2,3,5,6,7,8,10,11,12,13,14,15,16,17,20,21,22,24,25,26,27,29,30,32,33]);

if nargout<2
    % Plot diagram
    if isempty(cax)
        % If no current axes, create one
        cax = gca;
    end
    if isempty(ls)
        % Default linespec
        ls = '-';
    end
    [l,c,mp,msg] = colstyle(ls); error(msg) % Extract from linespec
    if isempty(mp)
        % Default markers at points        
        mp = '.';
    end
    if isempty(l)
        % Default linestyle
        l = get(ancestor(cax,'figure'),'defaultaxeslinestyleorder'); 
    end
    if isempty(c), 
        % Default color        
        co = get(ancestor(cax,'figure'),'defaultaxescolororder');
        c = co(1,:);
    end
    % Plot prototypes
%     h1 = plot(x,y,'marker',mp,'color',c,'linestyle','none','parent',cax);
% t=arrayfun(@(i) plot(w(c_w==i,1),w(c_w==i,2),'o','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','w'),1:nb_classes);
    h1 = plot(x,y,'o','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','w','parent',cax);
    arrayfun(@(i) text(x(i),y(i)+0.01,num2str(c_w(i)),'color','k','VerticalAlignment','middle','HorizontalAlignment','center','FontWeight','bold','FontSize',9),1:length(c_w));
    % Plot voronoi lines
    % receptive fields
    h3 = line(vx2,vy2,'color',[0.7 0.7 0.7],'linestyle','-','parent',cax,...%l
        'yliminclude','off','xliminclude','off');
    % decision boundary
    h2 = line(vx,vy,'color',c,'linestyle','-','parent',cax,...%l
        'yliminclude','off','xliminclude','off');    
    if nargout==1, vxx = [h1; h2; h3]; end % Return handles
else
    vxx = vx; % Don't plot, just return vertices
end

function [m,b] = genLine(P1,P2)
m = (P1(2)-P2(2))/(P1(1)-P2(1));
b = P1(2)-m*P1(1);


function c = circle(tri,x,y)
%CIRCLE Return center and radius for circumcircles
%   C = CIRCLE(TRI,X,Y) returns a N-by-2 vector containing [xcenter(:)
%   ycenter(:)] for each triangle in TRI.

% Reference: Watson, p32.
x1 = x(tri(:,1)); x2 = x(tri(:,2)); x3 = x(tri(:,3));
y1 = y(tri(:,1)); y2 = y(tri(:,2)); y3 = y(tri(:,3));

% Set equation for center of each circumcircle: 
%    [a11 a12;a21 a22]*[x;y] = [b1;b2] * 0.5;

a11 = x2-x1; a12 = y2-y1;
a21 = x3-x1; a22 = y3-y1;

% Solve the 2-by-2 equation explicitly
idet = a11.*a22 - a21.*a12;

% Add small random displacement to points that are either the same
% or on a line.
d = find(idet == 0);
if ~isempty(d), % Add small random displacement to points
    delta = sqrt(eps);
    x1(d) = x1(d) + delta*(rand(size(d))-0.5);
    x2(d) = x2(d) + delta*(rand(size(d))-0.5);
    x3(d) = x3(d) + delta*(rand(size(d))-0.5);
    y1(d) = y1(d) + delta*(rand(size(d))-0.5);
    y2(d) = y2(d) + delta*(rand(size(d))-0.5);
    y3(d) = y3(d) + delta*(rand(size(d))-0.5);
    a11 = x2-x1; a12 = y2-y1;
    a21 = x3-x1; a22 = y3-y1;
    idet = a11.*a22 - a21.*a12;
end

b1 = a11 .* (x2+x1) + a12 .* (y2+y1);
b2 = a21 .* (x3+x1) + a22 .* (y3+y1);

idet = 0.5 ./ idet;

xcenter = ( a22.*b1 - a12.*b2) .* idet;
ycenter = (-a21.*b1 + a11.*b2) .* idet;

c = [xcenter ycenter];


