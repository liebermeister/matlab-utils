% Tests for lp_solve, qp_solve and optim_solver
%
% The Gurobi tests run only if Gurobi is on the Matlab path; afterwards,
% the previous solver choice is restored.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

% LP: max x1 + 2 x2  s.t.  x1 + x2 <= 1,  x1 - x2 == 0.2,  0 <= x <= 1
f    = [-1; -2];
A    = [1 1];   b    = 1;
A_eq = [1 -1];  b_eq = 0.2;
xl   = [0; 0];  xu   = [1; 1];

% QP: min 1/2 |x - [1; 2]|^2  s.t.  x1 + x2 <= 1,  x >= 0
H    = eye(2);
h    = -[1; 2];

has_gurobi = exist('gurobi', 'file') > 0;
previous   = optim_solver;

%% lp_solve with linprog
optim_solver('matlab');
[x, fval, exitflag] = lp_solve(f, A, b, A_eq, b_eq, xl, xu);
assert(exitflag == 1 && max(abs(x - [0.6; 0.4])) < 1e-6 && abs(fval + 1.4) < 1e-6);
optim_solver(previous);

%% qp_solve with quadprog
optim_solver('matlab');
[x, fval, exitflag] = qp_solve(H, h, A, b, [], [], xl, []);
assert(exitflag == 1 && max(abs(x - [0; 1])) < 1e-4 && abs(fval + 1.5) < 1e-4);
optim_solver(previous);

%% lp_solve with Gurobi: same solution and Lagrange multipliers as linprog
if has_gurobi,
  optim_solver('matlab');
  [x1, fval1, exitflag1, ~, lambda1] = lp_solve(f, A, b, A_eq, b_eq, xl, xu);
  optim_solver('gurobi');
  [x2, fval2, exitflag2, output2, lambda2] = lp_solve(f, A, b, A_eq, b_eq, xl, xu);
  optim_solver(previous);
  assert(strcmp(output2.solver, 'gurobi'));
  assert(exitflag2 == 1 && max(abs(x2 - x1)) < 1e-6 && abs(fval2 - fval1) < 1e-6);
  assert(abs(lambda2.ineqlin - lambda1.ineqlin) < 1e-6 && abs(lambda2.eqlin - lambda1.eqlin) < 1e-6);
end

%% qp_solve with Gurobi: same solution as quadprog
if has_gurobi,
  optim_solver('gurobi');
  [x, fval, exitflag, output] = qp_solve(H, h, A, b, [], [], xl, []);
  optim_solver(previous);
  assert(strcmp(output.solver, 'gurobi'));
  assert(exitflag == 1 && max(abs(x - [0; 1])) < 1e-4 && abs(fval + 1.5) < 1e-4);
end

%% Gurobi: infeasible and unbounded problems
if has_gurobi,
  optim_solver('gurobi');
  [x, ~, exitflag_infeasible] = lp_solve([1; 1], [1 1], -1, [], [], xl, xu);
  [~, ~, exitflag_unbounded]  = lp_solve([-1; 0], [], [], [], [], [], []);
  optim_solver(previous);
  assert(isempty(x) && exitflag_infeasible == -2 && exitflag_unbounded == -3);
end
