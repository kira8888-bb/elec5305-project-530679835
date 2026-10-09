function [A,B,centres]=frequency_bands(f,mode,numBands)
% A: nonnegative, unit-row-sum PSD averaging. B: unit-row-sum gain mapping.
% Triangles are linear in Hz for both variants; only centre spacing differs.
f=f(:); F=numel(f);
if strcmp(mode,'binwise'), A=speye(F); B=A; centres=f; return; end
assert(numBands>=2 && numBands<=F);
switch mode
    case 'uniform', centres=linspace(f(1),f(end),numBands).';
    case 'erb'
        erb=@(x) 21.4*log10(1+0.00437*x);
        invErb=@(x) (10.^(x/21.4)-1)/0.00437;
        centres=invErb(linspace(erb(f(1)),erb(f(end)),numBands)).';
        centres([1 end])=f([1 end]);
    otherwise, error('Project:Bands','Unknown frequency grouping.');
end
% Piecewise linear interpolation produces endpoint shoulders & full coverage.
W=interp1(centres,eye(numBands),f,'linear').'; W=max(W,0);
assert(all(sum(W,2)>0),'Project:Bands','Empty band: reduce numBands/increase NFFT.');
A=W./sum(W,2); B=W.'./sum(W,1).';
end
