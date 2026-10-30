function [x_posterior_mean, x_posterior_cov_inv] = bayesian_linear_model(R_y_x, x_prior_mean, x_prior_cov_inv, y_data_mean, y_data_cov_inv)

% linear model: y = R_y_x * x
% data for y: vectors y_data_mean, y_data_cov
% prior for x: x_prior_mean, x_prior_cov
% solution: posterior for x: x_posterior_mean, x_posterior_cov
%
% to save computation time, inverse matrices are directly used as inputs

x_posterior_cov_inv  = x_prior_cov_inv + R_y_x' * y_data_cov_inv * R_y_x;
x_posterior_mean     = x_posterior_cov_inv \ (R_y_x' * y_data_cov_inv * y_data_mean + x_prior_cov_inv * x_prior_mean );

if nargout ==2,
  x_posterior_cov_inv = inv(x_posterior_cov_inv);
end