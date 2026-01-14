function [tf,frex] = zjf_MorletWavelet(data,frequency,nfre,fwhm,srate,power,var_fwhm)
%UNTITLED6 此处显示有关此函数的摘要
%   参数1 ：数据  时间 × 试次
%   参数2 ：最小频率和最大频率  [minfre,maxfre]
%   参数3 ：频率数量  线性   linspace(frequency(1),frequency(2),nfre);
%   参数4 ：fwhm  second 若采用变化，输入[minfwhm,maxfwhm]
%   参数5 ：采样率
%   参数6 ：是否转为功率  1 or 0
%   参数7 ：是否不同频率采用不同fwhm  1 or 0
%   输出 时频数据data[频率，时间，试次],频率f 向量 频率
%   参考文章  NeuroImage ：A better way to define and describe Morlet wavelets for time-frequency analysis
    frex = linspace(frequency(1),frequency(2),nfre);
    if var_fwhm
        fwhm = linspace(fwhm(1),fwhm(2),length(frex));
    end


    % morletwavelet parameters
    wavet = -5:1/srate:5;
    halfw = floor(length(wavet)/2)+1;
    nConv = size(data,1)*size(data,2) + length(wavet) - 1;

    % initialize time-frequency matrix and convolution
    tf = zeros(length(frex),size(data,1),size(data,2));
    dataX = fft(reshape(data,1,[]),nConv);
    if var_fwhm
        for fi=1:length(frex)
            % create wavelet
            waveX = fft( exp(2*1i*pi*frex(fi)*wavet).*exp(-4*log(2)*wavet.^2/fwhm(fi).^2),nConv );
            waveX = waveX./max(waveX); % normalize

            % convolve
            as = ifft( waveX.*dataX );

            % trim and reshape
            as = reshape(as(halfw:end-halfw+1),size(data,1),size(data,2));
            if power
                p = abs(as).^2;
                tf(fi,:,:) = p;
            end
        end
    else
        for fi=1:length(frex)
            % create wavelet
            waveX = fft( exp(2*1i*pi*frex(fi)*wavet).*exp(-4*log(2)*wavet.^2/fwhm.^2),nConv );
            waveX = waveX./max(waveX); % normalize

            % convolve
            as = ifft( waveX.*dataX );

            % trim and reshape
            as = reshape(as(halfw:end-halfw+1),size(data,1),size(data,2));
            if power
                p = abs(as).^2;
                tf(fi,:,:) = p;
            end
        end
    end

end