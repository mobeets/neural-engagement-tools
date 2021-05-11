function [engagement, inds] = inferEngagementGivenAim(aims, Y, eng_info)
% inputs:
% - aims [N x 1] - list of angles, in deg, between [0,360)
% - Y [N x D] - neural activity
% - eng_info (struct) - contains aiming ellipse and engagement dims
% outputs:
% - engagement [N x 1] - inferred engagement for each time step
% - inds [N x 1] - index of engagement axis used for each time step
% 
    engagement = nan(numel(aims),1);
    inds = nan(numel(aims),1);
    for t = 1:size(engagement,1)
        % interpolate to find aim and engagement dimensions
        angs = angdiff(aims(t), eng_info.grps_fine);
        [~,ix] = min(angs);
        engagement(t) = (Y(t,:) - eng_info.Ysmu(ix,:)) * ...
            eng_info.engagement_dims(ix,:)';
        inds(t) = find(ix);
    end 
end

function delta = angdiff(a,b)
% function delta = angdiff(a,b)
% 
% returns smallest angle difference between a and b (in degrees)
%  answer will be between 0-180. 
% 
    delta = min(360-mod(a-b,360), mod(a-b,360));
end
