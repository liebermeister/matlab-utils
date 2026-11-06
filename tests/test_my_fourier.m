% Tests for my_fourier and my_fourier_inverse

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

t = (0:63)/64 * 2*pi;
a = [cos(t); 0.3 * cos(2*t) + 0.5; sin(3*t)];

%% my_fourier: amplitudes and frequencies
[a_transformed, omega] = my_fourier(a, 10);
assert(isequal(size(a_transformed), [3, 33]));
assert(abs(a_transformed(1,2) - 1) < 1e-10);       % cos(t): amplitude 1 at frequency 1
assert(abs(a_transformed(2,3) - 0.3) < 1e-10);     % 0.3 cos(2t): amplitude 0.3 at frequency 2
assert(abs(a_transformed(2,1) - 2 * 0.5) < 1e-10); % constant 0.5 (frequency 0, factor 2 by convention)
assert(abs(a_transformed(3,4) + 1i) < 1e-10);      % sin(3t) = -i/2 exp(3it) + ..
assert(max(abs(omega - 2*pi*(0:32)/10)) < 1e-12);

%% my_fourier_inverse: reconstruction
a_transformed = my_fourier(a);
b = my_fourier_inverse(a_transformed);
assert(max(abs(b(:) - a(:))) < 1e-10);

%% my_fourier with fewer components: low-pass filtering
% keep 16 components (frequencies 0..8): the component at frequency 20 is removed;
% the inverse transform yields the time series at 16 time points (every 4th point)
a_transformed = my_fourier(a(1,:) + 0.1 * cos(20*t), 1, 16);
assert(isequal(size(a_transformed), [1, 9]));
b = my_fourier_inverse(a_transformed);
assert(max(abs(b - a(1,1:4:end))) < 1e-10);
