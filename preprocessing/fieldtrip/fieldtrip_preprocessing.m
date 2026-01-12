function fieldtrip_preprocessing(inputFile, outputFile, varargin)
% FIELDTRIP_PREPROCESSING - Modular EEG preprocessing pipeline using FieldTrip
%
% Usage:
%   fieldtrip_preprocessing(inputFile, outputFile, ...)
%
% Optional arguments (Name-Value pairs):
%   'LowFreq'       - Lower frequency for bandpass filter (default: 1)
%   'HighFreq'      - Upper frequency for bandpass filter (default: 40)
%   'Layout'        - FieldTrip layout file/string (e.g., 'easycapM11.mat' or '1020')
%   'BadChannels'   - Cell array of bad channel labels (e.g., {'Fp1', 'Cz'})
%   'RunICA'        - Boolean to run ICA after preprocessing (default: false)
%
% Example:
%   fieldtrip_preprocessing('sub01.eeg', 'sub01_preprocessed.mat', ...
%                           'Layout', '1020', 'BadChannels', {'T7'}, ...
%                           'RunICA', false);

    % Parse inputs manually or use inputParser
    p = inputParser;
    addRequired(p, 'inputFile', @ischar);
    addRequired(p, 'outputFile', @ischar);
    addParameter(p, 'LowFreq', 1, @isnumeric);
    addParameter(p, 'HighFreq', 40, @isnumeric);
    addParameter(p, 'Layout', '1020', @ischar);
    addParameter(p, 'BadChannels', {}, @iscell);
    addParameter(p, 'RunICA', false, @islogical);

    parse(p, inputFile, outputFile, varargin{:});
    params = p.Results;

    % Initialize FieldTrip
    ft_defaults;
    layout = []; % Initialize layout variable

    %% 1. Read Data
    fprintf('Reading data from %s...\n', params.inputFile);
    cfg = [];
    cfg.dataset = params.inputFile;
    data = ft_preprocessing(cfg);

    %% 2. Prepare Layout (Template)
    if ~isempty(params.Layout)
        fprintf('Preparing layout: %s\n', params.Layout);
        cfg = [];
        cfg.layout = params.Layout;
        try
            layout = ft_prepare_layout(cfg);
        catch
            warning('Could not prepare layout %s. Skipping layout preparation.', params.Layout);
            layout = [];
        end
    end

    %% 3. Bad Channel Repair (Interpolation)
    if ~isempty(params.BadChannels)
        if isempty(layout)
             warning('Layout is required for interpolation but is missing. Skipping bad channel repair.');
        else
            fprintf('Interpolating bad channels: %s\n', strjoin(params.BadChannels, ', '));
            cfg = [];
            cfg.method = 'spline'; % or 'nearest', 'triangulation'
            cfg.badchannel = params.BadChannels;
            cfg.layout = layout;
            data = ft_channelrepair(cfg, data);
        end
    else
        fprintf('No bad channels specified for repair.\n');
    end

    %% 4. Filter Data
    fprintf('Filtering data %d-%d Hz...\n', params.LowFreq, params.HighFreq);
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [params.LowFreq params.HighFreq];
    data = ft_preprocessing(cfg, data);

    %% 5. Re-reference (Average Reference)
    fprintf('Re-referencing to average...\n');
    cfg = [];
    cfg.reref = 'yes';
    cfg.refchannel = 'all';
    data = ft_preprocessing(cfg, data);

    %% 6. Save Preprocessed Data (Before ICA)
    fprintf('Saving preprocessed data to %s...\n', params.outputFile);
    save(params.outputFile, 'data', '-v7.3');

    %% 7. Run ICA (Optional)
    if params.RunICA
        fprintf('Running ICA...\n');
        cfg = [];
        cfg.method = 'runica'; % or 'fastica'
        % cfg.numcomponent = 20; % Optional: limit components

        comp = ft_componentanalysis(cfg, data);

        [path, name, ext] = fileparts(params.outputFile);
        icaFile = fullfile(path, [name, '_ICA', ext]);

        fprintf('Saving ICA components to %s...\n', icaFile);
        save(icaFile, 'comp', '-v7.3');
        fprintf('ICA complete. Components saved to %s\n', icaFile);
    else
        fprintf('Skipping ICA. Set RunICA to true to run it.\n');
    end

    fprintf('Preprocessing pipeline complete.\n');
end
