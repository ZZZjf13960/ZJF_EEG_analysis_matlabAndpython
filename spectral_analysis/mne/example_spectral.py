import os
import sys
import mne
import matplotlib.pyplot as plt

# Add current directory to path to allow importing mne_spectral if running from same dir
# Or add specific path if running from root
sys.path.append(os.path.dirname(__file__))

from mne_spectral import compute_psd_welch, compute_psd_multitaper, plot_psd, get_psd_data

def main():
    try:
        # 1. Load Sample Data
        print("Loading sample data...")
        sample_data_folder = mne.datasets.sample.data_path()
        raw_fname = os.path.join(sample_data_folder, 'MEG', 'sample', 'sample_audvis_raw.fif')
        raw = mne.io.read_raw_fif(raw_fname, preload=True, verbose=False)

        # Pick EEG channels only for clarity
        raw.pick(['eeg', 'eog']).load_data()

        # 2. Compute PSD using Welch's Method
        # fmin=1, fmax=50, 4s window (assuming sfreq ~600Hz, n_fft=2048 is ~3.4s, lets use 2048)
        spec_welch = compute_psd_welch(raw, fmin=1, fmax=50, n_fft=2048)

        # 3. Compute PSD using Multitaper Method
        spec_mt = compute_psd_multitaper(raw, fmin=1, fmax=50)

        # 4. Plot Results
        # Welch
        print("\nPlotting Welch PSD...")
        plot_psd(spec_welch, average=True, db=True, show=False)
        plt.title('PSD (Welch)')

        # Multitaper
        print("Plotting Multitaper PSD...")
        plot_psd(spec_mt, average=True, db=True, show=False)
        plt.title('PSD (Multitaper)')

        # 5. Access Data
        data, freqs = get_psd_data(spec_welch)
        print(f"\nExtracted PSD Data Shape (Channels x Freqs): {data.shape}")
        print(f"Frequency Resolution: {freqs[1] - freqs[0]:.2f} Hz")

        # Save plots
        output_dir = 'sample_output_mne_spectral'
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        print(f"\nSaving results to {output_dir}")
        spec_welch.save(os.path.join(output_dir, 'sample_welch-psd.h5'), overwrite=True)

        print("Done.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
