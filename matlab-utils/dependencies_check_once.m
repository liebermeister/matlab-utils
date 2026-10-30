function dependencies_check_once(dependencies_function, varargin)

% DEPENDENCIES_CHECK_ONCE Run a package's dependency check once per Matlab session
%
% dependencies_check_once(dependencies_function, varargin)
%
% dependencies_function: name of the function that checks the dependencies
% varargin:              arguments of this function
%
% The main functions of a package call this function, so the check runs
% automatically, but does not slow down repeated calls.

persistent checked

if any(strcmp(checked, dependencies_function))
  return
end

checked{end+1} = dependencies_function;
feval(dependencies_function, varargin{:});
