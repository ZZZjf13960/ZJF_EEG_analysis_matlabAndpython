% EXAMPLE_SPECTRAL_FIELDTRIP
% Demonstrates how to run the FieldTrip spectral analysis pipeline.

% 1. Setup Paths
inputName = 'Subject01.ds';
inputPath = '/path/to/fieldtrip/tutorial/data/';

% Check if file exists (dummy check)
if ~exist(fullfile(inputPath, inputName), 'file') && ~exist(fullfile(inputPath, inputName), 'dir')
    warning('Data file not found. Please edit this script to point to a valid dataset.');
    % return; % Commented out to allow syntax checking
end

outputDir = fullfile(pwd, 'sample_output_fieldtrip_spectral');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

outputName = 'Subject01_spec.mat';

% 2. Run Spectral Analysis (Welch-like / Hanning)
fprintf('Running FieldTrip Spectral Analysis (Hanning)...\n');
try
    fieldtrip_spectral(fullfile(inputPath, inputName), fullfile(outputDir, outputName), ...
        'Method', 'welch', ...
        'Fmin', 1, ...
        'Fmax', 50);

    % 3. Run Spectral Analysis (Multitaper)
    outputNameMT = 'Subject01_mt_spec.mat';
    fprintf('Running FieldTrip Spectral Analysis (Multitaper)...\n');
    fieldtrip_spectral(fullfile(inputPath, inputName), fullfile(outputDir, outputNameMT), ...
        'Method', 'multitaper', ...
        'Fmin', 1, ...
        'Fmax', 50, ...
        'Tapsmofrq', 4);

    fprintf('Check results in %s\n', outputDir);
catch ME
    fprintf('Error running FieldTrip pipeline: %s\n', ME.message);
end
