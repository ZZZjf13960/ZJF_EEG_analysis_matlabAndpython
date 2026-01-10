% EEGLAB Preprocessing Script
% This script demonstrates a standard preprocessing pipeline using EEGLAB functions.

% Define file parameters
% Note: Replace these with actual file paths
fileName = 'subject01.set'; % Input file name
filePath = '/path/to/data/'; % Input file path
outputName = 'subject01_preprocessed.set';
outputPath = '/path/to/save/';

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

% 1. Load Data
% Check file extension to use appropriate loading function
% This example uses pop_loadset for .set files.
% For .bdf, .edf use pop_biosig or similar.
fprintf('Loading %s...\n', fullfile(filePath, fileName));
try
    EEG = pop_loadset('filename', fileName, 'filepath', filePath);
catch ME
    error('Could not load file. Make sure file exists and EEGLAB is in path.');
end

[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', 'Raw Data', 'gui', 'off');

% 2. Filter Data (1-40 Hz)
% pop_eegfiltnew(EEG, locutoff, hicutoff, plotfreqz, usefft, revfilt, plotfilt, minphase)
% locutoff = 1, hicutoff = 40
fprintf('Filtering data 1-40 Hz...\n');
EEG = pop_eegfiltnew(EEG, 'locutoff', 1, 'hicutoff', 40, 'plotfreqz', 0);
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', 'Filtered', 'gui', 'off');

% 3. Re-reference (Average Reference)
% pop_reref(EEG, ref, 'keepref', 'on'/'off', 'exclude', [channels])
% ref = [] means average reference
fprintf('Re-referencing to average...\n');
EEG = pop_reref(EEG, []);
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', 'Referenced', 'gui', 'off');

% 4. ICA (Independent Component Analysis)
% Using 'runica' (Infomax) which is standard in EEGLAB
% Note: This can take a long time.
fprintf('Running ICA...\n');
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', 'ICA Computed', 'gui', 'off');

% Note: Automated artifact rejection (e.g., ICLabel) is recommended here
% but requires the ICLabel plugin.
% Example if ICLabel is installed:
% EEG = pop_iclabel(EEG, 'default');
% EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
% EEG = pop_subcomp(EEG, [], 0);

% 5. Save Preprocessed Data
fprintf('Saving data to %s...\n', fullfile(outputPath, outputName));
EEG = pop_saveset(EEG, 'filename', outputName, 'filepath', outputPath);

fprintf('Preprocessing complete.\n');
