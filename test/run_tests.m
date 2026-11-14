function report=run_tests()
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project();
cfg=default_config(); rng(17);
x=randn(4213,4); [X,meta]=tf_analysis(x,cfg); y=tf_synthesis(X,meta,cfg);
roundtrip=norm(x-y,'fro')/norm(x,'fro');
assert(roundtrip<1e-10 && isequal(size(x),size(y)),'STFT round trip failed.');
f=(0:cfg.nfft/2)'*cfg.fs/cfg.nfft;
for mode={'binwise','uniform','erb'}
    [A,B]=frequency_bands(f,mode{1},cfg.numBands);
    assert(max(abs(sum(A,2)-1))<1e-12 && max(abs(sum(B,2)-1))<1e-12);
    assert(all(A>=0,'all') && all(B>=0,'all'));
    P.speech=3*ones(numel(f),5); P.noise=ones(numel(f),5);
    [~,G]=wiener_variant(ones(size(P.speech)),P,f,mode{1},cfg);
    assert(max(abs(G-0.75),[],'all')<1e-12,'Constant PSD ratio changed.');
    P.speech(:)=0; [~,G]=wiener_variant(ones(size(P.speech)),P,f,mode{1},cfg);
    assert(all(G==cfg.gainFloor,'all'));
end
Z=randn(4,20)+1i*randn(4,20); R=Z*Z'/20; d=randn(4,1)+1i*randn(4,1);
[w,Rl]=mvdr_weights(R,d,cfg.loading);
assert(abs(w'*d-1)<1e-10);
% Independent constrained KKT solve, not a duplicate of R\d normalization.
kkt=[Rl d;d' 0]\[zeros(4,1);1];
kktError=norm(w-kkt(1:4)); assert(kktError<1e-10);
q=randn(4,1)+1i*randn(4,1); q=q-d*(d'*q)/(d'*d);
assert(real((w+q)'*Rl*(w+q))>=real(w'*Rl*w)-1e-12);
toolboxCheck='NOT RUN: Phased Array System Toolbox is not installed';
if exist('mvdrweights','file') && exist('steervec','file')
    pos=(0:3)*0.5; a=steervec(pos,25);
    wa=mvdr_weights(R,a,cfg.loading); ref=mvdrweights(pos,25,Rl);
    assert(norm(wa-ref)<1e-9); toolboxCheck='PASS: MathWorks mvdrweights';
end
cfg.duration=1; cfg.imageOrder=8;
r=run_condition(cfg);
assert(abs(r.scene.inputSNR-cfg.inputSNR)<1e-10,'Mixture SNR incorrect.');
assert(r.mvdrConstraintError<1e-9);
names=fieldnames(r.outputs);
for k=1:numel(names)
    assert(numel(r.outputs.(names{k}))==numel(r.scene.reference));
    assert(all(isfinite(r.outputs.(names{k}))));
end
assert(all(isnan(r.scores.STOI)),'STOI must be disabled for synthetic tests.');
assert(abs(r.scores.ReferenceErrorSNR_dB(1)-cfg.inputSNR)<1e-10);
test_component_scores();
test_paired_scores(r.scores);
report=struct('STFTRelativeError',roundtrip,'MVDRKKTError',kktError, ...
    'MVDRConstraintError',r.mvdrConstraintError,'ToolboxComparison',toolboxCheck, ...
    'SyntheticIntegration','PASS','ComponentMetrics','PASS', ...
    'PairedMetrics','PASS','MATLAB',version);
disp(report); fprintf('All required tests passed.\n');
end

function test_component_scores()
cfg = default_config();
cfg.referenceMic = 1;
t = sin(2*pi*(1:2048)'/64);
n = cos(2*pi*(1:2048)'/32);
% Use complex weights on channel 2 to catch conjugation/axis errors.
scene.target = [t,t];
scene.noise = [n,n];
scene.reference = t;
scene.evalIdx = (1:numel(t))';
[targetTF,meta] = tf_analysis(scene.target,cfg);
noiseTF = tf_analysis(scene.noise,cfg);
F = size(targetTF,1);
weights = [zeros(1,F);1i*ones(1,F)];
weights(2,[1,end]) = 1;
gain = 0.5*ones(size(targetTF(:,:,2)));
gains.mvdr_erb = gain;
targetOut = tf_synthesis(gain.*conj(weights(2,:).').*targetTF(:,:,2),meta,cfg);
noiseOut = tf_synthesis(gain.*conj(weights(2,:).').*noiseTF(:,:,2),meta,cfg);
outputs.mvdr_erb = targetOut + noiseOut;
outputs.mvdr = 2*outputs.mvdr_erb;
scores = table({'mvdr';'mvdr_erb'},'VariableNames',{'Method'});
scores = score_mvdr_components(scores,outputs,scene,weights,gains,meta,cfg);
assert(abs(scores.InterferenceAttenuation_dB(2)+10*log10(sum(noiseOut.^2)/sum(n.^2)))<1e-9);
assert(abs(scores.TargetDistortion_dB(2)-10*log10(sum((targetOut-t).^2)/sum(t.^2)))<1e-9);
end

function test_paired_scores(baseScores)
scores = table();
for utterance = 1:2
    for seed = 1:2
        t = baseScores;
        n = height(t);
        t.Utterance = repmat(utterance,n,1);
        t.Seed = repmat(seed,n,1);
        t.Noise = repmat({'stationary'},n,1);
        t.InputSNR = zeros(n,1);
        t.NominalRT60 = 0.2*ones(n,1);
        t.SI_SDR_dB = zeros(n,1);
        t.SI_SDR_dB(strcmp(t.Method,'mvdr_erb')) = 2*utterance + seed;
        scores = [scores; t]; %#ok<AGROW>
    end
end
[paired,summary] = summarize_paired_scores(scores(end:-1:1,:));
mask = strcmp(paired.Control,'mvdr_uniform') & strcmp(paired.Metric,'SI_SDR_dB');
assert(isequal(paired.ERBMinusControl(mask),[3.5;5.5]));
row = summary(strcmp(summary.Control,'mvdr_uniform') & strcmp(summary.Metric,'SI_SDR_dB'),:);
assert(row.NUtterancePairs==2 && row.MeanERBMinusControl==4.5);
assert(row.CI95Low==3.5 && row.CI95High==5.5);
stoi = summary(strcmp(summary.Metric,'STOI'),:);
assert(all(stoi.NUtterancePairs==0) && all(isnan(stoi.MeanERBMinusControl)));
[~,pilot] = summarize_paired_scores(scores(scores.Utterance==1,:));
assert(all(isnan(pilot.CI95Low)) && all(isnan(pilot.CI95High)));
try
    summarize_paired_scores(scores(1:end-1,:));
    error('Project:Test','Missing ERB row was accepted.');
catch err
    assert(strcmp(err.identifier,'Project:Pairs'),'Unexpected error: %s',err.message);
end
end
