% Tests for lognormal_normal2log and lognormal_log2normal

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

%% arithmetic convention: round trip
[mu_log, sigma_log] = lognormal_normal2log(10, 100, 'arithmetic');
[mu, sigma]         = lognormal_log2normal(mu_log, sigma_log, 'arithmetic');
assert(abs(mu - 10) < 1e-10 && abs(sigma - 100) < 1e-8);

%% geometric convention: round trip
[mu_log, sigma_log] = lognormal_normal2log([1; 5], [0.5; 2], 'geometric');
[mu, sigma]         = lognormal_log2normal(mu_log, sigma_log, 'geometric');
assert(max(abs([mu; sigma] - [1; 5; 0.5; 2])) < 1e-12);
