function root = setup_project()
% Add only project code; no downloads, toolbox changes or external writes.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root,'config'), fullfile(root,'code'), fullfile(root,'test'));
required = {'stft','istft','hann','resample','acousticRoomResponse'};
for k = 1:numel(required)
    assert(exist(required{k},'file') ~= 0, 'Project:Dependency', ...
        'Missing %s. See README for MATLAB/toolbox requirements.',required{k});
end
end
