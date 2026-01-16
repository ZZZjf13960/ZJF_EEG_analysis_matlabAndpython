function [microstate] = ft_microstates(data, n_states)
    % ft_microstates - Perform microstate analysis using FieldTrip data structure
    %
    % Inputs:
    %   data     - FieldTrip data structure (timelock or raw)
    %   n_states - Number of states (default 4)
    %
    % Outputs:
    %   microstate - Structure containing maps, labels, and GEV

    if nargin < 2
        n_states = 4;
    end

    % Concatenate trials if multiple
    if iscell(data.trial)
        % Raw data structure
        dat = cat(2, data.trial{:});
        time = cat(2, data.time{:}); % usually not needed for clustering
    else
        % Timelock data structure (avg or single trial matrix)
        dat = data.trial;
    end

    % Check dimensions: (nchans, nsamples)
    [nchans, nsamples] = size(dat);

    % 1. GFP Calculation
    gfp = std(dat, 0, 1);

    % 2. Peak finding
    % Manual simple peak finding
    df = diff(gfp);
    locs = find(df(1:end-1) > 0 & df(2:end) < 0) + 1;

    if isempty(locs)
        locs = 1:nsamples;
    end

    peak_maps = dat(:, locs);

    % Normalize
    peak_maps_norm = peak_maps ./ repmat(sqrt(sum(peak_maps.^2, 1)), nchans, 1);
    peak_maps_norm(isnan(peak_maps_norm)) = 0;

    % 3. Clustering
    % Note: Standard Microstate analysis uses "Modified K-Means" which ignores polarity
    % (treats map X and -X as same). This implementation uses standard K-Means, which
    % is a simplification. Polarity is handled in the backfitting step (absolute correlation).

    X = peak_maps_norm';
    opts = statset('Display','off');
    try
        [idx, C] = kmeans(X, n_states, 'Distance', 'sqeuclidean', 'Replicates', 5, 'Options', opts);
    catch
        % Fallback if stats toolbox missing (unlikely if using FT)
        error('Statistics Toolbox (kmeans) required for this implementation.');
    end

    maps = C; % (n_states x nchans)
    maps = maps ./ repmat(sqrt(sum(maps.^2, 2)), 1, nchans);

    % 4. Backfit
    dat_norm = dat ./ repmat(sqrt(sum(dat.^2, 1)), nchans, 1);
    dat_norm(isnan(dat_norm)) = 0;

    activation = maps * dat_norm;
    [max_corr, labels] = max(abs(activation), [], 1);

    % 5. GEV and Sorting
    gfp_sum_sq = sum(gfp.^2);
    state_gev = zeros(1, n_states);
    for k = 1:n_states
        mask = (labels == k);
        if any(mask)
            state_gev(k) = sum( (gfp(mask) .* max_corr(mask)).^2 ) / gfp_sum_sq;
        end
    end

    [gev_sorted, sort_order] = sort(state_gev, 'descend');
    maps = maps(sort_order, :);

    label_map = zeros(1, n_states);
    label_map(sort_order) = 1:n_states;
    labels = label_map(labels);

    % Prepare output structure
    microstate = [];
    microstate.maps = maps;         % (n_states x nchans)
    microstate.labels = labels;     % (1 x nsamples)
    microstate.gev = sum(gev_sorted);
    microstate.gev_per_state = gev_sorted;
    microstate.gfp = gfp;

end
