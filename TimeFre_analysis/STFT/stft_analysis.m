function [tf, frex, times] = stft_analysis(data, srate, frequency, window_size, overlap)
%STFT_ANALYSIS Short-Time Fourier Transform for time-frequency analysis
%   [tf, frex, times] = stft_analysis(data, srate, frequency, window_size, overlap)
%
%   Inputs:
%       data:        Signal data (time x trials) or (samples x 1)
%       srate:       Sampling rate (Hz)
%       frequency:   Frequency range [min_freq, max_freq]
%       window_size: Window size in seconds (e.g., 0.5)
%       overlap:     Overlap percentage (0 to 1, e.g., 0.5 for 50%)
%
%   Outputs:
%       tf:          Time-frequency power (frequencies x time_points x trials)
%       frex:        Frequency vector
%       times:       Time vector corresponding to window centers
%

    if nargin < 5
        overlap = 0.5;
    end

    % Parameters for spectrogram
    window_samples = round(window_size * srate);
    overlap_samples = round(window_samples * overlap);
    nfft = window_samples; % Use window size for nfft usually, or nextpow2

    % Initialize output
    % We process trial by trial
    n_trials = size(data, 2);
    n_samples = size(data, 1);

    % Check if input is likely (trials x samples) or (samples x trials)
    % The previous script assumed samples x trials for the reshaping logic.
    % We stick to samples x trials as per zjf_MorletWavelet logic usage in example.

    % Run on first trial to get dimensions
    [~, f_vec, t_vec] = spectrogram(data(:,1), window_samples, overlap_samples, nfft, srate);

    % Filter frequencies to desired range
    freq_idx = f_vec >= frequency(1) & f_vec <= frequency(2);
    frex = f_vec(freq_idx);

    % Initialize matrix
    tf = zeros(length(frex), length(t_vec), n_trials);

    for i = 1:n_trials
        [s, ~, ~] = spectrogram(data(:,i), window_samples, overlap_samples, nfft, srate);
        % Power
        p = abs(s).^2;
        % Store
        tf(:,:,i) = p(freq_idx, :);
    end

    times = t_vec;
end
