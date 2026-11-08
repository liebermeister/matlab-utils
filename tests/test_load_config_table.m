% Tests for load_config_table (reading options from SBtab Config tables)

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

filename = [tempname '.tsv'];
fid = fopen(filename, 'w');
fprintf(fid, '!!!SBtab SBtabVersion=''1.2''\n');
fprintf(fid, '!!SBtab TableID=''Other'' TableType=''Config''\n');
fprintf(fid, '!ID\t!Value\n');
fprintf(fid, 'a\t99\n');
fprintf(fid, '!!SBtab TableID=''MyConfig'' TableType=''Config'' Method=''my-tool''\n');
fprintf(fid, '%% comment line\n');
fprintf(fid, '!ID\t!Value\t!Description\n');
fprintf(fid, 'number\t0.001\tA number\n');
fprintf(fid, 'empty\t\tEmpty value\n');
fprintf(fid, 'empty_cell\t{}\t\n');
fprintf(fid, 'empty_string\t''''\t\n');
fprintf(fid, 'flag\tTrue\t\n');
fprintf(fid, 'not_a_number\tNaN\t\n');
fprintf(fid, 'minus_infinity\t-Inf\t\n');
fprintf(fid, 'string\tpolytope center\t\n');
fprintf(fid, 'vector\t[0,5,10]\t\n');
fprintf(fid, 'list\t["emc3sp","emc4cm"]\t\n');
fprintf(fid, 'quantities.v.max\t100\t\n');
fprintf(fid, 'quantities.c.min\t1e-07\t\n');
fclose(fid);

%% select table by TableID
[o, attributes] = load_config_table(filename, 'MyConfig');
assert(strcmp(attributes.Method, 'my-tool'));
assert(o.number == 0.001);
assert(isnumeric(o.empty) && isempty(o.empty));
assert(iscell(o.empty_cell) && isempty(o.empty_cell));
assert(ischar(o.empty_string) && isempty(o.empty_string));
assert(o.flag == 1);
assert(isnan(o.not_a_number));
assert(o.minus_infinity == -inf);
assert(strcmp(o.string, 'polytope center'));
assert(isequal(o.vector, [0 5 10]));
assert(isequal(o.list, {'emc3sp', 'emc4cm'}));
assert(o.quantities.v.max == 100);
assert(o.quantities.c.min == 1e-7);
assert(~isfield(o, 'a'));

%% first Config table by default
o = load_config_table(filename);
assert(isequal(fieldnames(o), {'a'}) && o.a == 99);

%% missing table
try
  load_config_table(filename, 'NoSuchTable');
  error('expected an error');
catch err
  assert(contains(err.message, 'NoSuchTable'));
end

delete(filename);
