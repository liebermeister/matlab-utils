function U = tensor_scale(T,k,x);

%U = tensor_scale(T,k,x);
%
% calculate U_(ab..i..lm) = sum_i T_(ab..i..lm) * x_i
% where i is the kth index of T

n_dims = length(size(T));
TT     = tensor_product(T,diag(x),k,1);
U      = permute(TT,[1:k-1, n_dims, k:n_dims-1]);
