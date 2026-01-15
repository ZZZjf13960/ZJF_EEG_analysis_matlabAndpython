function eeglab_spectral(fileName, filePath, outputName, outputPath, varargin)
% EEGLAB_SPECTRAL - Modular EEG spectral analysis (Welch, FFT)
%
% Usage:
%   eeglab_spectral(fileName, filePath, outputName, outputPath, ...)
%
% Optional arguments (Name-Value pairs):
%   'Method'        - 'welch' (default) or 'fft' (standard fft)
%   'Fmin'          - Lower frequency (default: 1)
%   'Fmax'          - Upper frequency (default: 50)
%   'Window'        - Window length in samples (for Welch) (default: [])
%   'Overlap'       - Overlap in samples (for Welch) (default: [])
%
% Example:
%   eeglab_spectral('sub01.set', '/data/', 'sub01_spec.mat', '/out/', 'Method', 'welch');

    % Parse inputs
    p = inputParser;
    addRequired(p, 'fileName', @ischar);
    addRequired(p, 'filePath', @ischar);
    addRequired(p, 'outputName', @ischar);
    addRequired(p, 'outputPath', @ischar);
    addParameter(p, 'Method', 'welch', @ischar);
    addParameter(p, 'Fmin', 1, @isnumeric);
    addParameter(p, 'Fmax', 50, @isnumeric);
    addParameter(p, 'Window', [], @isnumeric);
    addParameter(p, 'Overlap', [], @isnumeric);

    parse(p, fileName, filePath, outputName, outputPath, varargin{:});
    params = p.Results;

    % Start EEGLAB if needed
    if ~exist('eeglab', 'file')
        error('EEGLAB is not in the MATLAB path.');
    end
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

    %% 1. Load Data
    fprintf('Loading %s...\n', fullfile(params.filePath, params.fileName));
    if contains(params.fileName, '.set')
        EEG = pop_loadset('filename', params.fileName, 'filepath', params.filePath);
    else
        error('Currently only .set files are supported in this demo wrapper.');
    end

    %% 2. Compute Spectrum
    fprintf('Computing spectrum using %s method...\n', params.Method);

    if strcmpi(params.Method, 'welch')
        % Use pop_spectopo (Welch's method)
        % Note: pop_spectopo plots by default. To just get data:
        % [spectra, freqs] = spectopo(EEG.data, frames, srate, ...)

        % We use spectopo directly on data for flexibility
        % Default window is usually 2*srate or similar if empty
        if isempty(params.Window)
            winlen = 0; % 0 lets spectopo choose default
        else
            winlen = params.Window;
        end

        if isempty(params.Overlap)
            overlap = 0;
        else
            overlap = params.Overlap;
        end

        % spectopo(data, frames, srate, 'freqfac', ..., 'plot', 'off')
        [spectra, freqs] = spectopo(EEG.data, size(EEG.data, 2), EEG.srate, ...
            'winsize', winlen, 'overlap', overlap, 'plot', 'off');

        % spectopo returns spectra in dB by default (10*log10(muV^2/Hz))

    elseif strcmpi(params.Method, 'fft')
        % Standard FFT
        L = size(EEG.data, 2);
        NFFT = 2^nextpow2(L);
        Y = fft(EEG.data, NFFT, 2) / L;
        f = EEG.srate/2 * linspace(0, 1, NFFT/2+1);

        % Compute power single-sided
        powerSpec = 2 * abs(Y(:, 1:NFFT/2+1)).^2;

        % Convert to dB for consistency with spectopo result (optional)
        spectra = 10*log10(powerSpec);
        freqs = f;

    else
        error('Unknown method: %s', params.Method);
    end

    %% 3. Extract ROI (Frequency Range)
    idx = freqs >= params.Fmin & freqs <= params.Fmax;
    freqs_roi = freqs(idx);
    spectra_roi = spectra(:, idx);

    %% 4. Save Results
    outputFile = fullfile(params.outputPath, params.outputName);
    fprintf('Saving spectral results to %s...\n', outputFile);

    save(outputFile, 'spectra_roi', 'freqs_roi', 'params');

    fprintf('Spectral analysis complete.\n');
end
