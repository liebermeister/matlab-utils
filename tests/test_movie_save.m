% Tests for movie_save

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'matlab-utils'));

fig = figure('Visible','off'); cleanup = onCleanup(@() close(fig));
for k = 1:4
  clf; plot(1:10, (1:10).^(k/2)); M(k) = getframe(fig);
end
out_dir = tempname; mkdir(out_dir);
old_dir = pwd;

%% animated gif: written to the given folder, current directory unchanged
movie_save(fullfile(out_dir,'test_movie.gif'), M, [], 2);
assert(strcmp(pwd, old_dir));
info = imfinfo(fullfile(out_dir,'test_movie.gif'));
assert(numel(info) == 4);

%% delay given, no duration
movie_save(fullfile(out_dir,'test_movie_delay'), M, 50);
info = imfinfo(fullfile(out_dir,'test_movie_delay.gif'));
assert(numel(info) == 4);
assert(abs(info(2).DelayTime - 50) <= 1);

%% mp4
if any(strcmp({VideoWriter.getProfiles.Name}, 'MPEG-4'))
  movie_save(fullfile(out_dir,'test_movie.mp4'), M, [], 2, 'mp4');
  assert(strcmp(pwd, old_dir));
  v = VideoReader(fullfile(out_dir,'test_movie.mp4'));
  assert(v.NumFrames == 4);
end

%% avi (Motion JPEG, available on all systems)
movie_save(fullfile(out_dir,'test_movie.avi'), M, [], 2, 'avi');
assert(strcmp(pwd, old_dir));
v = VideoReader(fullfile(out_dir,'test_movie.avi'));
assert(v.NumFrames == 4);
