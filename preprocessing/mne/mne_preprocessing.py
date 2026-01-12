import mne
import os
import numpy as np

def load_data(file_path):
    """
    Load EEG data based on file extension.
    """
    print(f"Loading data from {file_path}")
    _, ext = os.path.splitext(file_path)
    if ext == '.fif':
        raw = mne.io.read_raw_fif(file_path, preload=True)
    elif ext == '.set':
        raw = mne.io.read_raw_eeglab(file_path, preload=True)
    elif ext == '.edf':
        raw = mne.io.read_raw_edf(file_path, preload=True)
    elif ext == '.vhdr':
        raw = mne.io.read_raw_brainvision(file_path, preload=True)
    else:
        raise ValueError(f"Unsupported file extension: {ext}")
    return raw

def set_montage(raw, montage_name='standard_1020'):
    """
    Set electrode montage (template).
    """
    print(f"Setting montage: {montage_name}")
    try:
        montage = mne.channels.make_standard_montage(montage_name)
        raw.set_montage(montage, on_missing='ignore')
    except Exception as e:
        print(f"Warning: Could not set montage. {e}")
    return raw

def interpolate_bad_channels(raw, bads=None, mode='accurate'):
    """
    Mark and interpolate bad channels.
    bads: list of bad channel names. If None, uses raw.info['bads'].
    """
    if bads:
        raw.info['bads'].extend(bads)
        # remove duplicates
        raw.info['bads'] = list(set(raw.info['bads']))

    print(f"Bad channels marked: {raw.info['bads']}")

    if raw.info['bads']:
        print("Interpolating bad channels...")
        raw.interpolate_bads(reset_bads=True, mode=mode)
    else:
        print("No bad channels to interpolate.")

    return raw

def preprocess_basic(raw, l_freq=1.0, h_freq=40.0, notch_freq=None):
    """
    Basic preprocessing: Filter and Re-reference.
    """
    # Filter
    print(f"Filtering ({l_freq}-{h_freq} Hz)...")
    raw.filter(l_freq=l_freq, h_freq=h_freq)

    if notch_freq:
        print(f"Notch filtering at {notch_freq} Hz...")
        raw.notch_filter(freqs=notch_freq)

    # Re-reference
    print("Re-referencing to average...")
    raw.set_eeg_reference('average', projection=True)
    raw.apply_proj()

    return raw

def run_ica(raw, n_components=20, method='fastica', random_state=97):
    """
    Run ICA.
    Returns the ICA object. Does NOT apply it to raw yet (needs manual component selection).
    """
    print(f"Running ICA (method={method}, n_components={n_components})...")
    ica = mne.preprocessing.ICA(n_components=n_components, method=method, random_state=random_state, max_iter=800)
    ica.fit(raw)
    return ica

def save_data(raw, output_path):
    if not output_path.endswith('.fif'):
        output_path += '.fif'
    print(f"Saving preprocessed data to {output_path}")
    raw.save(output_path, overwrite=True)

def save_ica(ica, output_path):
    if not output_path.endswith('-ica.fif'):
        output_path += '-ica.fif'
    print(f"Saving ICA solution to {output_path}")
    ica.save(output_path, overwrite=True)

if __name__ == "__main__":
    # Example workflow
    try:
        # 1. Prepare sample data
        sample_data_folder = mne.datasets.sample.data_path()
        raw_fname = os.path.join(sample_data_folder, 'MEG', 'sample', 'sample_audvis_raw.fif')
        output_fname = 'sample_preprocessed_raw.fif'
        ica_fname = 'sample_ica-ica.fif'

        # 2. Load
        raw = load_data(raw_fname)

        # 3. Set Montage
        # Note: sample data already has positions, but we demonstrate the call
        # raw = set_montage(raw, 'standard_1020')

        # 4. Bad Channel Handling
        # Manually specifying bad channels for demonstration (bad channels might be identified visually)
        # In a real pipeline, you might use autoreject or similar tools to find them.
        bad_channels = ['EEG 053']
        raw = interpolate_bad_channels(raw, bads=bad_channels)

        # 5. Basic Preprocessing (Filter + Reref)
        raw_clean = preprocess_basic(raw, l_freq=1.0, h_freq=40.0)

        # Save the basic preprocessed data (before ICA artifact removal)
        save_data(raw_clean, output_fname)

        # 6. Run ICA
        # Note: 'fastica' requires scikit-learn
        ica = run_ica(raw_clean, n_components=15, method='fastica')

        # Save ICA for later manual inspection
        save_ica(ica, ica_fname)

        print("Pipeline completed.")

        # Cleanup for the example
        if os.path.exists(output_fname):
            os.remove(output_fname)
        if os.path.exists(ica_fname):
            os.remove(ica_fname)

    except Exception as e:
        print(f"Error during example run: {e}")
