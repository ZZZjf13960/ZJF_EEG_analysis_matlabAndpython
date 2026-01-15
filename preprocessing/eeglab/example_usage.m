% EXAMPLE_USAGE_EEGLAB
% Demonstrates how to run the EEGLAB preprocessing pipeline.
%
% This script assumes you have EEGLAB installed and added to your MATLAB path.
% It attempts to use the 'eeglab_data.set' sample file included with EEGLAB.

% 1. Setup Paths
% Define where your data is.
% If EEGLAB is in the path, we can find the sample data.
if exist('eeglab', 'file')
    eeglabPath = fileparts(which('eeglab'));
    sampleDataPath = fullfile(eeglabPath, 'sample_data');
    sampleFileName = 'eeglab_data.set';

    if ~exist(fullfile(sampleDataPath, sampleFileName), 'file')
        warning('Sample data not found at %s. Please update the path.', sampleDataPath);
        return;
    end
else
    error('EEGLAB not found in MATLAB path.');
end

outputDir = fullfile(pwd, 'sample_output_eeglab');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

outputName = 'eeglab_data_clean.set';

% 2. Define Parameters
% Standard 10-20 channel locations are often needed for interpolation.
% EEGLAB comes with standard location files.
chanLocFile = fullfile(eeglabPath, 'plugins', 'dipfit', 'standard_BESA', 'standard-10-5-cap385.elp');
% Note: The sample data 'eeglab_data.set' already has channel locations,
% so providing chanLocFile is optional but good practice if your raw data lacks it.
% For this example, we might skip it or use it if available.
if ~exist(chanLocFile, 'file')
    chanLocFile = ''; % Let EEGLAB use internal defaults or existing locs
end

% 3. Run Preprocessing
% We run the pipeline with specific parameters.
% - Filter 1-40 Hz
% - Interpolate channel 10 (randomly chosen for demo)
% - Run ICA at the end

fprintf('Running EEGLAB preprocessing example...\n');

eeglab_preprocessing(sampleFileName, sampleDataPath, outputName, outputDir, ...
    'LowFreq', 1, ...
    'HighFreq', 40, ...
    'BadChannels', [10], ... % Example bad channel index
    'ChannelLocs', chanLocFile, ...
    'RunICA', true);

fprintf('Example run complete. Check %s for results.\n', outputDir);
