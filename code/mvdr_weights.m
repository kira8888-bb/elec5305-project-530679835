function [w,Rloaded]=mvdr_weights(R,d,loading)
% Standard distortionless solution; see MathWorks MVDR example in REFERENCES.
M=numel(d); R=(R+R')/2;
Rloaded=R+max(real(trace(R))/M,1e-12)*loading*eye(M);
q=Rloaded\d;
den=real(d'*q);
assert(isfinite(den) && den>0,'Project:MVDR','Invalid covariance/steering.');
w=q/den;
end
