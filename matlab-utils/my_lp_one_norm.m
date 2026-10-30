function x_lp = my_lp_one_norm(A,b,lb,ub,lambda)

% supposed to solve 
%      sum(abs(x)) -> min     s.t.     A*x = b (approximately)

% test
% m = 16; n = 8; A = randn(m,n); b = randn(m,1); x_lp = my_lp_one_norm(A,b,1); [A*x_lp,b]
 
[m,n] = size(A);
f     = [ zeros(n,1); lambda * ones(m,1); lambda * ones(m,1) ];
Aeq   = [ A, -lambda * eye(m), +lambda * eye(m) ];
Lb    = [ lb; zeros(m,1); zeros(m,1) ];
Ub    = [ ub; Inf*ones(m,1); Inf*ones(m,1);];

xzz   = lp_solve(f,[],[], Aeq,b,Lb,Ub);

x_lp  = xzz(1:n,:);
