function [spectra, freqs] = eeglab_welch(EEG, fmin, fmax, n_fft, n_overlap, window)
    % eeglab_welch - Compute PSD using Welch's method via EEGLAB's pop_spectopo or MATLAB's pwelch.
    %
    % Usage:
    %   [spectra, freqs] = eeglab_welch(EEG, fmin, fmax, n_fft, n_overlap, window)
    %
    % Inputs:
    %   EEG       - EEGLAB structure containing data (EEG.data, EEG.srate)
    %   fmin      - Lower frequency bound (Hz)
    %   fmax      - Upper frequency bound (Hz)
    %   n_fft     - Length of FFT (and window if not specified)
    %   n_overlap - Number of samples of overlap
    %   window    - Window function or length (default: hamming(n_fft))
    %
    % Outputs:
    %   spectra   - Power spectral density (Channels x Frequencies)
    %   freqs     - Frequency vector

    if nargin < 4
        n_fft = 256; % Default
    end
    if nargin < 5
        n_overlap = n_fft / 2;
    end
    if nargin < 6
        window = hamming(n_fft);
    end

    % Check if EEG.data is continuous or epoched.
    % If epoched (3D), reshape to 2D for pwelch or process average.
    % Here we assume we want average PSD over all data.

    data = EEG.data;
    [nchans, npnts, ntrials] = size(data);

    if ntrials > 1
        % Reshape for continuous-like processing or loop?
        % pwelch can handle matrix columns as channels.
        % For 3D data, we might want to average across trials.
        % Let's flatten to 2D: (Channels, TimePoints * Trials) if we treat as continuous
        % OR average the PSDs of each trial.

        % Standard Welch in EEGLAB pop_spectopo does per-epoch and averages.
        % We will use pwelch for simplicity and explicit control.

        spectra_sum = 0;

        for t = 1:ntrials
            [Pxx, F] = pwelch(data(:,:,t)', window, n_overlap, n_fft, EEG.srate);
            % Pxx is (Frequencies x Channels)
            spectra_sum = spectra_sum + Pxx;
        end
        spectra = (spectra_sum / ntrials)'; % Transpose to (Channels x Frequencies)
        freqs = F;

    else
        % Continuous data
        % pwelch inputs: (x, window, noverlap, nfft, fs)
        % x should be (Samples x Channels)
        [Pxx, F] = pwelch(data', window, n_overlap, n_fft, EEG.srate);
        spectra = Pxx'; % (Channels x Frequencies)
        freqs = F;
    end

    % Crop frequencies
    mask = freqs >= fmin & freqs <= fmax;
    freqs = freqs(mask);
    spectra = spectra(:, mask);

end
