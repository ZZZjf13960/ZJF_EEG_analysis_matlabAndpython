function [microstates, labels, gev] = microstate_analysis_eeglab(EEG, n_states)
    % microstate_analysis_eeglab - Perform microstate segmentation using K-means
    %
    % Inputs:
    %   EEG      - EEGLAB structure (must contain .data and .srate)
    %   n_states - Number of microstates to find (default: 4)
    %
    % Outputs:
    %   microstates - (n_states x n_channels) Normalized topography maps
    %   labels      - (1 x n_times) Sequence of microstate labels (1..n_states)
    %   gev         - Global Explained Variance (0..1)

    if nargin < 2
        n_states = 4;
    end

    % Check data dimensions
    if ndims(EEG.data) == 3
        % Reshape 3D (ch x time x trials) to 2D (ch x concatenated_time)
        [nchans, npnts, ntrials] = size(EEG.data);
        data = reshape(EEG.data, nchans, npnts * ntrials);
    else
        data = EEG.data;
    end

    [nchans, ntotal] = size(data);

    % 1. Calculate GFP (Standard deviation across channels)
    % Using std with normalization by N (second arg 1) or N-1 (second arg 0)?
    % GFP is usually defined as RMS of re-referenced data or STD.
    gfp = std(data, 0, 1);

    % 2. Find GFP Peaks
    % Use findpeaks if available (Signal Processing Toolbox)
    % Or simple local maxima logic
    try
        [~, locs] = findpeaks(gfp);
    catch
        % Fallback if findpeaks not present
        df = diff(gfp);
        locs = find(df(1:end-1) > 0 & df(2:end) < 0) + 1;
    end

    if isempty(locs)
        warning('No GFP peaks found. Using all data points.');
        locs = 1:ntotal;
    end

    peak_maps = data(:, locs);

    % Normalize peak maps (Spatial correlation relies on direction, not amplitude)
    % Norm along channels (dim 1)
    peak_maps_norm = peak_maps ./ repmat(sqrt(sum(peak_maps.^2, 1)), nchans, 1);

    % Handle NaNs if any silent channels
    peak_maps_norm(isnan(peak_maps_norm)) = 0;

    % 3. Clustering (K-Means)
    % Note: Standard Microstate analysis uses "Modified K-Means" which ignores polarity
    % (treats map X and -X as same). This implementation uses standard K-Means, which
    % is a simplification. Polarity is handled in the backfitting step (absolute correlation).

    % MATLAB kmeans expects (n_samples, n_features).
    % Samples = time points, Features = channels.
    X = peak_maps_norm';

    opts = statset('Display','off');
    % 'Replicates' to avoid local minima
    [idx, C] = kmeans(X, n_states, 'Distance', 'sqeuclidean', 'Replicates', 5, 'Options', opts);

    % C is (n_states x n_channels).
    microstates = C;

    % Normalize microstate maps
    microstates = microstates ./ repmat(sqrt(sum(microstates.^2, 2)), 1, nchans);

    % 4. Backfitting (Assignment) to full data
    % Normalize full data
    data_norm = data ./ repmat(sqrt(sum(data.^2, 1)), nchans, 1);
    data_norm(isnan(data_norm)) = 0;

    % Compute correlation: Maps (n_states x ch) * Data (ch x time)
    activation = microstates * data_norm;

    % Take absolute correlation (ignoring polarity)
    [max_corr, labels] = max(abs(activation), [], 1);

    % 5. Calculate GEV
    % GEV = Sum( (GFP(t) * Correlation(t))^2 ) / Sum( GFP(t)^2 )
    gfp_sum_sq = sum(gfp.^2);
    gev = sum( (gfp .* max_corr).^2 ) / gfp_sum_sq;

    % 6. Sort Microstates by GEV contribution
    state_gev = zeros(1, n_states);
    for k = 1:n_states
        mask = (labels == k);
        if any(mask)
            state_gev(k) = sum( (gfp(mask) .* max_corr(mask)).^2 ) / gfp_sum_sq;
        end
    end

    [~, sort_order] = sort(state_gev, 'descend');

    % Reorder maps
    microstates = microstates(sort_order, :);

    % Reorder labels
    % Create a mapping: old_label -> new_label
    % new_label i corresponds to old_label sort_order(i)
    % So if sort_order is [3 1 2 4], old 3 becomes 1, old 1 becomes 2...
    % map(sort_order) = 1:n_states

    label_map = zeros(1, n_states);
    label_map(sort_order) = 1:n_states;
    labels = label_map(labels);

end
