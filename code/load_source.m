function [s,isSynthetic] = load_source(filename,cfg,role,nSamples)
% User WAV is resampled, downmixed and cropped; not silently looped.
isSynthetic = isempty(filename);
if isSynthetic
    t = (0:nSamples-1)'/cfg.fs;
    if strcmp(role,'target'), f0=135; else, f0=207; end
    phase = 2*pi*(f0*t + 3*sin(2*pi*0.7*t));
    s = zeros(size(t));
    for h=1:24
        f=h*f0;
        envelope = exp(-((f-650)/300)^2) + 0.6*exp(-((f-1500)/450)^2) ...
            + 0.3*exp(-((f-2700)/500)^2);
        s = s + envelope*sin(h*phase)/sqrt(h);
    end
    s=s.*max(0,sin(2*pi*2.1*t)).^0.6;
else
    assert(isfile(filename),'Project:Audio','Audio file not found: %s',filename);
    [s,fs] = audioread(filename);
    s=mean(s,2);
    if fs~=cfg.fs, s=resample(s,cfg.fs,fs); end
    assert(numel(s)>=nSamples,'Project:Audio', ...
        '%s needs at least %.2f seconds of audio.',role,nSamples/cfg.fs);
    s=s(1:nSamples);
end
s=s-mean(s);
assert(all(isfinite(s)) && norm(s)>1e-10,'Project:Audio','Empty/invalid source.');
s=s/sqrt(mean(s.^2));
end
