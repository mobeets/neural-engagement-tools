%% make dummy data
% each neuron is cosine tuned with gain modulated by engagement

rng('default'); rng(666); % for reproducibility
T = 1000; % # of trials
D = 90; % # of neurons
grps = (0:45:359)'; % targets
X = grps(randi(numel(grps), T, 1))'; % random target per trial
Y = nan(T,D); % spike counts
pd = rad2deg(rand(D,1)*2*pi); % preferred directions (deg) per neuron
mu = randn(D,1) + 10; % mean firing rate per neuron
E = 1 + exp(-0.01*(1:T)); % engagement signal with exponential decay
for t = 1:T
    % find each neuron's response on this trial
    Y(t,:) = 2*E(t)*cosd(X(t) - pd) + E(t)*mu + randn(D,1)/1000;
end

% apply PCA (so we can visualize data in 3D)
[C,Y] = pca(Y);

%% find engagement dims, and then estimate engagement

grps_fine = (0:359)'; % for interpolating engagement dims between targets
signFlipStyle = 'first'; % appropriate when C(:,1) is all the same sign
info = findEngagementDims(Y, X, grps, grps_fine, signFlipStyle);
Ehat = inferEngagementGivenAim(X, Y, info);

%% plot engagement dims

figure; hold on; set(gcf, 'color', 'white');
for g = 1:numel(grps)
    scatter3(Y(X == grps(g),1), Y(X == grps(g),2), ...
        Y(X == grps(g),3), 5, 'k', 'filled');
end
plotEngagementDims(info);

%% plot estimated vs. actual engagement signal
% note: we z-score each b/c after applying PCA we lose our sense of scale

figure; hold on; set(gcf, 'color', 'white'); set(gca, 'FontSize', 16);
plot(zscore(Ehat), 'r-');
plot(zscore(E), 'k-', 'LineWidth', 2);
xlabel('trial #');
ylabel('engagement (a.u.)');
