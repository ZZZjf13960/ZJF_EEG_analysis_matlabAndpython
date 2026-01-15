import mne
import numpy as np
import matplotlib.pyplot as plt

def compute_psd_welch(inst, fmin=0, fmax=np.inf, n_fft=2048, n_overlap=0, n_per_seg=None, average='mean', window='hamming'):
    """
    Compute Power Spectral Density (PSD) using Welch's method.

    Parameters:
    -----------
    inst : mne.io.Raw | mne.Epochs
        The data instance (Raw or Epochs).
    fmin : float
        Lower frequency of interest.
    fmax : float
        Upper frequency of interest.
    n_fft : int
        The length of the FFT used, must be >= n_per_seg (default: 2048).
    n_overlap : int
        The number of points of overlap between segments.
    n_per_seg : int | None
        Length of each Welch segment (windowed). If None, n_per_seg = n_fft.
    average : str
        How to average the segments ('mean' or 'median').
    window : str
        The window type to use (e.g., 'hamming', 'hann').

    Returns:
    --------
    spectrum : mne.time_frequency.Spectrum
        The spectrum object containing PSD data.
    """
    print(f"Computing PSD (Welch) [{fmin}-{fmax} Hz]...")

    spectrum = inst.compute_psd(
        method='welch',
        fmin=fmin,
        fmax=fmax,
        n_fft=n_fft,
        n_overlap=n_overlap,
        n_per_seg=n_per_seg,
        average=average,
        window=window,
        verbose=False
    )
    return spectrum

def compute_psd_multitaper(inst, fmin=0, fmax=np.inf, bandwidth=None, adaptive=False, normalization='length'):
    """
    Compute Power Spectral Density (PSD) using Multitaper method.

    Parameters:
    -----------
    inst : mne.io.Raw | mne.Epochs
        The data instance.
    fmin : float
        Lower frequency.
    fmax : float
        Upper frequency.
    bandwidth : float | None
        The bandwidth of the multitaper windowing function in Hz.
    adaptive : bool
        Use adaptive weights to combine the tapered spectra.
    normalization : str
        Normalization method ('length' or 'full').

    Returns:
    --------
    spectrum : mne.time_frequency.Spectrum
        The spectrum object.
    """
    print(f"Computing PSD (Multitaper) [{fmin}-{fmax} Hz]...")

    spectrum = inst.compute_psd(
        method='multitaper',
        fmin=fmin,
        fmax=fmax,
        bandwidth=bandwidth,
        adaptive=adaptive,
        normalization=normalization,
        verbose=False
    )
    return spectrum

def plot_psd(spectrum, picks=None, average=False, db=True, show=True):
    """
    Plot the computed Power Spectral Density.

    Parameters:
    -----------
    spectrum : mne.time_frequency.Spectrum
        The spectrum object to plot.
    picks : list | str | None
        Channels to include.
    average : bool
        If True, plot the average across channels.
    db : bool
        If True, plot in dB.
    show : bool
        Show the plot immediately.
    """
    print("Plotting PSD...")
    fig = spectrum.plot(
        picks=picks,
        average=average,
        dB=db,
        show=show
    )
    return fig

def get_psd_data(spectrum):
    """
    Extract PSD data arrays from the Spectrum object.

    Returns:
    --------
    data : array
        The PSD data (channels x frequencies).
    freqs : array
        The frequency bins.
    """
    data = spectrum.get_data()
    freqs = spectrum.freqs
    return data, freqs
