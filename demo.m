%% 1. Generate example data

% 1a. In this example, we generate spiking activity for D neurons on T different trials, where each trial has its own trial condition.
% Here we assume the neurons are consine-tuned, so each trial condition is a different target direction.
% The level of neural engagement on each trial (shared across all neurons) acts as a gain term on each neuron's tuning response.

rng('default'); rng(666); % for reproducibility
T = 1000; % # of trials
D = 90; % # of neurons
grps = (0:45:359)'; % targets
X = grps(randi(numel(grps), T, 1))'; % trial condition for each trial (T x 1)
Y = nan(T,D); % spike counts for each trial (T x D)
pd = rad2deg(rand(D,1)*2*pi); % preferred directions (deg) per neuron (D x 1)
mu = randn(D,1) + 10; % mean firing rate per neuron (D x 1)
E = 1 + exp(-0.01*(1:T)); % neural engagement per trial (exponential decay) (T x 1)
for t = 1:T
    % find each neuron's response on this trial
    Y(t,:) = 2*E(t)*cosd(X(t) - pd) + E(t)*mu + randn(D,1)/1000;
end

% 1b. To allow for easier visualization of population activity (i.e., in 3D), apply PCA to spike counts
[C,Y] = pca(Y);

%% 2. Find neural engagement axes, and then infer the level of neural engagement on each trial

grps_fine = (0:359)'; % for interpolating engagement dims between targets
signFlipStyle = 'first'; % appropriate when C(:,1) is all the same sign
info = findEngagementDims(Y, X, grps, grps_fine, signFlipStyle);
Ehat = inferEngagementGivenAim(X, Y, info);

%% 3. Visualize neural engagement axes

figure; hold on; set(gcf, 'color', 'white');
for g = 1:numel(grps)
    scatter3(Y(X == grps(g),1), Y(X == grps(g),2), ...
        Y(X == grps(g),3), 5, 'k', 'filled');
end
plotEngagementDims(info);

%% 4. Plot estimated vs. actual neural engagement on each trial
% Note: E and Ehat are z-scored separately b/c we lose a common scale after applying PCA in 1b

figure; hold on; set(gcf, 'color', 'white'); set(gca, 'FontSize', 16);
plot(zscore(Ehat), 'r-');
plot(zscore(E), 'k-', 'LineWidth', 2);
xlabel('trial #');
ylabel('engagement (a.u.)');
