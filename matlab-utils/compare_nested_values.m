function differences = compare_nested_values(a, b, options, path)

% differences = compare_nested_values(a, b, options)
%
% Compare two (possibly nested) values, e.g. results of a computation and stored reference results.
% Structs (also struct arrays) and cell arrays are compared element by element; numerical arrays
% are compared with a relative tolerance (NaN values at the same positions count as equal).
%
% Inputs
%   a, b      values to be compared (a: new values, b: reference values)
%   options   struct with (optional) fields
%     .rel_tol      relative tolerance                       (default 1e-6)
%     .abs_tol      absolute tolerance                       (default 1e-9)
%     .ignore       cell array of names (struct fields) to be ignored (default {})
%     .max_report   maximal number of reported differences   (default 100)
%
% Output
%   differences   struct array with fields
%     .path         location of the difference (e.g. 'network.N' or 'c{3}.value')
%     .type         'value', 'size', 'class', 'missing_in_a', 'missing_in_b'
%     .max_abs_diff maximal absolute difference (only for type 'value')
%     .max_rel_diff maximal relative difference (only for type 'value')
%   An empty struct array means that both values agree within the tolerances.
%
% Numerical values are considered equal if |a - b| <= abs_tol + rel_tol * max(|a|,|b|) elementwise.
% Graphics objects and function handles are not compared.

if ~exist('options','var') || isempty(options), options = struct; end
if ~exist('path','var'), path = ''; end
options = set_default(options, 'rel_tol', 1e-6);
options = set_default(options, 'abs_tol', 1e-9);
options = set_default(options, 'ignore', {});
options = set_default(options, 'max_report', 100);

differences = struct('path', {}, 'type', {}, 'max_abs_diff', {}, 'max_rel_diff', {});

if is_not_comparable(a) || is_not_comparable(b)
  return
end

if ~strcmp(class(a), class(b)) && ~(isnumeric(a) && isnumeric(b)) && ~(islogical(a) || islogical(b))
  differences = add_difference(differences, path, 'class');
  return
end

if ~isequal(size(a), size(b))
  differences = add_difference(differences, path, 'size');
  return
end

if isstruct(a)
  fa = fieldnames(a); fb = fieldnames(b);
  fa = setdiff(fa, options.ignore, 'stable'); fb = setdiff(fb, options.ignore, 'stable');
  for it = 1:numel(setdiff(fb, fa)), m = setdiff(fb, fa); differences = add_difference(differences, join_path(path, m{it}), 'missing_in_a'); end
  for it = 1:numel(setdiff(fa, fb)), m = setdiff(fa, fb); differences = add_difference(differences, join_path(path, m{it}), 'missing_in_b'); end
  fields = intersect(fa, fb, 'stable');
  for ie = 1:numel(a)
    for it = 1:numel(fields)
      if numel(a) == 1, p = join_path(path, fields{it}); else, p = join_path(sprintf('%s(%d)', path, ie), fields{it}); end
      differences = [differences, compare_nested_values(a(ie).(fields{it}), b(ie).(fields{it}), options, p)];
      if numel(differences) >= options.max_report, return; end
    end
  end

elseif iscell(a)
  for ie = 1:numel(a)
    differences = [differences, compare_nested_values(a{ie}, b{ie}, options, sprintf('%s{%d}', path, ie))];
    if numel(differences) >= options.max_report, return; end
  end

elseif isnumeric(a) || islogical(a)
  a = double(full(a(:))); b = double(full(b(:)));
  nan_a = isnan(a); nan_b = isnan(b);
  if any(nan_a ~= nan_b)
    differences = add_difference(differences, path, 'value', inf, inf);
    return
  end
  ok   = ~nan_a;
  absd = abs(a(ok) - b(ok));
  absd(a(ok) == b(ok)) = 0;  % equal infinite values
  scale = max(abs(a(ok)), abs(b(ok)));
  if any(absd > options.abs_tol + options.rel_tol * scale)
    reld = absd ./ max(scale, realmin);
    differences = add_difference(differences, path, 'value', max(absd), max(reld));
  end

else
  % char, string, categorical, tables, other objects
  if ~isequaln(a, b)
    differences = add_difference(differences, path, 'value');
  end
end


% -----------------------------------------------------------

function r = is_not_comparable(x)
r = isa(x, 'function_handle') || isa(x, 'matlab.graphics.Graphics') || isa(x, 'matlab.ui.Figure');

function p = join_path(path, name)
if isempty(path), p = name; else, p = [path '.' name]; end

function options = set_default(options, name, value)
if ~isfield(options, name) || isempty(options.(name)), options.(name) = value; end

function differences = add_difference(differences, path, type, max_abs_diff, max_rel_diff)
if ~exist('max_abs_diff','var'), max_abs_diff = nan; end
if ~exist('max_rel_diff','var'), max_rel_diff = nan; end
differences(end+1) = struct('path', path, 'type', type, 'max_abs_diff', max_abs_diff, 'max_rel_diff', max_rel_diff);
