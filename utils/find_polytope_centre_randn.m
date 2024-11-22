function [x_centre, x1, x2] = find_polytope_centre_randn(M_eq,b_eq,M_ineq,b_ineq,x_lower,x_upper, epsilon, n, x_test)

% [x_centre, x1, x2] = find_polytope_centre_randn(M_eq, b_eq, M_ineq, b_ineq, x_lower, x_upper, epsilon, n, x_test)
%
% Central vector, given by the center of mass of extreme vectors (along n random axes) of a convex polytope
% default value of n: 5

eval(default('epsilon','[]','n','[]','x_test','[]'));  
  
if isempty(epsilon), epsilon = 10^-10; end 
if isempty(n), n = 5; end 

% -------------------------------
% check if test vector satisfies all constraints (used only for debugging)

if length(x_test),
  lower_violated = find(x_test < x_lower + epsilon)
  upper_violated = find(x_test > x_upper - epsilon)
  ineq_violated =[];
  if ~isempty(M_ineq),
    ineq_violated = find(M_ineq * x_test > b_ineq - epsilon)
  end
  eq_violated =[];
  if ~isempty(M_eq),
    eq_violated = find(M_eq * x_test ~= b_eq)
  end
  if length([lower_violated; lower_violated; ineq_violated; eq_violated]), 
    display('Warning: test vector does not satisfy constraints! Results for x_test:');
  end
end

% -------------------------------
% actual function

x_length = length(x_lower);

if x_length == 0, 
  x_centre = [];
  warning('x vector has zero length');
  return
end

% using this lead to problems before (no feasible solution found)!!
% opt = optimset('MaxIter',10^10,'LargeScale','off','Display','off');

x1 = [];
x2 = [];

if sum(x_upper < x_lower), error('Wrong bounds'); end

for it = 1:n,
  z = randn(x_length,1);
  if exist('cplexlp','file'),
    opt = cplexoptimset('cplex');
    [solution1,value,exitflag1] = cplexlp(z,M_ineq,b_ineq-epsilon,M_eq,b_eq,x_lower+epsilon,x_upper-epsilon,[],opt);
    [solution2,value,exitflag2] = cplexlp(z,M_ineq,b_ineq-epsilon,M_eq,b_eq,x_lower+epsilon,x_upper-epsilon,[],opt);
  else
    %opt = optimset('Display','off');
    opt = optimoptions('linprog','Display','off','Algorithm','interior-point','ConstraintTolerance',10^-10);
    [solution1,value,exitflag1] = linprog(z,M_ineq,b_ineq-epsilon,M_eq,b_eq,x_lower+epsilon,x_upper-epsilon,[],opt);
    [solution2,value,exitflag2] = linprog(z,M_ineq,b_ineq-epsilon,M_eq,b_eq,x_lower+epsilon,x_upper-epsilon,[],opt);
  end
  if [exitflag1 ~=1] + [exitflag2 ~=1],
    exitflag1 
    exitflag2
    error('No feasible point found');
  end
  if [exitflag1 ==-3] + [exitflag2 ==-3],
    exitflag1 
    exitflag2
    error('Problem is unbounded');
  end
  x1 = [x1, solution1];
  x2 = [x2, solution2];
end

x_centre = mean([x1 x2],2);
