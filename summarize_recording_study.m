function summary=summarize_recording_study(runDir,out)
% Average seeds within the same excerpt, then summarize paired differences.
% Excerpt variation is descriptive: the two source files recur throughout.
if ~isfolder(out), mkdir(out); end
raw=readtable(fullfile(runDir,'all_scores.csv'),'TextType','string');
gain=readtable(fullfile(runDir,'gain_variance.csv'),'TextType','string');
keys={'Noise','InputSNR_dB','NominalRT60','TargetRecording','ExcerptStart_s'};
metrics={'DeltaReferenceErrorSNR_dB','SI_SDR_dB','STOI','TargetError_dB', ...
    'InterferenceReduction_dB','LowBandTFError_dB','HighBandTFError_dB'};
assert(height(raw)==432*7 && height(gain)==144*3,'Expected the complete study.');
methods=["noisy","single_wiener","das","mvdr","mvdr_binwise","mvdr_uniform","mvdr_erb"];
assert(all(arrayfun(@(method) nnz(raw.Method==method),methods)==432));
means=groupsummary(raw,[keys {'Method'}],'mean',metrics);
assert(all(means.GroupCount==3),'Each method/excerpt must have three realizations.');
assert(all(isfinite(raw.STOI)) && all(abs(raw.STOI)<=1), ...
    'Unexpected STOI scores.');
means.GroupCount=[];
means.Properties.VariableNames(end-numel(metrics)+1:end)=metrics;
writetable(means,fullfile(out,'excerpt_means.csv'));

modes={'mvdr','mvdr_binwise','mvdr_uniform'};
erb=sortrows(means(means.Method=="mvdr_erb",:),keys);
differences=cell(numel(modes),1);
for k=1:numel(modes)
    other=sortrows(means(means.Method==modes{k},:),keys);
    assert(isequal(erb(:,keys),other(:,keys)),'Method results are unpaired.');
    differences{k}=[erb(:,keys),table(repmat(string(modes{k}),height(erb),1), ...
        'VariableNames',{'Comparison'}),array2table(erb{:,metrics}-other{:,metrics}, ...
        'VariableNames',metrics)];
end
paired=vertcat(differences{:});
conditions=keys(1:3);
summary=groupsummary(paired,[conditions {'Comparison'}],{'mean','median'},metrics);
agreement=groupsummary(paired,[conditions {'Comparison'}], ...
    {@(x) sum(x>0),@min,@max},'SI_SDR_dB');
assert(isequal(summary(:,[conditions {'Comparison'}]),agreement(:,[conditions {'Comparison'}])));
summary=[summary,array2table(agreement{:,end-2:end},'VariableNames', ...
    {'PositiveSI_SDR_Excerpts','MinimumSI_SDR_dB','MaximumSI_SDR_dB'})];
writetable(summary,fullfile(out,'paired_conditions.csv'));
writetable(groupsummary(paired,[conditions {'Comparison','TargetRecording'}], ...
    'mean',metrics),fullfile(out,'paired_by_recording.csv'));
overall=groupsummary(means,'Method','mean',metrics);
writetable(overall,fullfile(out,'methods_overall.csv'));
spread=groupsummary(gain,{'Noise','NominalRT60','Method'},'mean','AcrossSeedGainVariance');
writetable(spread,fullfile(out,'gain_variance_summary.csv'));
calibration=raw(raw.Method=="mvdr",:);
writetable(groupsummary(calibration,conditions,{'median','min','max'}, ...
    'TrueToEstimatedNoise_dB'),fullfile(out,'noise_psd_diagnostic.csv'));
for name={'all_scores.csv','gain_variance.csv','inputs.csv','rooms.csv'}
    copyfile(fullfile(runDir,name{1}),fullfile(out,name{1}));
end
plot_deltas(summary,out);
plot_components(summary,out);
end

function plot_deltas(summary,out)
fig=figure('Visible','off','Position',[100 100 1000 650],'Color','w');
cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
metrics={'mean_SI_SDR_dB','mean_STOI'};
labels={'Paired SI-SDR difference (dB)','Paired STOI difference'};
noises={"stationary","competing_speech"};
comparisons=ismember(summary.Comparison,["mvdr_uniform","mvdr_binwise"]);
for r=1:2
    limits=padded_limits(summary.(metrics{r})(comparisons));
    for k=1:2
        nexttile; hold on;
        colors=[0.06 0.36 0.64; 0.75 0.30 0.10];
        for i=1:2
            rt=0.2+0.4*(i-1);
            room=summary.Noise==noises{k} & abs(summary.NominalRT60-rt)<1e-9;
            uniform=sortrows(summary(room & summary.Comparison=="mvdr_uniform",:),'InputSNR_dB');
            binwise=sortrows(summary(room & summary.Comparison=="mvdr_binwise",:),'InputSNR_dB');
            plot(uniform.InputSNR_dB,uniform.(metrics{r}),'-o','LineWidth',1.6,'Color',colors(i,:), ...
                'DisplayName',sprintf('vs uniform, RT60 %.1f s',rt));
            plot(binwise.InputSNR_dB,binwise.(metrics{r}),'--s','LineWidth',1.6,'Color',colors(i,:), ...
                'DisplayName',sprintf('vs bin-wise, RT60 %.1f s',rt));
        end
        yline(0,':','HandleVisibility','off');
        xticks([-5 0 5]); xlabel('Input SNR (dB)'); ylabel(labels{r});
        xlim([-5.5 5.5]);
        ylim(limits);
        title(strrep(noises{k},'_',' ')); grid on;
        if r==1 && k==1, legend('Location','best'); end
    end
end
sgtitle('Paired differences for ERB Wiener after MVDR');
exportgraphics(fig,fullfile(out,'paired_postfilters.png'),'Resolution',170);
end

function plot_components(summary,out)
fig=figure('Visible','off','Position',[100 100 950 420],'Color','w');
cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
uniform=summary(summary.Comparison=="mvdr_uniform",:);
xLimits=padded_limits(uniform.mean_TargetError_dB);
yLimits=padded_limits(uniform.mean_InterferenceReduction_dB);
for rt=[0.2 0.6]
    nexttile; hold on;
    for noise=["stationary","competing_speech"]
        rows=summary(summary.NominalRT60==rt & summary.Noise==noise & ...
            summary.Comparison=="mvdr_uniform",:);
        scatter(rows.mean_TargetError_dB,rows.mean_InterferenceReduction_dB,52, ...
            'filled','DisplayName',strrep(noise,'_',' '));
        for k=1:height(rows)
            xOffset=0.012*diff(xLimits);
            yOffset=0.023*diff(yLimits)*(rows.InputSNR_dB(k)/5);
            text(rows.mean_TargetError_dB(k)+xOffset,rows.mean_InterferenceReduction_dB(k)+yOffset, ...
                sprintf('%g dB',rows.InputSNR_dB(k)),'FontSize',9);
        end
    end
    xline(0,':','HandleVisibility','off'); yline(0,':','HandleVisibility','off');
    xlabel('Target error difference (dB)'); ylabel('Interference reduction difference (dB)');
    title(sprintf('Nominal RT60 %.1f s',rt)); grid on;
    xlim(xLimits); ylim(yLimits); legend('Location','northwest');
end
sgtitle('ERB minus uniform | lower target error and higher interference reduction are better');
exportgraphics(fig,fullfile(out,'component_tradeoff.png'),'Resolution',170);
end

function limits=padded_limits(x)
lo=min([0;x]); hi=max([0;x]);
pad=0.14*max(hi-lo,eps);
limits=[lo-pad,hi+pad];
end
