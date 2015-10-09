function [echoBinaural, ITD] = ITDfromangle(refClick, Fs, angle )
%ITDfromangle Calculates the ITD value based on the angle 
%   angle = angle in degrees
%   echoBinaural = Echo for two ears based on ITD calculated
%   ITD  = the time difference in usec between two ears based on the angle
% Assumptions: 
%  - The ITD value is independent of distance of the object and only
%    depends on angle
%  - The ITD values change linearly from 0 to 650usec as angle changes from
%    0 degree to 90 degrees
%  - medium of travel is dry air so speed of sound = 343 m/s

% Fs = 100000;
timePerSample = 1/Fs *1000000 ; %(in usec)
ITD = abs((65 /9) * angle);
sampleDelay = ceil(ITD/timePerSample);
refClick = refClick';
if(angle <0)
    echoRight = [zeros(1, sampleDelay) refClick(2, :)];
    echoLeft  = [refClick(1, :) zeros(1, sampleDelay)];
else
    echoLeft  = [zeros(1, sampleDelay) refClick(1, :)];
    echoRight = [refClick(2, :) zeros(1, sampleDelay)];
end
echoBinaural = [echoLeft; echoRight];
end

