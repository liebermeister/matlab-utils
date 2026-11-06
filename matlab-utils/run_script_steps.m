function step_results = run_script_steps(steps, stop_on_error)

% step_results = run_script_steps(steps, stop_on_error)
%
% Run a sequence of Matlab scripts (or code snippets) in one common workspace,
% as if they were typed one after the other on the command line, and record
% for each step whether it ran without errors, the error message, and the computation time.
%
% Inputs
%   steps          cell array of strings, each one a script name or a piece of code
%                  (e.g. {'model_name = ''tca'';', 'hcc_filenames', 'hcc_make_model'})
%   stop_on_error  (Boolean, default 1) stop after the first failing step
%
% Output
%   step_results   struct array with fields
%     .step     the code that was run
%     .ok       true if the step ran without error
%     .message  error message ('' if ok)
%     .stack    first lines of the error stack (cell array of strings)
%     .time     computation time (s)
%   Steps that were not run (after a failing step) are not listed.
%
% The scripts may call 'clear' without disturbing this function: its state is kept
% outside the workspace (in appdata), and apart from the variable 'run_script_steps_error'
% (which is removed again) no variables are added to the workspace.

if ~exist('stop_on_error','var') || isempty(stop_on_error), stop_on_error = 1; end

setappdata(0, 'run_script_steps_state', struct('steps', {steps}, 'stop_on_error', stop_on_error, 'it', 0, ...
  'results', struct('step', {}, 'ok', {}, 'message', {}, 'stack', {}, 'time', {})));
clear steps stop_on_error

while run_script_steps_next()
  try
    eval(run_script_steps_current_code());
    run_script_steps_record([]);
  catch run_script_steps_error
    run_script_steps_record(run_script_steps_error);
    clear run_script_steps_error
  end
  if run_script_steps_stop(), break; end
end

step_results = getfield(getappdata(0, 'run_script_steps_state'), 'results');
rmappdata(0, 'run_script_steps_state');


% -----------------------------------------------------------

function go_on = run_script_steps_next()
state = getappdata(0, 'run_script_steps_state');
state.it = state.it + 1;
go_on = state.it <= numel(state.steps);
if go_on
  fprintf('\n===== STEP %s =====\n', state.steps{state.it});
  state.tic = tic;
end
setappdata(0, 'run_script_steps_state', state);

function code = run_script_steps_current_code()
state = getappdata(0, 'run_script_steps_state');
code  = state.steps{state.it};

function run_script_steps_record(err)
state = getappdata(0, 'run_script_steps_state');
r = struct('step', state.steps{state.it}, 'ok', isempty(err), 'message', '', 'stack', {{}}, 'time', toc(state.tic));
if ~r.ok
  r.message = err.message;
  st = err.stack;
  r.stack = arrayfun(@(s) sprintf('%s line %d', s.name, s.line), st(1:min(8, numel(st))), 'UniformOutput', false);
  fprintf('===== FAILED (%.1f s): %s\n', r.time, r.message);
  for k = 1:numel(r.stack), fprintf('   at %s\n', r.stack{k}); end
else
  fprintf('===== OK (%.1f s)\n', r.time);
end
state.results(end+1) = r;
setappdata(0, 'run_script_steps_state', state);

function stop = run_script_steps_stop()
state = getappdata(0, 'run_script_steps_state');
stop = ~state.results(end).ok && state.stop_on_error;
