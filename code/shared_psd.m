function psd=shared_psd(Y,noisePSD,cfg)
% One estimator is computed once and passed unchanged to all three variants.
% Noise PSD: fixed calibration average. Speech PSD: smoothed subtraction.
% There is no decision-directed estimator or oracle speech/noise in this code.
P=abs(Y).^2; Q=zeros(size(P)); prev=noisePSD(:);
for t=1:size(P,2)
    prev=cfg.psdAlpha*prev+(1-cfg.psdAlpha)*P(:,t);
    Q(:,t)=prev;
end
psd.noise=repmat(max(noisePSD(:),1e-12),1,size(P,2));
psd.speech=max(Q-psd.noise,0);
end
