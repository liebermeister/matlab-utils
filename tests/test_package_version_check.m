% Tests for package_version_check

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

%% sufficient versions
assert(package_version_check('utils', 'matlab_utils_version', '1.0.0') == 1);
assert(package_version_check('utils', 'matlab_utils_version', '0.9') == 1);

%% a newer version is required: the parts of the number are compared one by one
lastwarn('');
assert(package_version_check('utils', 'matlab_utils_version', '1.0.1') == 0);
assert(contains(lastwarn, 'or later is required'));
assert(package_version_check('utils', 'matlab_utils_version', '1.10') == 0);

%% missing package
lastwarn('');
assert(package_version_check('Unknown package', 'no_such_version_function', '1.0.0') == 0);
assert(contains(lastwarn, 'not installed'));
