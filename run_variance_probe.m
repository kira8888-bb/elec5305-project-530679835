function [diagnostics,out]=run_variance_probe(cfg)
% Repeated noise realizations with fixed target, room, positions and settings.
% Measures across-realization gain variance, NOT temporal gain fluctuations.
root=setup_project(); if nargin<1, cfg=default_config(); end
assert(strcmp(cfg.noiseType,'stationary'),'Use stationary noise for this probe.');
room=make_room(cfg); modes={'mvdr_binwise','mvdr_uniform','mvdr_erb'};
seeds=cfg.seed+(0:4);
for j=1:numel(seeds)
    cfg.seed=seeds(j); r=run_condition(cfg,room);
    for k=1:numel(modes), G{k}(:,:,j)=r.gains.(modes{k}); end %#ok<AGROW>
end
active=r.meta.frameStart>=cfg.calibrationSeconds & ...
    r.meta.frameEnd<=cfg.calibrationSeconds+cfg.duration;
rows=cell(3,2);
for k=1:3
    variance=var(G{k}(:,active,:),0,3);
    rows(k,:)={modes{k},mean(variance,'all')};
end
diagnostics=cell2table(rows,'VariableNames',{'Method','AcrossSeedGainVariance'});
parent=fullfile(root,'results','runs'); if ~isfolder(parent), mkdir(parent); end
out=tempname(parent); mkdir(out);
writetable(diagnostics,fullfile(out,'gain_variance.csv'));
save(fullfile(out,'gain_variance.mat'),'cfg','G','seeds','active');
disp(diagnostics);
fprintf('Variance alone is not quality: inspect SI-SDR, speech distortion and spectrograms too.\n');
end
