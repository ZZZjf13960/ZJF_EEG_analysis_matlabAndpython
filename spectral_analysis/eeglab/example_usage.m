% Example usage for EEGLAB spectral analysis
% This script assumes EEGLAB is installed and in path.

% Create dummy EEG structure
EEG = struct();
EEG.srate = 1000;
EEG.pnts = 5000;
EEG.nbchan = 2;
EEG.trials = 1;
EEG.xmin = 0;
EEG.xmax = (EEG.pnts-1)/EEG.srate;

% Signal: 10Hz and 50Hz sine waves
t = 0:1/EEG.srate:EEG.xmax;
EEG.data = [sin(2*pi*10*t) + 0.5*sin(2*pi*50*t); ...
            cos(2*pi*10*t) + 0.5*cos(2*pi*50*t)];
% Channel 2 is cosine phase

disp('Running EEGLAB Welch...');
[spectra_welch, freqs_welch] = eeglab_welch(EEG, 1, 100, 512, 256);

disp('Spectra size (Channels x Freqs):');
disp(size(spectra_welch));

% Find peaks
[~, idx10] = min(abs(freqs_welch - 10));
[~, idx50] = min(abs(freqs_welch - 50));
fprintf('Channel 1 Power at 10Hz: %f\n', spectra_welch(1, idx10));
fprintf('Channel 1 Power at 50Hz: %f\n', spectra_welch(1, idx50));


disp('Running EEGLAB FFT...');
[spectra_fft, freqs_fft] = eeglab_fft(EEG, 1, 100);
disp('Spectra FFT size:');
disp(size(spectra_fft));

[~, idx10f] = min(abs(freqs_fft - 10));
fprintf('Channel 1 FFT Power at 10Hz: %f\n', spectra_fft(1, idx10f));
