function [x, fval, exitflag, output, lambda] = qp_solve(H, f, A, b, A_eq, b_eq, lb, ub, x0, options)

% [x, fval, exitflag, output, lambda] = qp_solve(H, f, A, b, A_eq, b_eq, lb, ub, x0, options)
%
% Solve the convex quadratic program   min 1/2 * x' * H * x + f' * x   subject to
%   A * x <= b,   A_eq * x == b_eq,   lb <= x <= ub
%
% Inputs and outputs as in quadprog. The optional arguments 'x0' (start point)
% and 'options' (quadprog options) are only used by quadprog; by default,
% quadprog runs without screen output.
%
% Exit flags follow the quadprog convention
% (1: solution found, 0: iteration or time limit, -2: infeasible, -3: unbounded).
%
% Solver choice (see optim_solver):
%  - By default, Matlab's quadprog is used.
%  - After optim_solver('gurobi'), Gurobi is used. If a Gurobi call throws
%    an error, the problem is solved with quadprog instead, and Gurobi is not
%    used again in this Matlab session.

eval(default('A','[]','b','[]','A_eq','[]','b_eq','[]','lb','[]','ub','[]','x0','[]','options','[]'));

if strcmp(optim_solver, 'gurobi'),
  try
    [x, fval, exitflag, output, lambda] = gurobi_solve(H, f, A, b, A_eq, b_eq, lb, ub);
    return
  catch err
    warning('qp_solve:gurobiFailed', 'Gurobi failed (%s); using quadprog from now on.', err.message);
    optim_solver('gurobi_failed');
  end
end

if isempty(options),
  % the default algorithm (interior-point-convex) does not use a start point
  options = optimoptions('quadprog','Display','off');
  x0      = [];
end

[x, fval, exitflag, output, lambda] = quadprog(H, f, A, b, A_eq, b_eq, lb, ub, x0, options);
