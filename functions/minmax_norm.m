function [d_n,minmax] =  minmax_norm(d)
% data [samples, channels]

v_max = max(d);
v_min = min(d);

minmax = [v_min,v_max];

d_n = (d - v_min)./(v_max-v_min);
if ~isempty(find( (v_max-v_min)==0 ==1, 1) )
d_n(:,(v_max-v_min)==0) = 0;
end