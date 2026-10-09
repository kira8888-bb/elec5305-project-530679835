function scores=score_signals(outputs,scene,cfg)
% Main SNR metric is reference-to-error SNR, explicitly including distortion.
ref=scene.reference(scene.evalIdx); names=fieldnames(outputs);
input=scene.mixture(scene.evalIdx,cfg.referenceMic);
inputScore=error_snr(ref,input);
rows=cell(numel(names),5);
for k=1:numel(names)
    y=outputs.(names{k})(scene.evalIdx);
    errSNR=error_snr(ref,y); si=si_sdr(ref,y); st=NaN;
    if cfg.enableSTOI && ~scene.synthetic && exist('stoi','file')
        st=stoi(y,ref,cfg.fs);
    end
    rows(k,:)={names{k},errSNR,errSNR-inputScore,si,st};
end
scores=cell2table(rows,'VariableNames', ...
    {'Method','ReferenceErrorSNR_dB','DeltaReferenceErrorSNR_dB','SI_SDR_dB','STOI'});
end

function v=error_snr(s,y)
v=10*log10(max(sum(s.^2),realmin)/max(sum((s-y).^2),realmin));
end

function v=si_sdr(s,y)
s=s-mean(s); y=y-mean(y);
p=(s'*y/max(s'*s,realmin))*s;
v=10*log10(max(sum(p.^2),realmin)/max(sum((y-p).^2),realmin));
end
