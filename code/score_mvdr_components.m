function scores = score_mvdr_components(scores,outputs,scene,weights,gains,meta,cfg)
% Freeze the filters learned from the mixture before isolating either source.
% This diagnostic uses simulated stems only for scoring.
targetTF = tf_analysis(scene.target,cfg);
targetMVDR = sum(targetTF .* reshape(weights',[size(weights,2),1,size(weights,1)]),3);
idx = scene.evalIdx;
reference = scene.reference(idx);
targetEnergy = sum(reference.^2);
inputNoiseEnergy = sum(scene.noise(idx,cfg.referenceMic).^2);

scores.InterferenceAttenuation_dB = nan(height(scores),1);
scores.TargetDistortion_dB = nan(height(scores),1);
methods = [{'mvdr'}; fieldnames(gains)];
for k = 1:numel(methods)
    method = methods{k};
    targetOutputTF = targetMVDR;
    if k > 1
        targetOutputTF = gains.(method) .* targetOutputTF;
    end
    targetOutput = tf_synthesis(targetOutputTF,meta,cfg);
    % Superposition holds conditional on the frozen weights and gain map.
    residual = outputs.(method)(idx) - targetOutput(idx);
    row = strcmp(scores.Method,method);
    scores.InterferenceAttenuation_dB(row) = ...
        -10*log10(max(sum(residual.^2)/inputNoiseEnergy,1e-12));
    scores.TargetDistortion_dB(row) = ...
        10*log10(max(sum((targetOutput(idx)-reference).^2)/targetEnergy,1e-12));
end
end
