# EEG Spectral Analysis

This directory contains modular EEG spectral analysis pipelines (PSD) for three major frameworks: **MNE-Python**, **EEGLAB** (MATLAB), and **FieldTrip** (MATLAB).

## Directory Structure

- `mne/`: MNE-Python implementation.
- `eeglab/`: EEGLAB implementation.
- `fieldtrip/`: FieldTrip implementation.

## Features

- **Welch's Method**: Standard method for estimating Power Spectral Density (PSD) by averaging overlapping windowed segments.
- **Multitaper**: Advanced method using Slepian sequences (DPSS) for better control over bias and variance, useful for short data segments.
- **FFT**: Standard Fast Fourier Transform (implemented for EEGLAB/MNE comparisons).

## Usage Examples

### 1. MNE-Python

**Prerequisites:** `mne`, `numpy`, `matplotlib`.

**Running the example:**
```bash
python spectral_analysis/mne/example_spectral.py
```

**Methods provided:**
- `compute_psd_welch`: Wrapper for `raw.compute_psd(method='welch')`.
- `compute_psd_multitaper`: Wrapper for `raw.compute_psd(method='multitaper')`.

### 2. EEGLAB (MATLAB)

**Prerequisites:** MATLAB, EEGLAB.

**Running the example:**
```matlab
run('spectral_analysis/eeglab/example_spectral.m')
```

**Methods provided:**
- `eeglab_spectral(..., 'Method', 'welch')`: Uses `pop_spectopo`.
- `eeglab_spectral(..., 'Method', 'fft')`: Computes standard FFT on `EEG.data`.

### 3. FieldTrip (MATLAB)

**Prerequisites:** MATLAB, FieldTrip.

**Running the example:**
```matlab
run('spectral_analysis/fieldtrip/example_spectral.m')
```

**Methods provided:**
- `fieldtrip_spectral(..., 'Method', 'welch')`: Uses `ft_freqanalysis` with `mtmfft` and `hanning` taper.
- `fieldtrip_spectral(..., 'Method', 'multitaper')`: Uses `ft_freqanalysis` with `mtmfft` and `dpss` taper.
