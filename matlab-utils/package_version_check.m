function ok = package_version_check(package_name, version_function, minimum_version)

% PACKAGE_VERSION_CHECK Check whether a package is installed in a sufficient version
%
% ok = package_version_check(package_name, version_function, minimum_version)
%
% package_name:     name of the package (string, used in the warning)
% version_function: name of the function that returns the package version
% minimum_version:  required version (string, like '1.2.3'; missing parts count as 0)
%
% ok: 1 if the installed version is sufficient; otherwise 0, and a warning is issued

ok = 0;

if ~exist(version_function, 'file')
  warning('%s is not installed, or too old to have a version number (required: version %s or later).', package_name, minimum_version);
  return
end

installed = feval(version_function);
difference = version_numbers(installed) - version_numbers(minimum_version);
first = find(difference, 1);
ok = isempty(first) || difference(first) > 0;

if ~ok
  warning('%s version %s is installed, but version %s or later is required.', package_name, installed, minimum_version);
end


% -----------------------------------------------------

function numbers = version_numbers(v)

numbers = zeros(1, 3);
parts = sscanf(v, '%d.%d.%d');
numbers(1:length(parts)) = parts;
