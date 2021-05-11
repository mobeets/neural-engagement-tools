function y_target = interpCircular(y_source, x_source, x_target, ~)
% function y_target = interpCircular(y_source, x_source, x_target, ~)
%
% fits spline to interpolate data associated with angular measurements
% 
% y_source [N x K] - source data
% x_source [N x 1] - angles corresponding to source data (deg)
% x_target [M x 1] - angles we wish to interpolate the corresponding data
% 
% Note: assumes that the slope of the curve is 0 at the start-point
%    (this is needed to prevent having sharp points at the start...)
%
% Author: Jay Hennig
% 
    assert(size(y_source,1) == numel(x_source));

    % copy everything to make loop close
    x_source = [x_source; x_source(1:end)+360]';
    y_source = [y_source; y_source(1:end,:)];
    
    % adding 0's before and after fixes the slope at the endpoints to 0
    nd = size(y_source,2);
    y_source = [zeros(1,nd); y_source; zeros(1,nd)]';
    
    % fit spline and use it to interpolate data
    y_target = spline(deg2rad(x_source), y_source, deg2rad(x_target)')';
    return;
    
end
