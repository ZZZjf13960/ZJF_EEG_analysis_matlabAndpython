function fieldtrip_spectral(inputFile, outputFile, varargin)
% FIELDTRIP_SPECTRAL - Modular EEG spectral analysis (MTMFFT: Welch/Multitaper)
%
% Usage:
%   fieldtrip_spectral(inputFile, outputFile, ...)
%
% Optional arguments (Name-Value pairs):
%   'Method'        - 'welch' (hanning taper) or 'multitaper' (dpss) (default: 'welch')
%   'Fmin'          - Lower frequency (default: 1)
%   'Fmax'          - Upper frequency (default: 50)
%   'Tapsmofrq'     - Smoothing frequency for multitaper (default: 2)
%
% Example:
%   fieldtrip_spectral('sub01.mat', 'sub01_spec.mat', 'Method', 'welch');

    % Parse inputs
    p = inputParser;
    addRequired(p, 'inputFile', @ischar);
    addRequired(p, 'outputFile', @ischar);
    addParameter(p, 'Method', 'welch', @ischar);
    addParameter(p, 'Fmin', 1, @isnumeric);
    addParameter(p, 'Fmax', 50, @isnumeric);
    addParameter(p, 'Tapsmofrq', 2, @isnumeric);

    parse(p, inputFile, outputFile, varargin{:});
    params = p.Results;

    % Initialize FieldTrip
    ft_defaults;

    %% 1. Read Data
    fprintf('Reading data from %s...\n', params.inputFile);
    cfg = [];
    cfg.dataset = params.inputFile;
    data = ft_preprocessing(cfg);

    %% 2. Compute Frequency Analysis
    % We use ft_freqanalysis with method = 'mtmfft'.
    % This computes the FFT on the whole data (or segments if defined).
    % If data is one long continuous segment:
    % - 'hanning' window is effectively a single window FFT.
    % - To do true Welch (averaged windows), we usually need to segment the data first using ft_redefinetrial,
    %   but here we will demonstrate the standard mtmfft.
    %   For true Welch in FieldTrip, 'mtmconvol' or segmenting data into epochs + mtmfft is used.
    %   Here we assume the user might want to average over existing trials or the whole segment.

    cfg = [];
    cfg.output = 'pow';
    cfg.method = 'mtmfft';
    cfg.foilim = [params.Fmin params.Fmax];

    if strcmpi(params.Method, 'welch')
        % Note: On continuous data, this performs a windowed FFT (periodogram) with Hanning taper.
        % For true Welch's method (averaged overlapping windows), data usually needs to be segmented first.
        % FieldTrip's 'mtmfft' with hanning is often used as a standard PSD estimate.
        cfg.taper = 'hanning';
    elseif strcmpi(params.Method, 'multitaper')
        cfg.taper = 'dpss';
        cfg.tapsmofrq = params.Tapsmofrq;
    else
        error('Unknown method: %s', params.Method);
    end

    fprintf('Computing frequency analysis (%s)...\n', params.Method);
    freq = ft_freqanalysis(cfg, data);

    %% 3. Save Results
    fprintf('Saving spectral results to %s...\n', params.outputFile);
    save(params.outputFile, 'freq', '-v7.3');

    fprintf('Spectral analysis complete.\n');
end
