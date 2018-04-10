function c=a2c(a,p,cp)
%Function A2C: Computation of cepstral coeficients from AR coeficients.
%
%Usage: c=a2c(a,p,cp);
%   a   - vector of AR coefficients ( without a[0] = 1 )
%   p   - order of AR  model ( number of coefficients without a[0] )
%   c   - vector of cepstral coefficients (without c[0] )
%   cp  - order of cepstral model ( number of coefficients without c[0] )

%                              Made by PP
%                             CVUT FEL K331
%                           Last change 11-02-99

for n=1:cp
  sum=0;
  if n<p+1
    for k=1:n-1
      sum=sum+(n-k)*c(n-k)*a(k);
    end
    c(n)=-a(n)-sum/n;
  else
    for k=1:p
      sum=sum+(n-k)*c(n-k)*a(k);
    end
    c(n)=-sum/n;
  end
end
end