%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function f = featCC(curwin,order)
   cur_xlpc = real(lpc(curwin,order)');
   cur_xlpc = cur_xlpc(2:(order+1),:);
   Nsignals = size(curwin,2);
   cur_CC = zeros(order,Nsignals);
   for i_sig = 1 : Nsignals
      cur_CC(:,i_sig)=a2c(cur_xlpc(:,i_sig),order,order)';
   end
   f = reshape(cur_CC,[1,order*Nsignals]);
end