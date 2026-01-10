import mne
import os
import numpy as np

def preprocess_eeg(raw_path, output_path):
    """
    Preprocess EEG data using MNE-Python.
    Steps:
    1. Load data
    2. Filter (1-40 Hz)
    3. Re-reference (Average)
    4. ICA (FastICA) - Optional/Placeholder
    5. Save
    """

    print(f"Loading data from {raw_path}")
    # Load data based on extension
    _, ext = os.path.splitext(raw_path)
    if ext == '.fif':
        raw = mne.io.read_raw_fif(raw_path, preload=True)
    elif ext == '.set':
        raw = mne.io.read_raw_eeglab(raw_path, preload=True)
    elif ext == '.edf':
        raw = mne.io.read_raw_edf(raw_path, preload=True)
    elif ext == '.vhdr':
        raw = mne.io.read_raw_brainvision(raw_path, preload=True)
    else:
        raise ValueError(f"Unsupported file extension: {ext}")

    # 1. Filter
    print("Filtering data (1-40 Hz)...")
    raw.filter(l_freq=1.0, h_freq=40.0)

    # 2. Re-reference
    print("Re-referencing to average...")
    raw.set_eeg_reference('average', projection=True)
    raw.apply_proj()

    # 3. ICA (simplified for preprocessing)
    # Note: Real-world ICA requires manual component selection or automated methods like ICLabel.
    # Here we just fit ICA to demonstrate the step.
    print("Fitting ICA...")
    ica = mne.preprocessing.ICA(n_components=20, random_state=97, max_iter=800)
    ica.fit(raw)

    # In a real scenario, you would exclude components here:
    # ica.exclude = [0, 1] # e.g., excluding first two components
    # raw_clean = ica.apply(raw)

    # For now, we return the filtered/referenced data, assuming ICA components would be rejected manually.
    # Or we can apply the ICA with no exclusions (which does nothing) just to show the workflow.

    # 4. Save
    if not output_path.endswith('.fif'):
        output_path += '.fif'

    print(f"Saving preprocessed data to {output_path}")
    raw.save(output_path, overwrite=True)

if __name__ == "__main__":
    # Example usage
    # This block allows the script to be tested with sample data if available

    try:
        sample_data_folder = mne.datasets.sample.data_path()
        sample_data_raw_file = os.path.join(sample_data_folder, 'MEG', 'sample',
                                            'sample_audvis_raw.fif')

        output_file = 'sample_preprocessed_raw.fif'
        preprocess_eeg(sample_data_raw_file, output_file)
        print("Preprocessing completed successfully on sample data.")

        # Cleanup
        if os.path.exists(output_file):
            os.remove(output_file)

    except Exception as e:
        print(f"Could not run sample data test: {e}")
        print("Script requires valid EEG data path to run.")
