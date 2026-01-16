function [spectra, freqs] = eeglab_fft(EEG, fmin, fmax)
    % eeglab_fft - Compute spectrum using standard FFT (Periodogram).
    %
    % Usage:
    %   [spectra, freqs] = eeglab_fft(EEG, fmin, fmax)
    %
    % Inputs:
    %   EEG       - EEGLAB structure
    %   fmin      - Lower frequency bound
    %   fmax      - Upper frequency bound
    %
    % Outputs:
    %   spectra   - Power spectrum (Channels x Frequencies)
    %   freqs     - Frequency vector

    data = EEG.data;
    [nchans, npnts, ntrials] = size(data);
    srate = EEG.srate;

    % FFT length equal to number of points
    L = npnts;

    if ntrials > 1
        % Average spectrum across trials
        spectra_sum = 0;
        for t = 1:ntrials
            Y = fft(data(:,:,t), [], 2); % FFT along time dimension

            % Power (squared magnitude)
            % PSD = (1/(srate*L)) * |FFT|^2

            psd_trial = (1/(srate*L)) * abs(Y).^2;
            psd_trial = psd_trial(:, 1:floor(L/2)+1);

            % One-sided scaling
            if mod(L, 2) == 0
                % Even length: DC and Nyquist are unique, others doubled
                psd_trial(:, 2:end-1) = 2 * psd_trial(:, 2:end-1);
            else
                % Odd length: Only DC is unique, others doubled
                psd_trial(:, 2:end) = 2 * psd_trial(:, 2:end);
            end

            spectra_sum = spectra_sum + psd_trial;
        end
        spectra = spectra_sum / ntrials;

    else
        Y = fft(data, [], 2);
        % PSD
        spectra = (1/(srate*L)) * abs(Y).^2;
        spectra = spectra(:, 1:floor(L/2)+1);

        % One-sided scaling
        if mod(L, 2) == 0
            % Even length: DC and Nyquist are unique, others doubled
            spectra(:, 2:end-1) = 2 * spectra(:, 2:end-1);
        else
            % Odd length: Only DC is unique, others doubled
            spectra(:, 2:end) = 2 * spectra(:, 2:end);
        end
    end

    f = srate * (0:(L/2)) / L;

    % Crop frequencies
    mask = f >= fmin & f <= fmax;
    freqs = f(mask);
    spectra = spectra(:, mask);

end
