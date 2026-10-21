function [x, fval, exitflag] = lp_solve(f, A, b, A_eq, b_eq, lb, ub)

% [x, fval, exitflag] = lp_solve(f, A, b, A_eq, b_eq, lb, ub)
%
% Solve the linear program   min f' * x   subject to
%   A * x <= b,   A_eq * x == b_eq,   lb <= x <= ub
%
% Exit flags follow the linprog convention
% (1: solution found, -2: infeasible, -3: unbounded).
%
% Solver choice:
%  - CPLEX (cplexlp) is used if it is on the Matlab path. If a CPLEX call
%    throws an error, the problem is solved with linprog instead, and CPLEX
%    is not used again in this Matlab session.
%  - Otherwise, Matlab's linprog is used. If linprog's default algorithm
%    fails in the Matlab installation, the interior-point algorithm is used.
%
% To use linprog even if CPLEX is on the path, call
%   setpref('matlab_utils','lp_solver','linprog')
% (and rmpref('matlab_utils','lp_solver') to undo this). This is needed if
% CPLEX crashes Matlab, which a fallback cannot catch; this happens with
% CPLEX 12.10 in recent Matlab versions.

eval(default('A_eq','[]','b_eq','[]','lb','[]','ub','[]'));

if use_cplex,
  try
    [x, fval, exitflag] = cplexlp(f, A, b, A_eq, b_eq, lb, ub, [], cplex_options);
    return
  catch err
    warning('lp_solve:cplexFailed', 'CPLEX failed (%s); using linprog from now on.', err.message);
    use_cplex(false);
  end
end

[x, fval, exitflag] = linprog(f, A, b, A_eq, b_eq, lb, ub, linprog_options);

% ----------------------------------------------------------------

function flag = use_cplex(new_flag)

% Whether to use CPLEX; decided once per Matlab session.
% use_cplex(false) switches CPLEX off for the rest of the session.

persistent chosen

if nargin,
  chosen = new_flag;
elseif isempty(chosen),
  chosen = ~strcmp(getpref('matlab_utils','lp_solver','auto'), 'linprog') ...
           && exist('cplexlp','file') > 0;
end

flag = chosen;

% ----------------------------------------------------------------

function options = cplex_options()

% CPLEX options without screen output

persistent chosen

if isempty(chosen),
  try
    chosen = cplexoptimset('Display','off');
  catch
    chosen = [];
  end
end

options = chosen;

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
