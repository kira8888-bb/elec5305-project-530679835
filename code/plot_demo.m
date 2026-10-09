function plot_demo(r,out)
fig=figure('Visible','off','Color','w','Position',[100 100 1100 760]);
cleaner=onCleanup(@() close(fig));
names={'noisy','mvdr','mvdr_binwise','mvdr_uniform','mvdr_erb'};
[S,meta]=tf_analysis(r.scene.reference,r.cfg);
clim=[-70 0]; ref=max(abs(S),[],'all');
t=meta.frameStart+r.cfg.windowLength/(2*r.cfg.fs);
for k=1:6
    if k==1, X=S; label='Reverberant target reference';
    else, X=tf_analysis(r.outputs.(names{k-1}),r.cfg); label=strrep(names{k-1},'_',' '); end
    subplot(3,2,k); imagesc(t,meta.f/1000,20*log10(max(abs(X)/max(ref,eps),1e-6)));
    axis xy; caxis(clim); ylim([0 6]); xlim([r.cfg.calibrationSeconds max(t)]);
    title(label); xlabel('Time (s)'); ylabel('Frequency (kHz)'); colorbar;
end
if r.scene.synthetic, sgtitle('Synthetic engineering check - not speech performance evidence'); end
exportgraphics(fig,fullfile(out,'spectrograms.png'),'Resolution',150);
end
