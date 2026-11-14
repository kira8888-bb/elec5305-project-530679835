function diagnostic=diagnose_components(scene,bf,gains,outputs,meta,cfg)
% Replay the mixture-estimated filters on the known simulated components.
% The isolated components are used for scoring only.
targetX=tf_analysis(scene.target,cfg);
noiseX=tf_analysis(scene.noise,cfg);
weights=reshape(conj(bf.weights.'),numel(meta.f),1,[]);
targetMVDR=sum(targetX.*weights,3);
noiseMVDR=sum(noiseX.*weights,3);
refX=targetX(:,:,cfg.referenceMic);
idx=scene.evalIdx;
ref=scene.reference(idx);
refEnergy=sum(ref.^2);
noiseIn=scene.noise(idx,cfg.referenceMic);
active=meta.frameStart>=cfg.calibrationSeconds & ...
    meta.frameEnd<=cfg.calibrationSeconds+cfg.duration;
energy=sum(abs(refX).^2,1);
active=active & energy>=max(energy(active))*1e-3;
assert(any(active),'Project:Activity','No energetic reference frames.');

modes={'mvdr';'mvdr_binwise';'mvdr_uniform';'mvdr_erb'};
rows=zeros(numel(modes),7);
bands={meta.f>=250 & meta.f<2000, meta.f>=2000 & meta.f<=7500};
for k=1:numel(modes)
    name=modes{k};
    gain=1;
    if isfield(gains,name), gain=gains.(name); end
    targetOut=tf_synthesis(gain.*targetMVDR,meta,cfg);
    noiseOut=tf_synthesis(gain.*noiseMVDR,meta,cfg);
    mix=outputs.(name);
    assert(norm(mix-targetOut-noiseOut)<=1e-9*max(norm(mix),eps), ...
        'Project:Components','Component sum differs from the mixture output.');
    err=targetOut(idx)-ref;
    n=noiseOut(idx);
    targetError=sum(err.^2)/refEnergy;
    residual=sum(n.^2)/refEnergy;
    cross=2*(err'*n)/refEnergy;
    assert(abs(targetError+residual+cross-sum((mix(idx)-ref).^2)/refEnergy)<1e-9, ...
        'Project:Components','Reference error does not match its decomposition.');
    targetTFError=gain.*targetMVDR-refX;
    rows(k,:)=[10*log10(max(targetError,realmin)), ...
        10*log10(sum(noiseIn.^2)/max(sum(n.^2),realmin)), ...
        targetError, residual, cross, ...
        band_error(targetTFError,refX,bands{1},active), ...
        band_error(targetTFError,refX,bands{2},active)];
end
diagnostic.scores=[table(modes,'VariableNames',{'Method'}), ...
    array2table(rows,'VariableNames',{'TargetError_dB','InterferenceReduction_dB', ...
    'TargetErrorOverReference','ResidualOverReference','CrossOverReference', ...
    'LowBandTFError_dB','HighBandTFError_dB'})];
diagnostic.activeFrames=active;
diagnostic.trueToEstimatedNoise_dB=10*log10( ...
    sum(abs(noiseMVDR(:,active)).^2,'all')/(nnz(active)*sum(bf.noisePSD)));
end

function value=band_error(err,ref,band,active)
num=sum(abs(err(band,active)).^2,'all');
den=sum(abs(ref(band,active)).^2,'all');
value=10*log10(max(num,realmin)/max(den,realmin));
end
