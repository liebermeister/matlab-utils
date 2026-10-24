% res = nanquantile(M,q)
% quantiles of columns of M

function res = nanquantile(M,q)

res = nan;
for i=1:size(M,2),
  dum=sort(M(:,i));
  dum=dum(isfinite(dum));
  res(i)=nan;
  if length(dum),
    if q>1/length(dum),
      res(i)= 0.5*(dum(floor(q*length(dum))) + dum(floor(q*length(dum))+1));
    else,
      res(i)= dum(ceil(q*length(dum)));  
    end
  end
end
