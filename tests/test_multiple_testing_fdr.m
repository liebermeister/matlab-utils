% Tests for multiple_testing_fdr

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

%% known values (Benjamini-Hochberg)
assert(isequal(multiple_testing_fdr([0.01 0.04 0.03 0.5], 0.08), logical([1 1 1 0])));
assert(isequal(multiple_testing_fdr([0.01 0.04 0.03 0.5], 0.04), logical([1 0 0 0])));

%% nan values and empty input
assert(isequal(multiple_testing_fdr([0.001 nan], 0.05), [true false]));
assert(isempty(multiple_testing_fdr([], 0.05)));
assert(~any(multiple_testing_fdr([nan nan], 0.05)));

%% matrix shape is kept
assert(isequal(size(multiple_testing_fdr(rand(3,4), 0.05)), [3 4]));

%% empirical false discovery rate equals the nominal value
rng(1);
n = 1000; n_true = 200; q = 0.1; fdp = zeros(2000,1);
for i = 1:2000
  p = [rand(n-n_true,1); 1e-5 * rand(n_true,1)];
  s = multiple_testing_fdr(p, q);
  fdp(i) = sum(s(1:n-n_true)) / max(1,sum(s));
end
assert(abs(mean(fdp) - q * (n-n_true)/n) < 0.005);
