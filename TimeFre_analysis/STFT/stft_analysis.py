import numpy as np
from scipy import signal

def stft_analysis(data, srate, freqs=None, window_size=0.5, overlap=0.5):
    """
    Perform Short-Time Fourier Transform.

    Parameters:
    -----------
    data : array-like, (n_samples, n_trials)
    srate : float
    freqs : list or tuple (min_freq, max_freq), optional
        If provided, limits the output to this range.
    window_size : float (seconds)
    overlap : float (0-1)

    Returns:
    --------
    tf_data : array, (n_freqs, n_times, n_trials)
    freq_axis : array
    time_axis : array
    """
    n_samples, n_trials = data.shape
    nperseg = int(window_size * srate)
    noverlap = int(nperseg * overlap)

    tf_list = []

    # Process first trial to determine dimensions
    f, t, Zxx = signal.stft(data[:, 0], fs=srate, nperseg=nperseg, noverlap=noverlap)

    if freqs is not None:
        freq_mask = (f >= freqs[0]) & (f <= freqs[1])
        f = f[freq_mask]
    else:
        freq_mask = np.ones(len(f), dtype=bool)

    n_freqs = len(f)
    n_times = len(t)

    tf_data = np.zeros((n_freqs, n_times, n_trials))

    for i in range(n_trials):
        f_trial, t_trial, Zxx_trial = signal.stft(data[:, i], fs=srate, nperseg=nperseg, noverlap=noverlap)
        # Power
        p = np.abs(Zxx_trial)**2
        tf_data[:, :, i] = p[freq_mask, :]

    return tf_data, f, t
