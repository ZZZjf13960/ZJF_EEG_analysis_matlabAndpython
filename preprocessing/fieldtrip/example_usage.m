% EXAMPLE_USAGE_FIELDTRIP
% Demonstrates how to run the FieldTrip preprocessing pipeline.
%
% This script assumes you have FieldTrip installed and added to your MATLAB path.
% It uses a placeholder for the dataset path. Update 'inputPath' and 'inputName'
% to point to your data (e.g., Subject01.ds from the FieldTrip tutorial).

% 1. Setup Paths
% Update these to point to valid data!
% Example using the FieldTrip tutorial data 'Subject01.ds' if available.
inputName = 'Subject01.ds';
inputPath = '/path/to/fieldtrip/tutorial/data/';

% Check if file exists (dummy check for this example)
if ~exist(fullfile(inputPath, inputName), 'file') && ~exist(fullfile(inputPath, inputName), 'dir')
    warning(['Data file not found at %s. ' ...
             'Please edit this script to point to a valid EEG/MEG dataset.'], ...
             fullfile(inputPath, inputName));
    % For the purpose of this example file, we stop here.
    % To run it, download the tutorial data or use your own.
    fprintf('Please configure inputPath and inputName in example_usage.m\n');
    return;
end

outputDir = fullfile(pwd, 'sample_output_fieldtrip');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

outputName = 'Subject01_clean.mat';

% 2. Define Parameters
% Layout is critical for interpolation in FieldTrip.
% 'CTF151.lay' is standard for the tutorial data.
layoutName = 'CTF151.lay';

% 3. Run Preprocessing
% - Filter 1-40 Hz
% - Interpolate bad channels (e.g., 'MLC11')
% - Run ICA

fprintf('Running FieldTrip preprocessing example...\n');

try
    fieldtrip_preprocessing(fullfile(inputPath, inputName), fullfile(outputDir, outputName), ...
        'LowFreq', 1, ...
        'HighFreq', 40, ...
        'Layout', layoutName, ...
        'BadChannels', {'MLC11'}, ... % Example bad channel label
        'RunICA', true);

    fprintf('Example run complete. Check %s for results.\n', outputDir);
catch ME
    fprintf('Error running FieldTrip pipeline: %s\n', ME.message);
end
