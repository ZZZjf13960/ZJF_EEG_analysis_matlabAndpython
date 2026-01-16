import numpy as np
from sklearn.cluster import KMeans
from scipy.signal import find_peaks

def calculate_gfp(data):
    """
    Calculate Global Field Power (GFP).

    Parameters:
    -----------
    data : array, shape (n_channels, n_times)
        The EEG data.

    Returns:
    --------
    gfp : array, shape (n_times,)
        The GFP time series.
    """
    # GFP is the standard deviation of the potentials across electrodes at each time point
    # (equivalent to RMS if average reference is used)
    # Ensure average reference if not already done?
    # Usually assumed data is already re-referenced.

    # Using std across channels (axis 0)
    # data.std(axis=0) uses N-1 by default? No, numpy std default ddof=0
    gfp = np.std(data, axis=0)
    return gfp

def segment_microstates(inst, n_states=4, random_state=None, n_init=10):
    """
    Perform Microstate Analysis using K-Means clustering.

    Parameters:
    -----------
    inst : mne.io.Raw or mne.Epochs
        Data object.
    n_states : int
        Number of microstates to find (default 4).
    random_state : int | None
        Seed for KMeans.
    n_init : int
        Number of initializations for KMeans.

    Returns:
    --------
    maps : array, shape (n_states, n_channels)
        The microstate topography maps.
    segmentation : array, shape (n_times,)
        Label of the active microstate at each time point.
    gev : float
        Global Explained Variance.
    """

    # 1. Get data
    if hasattr(inst, 'get_data'):
        data = inst.get_data() # (n_channels, n_times) or (n_epochs, n_channels, n_times)
    else:
        raise ValueError("Instance must have get_data() method")

    # If epochs, concatenate trials for clustering?
    if data.ndim == 3:
        n_epochs, n_ch, n_times = data.shape
        data = np.hstack(data) # (n_ch, n_epochs * n_times)

    n_ch, n_times = data.shape

    # 2. Compute GFP
    gfp = calculate_gfp(data)

    # 3. Find GFP peaks (local maxima)
    # Simple peak finding
    peaks, _ = find_peaks(gfp)

    # Extract maps at peaks
    peak_maps = data[:, peaks].T # (n_peaks, n_channels)

    # Normalize maps at peaks (ignore polarity)?
    # Usually for microstates, polarity doesn't matter (map and -map are same state).
    # But standard K-means cares.
    # A common approach is to cluster [Map, -Map] or ensure polarity alignment.
    # Modified K-Means for microstates usually ignores polarity.
    # Since we are using sklearn KMeans, we can't easily change the distance metric to ignore polarity.
    # A simplified approach: Use standard KMeans. This is "Topographic Atomize and Agglomerate Hierarchical Clustering" (TAAHC)
    # or similar often used, but K-Means is also standard (e.g., Pascual-Marqui et al., 1995).
    # To handle polarity in standard KMeans, one might align all maps to have positive correlation with the first component?
    # Or just run KMeans on the raw vectors and accept that State A and -State A might be separate clusters if we are unlucky?
    # Actually, the standard "Modified K-Means" flips the sign of the data vector to match the cluster center.

    # For this implementation, we will stick to standard K-Means for simplicity
    # but we will normalize the peak maps to have unit norm.
    # Note: Standard Microstate analysis uses "Modified K-Means" which ignores polarity
    # (treats map X and -X as same). This implementation uses standard K-Means, which
    # is a simplification. Polarity is handled in the backfitting step (absolute correlation).
    peak_maps_norm = peak_maps / np.linalg.norm(peak_maps, axis=1, keepdims=True)

    # 4. Clustering
    # We use sklearn KMeans
    kmeans = KMeans(n_clusters=n_states, random_state=random_state, n_init=n_init)
    kmeans.fit(peak_maps_norm)

    maps = kmeans.cluster_centers_ # (n_states, n_channels)
    # Normalize result maps
    maps = maps / np.linalg.norm(maps, axis=1, keepdims=True)

    # 5. Backfitting
    # Assign every time point to the closest map (correlation)
    # Correlation is dot product of normalized vectors

    # Normalize data
    data_norm = data / (np.linalg.norm(data, axis=0, keepdims=True) + 1e-16)

    # Compute correlation with all state maps: (n_states, n_channels) @ (n_channels, n_times) -> (n_states, n_times)
    activation = maps @ data_norm

    # Take absolute correlation because polarity doesn't matter
    activation = np.abs(activation)

    # Assign label
    segmentation = np.argmax(activation, axis=0)

    # 6. Global Explained Variance
    # GEV = sum( (GFP * corr)^2 ) / sum( GFP^2 )
    # corr is the correlation of the assigned map with the data

    gfp_sum_sq = np.sum(gfp**2)
    max_corr = np.max(activation, axis=0) # Correlation of best matching map
    gev = np.sum( (gfp * max_corr)**2 ) / gfp_sum_sq

    # Sort states by occurrence or GEV contribution?
    # Let's sort by GEV contribution of each state
    state_gev = []
    for k in range(n_states):
        mask = (segmentation == k)
        gfp_k = gfp[mask]
        corr_k = max_corr[mask]
        gev_k = np.sum((gfp_k * corr_k)**2) / gfp_sum_sq
        state_gev.append(gev_k)

    sort_idx = np.argsort(state_gev)[::-1] # Descending

    maps = maps[sort_idx]

    # Re-map segmentation labels
    remap = {old: new for new, old in enumerate(sort_idx)}
    segmentation = np.array([remap[s] for s in segmentation])

    return maps, segmentation, gev
