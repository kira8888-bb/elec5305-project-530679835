function r=run_condition(cfg,room)
if nargin<2, room=make_room(cfg); end
scene=simulate_scene(cfg,room); [X,meta]=tf_analysis(scene.mixture,cfg);
% Exclude initial propagation transient and any frame overlapping the target.
calibration=meta.frameStart>=0.3 & meta.frameEnd<=cfg.calibrationSeconds;
assert(nnz(calibration)>=8,'Project:Calibration','Need at least 8 noise-only frames.');
bf=beamform(X,meta,calibration,cfg,room);
refX=X(:,:,cfg.referenceMic);
psd=shared_psd(bf.mvdr,bf.noisePSD,cfg);
refPSD=shared_psd(refX,bf.referenceNoisePSD,cfg);
spec.noisy=refX;
spec.single_wiener=wiener_variant(refX,refPSD,meta.f,'binwise',cfg);
spec.das=bf.das; spec.mvdr=bf.mvdr;
modes={'binwise','uniform','erb'};
for k=1:numel(modes)
    key=['mvdr_' modes{k}];
    [spec.(key),gains.(key)]=wiener_variant(bf.mvdr,psd,meta.f,modes{k},cfg);
end
names=fieldnames(spec);
for k=1:numel(names), outputs.(names{k})=tf_synthesis(spec.(names{k}),meta,cfg); end
r.scores=score_signals(outputs,scene,cfg);
r.outputs=outputs; r.scene=scene; r.gains=gains; r.cfg=cfg; r.meta=meta;
r.mvdrConstraintError=bf.constraintError;
end
