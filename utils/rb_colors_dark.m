function c = rb_colors(ncol)

% c = rb_colors(ncol)

eval(default('ncol','256'));

ncol = ceil(ncol/4);

c = [ repmat([0, 0, 0.2],ncol,1) + (0: 1/[ncol-1]:1)' * [0 0 .8]; ...
      repmat([0 0 1],ncol,1) + (0: 1/[ncol-1]:1)' * [1 1 0]; ...
      repmat([1 0 0],ncol,1) + (1:-1/[ncol-1]:0)' * [0 1 1]; ...
      repmat([0.2, 0, 0],ncol,1) + (1:-1/[ncol-1]:0)' * [.8 0 0] ] ; 

c = flipud(c);

if sum(c(:)<0)
  error('Negative values encountered')
  c(c<0) = 0;
end

c(find(prod(double(c==1),2)),:) = 0.999;
