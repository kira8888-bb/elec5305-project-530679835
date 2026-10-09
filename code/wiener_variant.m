function [Z,G]=wiener_variant(Y,psd,f,mode,cfg)
[A,B]=frequency_bands(f,mode,cfg.numBands);
speech=A*psd.speech; noise=A*psd.noise;
xi=speech./max(noise,1e-12);
bandGain=xi./(1+xi);
G=max(cfg.gainFloor,min(1,B*bandGain));
Z=G.*Y;
end
