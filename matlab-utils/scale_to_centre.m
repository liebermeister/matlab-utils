function M = scale_to_csntre(M)

% M = scale_to_centre(M)
%
% M: row vector or matrix (then each row is treated separately)
% linear scaling for positive values such that 
%                  0  -> 0
% mean(min(x),max(x)) -> 0.5

M = M ./ repmat(10^-10 + nanmin(M')'+nanmax(M')',1,size(M,2));