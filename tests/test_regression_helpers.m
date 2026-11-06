% Tests for compare_nested_values and run_script_steps

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

a = struct('x', [1 2 nan], 'c', {{'abc', [1; 2]}}, 's', struct('y', sparse([1 0; 0 2])), 'f', @sin);

%% compare_nested_values: equal values (within tolerance) give no differences
b = a; b.x(1) = 1 + 1e-9; b.f = @cos;
d = compare_nested_values(a, b);
assert(isempty(d));

%% compare_nested_values: detects value, size, class and field differences
b = a; b.x(2) = 2.1; b.c{1} = 'abd'; b.s.y = [1 2 3]; b.extra = 1; b.f = @cos;
d = compare_nested_values(a, b);
paths = {d.path}; types = {d.type};
assert(any(strcmp(paths, 'x') & strcmp(types, 'value')));
assert(abs(d(strcmp(paths, 'x')).max_rel_diff - 0.1/2.1) < 1e-12);
assert(any(strcmp(paths, 'c{1}') & strcmp(types, 'value')));
assert(any(strcmp(paths, 's.y') & strcmp(types, 'size')));
assert(any(strcmp(paths, 'extra') & strcmp(types, 'missing_in_a')));
assert(~any(strcmp(paths, 'f')));  % function handles are not compared
d = compare_nested_values(1, 'a');
assert(strcmp(d.type, 'class'));

%% compare_nested_values: NaN at different positions; option 'ignore'
d = compare_nested_values([1 nan], [1 2]);
assert(numel(d) == 1 && isinf(d.max_abs_diff));
d = compare_nested_values(struct('t', 1, 'u', 2), struct('t', 5, 'u', 2), struct('ignore', {{'t'}}));
assert(isempty(d));

%% run_script_steps: common workspace, 'clear' in a step, error handling
r = run_script_steps({'x = 1;', 'clear; y = 2;', 'z = y + 1; assert(~exist(''x'',''var''));', 'error(''my:id'', ''planned error'')', 'w = 1;'});
assert(numel(r) == 4);
assert(all([r(1:3).ok]) && ~r(4).ok);
assert(strcmp(r(4).message, 'planned error'));
assert(all([r.time] >= 0));
r = run_script_steps({'error(''planned error'')', 'w = 1;'}, 0);
assert(numel(r) == 2 && ~r(1).ok && r(2).ok);
