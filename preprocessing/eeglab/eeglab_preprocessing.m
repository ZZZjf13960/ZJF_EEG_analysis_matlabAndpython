function eeglab_preprocessing(fileName, filePath, outputName, outputPath, varargin)
% EEGLAB_PREPROCESSING - Modular EEG preprocessing pipeline
%
% Usage:
%   eeglab_preprocessing(fileName, filePath, outputName, outputPath, ...)
%
% Optional arguments (Name-Value pairs):
%   'LowFreq'       - Lower frequency for bandpass filter (default: 1)
%   'HighFreq'      - Upper frequency for bandpass filter (default: 40)
%   'BadChannels'   - Vector of bad channel indices to interpolate (default: [])
%   'ChannelLocs'   - Path to channel location file (e.g., 'standard-10-20-cap81.elp')
%   'RunICA'        - Boolean to run ICA after preprocessing (default: false)
%
% Example:
%   eeglab_preprocessing('sub01.set', '/data/', 'sub01_clean.set', '/out/', ...
%                        'BadChannels', [10 12], 'ChannelLocs', 'standard_1020.elc', ...
%                        'RunICA', false);

    % Parse inputs
    p = inputParser;
    addRequired(p, 'fileName', @ischar);
    addRequired(p, 'filePath', @ischar);
    addRequired(p, 'outputName', @ischar);
    addRequired(p, 'outputPath', @ischar);
    addParameter(p, 'LowFreq', 1, @isnumeric);
    addParameter(p, 'HighFreq', 40, @isnumeric);
    addParameter(p, 'BadChannels', [], @isnumeric);
    addParameter(p, 'ChannelLocs', '', @ischar);
    addParameter(p, 'RunICA', false, @islogical);

    parse(p, fileName, filePath, outputName, outputPath, varargin{:});
    params = p.Results;

    % Start EEGLAB
    if ~exist('eeglab', 'file')
        error('EEGLAB is not in the MATLAB path.');
    end
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

    %% 1. Load Data
    fprintf('Loading %s...\n', fullfile(params.filePath, params.fileName));
    if contains(params.fileName, '.set')
        EEG = pop_loadset('filename', params.fileName, 'filepath', params.filePath);
    else
        % Add other formats here as needed (e.g., pop_biosig)
        error('Currently only .set files are supported in this demo wrapper.');
    end
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', 'Raw Data', 'gui', 'off');

    %% 2. Load Channel Locations (Montage)
    if ~isempty(params.ChannelLocs)
        fprintf('Loading channel locations from %s...\n', params.ChannelLocs);
        EEG = pop_chanedit(EEG, 'lookup', params.ChannelLocs);
    elseif isempty(EEG.chanlocs)
        warning('No channel locations provided and none in dataset. Interpolation and ICA might fail.');
    end

    %% 3. Bad Channel Interpolation
    if ~isempty(params.BadChannels)
        if isempty(EEG.chanlocs)
            warning('Cannot interpolate without channel locations. Skipping interpolation.');
        else
            fprintf('Interpolating bad channels: %s\n', num2str(params.BadChannels));
            EEG = pop_interp(EEG, params.BadChannels, 'spherical');
        end
    else
        fprintf('No bad channels specified for interpolation.\n');
    end

    %% 4. Filter Data
    fprintf('Filtering data %d-%d Hz...\n', params.LowFreq, params.HighFreq);
    EEG = pop_eegfiltnew(EEG, 'locutoff', params.LowFreq, 'hicutoff', params.HighFreq, 'plotfreqz', 0);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', 'Filtered', 'gui', 'off');

    %% 5. Re-reference
    fprintf('Re-referencing to average...\n');
    EEG = pop_reref(EEG, []);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', 'Referenced', 'gui', 'off');

    %% 6. Save Preprocessed Data
    fprintf('Saving preprocessed data to %s...\n', fullfile(params.outputPath, params.outputName));
    EEG = pop_saveset(EEG, 'filename', params.outputName, 'filepath', params.outputPath);

    %% 7. Run ICA (Optional)
    if params.RunICA
        fprintf('Running ICA...\n');
        EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');

        [~, name, ext] = fileparts(params.outputName);
        icaOutputName = [name, '_ICA', ext];
        fprintf('Saving data with ICA weights to %s...\n', fullfile(params.outputPath, icaOutputName));
        EEG = pop_saveset(EEG, 'filename', icaOutputName, 'filepath', params.outputPath);
    else
        fprintf('Skipping ICA. Set RunICA to true to run it.\n');
    end

    fprintf('Preprocessing pipeline complete.\n');
end
