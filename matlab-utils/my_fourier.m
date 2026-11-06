function [a_transformed, omega] = my_fourier(a,T,n_components)

% [a_transformed, omega] = my_fourier(a,T,n_components)
%
% Discrete Fourier transform for real-valued periodic time series
%
% Inputs
%   a             time series (row vector, or matrix with one time series per row);
%                 a must be real-valued and have an even number of time points
%   T             duration of one period (default 1); only used to compute the angular frequencies omega
%   n_components  number of Fourier components to be kept (even number, default: number of time points)
%
% Outputs
%   a_transformed Fourier components (one row per time series) for the frequencies 0, 1, .., n_components/2
%                 (in units of the basic frequency)
%   omega         list of angular frequencies 2 * pi * [0, 1, ..]/T
%
% To make the Fourier components easily interpretable as amplitudes, we use the
% following prefactor convention: 2/n for Fourier transform; 1/2 for inverse Fourier transform
% (differing from the convention in https://de.wikipedia.org/wiki/Diskrete_Fourier-Transformation)
%
% Example:
%   t = (0:63)/64 * 2*pi;
%   a = [cos(t); 0.3 * cos(2*t)];
%   a_transformed = my_fourier(a);
%   b = my_fourier_inverse(a_transformed);  % b equals a
%
% See also: my_fourier_inverse

eval(default('T','1','n_components','size(a,2)'));

if size(a,1) > 1,

  for it = 1:size(a,1),
    [a_transformed(it,:), omega] = my_fourier(a(it,:),T,n_components);
  end

else

  a = column(a);
  n = length(a);

  if ceil(n/2)~=n/2,
    error('Length of time series must be an even number');
  end

  if ceil(n_components/2)~=n_components/2,
    error('Number of Fourier components to be kept must be an even number');
  end

  if n_components > n,
    warning('It makes no sense to keep a higher number of Fourier components than the length of the time series');
  end

  a_transformed = 2/n * exp(-2 * pi * i * [0:n_components-1]' * [0:n-1] / n) * a;
  a_transformed = a_transformed(1:n_components/2+1);

  a_transformed = transpose(a_transformed);

  n = length(a_transformed);
  omega = 2 * pi * [0:n-1]/T;

end
