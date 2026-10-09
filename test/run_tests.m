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
report=struct('STFTRelativeError',roundtrip,'MVDRKKTError',kktError, ...
    'MVDRConstraintError',r.mvdrConstraintError,'ToolboxComparison',toolboxCheck, ...
    'SyntheticIntegration','PASS','MATLAB',version);
disp(report); fprintf('All required tests passed.\n');
end
