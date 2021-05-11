function info = findEngagementDims(Y, X, grps, grps_fine, signFlipStyle)
% function [Ysmu, Ysmu_raw] = getEllipse(X, Y, grps, grps_fine)
% 
% inputs:
% - X (N x 1): group identity
% - Y (N x D): data
% - grps (K x 1): list of all groups (units: degrees)
% - grps_fine (M x 1): list of groups to interpolate to (units: degrees)
% - signFlipStyle (bool): how to define sign of engagement dimension
%      - '': do not define sign
%      - 'mode': + direction is one that increases sign for most cols of Y
%      - 'first': + direction is one that increases along Y(:,1)
% outputs:
% - info (struct)
%       - Ysmu (M x D): mean of Y for each group in grps_fine
%       - engagement_dims (M x D): eng. dim for each group in grps_fine
%       - Ysmu_anchors (K x D): mean of Y for each group in grps
%       - engagement_dims_anchors (K x D): eng. dim for each group in grps
%       - stats (struct): info on variance explained by each engagement dim
% 
    if nargin < 3
        grps = unique(X);
    end
    if nargin < 4
        grps_fine = unique(X);
    end
    if nargin < 5
        signFlipStyle = 'mode';
    end

    % find aiming ellipse and engagement dims, interpolated to grps_fine
    [Ysmu, Ysmu_anchors] = getEllipse(X, Y, grps, grps_fine);
    [engagement_dims, engagement_dims_anchors, vars] = ...
        getEngagementDimensions(X, Y, grps, grps_fine, signFlipStyle);
    
    % store results
    clear info;
    info.Ysmu = Ysmu;
    info.engagement_dims = engagement_dims;
    info.Ysmu_anchors = Ysmu_anchors;    
    info.engagement_dims_anchors = engagement_dims_anchors;
    info.grps = grps;
    info.grps_fine = grps_fine;
    info.signFlipStyle = signFlipStyle;
    info.stats.engagement_dim_variance_explained = vars(:,1);
    info.stats.engagement_dim_vars_anchors = vars(:,2);
    info.stats.engagement_dim_vars = interpCircular(vars(:,2), grps, grps_fine);
end
