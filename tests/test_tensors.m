% Tests for tensor_product and tensor_scale

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'utils'));

%% tensor_product: size of result
C = tensor_product(ones(2,3,4), ones(2,3,3), 2, 3);
assert(isequal(size(C), [2 4 2 3]));
assert(all(C(:) == 3));

%% tensor_product: matrix case
C = tensor_product([1 2; 3 4], [1 2], 1, 2);
assert(isequal(C, [7; 10]));

%% tensor_scale: scaling and unscaling gives back the original tensor
A = ones(1,2,3);
B = [2,3];
C = [3,4,5];
U = tensor_scale(tensor_scale(tensor_scale(tensor_scale(A,2,B),3,C),2,1./B),3,1./C);
assert(max(abs(U(:) - A(:))) < 1e-12);
