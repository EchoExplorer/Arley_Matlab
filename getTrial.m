function [trial, Fs, trueAcc, filename] = getTrial(level, letters)

% Initial creation: June 23, 2015 by Arley

% June 30, 2015: updated to read in more filetypes than 'PA': now works for
% LM and RM

% July 7, 2015: works for LR

% August 6, 2015: works for artificially generated LR -- both varying level
% of amplification and varying degrees from center

% level: level in dB or degrees
% letters: specify what type of files you're comparing
%    PA: recorded present/absent; varying level of amplification
%    LM: recorded left/middle; varying degrees
%    RM: recorded right/middle; varying degrees
%    LR45: recorded left/right at 45 degrees; varying level of amp.
%    LR90: recorded left/right at 90 degrees; varying level of amp.
%    artLR45: artificially generated left/right at 45 degrees; varying
%       level of amp.
%    artLR90: artificially generated left/right at 90 degrees; varying
%       level of amp.
%    artLR: artificially generated left/right; varying degrees


if strcmp(letters, 'PA')
    wavDir = sprintf('../WAVfiles/BoardPA/');
    file = sprintf('*oard**_%sdB*.wav', num2str(level));
    echoFolder = dir(strcat(wavDir, file));
    rand_index = randi(numel(echoFolder));
    filename = echoFolder(rand_index).name;
    
elseif strcmp(letters, 'LR45')
    wavDir = sprintf('../WAVfiles/BoardLR_45deg/');
    file = sprintf('clicker**_45deg_%sdB*.wav', num2str(level));
    echoFolder = dir(strcat(wavDir, file));
    rand_index = randi(numel(echoFolder));
    filename = echoFolder(rand_index).name;
    
elseif strcmp(letters, 'LR90')
    wavDir = sprintf('../WAVfiles/BoardLR_90deg/');
    file = sprintf('clicker**_90deg_%sdB*.wav', num2str(level));
    echoFolder = dir(strcat(wavDir, file));
    rand_index = randi(numel(echoFolder));
    filename = echoFolder(rand_index).name;
    
elseif strcmp(letters, 'artLR90') % staircase on level of amplification
    wavDir = sprintf('../WAVfiles/artificial/artLRtrials_%sdB/', num2str(level));
    file = 'mc**_90deg_******m_****ILD.wav';
    echoFolder = dir(strcat(wavDir, file));
    rand_index = randi(numel(echoFolder));
    filename = echoFolder(rand_index).name;
    disp(filename);
elseif strcmp(letters, 'artLR45') % staircase on level of amplification
    wavDir = sprintf('../WAVfiles/artificial/artLRtrials_%sdB/', num2str(level));
    file = 'mc**_45deg_******m_****ILD.wav';
    echoFolder = dir(strcat(wavDir, file));
    rand_index = randi(numel(echoFolder));
    filename = echoFolder(rand_index).name;
elseif strcmp(letters, 'artLR') % staircase on degrees from center
    wavDir = '../WAVfiles/artificial/artLRtrials_0dB/';
    file = sprintf('mc**_%sdeg_******m_****ILD.wav', num2str(level));
    disp(strcat(wavDir, file));
    echoFolder = dir(strcat(wavDir, file));
    rand_index = randi(numel(echoFolder));
    filename = echoFolder(rand_index).name;
else % LM or RM
    wavDir = sprintf('../WAVfiles/Board%s/', letters);
    file = sprintf('board**_%sdeg.wav', num2str(level));
    echoFolder = dir(strcat(wavDir, file));
    rand_index = randi(numel(echoFolder));
    filename = echoFolder(rand_index).name;
end



[trial, Fs] = audioread(strcat(wavDir, filename));

if strcmp(letters, 'PA')
    if strcmp(filename(6:7), 'PA')
        trueAcc = 1;
    else
        trueAcc = 2;
    end
elseif strcmp(letters, 'LM')
    if strcmp(filename(6:7), 'LM')
        trueAcc = 1;
    else
        trueAcc = 2;
    end
elseif strcmp(letters, 'RM')
    if strcmp(filename(6:7), 'RM')
        trueAcc = 1;
    else
        trueAcc = 2;
    end
elseif strcmp(letters, 'LR45') || strcmp(letters, 'LR90')
    if strcmp(filename(8:9), 'LR') % clickerLR/RL
        trueAcc = 1;
    else
        trueAcc = 2;
    end
elseif strcmp(letters, 'artLR90') || strcmp(letters, 'artLR45') || strcmp(letters, 'artLR')
    if strcmp(filename(3:4), 'LR')
        trueAcc = 1;
    else
        trueAcc = 2;
    end
    
end
