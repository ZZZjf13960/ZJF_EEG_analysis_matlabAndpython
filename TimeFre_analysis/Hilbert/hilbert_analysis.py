import numpy as np
from scipy.signal import butter, filtfilt, hilbert

def hilbert_analysis(data, srate, frequency_bands):
    """
    Perform Hilbert Transform for power and phase extraction.

    Parameters:
    -----------
    data : array-like, (n_samples, n_trials)
    srate : float
    frequency_bands : list of tuples/lists, e.g. [[4, 8], [8, 12]]

    Returns:
    --------
    tf_power : array, (n_bands, n_samples, n_trials)
    tf_phase : array, (n_bands, n_samples, n_trials)
    """
    n_samples, n_trials = data.shape
    n_bands = len(frequency_bands)

    tf_power = np.zeros((n_bands, n_samples, n_trials))
    tf_phase = np.zeros((n_bands, n_samples, n_trials))

    nyquist = srate / 2.0

    for b_idx, band in enumerate(frequency_bands):
        low, high = band
        # Design filter
        b, a = butter(4, [low / nyquist, high / nyquist], btype='bandpass')

        for i in range(n_trials):
            # Filter
            filtered = filtfilt(b, a, data[:, i])

            # Hilbert
            analytic = hilbert(filtered)

            # Extract features
            tf_power[b_idx, :, i] = np.abs(analytic)**2
            tf_phase[b_idx, :, i] = np.angle(analytic)

    return tf_power, tf_phase
