function C = color_scale_grey(n)

eval(default('n','256'));

C = 1/(n+1) * [1:n]'*[0 0 0] + 1/(n+1) * [n:-1:1]'*[1 1 1];
