% Example usage for FieldTrip spectral analysis
% Assumes FieldTrip is in path and ft_defaults has been run.

% Create dummy data structure
data = [];
data.label = {'Cz'; 'Pz'};
data.fsample = 1000;
data.trial = {randn(2, 1000)}; % 1 second of noise
data.time = {0:0.001:0.999};

disp('Running FieldTrip FFT...');
freq_fft = ft_spectral_analysis(data, 'fft', 1, 100);
disp(freq_fft);

disp('Running FieldTrip Welch-like...');
freq_welch = ft_spectral_analysis(data, 'welch', 1, 100);
disp(freq_welch);
