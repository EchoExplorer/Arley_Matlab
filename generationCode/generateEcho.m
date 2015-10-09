function [ echoAngle ] = generateEcho(file, angle, ild, varargin )
% combinedEchos = generateEcho(angle, varargin)
%
% This function generates the echo given the reference click and the angle
%(in degrees) which indicates the direction of the object. 0 degrees is 
% considered the position straight in front of the user. Hence a negative 
% angle is considered to the left of the user and a positive anlge is 
% considered to the right of the user.
%
% The function returns the computed echo. If the user chooses to pass a 
% filename, it will write that echo to the specified file. 
%
% Interaural level differences: set ild == 1 if you want to generate
% files with level differences; set ild == 0 if you do not
% 
% 90º corresponds to 10 dB of attenuation in farther channel
% Attenuation varies linearly according to that ratio for other angles


    objCenter = 0;            
    nVarargs = length(varargin);
    if (nVarargs > 1)
        fprintf('You cannot pass more than one optional argument');
        combinedEchos = [];
        return;
    end
    
    %InterAural Time delays 
    [ref, Fs] = audioread(file);
    
    % combination of center and angle echoes: used when encountering an
    % opening in a hallway (maybe?)
    [echoCenter, ITD1] = ITDfromangle(ref, Fs, objCenter); %Centre
    [echoAngle, ITD2] = ITDfromangle(ref, Fs, angle); %Right
    
%     combinedEchos = [echoCenter zeros(2,0.8*100000) echoAngle];
%     combinedEchos = combinedEchos';
    echoAngle = echoAngle';
    
    % Interaural level delays
    if ild
        leftChannel = echoAngle(:, 1);
        rightChannel = echoAngle(:, 2);
        if angle < 0 % echo on the left
            rightChannel = AttenuateSound(leftChannel, -((10/90)*abs(angle)));
        elseif angle > 0 % echo on the right
            leftChannel = AttenuateSound(rightChannel, -((10/90)*abs(angle)));
        end
    end
    
    echoAngle = [leftChannel, rightChannel];
    
    
    if (nVarargs == 1)
        %if the user has passed a filename argument
        if (~ischar(varargin{1}))
            fprintf('fileName must be a string');
            return;
        end
        fileName = varargin{1};
        audiowrite(fileName, echoAngle, Fs);
    end
end


