function idx_org_cell = idx2orgcell(idx,cumsum_idx)
    N_cumsum = numel(cumsum_idx);
    
    for i = 1 : N_cumsum
        if i==1
            if (idx <= cumsum_idx(i))
                idx_org_cell = 1;
            end
%         elseif i==N_cumsum
%             if (idx <= cumsum_idx(1))
%                 idx_org_cell = 1;
%             end
        else
            
            if (idx > cumsum_idx(i-1))&&(idx <= cumsum_idx(i))
                idx_org_cell = i;
            end
        end
    end
end
   