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

N = str2double(C);

% cell arrays that contain numbers (e.g. tables built in Matlab): use the numbers
if iscell(C)
  is_number = cellfun(@(e) (isnumeric(e) || islogical(e)) && isscalar(e), C);
  if any(is_number(:))
    N(is_number) = double([C{is_number}]);
  end
end
