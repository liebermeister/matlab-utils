function movie_save(filename, M, my_delay, duration, format)

% movie_save(filename, M, my_delay, duration, format)
%
% M movie object
% my_delay is in 1/100 seconds
% duration (in seconds) overrides my_delay (default, if neither is given: duration 20 seconds)
% format: 'gif' (animated gif, default), 'mp4' (.mp4) or 'avi' (.avi, Motion JPEG);
%         mp4 and avi are written with VideoWriter (mp4 is not available on all systems, e.g. Linux)
%
% The file is written to the folder given in filename; the current directory does not change.

eval(default('my_delay','[]','resolution','30','duration','[]','format','''gif'''));

if isempty(duration) && isempty(my_delay),
  duration = 20;
end

[fpath,fname,fext] = fileparts(filename);

if strcmp(fext,['.' format]),
  fext = [];
end

fname = fullfile(fpath, [fname fext]);

% -------------------------------------
% make movie

switch format,
  
  case 'gif',

    if length(duration),
      my_delay = 100*duration/length(M);
    end

    my_delay = 0.01 * my_delay;

    for itt = 1:length(M),
      im{itt} = frame2im(M(itt));
      [A,map] = rgb2ind(im{itt},256);
      if itt == 1
        imwrite(A,map,[fname '.gif'],'gif','LoopCount',Inf,'DelayTime',my_delay,'ScreenSize',[400, 400]);
      else        
        imwrite(A,map,[fname '.gif'],'gif','WriteMode','append','DelayTime',my_delay);
      end
    end

  case {'mp4','avi'},

    switch format
      case 'mp4', profile = 'MPEG-4';
      case 'avi', profile = 'Motion JPEG AVI';
    end
    if ~any(strcmp({VideoWriter.getProfiles.Name}, profile))
      error('Video profile %s is not available on this system; use format ''avi'' or ''gif''', profile);
    end
    if length(duration),
      frame_rate = length(M) / duration;
    else
      frame_rate = 100 / my_delay;
    end
    v = VideoWriter([fname '.' format], profile);
    v.FrameRate = frame_rate;
    open(v);
    % all frames must have the same size: crop to the smallest frame
    sizes = cell2mat(arrayfun(@(m) [size(m.cdata,1), size(m.cdata,2)], M(:), 'UniformOutput', false));
    n_rows = 2 * floor(min(sizes(:,1))/2);
    n_cols = 2 * floor(min(sizes(:,2))/2);
    for k = 1:length(M),
      writeVideo(v, M(k).cdata(1:n_rows, 1:n_cols, :));
    end
    close(v);
    
  otherwise,
    error('unknown movie format');
end