function r=run_demo(cfg)
% RUN_DEMO default is a reproducible synthetic engineering check, not results.
root=setup_project();
if nargin==0, cfg=default_config(); end
if isempty(cfg.outputDir)
    parent=fullfile(root,'results','runs');
    if ~isfolder(parent), mkdir(parent); end
    cfg.outputDir=tempname(parent); % does not overwrite earlier runs
end
mkdir(cfg.outputDir);
fprintf('Simulating nominal RT60 %.2f s; SNR %.1f dB...\n',cfg.rt60,cfg.inputSNR);
r=run_condition(cfg);
disp(r.scores);
writetable(r.scores,fullfile(cfg.outputDir,'metrics.csv'));
save(fullfile(cfg.outputDir,'run.mat'),'r','-v7');
names=fieldnames(r.outputs); peak=max(abs(r.scene.reference));
for k=1:numel(names), peak=max(peak,max(abs(r.outputs.(names{k})))); end
audioScale=0.95/max(peak,eps); % ONE common scale for listening only
for k=1:numel(names)
    audiowrite(fullfile(cfg.outputDir,[names{k} '.wav']),r.outputs.(names{k})*audioScale,cfg.fs);
end
audiowrite(fullfile(cfg.outputDir,'target_reference.wav'),r.scene.reference*audioScale,cfg.fs);
write_run_notes(r,audioScale,cfg.outputDir);
plot_demo(r,cfg.outputDir);
fprintf('Output: %s\n',cfg.outputDir);
end

function write_run_notes(r,scale,out)
fid=fopen(fullfile(out,'RUN_INFO.txt'),'w'); c=onCleanup(@() fclose(fid));
fprintf(fid,'Synthetic test only: %d\nMATLAB: %s\n',r.scene.synthetic,version);
fprintf(fid,'Nominal RT60: %.4f s\nMeasured broadband T20: %.4f s\n', ...
    r.cfg.rt60,r.scene.room.measuredT20);
fprintf(fid,'Input SNR: %.6f dB\nShared listening scale: %.8g\n',r.scene.inputSNR,scale);
fprintf(fid,'Steering: %s\nMVDR constraint error: %.3g\n',r.cfg.steering,r.mvdrConstraintError);
fprintf(fid,'Metrics use original amplitudes and reverberant reference.\n');
fprintf(fid,'Noise estimation uses an explicit target-absent calibration segment.\n');
fprintf(fid,'This single run does not establish speech enhancement performance.\n');
end
