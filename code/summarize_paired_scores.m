function [paired,summary] = summarize_paired_scores(scores)
% ERB minus each control on identical mixtures. Resample utterance pairs.
conditions = {'Noise','InputSNR','NominalRT60'};
pairKey = [conditions,{'Utterance','Seed'}];
metrics = {'SI_SDR_dB','ReferenceErrorSNR_dB','STOI', ...
    'InterferenceAttenuation_dB','TargetDistortion_dB'};
erb = sortrows(scores(strcmp(scores.Method,'mvdr_erb'),:),pairKey);
assert(~isempty(erb) && height(unique(erb(:,pairKey))) == height(erb), ...
    'Project:Pairs','Expected a single ERB row per condition, utterance and seed.');
[utteranceGroup,utterances] = findgroups(erb(:,[conditions,{'Utterance'}]));
[conditionGroup,conditionRows] = findgroups(utterances(:,conditions));
controls = {'mvdr_binwise','mvdr_uniform'};
paired = table();
summary = table();
stream = RandStream('mt19937ar','Seed',5305);
for c = 1:numel(controls)
    control = controls{c};
    baseline = sortrows(scores(strcmp(scores.Method,control),:),pairKey);
    assert(isequal(erb(:,pairKey),baseline(:,pairKey)), ...
        'Project:Pairs','ERB and %s must score exactly the same mixtures.',control);

    for m = 1:numel(metrics)
        metric = metrics{m};
        seedDeltas = erb.(metric) - baseline.(metric);
        % Require all seed pairs for an utterance/metric. STOI can be unavailable.
        seedDeltas(~isfinite(seedDeltas)) = NaN;
        utteranceDeltas = splitapply(@mean,seedDeltas,utteranceGroup);
        rows = utterances;
        rows.Control = repmat({control},height(rows),1);
        rows.Metric = repmat({metric},height(rows),1);
        rows.ERBMinusControl = utteranceDeltas;
        paired = [paired; rows]; %#ok<AGROW>

        rows = conditionRows;
        rows.Control = repmat({control},height(rows),1);
        rows.Metric = repmat({metric},height(rows),1);
        stats = nan(height(rows),4);
        for k = 1:height(rows)
            d = utteranceDeltas(conditionGroup == k & isfinite(utteranceDeltas));
            n = numel(d);
            stats(k,1:2) = [n,mean(d)];
            if n >= 2
                draw = randi(stream,n,n,2000);
                replicateMeans = sort(mean(reshape(d(draw),n,[]),1));
                stats(k,3:4) = replicateMeans([50,1950]);
            end
        end
        rows.NUtterancePairs = stats(:,1);
        rows.MeanERBMinusControl = stats(:,2);
        rows.CI95Low = stats(:,3);
        rows.CI95High = stats(:,4);
        summary = [summary; rows]; %#ok<AGROW>
    end
end
end
