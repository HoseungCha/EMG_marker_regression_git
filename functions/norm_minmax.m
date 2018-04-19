function d_norm = norm_minmax(d)

Max = max(d);
Min = min(d);
d_norm = (d-Min)./(Max-Min);
end





%             Max = max(tmp_m_set_median);
%             Min = min(tmp_m_set_median);
%             mark_n = (tmp_m_set_median-Min)./(Max-Min);
%             figure;
%             plot(mark_n);title(name_mark(i_mark))
%             text(1:n_seg2use:n_FE*n_seg2use,min(min(mark_n))*ones(n_FE,1),...
%             name_FE(idx_FE_2_change))