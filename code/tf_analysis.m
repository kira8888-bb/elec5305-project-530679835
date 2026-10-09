function [X,meta]=tf_analysis(x,cfg)
% Wrap MATLAB STFT with explicit padding/cropping for invertibility.
W=cfg.windowLength; H=cfg.hop;
assert(mod(W,2)==0 && cfg.nfft>=W && mod(cfg.nfft,2)==0);
meta.length=size(x,1); meta.front=W;
n=meta.length+2*W; tail=mod(-(n-W),H);
xp=[zeros(W,size(x,2));x;zeros(W+tail,size(x,2))];
win=sqrt(hann(W,'periodic'));
X=stft(xp,cfg.fs,'Window',win,'OverlapLength',W-H, ...
    'FFTLength',cfg.nfft,'FrequencyRange','onesided');
meta.f=(0:cfg.nfft/2)'*cfg.fs/cfg.nfft;
meta.frameStart=((0:size(X,2)-1)*H-W)/cfg.fs;
meta.frameEnd=meta.frameStart+W/cfg.fs;
end
