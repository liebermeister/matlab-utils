function [x, fval, exitflag, output, lambda] = gurobi_solve(H, f, A, b, A_eq, b_eq, lb, ub)

% [x, fval, exitflag, output, lambda] = gurobi_solve(H, f, A, b, A_eq, b_eq, lb, ub)
%
% Solve a linear (H = []) or convex quadratic program with Gurobi:
%   min 1/2 * x' * H * x + f' * x   subject to
%   A * x <= b,   A_eq * x == b_eq,   lb <= x <= ub
%
% Used by lp_solve and qp_solve; inputs and outputs as in linprog and quadprog

n = length(f);

if isempty(A),    A    = zeros(0,n); b    = zeros(0,1); end
if isempty(A_eq), A_eq = zeros(0,n); b_eq = zeros(0,1); end
if isempty(lb),   lb   = -inf(n,1); end
if isempty(ub),   ub   =  inf(n,1); end

n_ineq = size(A,1);

model.A          = sparse([A; A_eq]);
model.rhs        = full([b(:); b_eq(:)]);
model.sense      = [repmat('<', n_ineq, 1); repmat('=', size(A_eq,1), 1)];
model.obj        = full(f(:));
model.lb         = full(lb(:));  % Gurobi's default lower bound would be 0
model.ub         = full(ub(:));
model.modelsense = 'min';
if ~isempty(H),
  % Gurobi minimises x' * Q * x + obj' * x
  model.Q = sparse(H + H') / 4;
end

% DualReductions = 0: distinguish between infeasible and unbounded problems
params = struct('OutputFlag', 0, 'DualReductions', 0);

result = gurobi(model, params);

switch result.status,
  case 'OPTIMAL',                     exitflag =  1;
  case {'INFEASIBLE', 'INF_OR_UNBD'}, exitflag = -2;
  case 'UNBOUNDED',                   exitflag = -3;
  case 'NUMERIC',                     exitflag = -4;
  otherwise,                          exitflag =  0;
end

output = struct('message', result.status, 'solver', 'gurobi');
if isfield(result, 'itercount'), output.iterations = result.itercount; end
if isfield(result, 'runtime'),   output.runtime    = result.runtime;   end

if isfield(result, 'x'),
  x    = result.x;
  fval = result.objval;
else
  x    = [];
  fval = [];
end

% Lagrange multipliers in the linprog / quadprog convention:
%   f + H * x + A' * ineqlin + A_eq' * eqlin - lower + upper = 0
if isfield(result, 'pi') && isfield(result, 'rc'),
  lambda.ineqlin = -result.pi(1:n_ineq);
  lambda.eqlin   = -result.pi(n_ineq+1:end);
  lambda.lower   =  max(result.rc, 0);
  lambda.upper   =  max(-result.rc, 0);
else
  lambda = struct('ineqlin', [], 'eqlin', [], 'lower', [], 'upper', []);
end
