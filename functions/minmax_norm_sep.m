function [d_n,minmax] =  minmax_norm_sep(d)
% data [samples, channels]

v_max = max(abs(d));
v_min = min(abs(d));

minmax = [v_min,v_max];

d_n = (d - v_min)./(v_max-v_min);
d_n(:,(v_max-v_min)==0) = 0;

end