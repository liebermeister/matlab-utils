function wheelchart(z,pars,x,y,r);

% wheelchart(z,pars,x,y,r)
%
% draw positive data vector as a black-and-white
% pie chart-like wheel
%
% pars.cm          color map
% pars.scale       {'no_scaling','scale_to_given_max_abs','scale_to_range','scale_to_median',
%                   'scale_to_mean','scale_to_centre','scale_to_max_abs'}
% pars.max_abs     maximal value (for scaling)
% pars.angles      Angles on wheels
% pars.star        Boolean star-like plot
% pars.linewidth 
% pars.experiments


if 0,
  z = exp(randn(100,1));
  x = 1;
  y = 2;
  r = 1;
  wheelchart(z,x,y,r);
  axis equal
end

eval(default('pars','struct','x','0','y','0','r','1'));
default_pars = struct('scale','scale_to_max_abs','cm',rb_colors(250),'star',0,'angles',[],'linewidth',1);
pars         = join_struct(default_pars,pars);

ncol = size(pars.cm,1);

switch pars.scale,
  case 'no_scaling',
    z(z<0)=0;
    z(z>1)=1;    
  case 'scale_to_given_max_abs',
    z       = z/pars.max_abs;
    z(z<-1) = -1;
    z(z>1)  = 1;   
    z       = 0.5 + 0.5 * z;
  case 'scale_to_range',
    z = z-nanmin(z);
    z = z/nanmax(abs(z)+10^-10);
  case 'scale_to_median',
    z = z-nanmedian(z');
    z = z/nanmax(abs(z)+10^-10);
    z = 0.5 + 0.5 * z;
  case 'scale_to_mean',
    z = z-nanmean(z');
    z = z/nanmax(abs(z)+10^-10);
    z = 0.5 + 0.5 * z;
  case 'scale_to_centre',
    z(z<0)=0;
    z = scale_to_centre(z);
  case 'scale_to_max_abs',
    z   = z/nanmax(abs(z)+10^-10);
    z   = 0.5+0.5*z;
end
col = pars.cm(1+ceil((ncol-1)*z),:);
ind_nan = find(isnan(col(:,1)));
col(ind_nan,:) = repmat([0 0 0.2],length(ind_nan),1);

hold on;
da = 2*pi/length(z);

if ~isempty(pars.angles),
  aa = [pars.angles; 1];
end

for it=1:length(z),
  if isempty(pars.angles),
    a1 = pi/2 - (it-1)*da;
    a2 = pi/2 - it*da;
  else,
    a1 = pi/2 - 2 * pi * aa(it);
    a2 = pi/2 - 2 * pi * aa(it+1);
  end
  if pars.star,
    fill(x+z(it)*r*[0, cos(a1), cos(a2)],y+z(it)*r*[0, sin(a1), sin(a2)],col(it,:),'EdgeColor',col(it,:));
  else,
    fill(x+r*[0, cos(a1), cos(a2)],y+r*[0, sin(a1), sin(a2)],col(it,:),'EdgeColor',col(it,:));
  end
end

plot(x+r*cos(2*pi*[-1/4:1/length(z):3/4]),y+r*sin(2*pi*[-1/4:1/length(z):3/4]),'k','Linewidth',pars.linewidth);

if isfield(pars,'experiments')
  plot(x+r*[0 0],y+r*[0 1],'k');
  for it = 1:length(pars.experiments),
    phi = 2*pi*pars.experiments{it}(end)/length(z);
    plot(x+r*[0 cos(pi/2-phi)],y+r*[0 sin(pi/2-phi)],'k','Linewidth',pars.linewidth);
  end
end

hold off
