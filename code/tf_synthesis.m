function y=tf_synthesis(Y,meta,cfg)
Y(1,:,:)=real(Y(1,:,:)); Y(end,:,:)=real(Y(end,:,:));
y=istft(Y,cfg.fs,'Window',sqrt(hann(cfg.windowLength,'periodic')), ...
    'OverlapLength',cfg.windowLength-cfg.hop,'FFTLength',cfg.nfft, ...
    'FrequencyRange','onesided','ConjugateSymmetric',true);
y=real(y(meta.front+(1:meta.length),:));
end
