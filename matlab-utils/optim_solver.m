function solver = optim_solver(new_solver)

% solver = optim_solver(new_solver)
%
% Solver used by lp_solve (linear programs) and qp_solve (quadratic programs)
%
%  'matlab' (default): linprog and quadprog (Optimization Toolbox)
%  'gurobi':           Gurobi; requires the Gurobi Matlab interface (function 'gurobi')
%                      on the Matlab path and a valid Gurobi license
%
% Usage:
%   optim_solver            returns the current choice
%   optim_solver('gurobi')  use Gurobi from now on (stored as a Matlab preference,
%                           so the choice holds in later Matlab sessions as well)
%   optim_solver('matlab')  go back to linprog and quadprog
%
% If 'gurobi' is chosen but Gurobi is not on the Matlab path, or if a Gurobi call
% throws an error, the Matlab solvers are used for the rest of the Matlab session
% (with a warning).

persistent chosen gurobi_failed

if isempty(chosen),
  chosen = getpref('matlab_utils', 'optim_solver', 'matlab');
end

if nargin,
  switch new_solver,
    case {'matlab', 'gurobi'},
      chosen = new_solver;
      gurobi_failed = false;
      setpref('matlab_utils', 'optim_solver', chosen);
    case 'gurobi_failed',
      % used internally by lp_solve and qp_solve
      gurobi_failed = true;
    otherwise,
      error('Unknown solver ''%s''; use ''matlab'' or ''gurobi''.', new_solver);
  end
end

solver = chosen;

if strcmp(solver, 'gurobi'),
  if isequal(gurobi_failed, true),
    solver = 'matlab';
  elseif ~exist('gurobi', 'file'),
    warning('optim_solver:noGurobi', 'Gurobi is not on the Matlab path; using linprog and quadprog instead.');
    gurobi_failed = true;
    solver = 'matlab';
  end
end
