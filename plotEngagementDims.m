function plotEngagementDims(info, opts)
% function plotEngagementDims(info, opts)
% 
% plots the aiming ellipse and engagement dimensions per group
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('showEllipse', true, ...
        'showMean', true, ...
        'showAxis', true, ...
        'markerSizeMean', 75, ...
        'axisLineWidth', 2, ...
        'axisColor', [241 90 41]/255, ...
        'ellipseColor', 0.8*ones(1,3));
    opts = setDefaultOptsWhenNecessary(opts, defopts, true);
    
    % plot aiming ellipse
    if opts.showEllipse
        ysmu = info.Ysmu;
        ysmu = [ysmu; ysmu(1,:)];
        plot3(ysmu(:,1), ysmu(:,2), ysmu(:,3), '-', ...
            'Color', opts.ellipseColor);
    end
    
    % plot mean and axis per group
    mus = info.Ysmu_anchors;
    dims = info.engagement_dims_anchors;
    mus_plus_eng = mus + bsxfun(@times, dims, ...
        sqrt(info.stats.engagement_dim_variance_explained));
    for g = 1:numel(info.grps)
        if opts.showMean
            scatter3(mus(g,1), mus(g,2), mus(g,3), ...
                opts.markerSizeMean, 'filled');
        end
        if opts.showAxis
            plot3([mus(g,1) mus_plus_eng(g,1)], ...
                [mus(g,2) mus_plus_eng(g,2)], ...
                [mus(g,3) mus_plus_eng(g,3)], ...
                '-', 'Color', opts.axisColor, ...
                'LineWidth', opts.axisLineWidth);
        end
    end
    axis equal;
    axis off;
end

function opts = setDefaultOptsWhenNecessary(opts, defopts, warnIfNoDefault)
    if nargin < 3
        % if opts has a field that defopts does not, give a warning
        warnIfNoDefault = false;
    end
    fns = fieldnames(defopts);
    for ii = 1:numel(fns)
        if ~isfield(opts, fns{ii})
            opts.(fns{ii}) = defopts.(fns{ii});
        end
    end
    if ~warnIfNoDefault
        return;
    end
    extra_fns = setdiff(fieldnames(opts), fns);
    if numel(extra_fns) > 0
        warning(['The following fields in opts had no defaults: ''' ...
            strjoin(extra_fns, ''', ''') '''. Are these fields valid?']);
    end
end
