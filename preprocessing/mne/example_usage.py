import os
import sys
import mne

# Add current directory to path
sys.path.append(os.path.dirname(__file__))

from mne_preprocessing import load_data, set_montage, interpolate_bad_channels, preprocess_basic, run_ica, save_data, save_ica

def main():
    """
    Example usage of the MNE preprocessing pipeline using the MNE sample dataset.
    """
    try:
        # 1. Get Sample Data
        print("Fetching sample data...")
        sample_data_folder = mne.datasets.sample.data_path()
        raw_fname = os.path.join(sample_data_folder, 'MEG', 'sample', 'sample_audvis_raw.fif')

        # Define output paths
        output_dir = os.path.join(os.getcwd(), 'sample_output_mne')
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        output_fname = os.path.join(output_dir, 'sample_preprocessed_raw.fif')
        ica_fname = os.path.join(output_dir, 'sample_ica.fif')

        # 2. Load Data
        raw = load_data(raw_fname)

        # 3. Set Montage (Optional for this dataset as it has positions, but good practice)
        # raw = set_montage(raw, 'standard_1020')

        # 4. Interpolate Bad Channels
        # Simulating a bad channel for demonstration
        bad_channels = ['EEG 053']
        raw = interpolate_bad_channels(raw, bads=bad_channels)

        # 5. Basic Preprocessing (Filter 1-40Hz, Average Reference)
        raw_clean = preprocess_basic(raw, l_freq=1.0, h_freq=40.0)

        # Save the cleaned continuous data
        save_data(raw_clean, output_fname)

        # 6. Run ICA
        # Using FastICA as requested.
        # Note: We compute ICA but do not apply it (exclude components) automatically.
        ica = run_ica(raw_clean, n_components=15, method='fastica')

        # Save ICA solution for manual inspection/application later
        save_ica(ica, ica_fname)

        print("\nPipeline completed successfully!")
        print(f"Preprocessed data: {output_fname}")
        print(f"ICA solution: {ica_fname}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
