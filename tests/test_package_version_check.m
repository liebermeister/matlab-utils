% Tests for package_version_check

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

%% sufficient versions
assert(package_version_check('utils', 'matlab_utils_version', '1.0.0') == 1);
assert(package_version_check('utils', 'matlab_utils_version', '1.0') == 1);

%% a newer version is required: the parts of the number are compared one by one
lastwarn('');
assert(package_version_check('utils', 'matlab_utils_version', '1.0.1') == 0);
assert(contains(lastwarn, 'or later is required'));
assert(package_version_check('utils', 'matlab_utils_version', '1.10') == 0);

%% a newer major version than the required one
lastwarn('');
assert(package_version_check('utils', 'matlab_utils_version', '0.9') == 0);
assert(contains(lastwarn, 'major version 0'));

%% missing package
lastwarn('');
assert(package_version_check('Unknown package', 'no_such_version_function', '1.0.0') == 0);
assert(contains(lastwarn, 'not installed'));

%% dependencies_check_once: the check runs only once
counter_file = [tempname '.txt'];
folder = tempname;
mkdir(folder);
fid = fopen(fullfile(folder, 'my_test_dependencies.m'), 'w');
fprintf(fid, 'function my_test_dependencies(filename)\nfid = fopen(filename, ''a'');\nfprintf(fid, ''x'');\nfclose(fid);\n');
fclose(fid);
addpath(folder);
clear dependencies_check_once
dependencies_check_once('my_test_dependencies', counter_file);
dependencies_check_once('my_test_dependencies', counter_file);
assert(length(fileread(counter_file)) == 1);
rmpath(folder);
rmdir(folder, 's');
delete(counter_file);
