import numpy as np
from scipy import signal
import mne

def wavelet_analysis(data, srate, freqs, n_cycles=7.0, use_fft=True, power=True):
    """
    Perform Morlet Wavelet time-frequency analysis.

    Parameters:
    -----------
    data : array-like, shape (n_epochs, n_channels, n_times) or (n_epochs, n_times)
        Input data. If 2D (n_epochs, n_times), it is treated as 1 channel.
    srate : float
        Sampling rate.
    freqs : array-like
        Array of frequencies of interest.
    n_cycles : float or array-like
        Number of cycles in the wavelet. Fixed number or one per frequency.
    use_fft : bool
        Whether to use FFT for convolution (default True).
    power : bool
        Whether to return power (True) or complex values (False).

    Returns:
    --------
    out : array
        Time-frequency representation. Shape depends on input:
        (n_epochs, n_channels, n_freqs, n_times)
    """

    # Ensure data is 3D: (n_epochs, n_channels, n_times)
    data = np.array(data)
    if data.ndim == 2:
        # Assume (n_epochs, n_times), add channel dim
        data = data[:, np.newaxis, :]

    # MNE's tfr_array_morlet expects (n_epochs, n_channels, n_times)
    # output: (n_epochs, n_channels, n_freqs, n_times)

    out = mne.time_frequency.tfr_array_morlet(
        data,
        sfreq=srate,
        freqs=freqs,
        n_cycles=n_cycles,
        output='power' if power else 'complex',
        use_fft=use_fft
    )

    return out

def simple_morlet_wrapper(data, freqs, srate, fwhm_time=0.5):
    """
    A wrapper closer to the MATLAB implementation provided.

    Parameters:
    -----------
    data : array, (n_samples, n_trials) - similar to MATLAB input
    freqs : array, frequencies
    srate : float
    fwhm_time : float, Full Width Half Max in seconds (approximates n_cycles)

    Returns:
    --------
    tf_data : array, (n_freqs, n_samples, n_trials)
    """
    # MATLAB input was (samples, trials) reshaped to 1D then back.
    # We'll treat it as (n_trials, 1_channel, n_samples) for MNE

    n_samples, n_trials = data.shape
    data_reshaped = data.T[:, np.newaxis, :] # (trials, 1, samples)

    # Convert FWHM to n_cycles
    # FWHM = n_cycles / (pi * f) * sqrt(2 * log(2)) ??
    # Actually, standard relation for Morlet: sigma_t = n_cycles / (2 * pi * f)
    # FWHM = 2.355 * sigma_t
    # So n_cycles ~= FWHM * pi * f / 1.177 roughly.
    # Or just use a fixed reasonable n_cycles for now, or calculate if critical.
    # The MATLAB script uses FWHM directly to generate the Gaussian window.
    # MNE uses n_cycles. We will use a standard approximation or just expose n_cycles.

    # Let's calculate n_cycles from FWHM for each frequency to match MATLAB behavior
    # MATLAB: exp( -4 * log(2) * t^2 / fwhm^2 ) -> Gaussian
    # MNE: exp( -t^2 / (2 * sigma^2) )
    # So 4*log(2)/fwhm^2 = 1/(2*sigma^2)
    # sigma = fwhm / (2 * sqrt(2*log(2)))
    # n_cycles = 6 * sigma * f (usually defined as such in MNE for sigma being standard dev)
    # actually MNE: n_cycles = sigma * 2 * pi * f

    sigma = fwhm_time / (2 * np.sqrt(2 * np.log(2)))
    n_cycles = sigma * 2 * np.pi * freqs

    power = mne.time_frequency.tfr_array_morlet(
        data_reshaped, srate, freqs, n_cycles=n_cycles, output='power'
    )

    # MNE output: (n_epochs, n_channels, n_freqs, n_times)
    # We want: (n_freqs, n_times, n_trials) to match MATLAB roughly
    # (MATLAB out: freq, time, trial)

    # power shape: (n_trials, 1, n_freqs, n_samples)
    power = power.squeeze(1) # (n_trials, n_freqs, n_samples)
    power = np.transpose(power, (1, 2, 0)) # (n_freqs, n_samples, n_trials)

    return power
