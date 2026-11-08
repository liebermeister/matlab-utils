function [options, attributes] = load_config_table(filename, table_id)

% LOAD_CONFIG_TABLE - Read tool options from an SBtab Config table into a matlab struct
%
% [options, attributes] = load_config_table(filename, table_id)
%
% Reads a table of type 'Config' (columns !ID and !Value; in older files, !Option
% instead of !ID) from an SBtab file and returns the options as a matlab struct.
% Packages use this function to read the default values of their options from a
% Config file. It does not require the SBtab toolbox.
%
% Arguments
%   filename    SBtab file (tab-separated); it may contain several tables
%   table_id    (optional) TableID of the Config table to be read
%               (default: the first table of type 'Config' in the file)
%
% Outputs
%   options     struct with one field per option (field names from column !ID)
%   attributes  struct with the table attributes (e.g. TableID, TableType, Method)
%
% Option names containing dots (e.g. 'quantities.v.max') yield nested structs.
%
% Conversion of the values (column !Value):
%   (empty)                  -> []
%   {}                       -> {}  (empty cell array)
%   ''                       -> ''  (empty string)
%   True, False              -> 1, 0
%   numbers, NaN, Inf, -Inf  -> numbers
%   JSON strings starting with '[' or '{' -> decoded by jsondecode; one-dimensional
%                               arrays are returned as row vectors (e.g. [1,2,3] -> [1 2 3])
%   other strings            -> strings
%
% Comment lines (starting with '%') are ignored.
%
% See also: options_to_sbtab, sbtab_to_options (SBtab toolbox)

if ~exist('table_id','var'), table_id = []; end

if ~exist(filename,'file')
  error('load_config_table: file %s not found', filename);
end

lines = regexp(fileread(filename), '\r?\n', 'split');

options    = struct;
attributes = struct;
in_table   = false;
found      = false;
header     = {};
id_col     = [];
value_col  = [];

for it = 1:length(lines)
  line = lines{it};
  if isempty(strtrim(line)) || strncmp(line, '%', 1) || strncmp(line, '!!!', 3)
    continue
  end
  if strncmp(line, '!!', 2)
    % table declaration line
    if found, break; end
    my_attributes = config_table_attributes(line);
    if isempty(table_id)
      in_table = isfield(my_attributes,'TableType') && strcmp(my_attributes.TableType,'Config');
    else
      in_table = isfield(my_attributes,'TableID') && strcmp(my_attributes.TableID, table_id);
    end
    if in_table
      attributes = my_attributes;
      found      = true;
    end
    continue
  end
  if ~in_table, continue; end
  fields = regexp(line, '\t', 'split');
  if isempty(header)
    % header line with column names
    header    = strtrim(fields);
    id_col    = find(strcmp(header,'!ID'), 1);
    if isempty(id_col), id_col = find(strcmp(header,'!Option'), 1); end
    value_col = find(strcmp(header,'!Value'), 1);
    if isempty(id_col) || isempty(value_col)
      error('load_config_table: columns !ID (or !Option) and !Value are required (file %s)', filename);
    end
    continue
  end
  fields(end+1:length(header)) = {''};
  name = strtrim(fields{id_col});
  if isempty(name), continue; end
  path    = strsplit(name, '.');
  options = setfield(options, path{:}, config_value(fields{value_col}));
end

if ~found
  if isempty(table_id)
    error('load_config_table: no table of type Config found in file %s', filename);
  else
    error('load_config_table: no table with TableID ''%s'' found in file %s', table_id, filename);
  end
end


% -----------------------------------------------------------------

function attributes = config_table_attributes(line)

attributes = struct;
tokens = regexp(line, '(\w+)\s*=\s*[''"]([^''"]*)[''"]', 'tokens');
for it = 1:length(tokens)
  attributes.(tokens{it}{1}) = tokens{it}{2};
end


% -----------------------------------------------------------------

function value = config_value(s)

s = strtrim(s);

if isempty(s),             value = [];  return; end
if strcmp(s, '{}'),        value = {};  return; end
if strcmp(s, ''''''),      value = '';  return; end
if strcmpi(s, 'True'),     value = 1;   return; end
if strcmpi(s, 'False'),    value = 0;   return; end

if s(1) == '[' || s(1) == '{'
  value = jsondecode(s);
  if (isnumeric(value) || islogical(value) || iscell(value)) && iscolumn(value)
    value = value.';
  end
  return
end

number = str2double(s);
if (~isnan(number) && isreal(number)) || strcmpi(s, 'NaN')
  value = number;
else
  value = s;
end
