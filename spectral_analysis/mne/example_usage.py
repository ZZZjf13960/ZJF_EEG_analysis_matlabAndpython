
import numpy as np
import mne
from spectral_methods import compute_psd_welch, compute_psd_fft

def create_dummy_data():
    """Create dummy MNE Raw data."""
    sfreq = 1000
    times = np.arange(0, 10, 1/sfreq)
    # Sine wave at 50 Hz and 10 Hz
    data = np.sin(2 * np.pi * 50 * times) + 0.5 * np.sin(2 * np.pi * 10 * times)
    data = data[np.newaxis, :] # (1, n_times)
    info = mne.create_info(ch_names=['Cz'], sfreq=sfreq, ch_types=['eeg'])
    raw = mne.io.RawArray(data, info)
    return raw

def main():
    print("Creating dummy data...")
    raw = create_dummy_data()

    print("\nRunning Welch PSD...")
    try:
        spectrum_welch = compute_psd_welch(raw, fmin=1, fmax=100, n_fft=1024)
        print("Welch PSD computed successfully.")
        # Accessing data depends on MNE version, but let's just print the object
        print(spectrum_welch)

        # Verify peak at 50Hz and 10Hz?
        psd, freqs = spectrum_welch.get_data(return_freqs=True)
        # psd shape (n_channels, n_freqs)

        idx_50 = np.argmin(np.abs(freqs - 50))
        idx_10 = np.argmin(np.abs(freqs - 10))
        idx_30 = np.argmin(np.abs(freqs - 30)) # noise

        print(f"Power at 10Hz: {psd[0, idx_10]:.2e}")
        print(f"Power at 50Hz: {psd[0, idx_50]:.2e}")
        print(f"Power at 30Hz (noise): {psd[0, idx_30]:.2e}")

    except Exception as e:
        print(f"Welch failed: {e}")

    print("\nRunning FFT PSD...")
    try:
        freqs_fft, psd_fft = compute_psd_fft(raw, fmin=1, fmax=100)
        print("FFT PSD computed successfully.")
        print(f"Freqs shape: {freqs_fft.shape}, PSD shape: {psd_fft.shape}")

        idx_50 = np.argmin(np.abs(freqs_fft - 50))
        idx_10 = np.argmin(np.abs(freqs_fft - 10))
        idx_30 = np.argmin(np.abs(freqs_fft - 30))

        print(f"Power at 10Hz: {psd_fft[0, idx_10]:.2e}")
        print(f"Power at 50Hz: {psd_fft[0, idx_50]:.2e}")
        print(f"Power at 30Hz (noise): {psd_fft[0, idx_30]:.2e}")

    except Exception as e:
        print(f"FFT failed: {e}")

if __name__ == "__main__":
    main()
