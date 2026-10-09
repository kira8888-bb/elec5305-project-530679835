function room = make_room(cfg)
% Established image-source simulator; no custom late-reverberation generator.
V=prod(cfg.room); S=2*sum(cfg.room.*cfg.room([2 3 1]));
alpha=0.161*V/(S*cfg.rt60);
assert(alpha>0 && alpha<1,'Project:Room','Nominal RT60 gives invalid absorption.');
if isempty(cfg.imageOrder)
    order=ceil(cfg.soundSpeed*cfg.rt60/(4*V/S));
else
    order=cfg.imageOrder;
end
args={'SampleRate',cfg.fs,'SoundSpeed',cfg.soundSpeed, ...
    'Algorithm','image-source','ImageSourceOrder',order, ...
    'MaterialAbsorption',alpha,'MaterialScattering',0};
room.target=acousticRoomResponse(cfg.room,cfg.targetPosition,cfg.microphones,args{:}).';
room.interferer=acousticRoomResponse(cfg.room,cfg.interfererPosition,cfg.microphones,args{:}).';
room.absorption=alpha; room.imageOrder=order;
room.measuredT20=estimate_t20(room.target(:,cfg.referenceMic),cfg.fs);
room.nominalRT60=cfg.rt60;
end

function value=estimate_t20(h,fs)
% Broadband Schroeder decay fit from -5 to -25 dB, extrapolated to 60 dB.
edc=flipud(cumsum(flipud(h.^2)));
dB=10*log10(max(edc,realmin)/max(edc));
idx=find(dB<=-5 & dB>=-25); value=NaN;
if numel(idx)>20
    p=polyfit((idx-1)/fs,dB(idx),1);
    if p(1)<0, value=-60/p(1); end
end
end
