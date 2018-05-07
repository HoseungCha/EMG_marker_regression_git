function d_n =  minmax_norm(d)
% data [samples, channels]

v_max = max(d);
v_min = min(d);

d_n = (d - v_min)./(v_max-v_min);

d_n(:,(v_max-v_min)==0) = 0;
end