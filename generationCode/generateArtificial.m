function [ ] = generateArtificial(file, levelStart, levelEnd, stepSize, angle, distance, ild)

    % Rudina Morina and Arley Schenker
    % Writes wav files of artificial echoes for Staircase function in EcholocationCode folder
    
    %%%%% Parameters:
    % angle = location of object 
    % distance = m distance of object
    % ild = 1 if you want to generate with ILDs, 0 otherwise
    
    % Ref_file MUST have both a left and right channel
    
    levels = levelStart:stepSize:levelEnd;

    fileoutDir = '../WAVfiles/artificial/';
    soundSpeed = 343; % 343 m/s
    
    clickDir = '../WAVfiles/clicks/';
    [r_click, Fs] = audioread(strcat(clickDir, file));
    attenuatedRef = AttenuateSound(r_click, -6);
    audiowrite('../WAVfiles/attenuatedClick.wav', attenuatedRef, Fs);
    
    % generate the echo, then amplify or attenuate it based on the level we're in
    for e=1:size(levels,2)
        echo = generateEcho('../WAVfiles/attenuatedClick.wav', angle, ild);
        attenuatedEcho = AttenuateSound(echo, levelStart + (e-1)*stepSize);
        delayedEcho = delayEcho(attenuatedEcho, distance, soundSpeed, Fs);
        combinedEcho = concatenate(attenuatedRef, delayedEcho);
        combinedEcho = combinedEcho';
        if ild
            filename = strcat(fileoutDir, file, '_', num2str(levelStart + (e-1)*stepSize), 'dB_', num2str(angle), 'deg_', num2str(distance), 'm_ILD.wav');
        else
            filename = strcat(fileoutDir, file, '_', num2str(levelStart + (e-1)*stepSize), 'dB_', num2str(angle), 'deg_', num2str(distance), 'm.wav');
        end
        audiowrite(filename, combinedEcho, Fs);
    end
    
    
end

