% Tests for small helper functions used by other packages

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

%% make_symmetric
M = make_symmetric([1 2; 4 3]);
assert(isequal(M, [1 3; 3 3]));

%% wheelchart runs with its default scaling (uses scale_to_centre)
figure('Visible', 'off');
wheelchart([1 2 3]', struct, 0, 0, 1);
close;

%% save_matlab_structure_to_tsv writes a file
basename = tempname;
save_matlab_structure_to_tsv(struct('a', 1), basename, '\t');
files = dir([basename '*']);
assert(~isempty(files));
delete([basename '*']);
