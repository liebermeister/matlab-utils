% Tests for cell_string2num: numbers are converted; numbers with a comma raise an error
% (str2double would read '1,5' as 15)

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

assert(isequaln(cell_string2num({'1.5'; '2'; ''; 'abc'; '1e-06'}), [1.5; 2; NaN; NaN; 1e-06]));
assert(isequal(cell_string2num([1 2]), [1 2]));
assert(isequal(cell_string2num({1; '2'}), [1; 2]));

% numbers with commas are rejected
for bad = {'1,5', '1,00E-06', '-0,25', '1,000'}
  failed = 0;
  try, cell_string2num({'1'; bad{1}}); catch, failed = 1; end
  assert(failed, sprintf('no error for %s', bad{1}));
end
failed = 0; try, cell_string2num('1,5'); catch, failed = 1; end
assert(failed);

% text with commas that is not a number is not affected
assert(isnan(cell_string2num({'a,b'})));
assert(isnan(cell_string2num({'[1,2]'})));
