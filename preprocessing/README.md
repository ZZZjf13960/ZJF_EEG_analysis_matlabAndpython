# EEG Preprocessing Pipelines

This directory contains modular EEG preprocessing pipelines for three major frameworks: **MNE-Python**, **EEGLAB** (MATLAB), and **FieldTrip** (MATLAB).

## Directory Structure

- `mne/`: MNE-Python implementation.
- `eeglab/`: EEGLAB implementation.
- `fieldtrip/`: FieldTrip implementation.

Each subdirectory contains:
- A library file (e.g., `mne_preprocessing.py`, `eeglab_preprocessing.m`) containing the parameterized functions.
- An example usage script (`example_usage.py` or `example_usage.m`) demonstrating how to call the functions.

## Usage Examples

### 1. MNE-Python

**Prerequisites:** `mne`, `scikit-learn` (for FastICA), `numpy`.

**Running the example:**
The example script downloads the MNE sample dataset and runs the full pipeline (Filter, Interpolate, ICA).

```bash
python preprocessing/mne/example_usage.py
```

**Custom usage:**
```python
from preprocessing.mne.mne_preprocessing import load_data, preprocess_basic, run_ica

raw = load_data('my_data.fif')
raw_clean = preprocess_basic(raw, l_freq=1, h_freq=40)
ica = run_ica(raw_clean)
```

### 2. EEGLAB (MATLAB)

**Prerequisites:** MATLAB, EEGLAB (installed and in path).

**Running the example:**
Open MATLAB and run:
```matlab
run('preprocessing/eeglab/example_usage.m')
```

**Custom usage:**
```matlab
eeglab_preprocessing('sub01.set', '/data/path/', 'sub01_clean.set', '/output/path/', ...
    'LowFreq', 1, 'HighFreq', 40, 'RunICA', true);
```

### 3. FieldTrip (MATLAB)

**Prerequisites:** MATLAB, FieldTrip (installed and in path).

**Running the example:**
Open MATLAB and run:
```matlab
run('preprocessing/fieldtrip/example_usage.m')
```
*Note: You may need to edit the example script to point to a valid dataset path (e.g., FieldTrip tutorial data).*

**Custom usage:**
```matlab
fieldtrip_preprocessing('sub01.ds', 'sub01_clean.mat', ...
    'Layout', 'CTF151.lay', 'RunICA', true);
```
