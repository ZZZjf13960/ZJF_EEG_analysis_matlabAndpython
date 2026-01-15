% EXAMPLE_SPECTRAL_EEGLAB
% Demonstrates how to run the EEGLAB spectral analysis pipeline.

% 1. Setup Paths
if exist('eeglab', 'file')
    eeglabPath = fileparts(which('eeglab'));
    sampleDataPath = fullfile(eeglabPath, 'sample_data');
    sampleFileName = 'eeglab_data.set';

    if ~exist(fullfile(sampleDataPath, sampleFileName), 'file')
        warning('Sample data not found. Please update paths.');
        return;
    end
else
    error('EEGLAB not found in MATLAB path.');
end

outputDir = fullfile(pwd, 'sample_output_eeglab_spectral');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

outputName = 'eeglab_welch_spec.mat';

% 2. Run Spectral Analysis (Welch)
fprintf('Running EEGLAB Spectral Analysis (Welch)...\n');
eeglab_spectral(sampleFileName, sampleDataPath, outputName, outputDir, ...
    'Method', 'welch', ...
    'Fmin', 1, ...
    'Fmax', 50);

% 3. Run Spectral Analysis (FFT)
outputNameFFT = 'eeglab_fft_spec.mat';
fprintf('Running EEGLAB Spectral Analysis (FFT)...\n');
eeglab_spectral(sampleFileName, sampleDataPath, outputNameFFT, outputDir, ...
    'Method', 'fft', ...
    'Fmin', 1, ...
    'Fmax', 50);

fprintf('Check results in %s\n', outputDir);
