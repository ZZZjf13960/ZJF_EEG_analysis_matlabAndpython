% Example usage for EEGLAB microstate analysis

% Create dummy data
EEG = struct();
EEG.srate = 100;
EEG.nbchan = 30;
EEG.pnts = 2000;
EEG.data = randn(EEG.nbchan, EEG.pnts);
EEG.trials = 1;

disp('Running EEGLAB Microstates...');
[microstates, labels, gev] = microstate_analysis_eeglab(EEG, 4);

disp(['GEV: ', num2str(gev)]);
disp(['Maps size: ', num2str(size(microstates))]);
