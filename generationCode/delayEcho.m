 function [echo] = delayEcho(attenuatedEcho, distance, soundSpeed, Fs)

% attenuatedEcho: echo adjusted to sound level we want
%                 must have two channels: (size(aE, 1) == 2)
% distance: m
% soundSpeed: m/s
% Fs: sampling speed, Hz

% if size(attenuatedEcho, 1) ~= 2
%     disp('Sound file must have exactly 2 channels');
%     return
% end
delayTime = distance / soundSpeed;
numSamples = round(delayTime * Fs);
delay = zeros(2, numSamples);
echo = [delay attenuatedEcho'];
echo = echo';

end