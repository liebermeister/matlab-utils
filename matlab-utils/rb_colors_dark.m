function c = rb_colors_dark(ncol)

% RB_COLORS_DARK Diverging colormap: dark blue - blue - white - red - dark red
%
% c = rb_colors_dark(ncol)   (default ncol = 256)
%
% Colours go from blue (first row, negative values) via white to red (last row, positive values).
% (Until November 2026, the order was reversed: red for negative values.)

eval(default('ncol','256'));

ncol = ceil(ncol/4);

c = [ repmat([0, 0, 0.2],ncol,1) + (0: 1/[ncol-1]:1)' * [0 0 .8]; ...
      repmat([0 0 1],ncol,1) + (0: 1/[ncol-1]:1)' * [1 1 0]; ...
      repmat([1 0 0],ncol,1) + (1:-1/[ncol-1]:0)' * [0 1 1]; ...
      repmat([0.2, 0, 0],ncol,1) + (1:-1/[ncol-1]:0)' * [.8 0 0] ] ; 

if sum(c(:)<0)
  error('Negative values encountered')
end

c(find(prod(double(c==1),2)),:) = 0.999;
