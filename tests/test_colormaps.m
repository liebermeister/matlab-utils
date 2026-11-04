% Tests for colormaps

setup_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils');
addpath(setup_dir);

%% Diverging colormaps go from blue (negative values) to red (positive values)
maps = {@rb_colors, @rb_colors_dark, @my_colors, @ryb_colors, @rby_colors, @sunrise_colors};
for it = 1:numel(maps)
  c = maps{it}(100);
  assert(size(c,2) == 3 && all(c(:) >= 0) && all(c(:) <= 1), func2str(maps{it}));
  assert(c(1,3) > c(1,1),     [func2str(maps{it}) ': first colour should be blue']);
  assert(c(end,1) > c(end,3), [func2str(maps{it}) ': last colour should be red']);
end

%% rb_colors is white in the middle
c = rb_colors(250);
assert(all(c(125,:) > 0.98));

%% magma_colors: size, range, dark to light
c = magma_colors;
assert(isequal(size(c), [256 3]));
c = magma_colors(10);
assert(isequal(size(c), [10 3]) && all(c(:) >= 0) && all(c(:) <= 1));
assert(all(diff(sum(c,2)) > 0));
assert(isequal(size(magma_colors(1)), [1 3]));
