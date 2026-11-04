function c = rb_colors(ncol)

% RB_COLORS Diverging colormap: blue - white - red
%
% c = rb_colors(ncol)   (default ncol = 250)
%
% Colours go from blue (first row, negative values) via white to red (last row, positive values).
% (Until November 2026, the order was reversed: red for negative values.)

eval(default('ncol','250'));

ncol = ceil(ncol/2);

c = [ repmat([0 0 1],ncol,1) + (0: 1/[ncol-1]:1)' * [1 1 0]; ...
      repmat([1 0 0],ncol,1) + (1:-1/[ncol-1]:0)' * [0 1 1] ] ; 

if sum(c(:)<0)
  error('Negative values encountered')
end

c(find(prod(double(c==1),2)),:) = 0.999;
