function [mu_X,std_X,var_logX,std_logX] =logNormal_to_Normal(mu_logX,cov_logX)

var_logX = diag(cov_logX);
mu_X     = exp(mu_logX + 0.5 * var_logX);
std_X    = sqrt(exp(2*mu_logX+var_logX).*(exp(var_logX)-1));
std_logX = sqrt(var_logX);