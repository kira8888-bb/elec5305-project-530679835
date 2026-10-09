function [allScores,out]=run_experiments(targetFiles,interfererFiles)
% Paired real-speech pilot: 2 noises x 3 SNRs x 2 rooms x 3 seeds per target.
% No synthetic fallback. Supply separately licensed target/interferer WAVs.
root=setup_project();
assert(nargin==2,'Supply targetFiles and interfererFiles as string/cell arrays.');
targetFiles=cellstr(targetFiles); interfererFiles=cellstr(interfererFiles);
assert(~isempty(targetFiles) && numel(targetFiles)==numel(interfererFiles));
cfg=default_config();
parent=fullfile(root,'results','experiments'); if ~isfolder(parent), mkdir(parent); end
out=tempname(parent); mkdir(out);
allScores=table();
for rt=[0.2 0.6]
    cfg.rt60=rt; room=make_room(cfg);
    for u=1:numel(targetFiles)
        assert(~strcmp(targetFiles{u},interfererFiles{u}),'Use different target/interferer recordings.');
        cfg.targetFile=targetFiles{u}; cfg.interfererFile=interfererFiles{u};
        for noise={'stationary','competing_speech'}
            cfg.noiseType=noise{1};
            for snrValue=[-5 0 5]
                cfg.inputSNR=snrValue;
                for seed=[5305 5306 5307]
                    cfg.seed=seed; r=run_condition(cfg,room);
                    assert(~r.scene.synthetic);
                    t=r.scores; N=height(t);
                    t.Utterance=repmat(u,N,1); t.Seed=repmat(seed,N,1);
                    t.Noise=repmat(noise,N,1); t.InputSNR=repmat(snrValue,N,1);
                    t.NominalRT60=repmat(rt,N,1); t.MeasuredT20=repmat(room.measuredT20,N,1);
                    allScores=[allScores;t]; %#ok<AGROW>
                    label=sprintf('u%03d_%s_snr%d_rt%.1f_seed%d.mat',u,noise{1},snrValue,rt,seed);
                    gains=r.gains; meta=r.meta; scores=t; %#ok<NASGU>
                    save(fullfile(out,label),'cfg','scores','gains','meta');
                    writetable(allScores,fullfile(out,'all_scores.csv'));
                end
            end
        end
    end
end
fprintf('Saved paired observations to %s\n',out);
fprintf('Aggregate by utterance before confidence intervals; seeds are not new speakers.\n');
end
