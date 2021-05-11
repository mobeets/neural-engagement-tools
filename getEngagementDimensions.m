function [engagement_dims_fine, engagement_dims_raw, vars] = ...
    getEngagementDimensions(X, Y, grps, grps_fine, signFlipStyle)
% function [engagement_dims_fine, engagement_dims, vars] = ...
%    getEngagementDimensions(X, Y, grps, grps_fine, signFlipMode)
% 
% for each x in grps:
%    - finds the first PC of Y(X == x,:) (the "engagement dimension")
%    - flips the sign if necessary
% then interpolates all engagement dims to intermediate groups in grps_fine
% 
% inputs:
% - X (N x 1): group identity
% - Y (N x D): data
% - grps (K x 1): list of all groups
% - grps_fine (M x 1): list of groups to interpolate to
% - signFlipStyle (bool): how to define sign of engagement dimension
%      - '': do not define sign
%      - 'mode': + direction is one that increases sign for most cols of Y
%      - 'first': + direction is one that increases along Y(:,1)
% outputs:
% - engagement_dims_fine (M x D): eng. dim for each group in grps_fine
% - engagement_dims_raw (K x D): eng. dim for each group in grps
% - vars (K x 2): info on variance explained by each engagement dim
% 
    if nargin < 5
        signFlipStyle = '';
    end
    
    engagement_dims = nan(numel(grps), size(Y,2));
    vars = nan(numel(grps),2);
    for kk = 1:numel(grps)
        ix = X == grps(kk);
        if sum(ix) == 0
            continue;
        end
        
        % handle columns that have no variability by skipping them
        if any(var(Y(ix,:)) == 0)
            indsToSkip = var(Y(ix,:)) == 0;
            Yc = Y(ix,~indsToSkip);
        else
            indsToSkip = false(size(Y,1),1);
            Yc = Y(ix,:);
        end
        
        % apply PCA
        [coeff, ~, ~, ~, vexp] = pca(Yc);
        vars(kk,1) = vexp(1);
        engagement_dim = coeff(:,1);
        vars(kk,2) = var((Yc - repmat(nanmean(Yc), size(Yc,1), 1))*engagement_dim);
        
        % any columns that had no variability get zeroed out in loadings
        if sum(indsToSkip) > 0
            origInds = nan(size(Y,2),1);
            origInds(~indsToSkip) = 1:sum(~indsToSkip);
            new_vdim = zeros(size(origInds));
            for ll = 1:numel(engagement_dim)
                new_vdim(origInds == ll) = engagement_dim(ll);
            end
            engagement_dim = new_vdim;
        end
        
        if doFlipDim(engagement_dim, signFlipStyle)
            engagement_dim = -engagement_dim;
        end
        engagement_dims(kk,:) = engagement_dim;
    end

    % interpolate engagement dimensions with spline
    engagement_dims_raw = engagement_dims;
    engagement_dims_fine = interpCircular(engagement_dims, grps, grps_fine);
    nrms = rowwiseNorm(engagement_dims_fine);
    engagement_dims_fine = bsxfun(@times, engagement_dims_fine, 1./nrms);
end

function doFlip = doFlipDim(cdim, signFlipStyle)
    if isempty(signFlipStyle)
        doFlip = false;
    elseif strcmpi(signFlipStyle, 'first')
        doFlip = cdim(1) < 0;
    elseif strcmpi(signFlipStyle, 'mode')
        doFlip = mean(cdim > 0) < 0.5;
    else
        error('Invalid signFlipStyle.');
    end
end

function nrms = rowwiseNorm(Xs)
    nrms = sqrt(sum(Xs.^2,2));
end
