clc;clear
load E:\tool_matlab\zjf\time_fre_Wavelet\MorletWavelets-main\MorletWaveletDefinition_data.mat

bidx = dsearchn(EEG.times',[-500 -200]');
tidx = dsearchn(EEG.times',-500):dsearchn(EEG.times',1300);
[timefre_data,f] = zjf_MorletWavelet(EEG.data,[2,40],80,0.5,EEG.srate,1,0);
tf = mean(timefre_data,3);
tf_base = 10*log10(bsxfun(@rdivide,tf(:,tidx),mean(tf(:,bidx(1):bidx(2)),2)));


figure
contourf(EEG.times(tidx),f,tf_base,60,'linecolor','none')
set(gca,'clim',clim,'YScale','log','YTick',logspace(log10(f(1)),log10(f(end)),10),'YTickLabel',round(logspace(log10(f(1)),log10(f(end)),10),2))
axis square
colormap(zjf_bluewhitered(64))
%% 变换fwhm
clc;clear
load E:\tool_matlab\zjf\time_fre_Wavelet\MorletWavelets-main\MorletWaveletDefinition_data.mat
[timefre_data,f] = zjf_MorletWavelet(EEG.data,[2,40],80,[1,.2],EEG.srate,1,1);

bidx = dsearchn(EEG.times',[-500 -200]');
tidx = dsearchn(EEG.times',-500):dsearchn(EEG.times',1300);
tf = mean(timefre_data,3);
tf_base = 10*log10(bsxfun(@rdivide,tf(:,tidx),mean(tf(:,bidx(1):bidx(2)),2)));


figure
contourf(EEG.times(tidx),f,tf_base,60,'linecolor','none')
set(gca,'clim',clim,'YScale','log','YTick',logspace(log10(f(1)),log10(f(end)),10),'YTickLabel',round(logspace(log10(f(1)),log10(f(end)),10),2))
axis square
colormap(zjf_bluewhitered(64))
%%
clc;clear
load E:\tool_matlab\zjf\time_fre_Wavelet\MorletWavelets-main\MorletWaveletDefinition_data.mat

data = EEG.data;
bidx = dsearchn(EEG.times',[-500 -200]');
tidx = dsearchn(EEG.times',-500):dsearchn(EEG.times',1300);


fs = EEG.srate;
winsize   = 0.5;

f = 2:0.5:40;
t = EEG.times/1000;

[S,P,F,U] = sub_stft(data, t,t, f, fs, winsize);
tf = mean(P,3);
tf_base = 10*log10(bsxfun(@rdivide,tf(:,tidx),mean(tf(:,bidx(1):bidx(2)),2)));

figure
contourf(EEG.times(tidx),f,tf_base,60,'linecolor','none')
set(gca,'clim',clim,'YScale','log','YTick',logspace(log10(f(1)),log10(f(end)),10),'YTickLabel',round(logspace(log10(f(1)),log10(f(end)),10),2))
axis square
colormap(zjf_bluewhitered(64))