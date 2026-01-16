function [freq] = ft_spectral_analysis(data, method, fmin, fmax)
    % ft_spectral_analysis - Compute power spectrum using FieldTrip.
    %
    % Usage:
    %   [freq] = ft_spectral_analysis(data, method, fmin, fmax)
    %
    % Inputs:
    %   data    - FieldTrip data structure
    %   method  - 'welch' (mimicked via hanning taper) or 'fft' (boxcar taper)
    %   fmin    - Lower frequency
    %   fmax    - Upper frequency
    %
    % Outputs:
    %   freq    - FieldTrip frequency structure containing .powspctrm and .freq

    cfg = [];
    cfg.output = 'pow';
    cfg.method = 'mtmfft';
    cfg.keeplearning = 'no'; % often not needed

    if strcmp(method, 'fft')
        cfg.taper = 'boxcar'; % Rectangular window -> standard FFT/Periodogram
    elseif strcmp(method, 'welch')
        cfg.taper = 'hanning';
        % Note: strict Welch method involves averaging overlapping segments.
        % 'mtmfft' with a single taper on the whole trial calculates a windowed
        % periodogram, not Welch's method (unless the data is already segmented
        % into Welch-sized windows and averaged later).
        %
        % If the input `data` is continuous (one long trial), this setting
        % results in a single windowed estimate.
        % If the input `data` is epoched (many short trials), `mtmfft` computes
        % the spectrum per trial, which can then be averaged to achieve a
        % Welch-like estimate.
        %
        % For proper Welch on continuous data without prior segmentation,
        % consider using cfg.method = 'mtmconvol' with averaging, or segmenting
        % the data first. Here we assume the user provides appropriate data structure
        % (e.g., segmented data) or accepts the windowed periodogram behavior.
    else
        error('Unknown method. Use ''fft'' or ''welch''.');
    end

    % Frequency range
    % mtmfft usually uses foilim or foi
    cfg.foilim = [fmin fmax];

    freq = ft_freqanalysis(cfg, data);

end
