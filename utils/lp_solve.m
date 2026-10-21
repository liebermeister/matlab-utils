function [x, fval, exitflag] = lp_solve(f, A, b, A_eq, b_eq, lb, ub)

% [x, fval, exitflag] = lp_solve(f, A, b, A_eq, b_eq, lb, ub)
%
% Solve the linear program   min f' * x   subject to
%   A * x <= b,   A_eq * x == b_eq,   lb <= x <= ub
%
% Wrapper around Matlab's linprog (no display output). Exit flags follow the
% linprog convention (1: solution found, -2: infeasible, -3: unbounded).
% If linprog's default algorithm fails in the Matlab installation, the
% interior-point algorithm is used instead.
%
% CPLEX is not used: CPLEX 12.10 (the last version with a Matlab interface)
% crashes recent Matlab versions.

eval(default('A_eq','[]','b_eq','[]','lb','[]','ub','[]'));

[x, fval, exitflag] = linprog(f, A, b, A_eq, b_eq, lb, ub, linprog_options);

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
