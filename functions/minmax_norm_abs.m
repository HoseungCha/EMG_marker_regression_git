function d_n =  minmax_norm_abs(d)
% data [samples, channels]

v_max = max(abs(d));
v_min = min(abs(d));

d_n = (d - v_min)./(v_max-v_min);
d_n(:,(v_max-v_min)==0) = 0;
end