function comparison=compare_recording_studies(originalDir,followupDir)
% Compare condition means for two disjoint, identically weighted recording pairs.
names={'Noise','InputSNR_dB','NominalRT60','Comparison'};
metrics={'mean_SI_SDR_dB','mean_STOI','mean_DeltaReferenceErrorSNR_dB', ...
    'mean_TargetError_dB','mean_InterferenceReduction_dB'};
original=readtable(fullfile(originalDir,'paired_conditions.csv'),'TextType','string');
followup=readtable(fullfile(followupDir,'paired_conditions.csv'),'TextType','string');
original=sortrows(original,names);
followup=sortrows(followup,names);
assert(height(original)==36 && isequal(original(:,names),followup(:,names)), ...
    'Expected the same 12 conditions and three comparisons in each study.');
assert(all(original.GroupCount==12) && all(followup.GroupCount==12), ...
    'Expected 12 target-role excerpts per condition in each study.');
comparison=original(:,names);
for k=1:numel(metrics)
    name=metrics{k};
    comparison.(['Original_' name])=original.(name);
    comparison.(['Followup_' name])=followup.(name);
    comparison.(['Combined_' name])=0.5*(original.(name)+followup.(name));
end
comparison.Original_PositiveSI_SDR_Excerpts=original.PositiveSI_SDR_Excerpts;
comparison.Followup_PositiveSI_SDR_Excerpts=followup.PositiveSI_SDR_Excerpts;

% Recording 3 reached near full scale in the window beginning at 1 s.
% Omit that window for both roles to retain the balanced pair.
excerpts=readtable(fullfile(followupDir,'excerpt_means.csv'),'TextType','string');
excerpts=excerpts(excerpts.ExcerptStart_s~=1,:);
conditions=names(1:3);
excerptKeys=[conditions,{'TargetRecording','ExcerptStart_s'}];
erb=sortrows(excerpts(excerpts.Method=="mvdr_erb",:),excerptKeys);
comparison.Followup_WithoutFirstWindow_SI_SDR_dB=nan(height(comparison),1);
comparison.Followup_WithoutFirstWindow_STOI=nan(height(comparison),1);
for method=["mvdr","mvdr_binwise","mvdr_uniform"]
    baseline=sortrows(excerpts(excerpts.Method==method,:),excerptKeys);
    assert(isequal(erb(:,excerptKeys),baseline(:,excerptKeys)),'Unpaired excerpts.');
    deltas=erb(:,conditions);
    deltas.SI_SDR_dB=erb.SI_SDR_dB-baseline.SI_SDR_dB;
    deltas.STOI=erb.STOI-baseline.STOI;
    reduced=sortrows(groupsummary(deltas,conditions,'mean',{'SI_SDR_dB','STOI'}),conditions);
    rows=comparison.Comparison==method;
    assert(all(reduced.GroupCount==10) && isequal(comparison(rows,conditions),reduced(:,conditions)));
    comparison.Followup_WithoutFirstWindow_SI_SDR_dB(rows)=reduced.mean_SI_SDR_dB;
    comparison.Followup_WithoutFirstWindow_STOI(rows)=reduced.mean_STOI;
end
writetable(comparison,fullfile(followupDir,'comparison_with_original.csv'));
end
