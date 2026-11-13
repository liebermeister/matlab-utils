function N = cell_string2num(C)

% N = cell_string2num(C)
%
% Convert a cell array of strings into a numerical array (non-numerical strings -> NaN).
% Numerical arrays are returned unchanged; numbers within cell arrays are kept.

%try
%N = zeros(size(C));
%
%for i=1:size(C,1),
%  for k=1:size(C,2),
%    if length(C{i,k}),
%      switch C{i,k},
%        case 'True',
%          C{i,k} = 'true';
%        case 'False',
%          C{i,k} = 'false';
%      end
%      N(i,k)= str2num(C{i,k});
%    else, 
%      N(i,k) = nan;
%    end     
%  end
%end
%
%catch
%  N = C;
%  warning('Non-numerical value found')
%end

% numerical input (e.g. columns of SBtab objects built in Matlab): returned unchanged
if isnumeric(C) || islogical(C)
  N = double(C);
  return
end

% numbers with a comma (e.g. '1,5' or '1,00E-06', written by spreadsheet programs with German
% locale settings) would be misread by str2double, which treats the comma as a thousands
% separator ('1,5' -> 15): raise an error instead
if ischar(C), C_check = {C}; else, C_check = C; end
if iscell(C_check)
  is_text = cellfun(@ischar, C_check);
  if any(is_text(:))
    texts = C_check(is_text);
    has_comma = ~cellfun(@isempty, regexp(texts, '^\s*[-+]?\d+(,\d+)+([eE][-+]?\d+)?\s*$', 'once'));
    if any(has_comma)
      examples = texts(has_comma);
      error('cell_string2num: number(s) with a comma found (e.g. ''%s''). Commas as decimal or thousands separators are not allowed in numerical data (often caused by saving a file from a spreadsheet program with non-English locale settings). Please use a decimal point.', examples{1});
    end
  end
end

N = str2double(C);

% cell arrays that contain numbers (e.g. tables built in Matlab): use the numbers
if iscell(C)
  is_number = cellfun(@(e) (isnumeric(e) || islogical(e)) && isscalar(e), C);
  if any(is_number(:))
    N(is_number) = double([C{is_number}]);
  end
end
