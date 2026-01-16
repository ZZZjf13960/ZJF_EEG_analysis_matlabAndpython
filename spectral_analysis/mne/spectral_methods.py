import mne
import numpy as np

def compute_psd_welch(inst, fmin=0, fmax=np.inf, n_fft=2048, n_overlap=0, n_per_seg=None):
    """
    Compute Power Spectral Density (PSD) using Welch's method.

    Parameters:
    -----------
    inst : mne.io.Raw, mne.Epochs, or mne.Evoked
        The data object to process.
    fmin : float
        Lower frequency of interest.
    fmax : float
        Upper frequency of interest.
    n_fft : int
        The length of the FFT used, must be >= n_per_seg (default: 2048).
    n_overlap : int
        The number of points of overlap between segments.
    n_per_seg : int | None
        Length of each Welch segment (windowed). If None, n_per_seg is equal to n_fft.

    Returns:
    --------
    spectrum : mne.time_frequency.Spectrum
        The spectrum object containing PSD data.
    """

    # Check if we are using newer MNE version which uses .compute_psd()
    if hasattr(inst, 'compute_psd'):
        # MNE 1.0+ style
        spectrum = inst.compute_psd(method='welch', fmin=fmin, fmax=fmax,
                                    n_fft=n_fft, n_overlap=n_overlap, n_per_seg=n_per_seg)
        return spectrum
    else:
        raise NotImplementedError("This function requires a newer version of MNE-Python (>=1.2) that supports .compute_psd()")

def compute_psd_fft(inst, fmin=0, fmax=np.inf):
    """
    Compute Power Spectral Density (PSD) using standard FFT (Periodogram).

    This is effectively a wrapper for compute_psd with method='multitaper' and
    adaptative=False, low_bias=False, normalization='full' which with a single taper
    approximates a periodogram/FFT on the whole interval, OR we can implement
    it manually if strict FFT is required.

    Here we use MNE's compute_psd with method='multitaper' as a proxy for FFT-based
    spectrum analysis on the whole epoch/segment, but we can also use numpy.fft manually.

    For strict FFT on raw data without windowing/tapering (boxcar), we should use
    numpy directly or configure multitaper to behave like it.

    Parameters:
    -----------
    inst : mne.io.Raw, mne.Epochs
        The data object.
    fmin : float
        Lower frequency.
    fmax : float
        Upper frequency.

    Returns:
    --------
    freqs : array
        Frequencies.
    psd : array
        Power spectral density.
    """

    if hasattr(inst, 'compute_psd'):
         # Using multitaper with specific settings can mimic FFT (no smoothing if not requested)
         # However, MNE doesn't have a direct 'fft' method exposed in compute_psd easily without tapering.
         # So we will implement a simple FFT based PSD manually for demonstration of "common fft method".

         sfreq = inst.info['sfreq']
         data = inst.get_data() # (n_channels, n_times) or (n_epochs, n_channels, n_times)

         # Handle raw vs epochs
         if data.ndim == 2:
             # Raw: (n_channels, n_times)
             n_times = data.shape[1]
             # simple fft
             fft_vals = np.fft.rfft(data, axis=1)
             psd = np.abs(fft_vals) ** 2 / (n_times * sfreq)
             freqs = np.fft.rfftfreq(n_times, 1.0/sfreq)
         elif data.ndim == 3:
             # Epochs: (n_epochs, n_channels, n_times)
             n_times = data.shape[2]
             fft_vals = np.fft.rfft(data, axis=2)
             psd = np.abs(fft_vals) ** 2 / (n_times * sfreq)
             freqs = np.fft.rfftfreq(n_times, 1.0/sfreq)

         # Apply one-sided scaling: multiply by 2 for all freqs except DC and Nyquist (if present)
         # rfftfreq returns [0, 1, ..., n/2]
         # psd matches this last dimension

         if n_times % 2 == 0:
             # Last point is Nyquist
             if data.ndim == 2:
                 psd[:, 1:-1] *= 2
             else:
                 psd[:, :, 1:-1] *= 2
         else:
             # No Nyquist point in rfft output (it goes up to (n-1)/2)
             if data.ndim == 2:
                 psd[:, 1:] *= 2
             else:
                 psd[:, :, 1:] *= 2

         # Crop to fmin/fmax
         mask = (freqs >= fmin) & (freqs <= fmax)
         freqs = freqs[mask]

         if data.ndim == 2:
             psd = psd[:, mask]
         else:
             psd = psd[:, :, mask]

         return freqs, psd

    else:
         raise NotImplementedError("This function requires a newer version of MNE-Python.")
