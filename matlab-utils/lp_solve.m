function [x, fval, exitflag, output, lambda] = lp_solve(f, A, b, A_eq, b_eq, lb, ub, options)

% [x, fval, exitflag, output, lambda] = lp_solve(f, A, b, A_eq, b_eq, lb, ub, options)
%
% Solve the linear program   min f' * x   subject to
%   A * x <= b,   A_eq * x == b_eq,   lb <= x <= ub
%
% Inputs and outputs as in linprog. The optional argument 'options' (linprog
% options) is only used by linprog; by default, linprog runs without screen output.
%
% Exit flags follow the linprog convention
% (1: solution found, 0: iteration or time limit, -2: infeasible, -3: unbounded).
%
% Solver choice (see optim_solver):
%  - By default, Matlab's linprog is used. If linprog's default algorithm
%    fails in the Matlab installation, the interior-point algorithm is used.
%  - After optim_solver('gurobi'), Gurobi is used. If a Gurobi call throws
%    an error, the problem is solved with linprog instead, and Gurobi is not
%    used again in this Matlab session.

eval(default('A_eq','[]','b_eq','[]','lb','[]','ub','[]','options','[]'));

if strcmp(optim_solver, 'gurobi'),
  try
    [x, fval, exitflag, output, lambda] = gurobi_solve([], f, A, b, A_eq, b_eq, lb, ub);
    return
  catch err
    warning('lp_solve:gurobiFailed', 'Gurobi failed (%s); using linprog from now on.', err.message);
    optim_solver('gurobi_failed');
  end
end

if isempty(options),
  options = linprog_options;
end

[x, fval, exitflag, output, lambda] = linprog(f, A, b, A_eq, b_eq, lb, ub, options);

% ----------------------------------------------------------------

function options = linprog_options()

% Choose working linprog options once per Matlab session

persistent chosen

if isempty(chosen),
  chosen = optimoptions('linprog','Display','off');
  try
    [~, ~, exitflag] = linprog([1;1], [1 1], 1, [], [], [0;0], [1;1], chosen);
    default_works = (exitflag == 1);
  catch
    default_works = false;
  end
  if ~default_works,
    chosen = optimoptions('linprog','Display','off','Algorithm','interior-point');
  end
end

options = chosen;
