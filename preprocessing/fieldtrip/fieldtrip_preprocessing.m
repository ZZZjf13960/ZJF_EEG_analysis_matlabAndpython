% FieldTrip Preprocessing Script
% This script demonstrates a standard preprocessing pipeline using FieldTrip.

% Initialize FieldTrip (ensure it is in the path)
ft_defaults;

% Define filenames
inputFile = 'subject01.eeg'; % Replace with your data file
outputFile = 'subject01_preprocessed.mat';

%% 1. Define Trials and Read Data
% If the data is continuous, we can read it as one long trial or segment it later.
% Here we assume continuous data read-in.

cfg = [];
cfg.dataset = inputFile;
% Define trial as the whole dataset (or define specific triggers here)
% For continuous data without specific trial definition:
% cfg.trialdef.triallength = Inf;
% cfg.trialdef.ntrials     = 1;

% Simple read of data
data = ft_preprocessing(cfg);

%% 2. Filter Data (1-40 Hz)
% High-pass and Low-pass filtering
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [1 40];
% Optional: notch filter for line noise (50Hz or 60Hz)
% cfg.bsfilter = 'yes';
% cfg.bsfreq = [49 51];

data_filtered = ft_preprocessing(cfg, data);

%% 3. Re-reference (Average Reference)
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = 'all'; % 'all' for average reference

data_reref = ft_preprocessing(cfg, data_filtered);

%% 4. ICA (Independent Component Analysis)
% To perform ICA, we usually need to resample or epoch the data to reduce computation,
% but here we run it on the preprocessed data.

% Decompose
cfg = [];
cfg.method = 'runica'; % or 'fastica'
% cfg.numcomponent = 20; % Optional: limit number of components

comp = ft_componentanalysis(cfg, data_reref);

% Note: Visual inspection is typically required to reject components.
% Use ft_databrowser to inspect components:
% cfg = [];
% cfg.viewmode = 'component';
% ft_databrowser(cfg, comp);

% Automated rejection is not standard in FieldTrip without extra logic/plugins.
% Assuming we identified bad components (e.g., [1 2]):
% cfg = [];
% cfg.component = [1 2]; % Indices of components to reject
% data_clean = ft_rejectcomponent(cfg, comp, data_reref);

% For this script, we keep 'comp' as the result, assuming manual rejection follows.

%% 5. Save Data
% Save the final structure
save(outputFile, 'data_reref', 'comp', '-v7.3');

fprintf('Preprocessing complete. Data saved to %s\n', outputFile);
