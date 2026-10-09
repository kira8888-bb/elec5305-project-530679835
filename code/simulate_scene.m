function scene = simulate_scene(cfg,room)
% References are kept separately and used ONLY by evaluator/known_rtf mode.
rng(cfg.seed,'twister');
if nargin<2, room=make_room(cfg); end
ns=round(cfg.duration*cfg.fs); nc=round(cfg.calibrationSeconds*cfg.fs);
[s,synthetic]=load_source(cfg.targetFile,cfg,'target',ns);
s=[zeros(nc,1); s];
nTotal=numel(s);
switch cfg.noiseType
    case 'stationary'
        i=randn(nTotal,1); syntheticInterferer=false;
    case 'competing_speech'
        [i,syntheticInterferer]=load_source(cfg.interfererFile,cfg,'interferer',nTotal);
    otherwise
        error('Project:Noise','Unknown noiseType.');
end
M=size(cfg.microphones,1);
L=nTotal+max(size(room.target,1),size(room.interferer,1))-1;
target=zeros(L,M); directional=zeros(L,M);
for m=1:M
    a=conv(s,room.target(:,m)); target(1:numel(a),m)=a;
    b=conv(i,room.interferer(:,m)); directional(1:numel(b),m)=b;
end
ref=cfg.referenceMic;
% Same fixed evaluation interval for all outputs; includes target RIR tail.
evalIdx=(nc+1:L)';
v=randn(L,M);
v=v*sqrt(cfg.backgroundPowerRatio*mean(directional(evalIdx,ref).^2));
noise=directional+v;
scale=sqrt(sum(target(evalIdx,ref).^2)/(10^(cfg.inputSNR/10)*sum(noise(evalIdx,ref).^2)));
noise=noise*scale;
scene.mixture=target+noise; scene.target=target; scene.noise=noise;
scene.reference=target(:,ref); scene.evalIdx=evalIdx; scene.room=room;
scene.synthetic=synthetic || syntheticInterferer;
scene.inputSNR=10*log10(sum(target(evalIdx,ref).^2)/sum(noise(evalIdx,ref).^2));
end
