% Tests for convex_sampling, find_polytope_centre and related functions
%
% Most tests use the triangle  x1 >= 0, x2 >= 0, x1 + x2 <= 1

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'utils'));

rng(1);
A  = [1 1];
b  = 1;
xl = [0; 0];
xu = [1; 1];
inside = @(x) all(x(:) >= -1e-8) && all(sum(x,1) <= 1 + 1e-8);
opt = struct('x_mean',[],'x_cov',[],'n_warm',[],'n_pick',5,'flag_artificial_centering',0,'x_start',[]);

%% lp_solve
[x, fval, exitflag] = lp_solve([-1; -1], A, b, [], [], xl, xu);
assert(exitflag == 1 && abs(fval + 1) < 1e-8);

%% find_polytope_centre: interval [-1, 1]
x = find_polytope_centre([], [], [], [], -1, 1);
assert(abs(x) < 1e-8);

%% find_polytope_centre: triangle
x = find_polytope_centre([], [], A, b, xl, xu);
assert(max(abs(x - [0.25; 0.25])) < 1e-6);

%% find_polytope_centre_randn: triangle
x = find_polytope_centre_randn([], [], A, b, xl, xu, [], 20);
assert(inside(x));

%% convex_sampling: rejection method
[x, x_lower, x_upper] = convex_sampling(A, b, [], [], 20, xl, xu, 0, 'rejection', opt);
assert(isequal(size(x), [2 20]) && inside(x));
assert(max(abs([x_lower; x_upper] - [0; 0; 1; 1])) < 1e-6);

%% convex_sampling: extreme points
[x, x_lower, x_upper] = convex_sampling(A, b, [], [], 0, xl, xu, 0, 'extreme-points', opt);
assert(inside(x));
assert(max(abs([x_lower; x_upper] - [0; 0; 1; 1])) < 1e-6);

%% convex_sampling: hit-and-run
x = convex_sampling(A, b, [], [], 20, xl, xu, 0, 'hit-and-run', opt);
assert(isequal(size(x), [2 20]) && inside(x));

%% convex_sampling: hit-and-run with artificial centering
opt.flag_artificial_centering = 1;
x = convex_sampling(A, b, [], [], 20, xl, xu, 0, 'hit-and-run', opt);
assert(isequal(size(x), [2 20]) && inside(x));

%% convex_sampling: hit-and-run with Gaussian weights
opt.x_mean = [0.2; 0.2];
opt.x_cov  = 0.01 * eye(2);
x = convex_sampling(A, b, [], [], 200, xl, xu, 0, 'hit-and-run', opt);
assert(inside(x));
assert(max(abs(mean(x,2) - [0.2; 0.2])) < 0.05);

%% convex_sampling: equality constraint (x1 = x2)
[x, x_lower, x_upper] = convex_sampling(A, b, [1 -1], 0, 20, xl, xu, 0, 'rejection', opt);
assert(inside(x) && max(abs(x(1,:) - x(2,:))) < 1e-8);

%% convex_sampling_hit_and_run: box without other constraints
x_lower = -rand(5,1);
x_upper = -x_lower;
x = convex_sampling_hit_and_run([], [], x_lower, x_upper, [], [], 50, [], 5, 1);
assert(all(all(x >= x_lower - 1e-8 & x <= x_upper + 1e-8)));
