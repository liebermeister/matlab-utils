% Tests for pca_simple

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab'));

%% standard deviations of principal components agree with svd
rng(0);
X = randn(3,1) * randn(1,200) + 0.1 * randn(3,200);
Xeig = pca_simple(X);
Xc   = X - mean(X,2);
assert(max(abs(Xeig - svd(Xc) / sqrt(size(X,2)-1))) < 1e-10);

%% columns containing NaN are ignored
X(2,5) = nan;
Xeig = pca_simple(X);
X(:,5) = [];
assert(max(abs(Xeig - pca_simple(X))) < 1e-12);
