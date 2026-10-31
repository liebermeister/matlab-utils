function significant = multiple_testing_fdr(all_p, false_discovery_rate)

% MULTIPLE_TESTING_FDR - Significance for multiple tests at a given false discovery rate
%
% significant = multiple_testing_fdr(all_p, false_discovery_rate)
%
% Benjamini-Hochberg procedure (valid for independent tests)
%
% all_p (vector or matrix) contains the p values for all tests; nan values are ignored
% significant: logical array of the same size as all_p (false for nan values)

p = sort(column(all_p(isfinite(all_p))));

significant = false(size(all_p));

if isempty(p), return; end

n_tests  = length(p);
n_accept = find(p <= (1:n_tests)' / n_tests * false_discovery_rate, 1, 'last');

if length(n_accept)
  significant = (all_p <= p(n_accept));
end
