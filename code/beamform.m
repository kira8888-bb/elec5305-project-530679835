function bf=beamform(X,meta,calibration,cfg,room)
% Estimate SCM from target-absent calibration, then freeze for fair ablation.
[F,T,M]=size(X); ref=cfg.referenceMic;
dist=sqrt(sum((cfg.microphones-cfg.targetPosition).^2,2));
tau=(dist-dist(ref))/cfg.soundSpeed;
if strcmp(cfg.steering,'known_rtf')
    % Privileged diagnostic: full simulated RIR, no NFFT truncation.
    H=zeros(F,M);
    for m=1:M, H(:,m)=freqz(room.target(:,m),1,meta.f,cfg.fs); end
    dAll=H./H(:,ref);
    assert(all(isfinite(dAll),'all'),'Project:RTF','Reference RIR has spectral zeros.');
else
    assert(strcmp(cfg.steering,'direct_path'));
    dAll=(dist(ref)./dist.').*exp(-1i*2*pi*meta.f*tau.');
end
% DAS uses phase-only steering; MVDR includes direct-path amplitude ratios.
dasAll=exp(-1i*2*pi*meta.f*tau.');
bf.mvdr=zeros(F,T); bf.das=zeros(F,T);
bf.weights=zeros(M,F); bf.dasWeights=zeros(M,F);
bf.noisePSD=zeros(F,1); bf.referenceNoisePSD=zeros(F,1);
bf.constraintError=0;
for f=1:F
    Z=reshape(X(f,:,:),T,M).'; C=Z(:,calibration);
    R=(C*C')/size(C,2);
    d=dAll(f,:).'; [w,~]=mvdr_weights(R,d,cfg.loading);
    if f==1 || f==F
        % Self-conjugate FFT bins require real filters for real reconstruction.
        d=real(d); [w,~]=mvdr_weights(real(R),d,cfg.loading);
    end
    a=dasAll(f,:).';
    if f==1 || f==F, a=real(a); end
    wD=a/max(real(a'*a),eps);
    bf.weights(:,f)=w; bf.dasWeights(:,f)=wD;
    bf.mvdr(f,:)=w'*Z; bf.das(f,:)=wD'*Z;
    bf.noisePSD(f)=max(real(w'*R*w),eps);
    bf.referenceNoisePSD(f)=max(real(R(ref,ref)),eps);
    bf.constraintError=max(bf.constraintError,abs(w'*d-1));
end
end
