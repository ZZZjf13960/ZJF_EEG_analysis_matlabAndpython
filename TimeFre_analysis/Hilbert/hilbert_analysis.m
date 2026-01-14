function [tf, phase] = hilbert_analysis(data, srate, frequency_bands)
%HILBERT_ANALYSIS Hilbert transform for instantaneous power and phase
%   [tf, phase] = hilbert_analysis(data, srate, frequency_bands)
%
%   Inputs:
%       data:            Signal data (samples x trials)
%       srate:           Sampling rate (Hz)
%       frequency_bands: Cell array of frequency bands, e.g., {[4 8], [8 12]}
%                        or matrix [min1 max1; min2 max2]
%
%   Outputs:
%       tf:              Power envelope (bands x samples x trials)
%       phase:           Instantaneous phase (bands x samples x trials)

    n_samples = size(data, 1);
    n_trials = size(data, 2);

    if iscell(frequency_bands)
        n_bands = length(frequency_bands);
        bands = zeros(n_bands, 2);
        for i=1:n_bands
            bands(i,:) = frequency_bands{i};
        end
    else
        n_bands = size(frequency_bands, 1);
        bands = frequency_bands;
    end

    tf = zeros(n_bands, n_samples, n_trials);
    phase = zeros(n_bands, n_samples, n_trials);

    for b = 1:n_bands
        f_low = bands(b, 1);
        f_high = bands(b, 2);

        % Design filter (simple Butterworth bandpass)
        nyquist = srate / 2;
        [b_filt, a_filt] = butter(4, [f_low, f_high] / nyquist, 'bandpass');

        for trial = 1:n_trials
            % Filter data
            filt_data = filtfilt(b_filt, a_filt, data(:, trial));

            % Hilbert transform
            analytic_signal = hilbert(filt_data);

            % Power (envelope squared)
            tf(b, :, trial) = abs(analytic_signal).^2;

            % Phase
            phase(b, :, trial) = angle(analytic_signal);
        end
    end

end
