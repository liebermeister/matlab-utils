function axis_tight_positive()

% axis_tight_positive()
%
% Tight axes, with the lower y limit at 0

axis tight;
a = axis;
axis([a(1) a(2) 0 max(a(4),10^-10)]);
