function [Ysmu, Ysmu_raw] = getEllipse(X, Y, grps, grps_fine)
% function [Ysmu, Ysmu_raw] = getEllipse(X, Y, grps, grps_fine)
% 
% for each x in grps: finds mean(Y(X == x,:))
% and then interpolates these means across all groups in grps_fine
%   (where grps and grps_fine is a list of angles in degrees)
% 
% inputs:
% - X (N x 1): group identity
% - Y (N x D): data
% - grps (K x 1): list of all groups (unit: degrees)
% - grps_fine (M x 1): list of groups to interpolate to (unit: degrees)
% outputs:
% - Ysmu (M x D): mean of Y for each group in grps_fine
% - Ysmu_raw (K x D): mean of Y for each group in grps
%
    if nargin < 4
        grps_fine = grps;
    end
    
    % find average Y for each group X
    Ysmu = nan(numel(grps), size(Y,2));
    for kk = 1:numel(grps)
        Ysmu(kk,:) = nanmean(Y(X == grps(kk),:));
    end
    
    % interpolate Y for intermediate values of X
    Ysmu_raw = Ysmu;
    if ~isequal(grps, grps_fine)
        Ysmu = interpCircular(Ysmu, grps, grps_fine);
    end
end
