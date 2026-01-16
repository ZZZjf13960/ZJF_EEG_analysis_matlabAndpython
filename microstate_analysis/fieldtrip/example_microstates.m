% Example usage for FieldTrip microstate analysis

% Create dummy data
data = [];
data.label = cellstr(string(1:30)');
data.fsample = 100;
data.trial = {randn(30, 2000)};
data.time = {0:0.01:19.99};

disp('Running FieldTrip Microstates...');
microstate = ft_microstates(data, 4);

disp(['GEV: ', num2str(microstate.gev)]);
disp(['Maps size: ', num2str(size(microstate.maps))]);
