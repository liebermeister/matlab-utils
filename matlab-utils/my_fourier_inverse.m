function a = my_fourier_inverse(a_transformed,n_points)

% a = my_fourier_inverse(a_transformed,n_points)
%
% Inverse of the discrete Fourier transform in 'my_fourier'
% (for real-valued periodic time series; see the comments in my_fourier)
%
% Inputs
%   a_transformed Fourier components (row vector, or matrix with one row per time series),
%                 for frequencies 0, 1, .., n/2 (as returned by my_fourier)
%   n_points      (optional) number of time points to be reconstructed (by linear interpolation);
%                 default: n, where n/2+1 is the number of Fourier components
%
% Output
%   a             time series (one row per time series)
%
% See also: my_fourier

eval(default('n_points','[]'));

if size(a_transformed,1)>1,

  for it = 1:size(a_transformed,1),
    a(it,:) = my_fourier_inverse(a_transformed(it,:),n_points);
  end

else

  a_transformed = column(a_transformed);

  a_transformed = [a_transformed(1); ...
                   a_transformed(2:end-1); ...
                   a_transformed(end);
                   flipud(transpose(ctranspose(a_transformed(2:end-1) )));
                  ];

  n = length(a_transformed);

  a = 1/2 * exp(2 * pi * i * [0:n-1]' * [0:n-1] / n) * a_transformed;

  a = real(a);
  a = column(a);

  if length(n_points),
    a = interp1(0:1/n:1,[a', a(1)],0:1/n_points:1,'linear'); % 'cubic' is slower
    a = column(a(1:end-1));
  end

  a = transpose(a);

end
