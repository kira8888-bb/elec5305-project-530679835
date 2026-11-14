function out=run_recording_study(recordingFiles,recordingIds)
% Fixed two-recording case study. Each 5 s window is used in both roles.
root=setup_project();
recordingFiles=string(recordingFiles(:));
assert(numel(recordingFiles)==2 && all(isfile(recordingFiles)), ...
    'Supply two existing audio files in recording ID order.');
if nargin<2, recordingIds=[1 2]; end
validateattributes(recordingIds,{'numeric'},{'vector','numel',2,'integer','positive','finite'});
assert(numel(unique(recordingIds))==2,'Use distinct recording IDs.');
cfg=default_config();
assert(~isempty(which('stoi')),'This study requires MATLAB STOI.');
starts=1:5:26;
seeds=[5305 5306 5307];
noiseTypes={'stationary','competing_speech'};
snrs=[-5 0 5];
rt60s=[0.2 0.6];
imageOrders=[24 36]; % Chosen from impulse-response checks before scoring speech.
work=tempname; mkdir(work);
cleanup=onCleanup(@() rmdir(work,'s')); %#ok<NASGU>
[clipFiles,inputs]=prepare_clips(recordingFiles,recordingIds,starts,cfg,work);
parent=fullfile(root,'results','experiments');
if ~isfolder(parent), mkdir(parent); end
out=tempname(parent); mkdir(out);
fprintf('Study output: %s\n',out);
writetable(inputs,fullfile(out,'inputs.csv'));
save(fullfile(out,'design.mat'),'cfg','starts','seeds','noiseTypes','snrs','rt60s','imageOrders','recordingIds');

runs=cell(numel(rt60s)*numel(noiseTypes)*numel(snrs)*numel(starts)*2*numel(seeds),1);
gainRuns=cell(numel(rt60s)*numel(noiseTypes)*numel(snrs)*numel(starts)*2,1);
roomRows=zeros(numel(rt60s),4);
runIdx=0; gainIdx=0;
for rtIdx=1:numel(rt60s)
    cfg.rt60=rt60s(rtIdx);
    cfg.imageOrder=imageOrders(rtIdx);
    room=make_room(cfg);
    roomRows(rtIdx,:)=[cfg.rt60,room.measuredT20,room.imageOrder,size(room.target,1)];
    fprintf('Room %.2f s, achieved T20 extrapolation %.4f s, order %d\n', ...
        cfg.rt60,room.measuredT20,room.imageOrder);
    for noiseIdx=1:numel(noiseTypes)
        cfg.noiseType=noiseTypes{noiseIdx};
        for snr=snrs
            cfg.inputSNR=snr;
            for clipIdx=1:numel(starts)
                for target=1:2
                    cfg.targetFile=clipFiles(target,clipIdx);
                    cfg.interfererFile=clipFiles(3-target,clipIdx);
                    for seedIdx=1:numel(seeds)
                        cfg.seed=seeds(seedIdx);
                        r=run_condition(cfg,room,true);
                        assert(~r.scene.synthetic && all(isfinite(r.scores.STOI)));
                        assert(abs(r.scene.inputSNR-snr)<1e-9);
                        runIdx=runIdx+1;
                        observation=observation_key(cfg,starts(clipIdx),recordingIds(target),room);
                        observation.Seed=cfg.seed;
                        observation.TrueToEstimatedNoise_dB=r.components.trueToEstimatedNoise_dB;
                        [present,loc]=ismember(r.scores.Method,r.components.scores.Method);
                        componentValues=nan(height(r.scores),width(r.components.scores)-1);
                        componentValues(present,:)=r.components.scores{loc(present),2:end};
                        runs{runIdx}=[r.scores,array2table(componentValues, ...
                            'VariableNames',r.components.scores.Properties.VariableNames(2:end))];
                        runs{runIdx}=[repmat(observation,height(runs{runIdx}),1),runs{runIdx}];
                        if seedIdx==1, gainStack=struct(); end
                        methods=fieldnames(r.gains);
                        for k=1:numel(methods)
                            name=methods{k};
                            gainStack.(name)(:,:,seedIdx)=r.gains.(name)(:,r.components.activeFrames);
                        end
                        % Select a listening example before comparing scores.
                        if starts(clipIdx)==6 && target==1 && seedIdx==1 && ...
                                snr==-5 && rtIdx==2 && strcmp(cfg.noiseType,'competing_speech')
                            export_example(r,fullfile(out,'listening_example'),recordingIds);
                        end
                    end
                    gainIdx=gainIdx+1;
                    gainVariance=cellfun(@(name) mean(var(gainStack.(name),0,3),'all'),methods);
                    key=observation_key(cfg,starts(clipIdx),recordingIds(target),room);
                    gainRuns{gainIdx}=[repmat(key,numel(methods),1),table(methods,gainVariance, ...
                        'VariableNames',{'Method','AcrossSeedGainVariance'})];
                end
            end
            fprintf('Completed %s, %+g dB, %.1f s (%d/%d runs)\n', ...
                cfg.noiseType,snr,cfg.rt60,runIdx,numel(runs));
            writetable(vertcat(runs{1:runIdx}),fullfile(out,'all_scores.csv'));
            writetable(vertcat(gainRuns{1:gainIdx}),fullfile(out,'gain_variance.csv'));
        end
    end
end
assert(runIdx==numel(runs) && gainIdx==numel(gainRuns));
writetable(array2table(roomRows,'VariableNames', ...
    {'NominalRT60','MeasuredT20','ImageSourceOrder','RIRSamples'}),fullfile(out,'rooms.csv'));
fprintf('Finished %d mixtures.\n',runIdx);
end

function [clipFiles,inputs]=prepare_clips(recordingFiles,recordingIds,starts,cfg,work)
clipFiles=strings(2,numel(starts));
inputs=table();
for k=1:2
    [x,fs]=audioread(recordingFiles(k));
    [~,name,ext]=fileparts(recordingFiles(k));
    peak=max(abs(x),[],'all');
    assert(size(x,2)==2 && all(isfinite(x),'all') && peak<1);
    correlation=corrcoef(x);
    duration=size(x,1)/fs;
    mono=mean(x,2);
    if fs~=cfg.fs, mono=resample(mono,cfg.fs,fs); end
    for j=1:numel(starts)
        n=round((cfg.duration+cfg.calibrationSeconds)*cfg.fs);
        window=mono(round(starts(j)*cfg.fs)+(1:n));
        filename=fullfile(work,sprintf('recording%d_%02ds.wav',k,starts(j)));
        audiowrite(filename,window,cfg.fs,'BitsPerSample',24);
        clipFiles(k,j)=filename;
        nc=round(cfg.calibrationSeconds*cfg.fs);
        level=10*log10(mean(window.^2));
        calibrationLevel=10*log10(mean(window(1:nc).^2));
        evaluationLevel=10*log10(mean(window(nc+1:end).^2));
        inputs=[inputs;table(recordingIds(k),name+ext,fs,duration,peak,correlation(1,2),starts(j), ...
            level,calibrationLevel,evaluationLevel,'VariableNames', ...
            {'Recording','Filename','SampleRate_Hz','Duration_s','Peak','StereoCorrelation', ...
            'ExcerptStart_s','ExcerptRMS_dBFS','FirstSecondRMS_dBFS','LastFourSecondsRMS_dBFS'})]; %#ok<AGROW>
    end
end
end

function key=observation_key(cfg,start,target,room)
key=table(target,start,string(cfg.noiseType),cfg.inputSNR,cfg.rt60,room.measuredT20, ...
    'VariableNames',{'TargetRecording','ExcerptStart_s','Noise','InputSNR_dB', ...
    'NominalRT60','MeasuredT20'});
end

function export_example(r,out,recordingIds)
mkdir(out);
idx=r.scene.evalIdx;
names={'target_reference';'noisy';'mvdr';'mvdr_binwise';'mvdr_uniform';'mvdr_erb'};
clips=r.scene.reference(idx);
for k=2:numel(names), clips(:,k)=r.outputs.(names{k})(idx); end
scale=0.95/max(abs(clips),[],'all');
for k=1:numel(names)
    audiowrite(fullfile(out,[names{k} '.wav']),clips(:,k)*scale,r.cfg.fs,'BitsPerSample',24);
end
writetable(r.scores,fullfile(out,'metrics.csv'));
writetable(r.components.scores,fullfile(out,'components.csv'));
plot_demo(r,out);
fprintf('Listening example: target recording %d, 6–10 s; interference recording %d, 6–11 s. Shared gain %.8g\n', ...
    recordingIds(1),recordingIds(2),scale);
end
