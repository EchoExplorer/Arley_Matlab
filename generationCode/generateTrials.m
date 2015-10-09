function [] = generateTrials(level, angle)

% generate trials based on the clicks and echoes - 2 click/echo sets per
% trial

angle2 = -1 * angle;
ild = 1; % 1 if you want to generate with ILDs; 0 if not

wavDir = sprintf('../WAVfiles/artificial/artLR_%sdB/', num2str(level));
if ild
    file1 = sprintf('norm_mc986_**.wav_*dB_%sdeg_1.2192m_ILD.wav', num2str(angle)); % echo on right
    file2 = sprintf('norm_mc986_**.wav_*dB_%sdeg_1.2192m_ILD.wav', num2str(angle2)); % echo on left
else
    file1 = sprintf('norm_mc986_**.wav_*dB_%sdeg_1.2192m_ILD.wav', num2str(angle)); % echo on right
    file2 = sprintf('norm_mc986_**.wav_*dB_%sdeg_1.2192m_ILD.wav', num2str(angle2)); % echo on left
end

folder1 = dir(strcat(wavDir, file1));
folder2 = dir(strcat(wavDir, file2));
levelStart = 0;
levelEnd = 0;
stepSize = 1;
distance = 1.2192; % 4 feet

% generate left/right trials
for file = folder2'
    label1 = file.name(12:13);
    [wavFile, Fs] = audioread(strcat(wavDir, file.name));
    delay1 = Fs * .2;
    delay2 = Fs * .5;
    wavFile = [zeros(2, delay1), wavFile', zeros(2, delay2)];
    for file2 = folder1'
        label2 = file2.name(12:13);
        [wavFile2, Fs] = audioread(strcat(wavDir, file2.name));
        wavFileFinal = [wavFile wavFile2' zeros(2, delay1)];
        wavFileFinal = wavFileFinal';
        if ild
            filename = sprintf('mcLR_%sdeg_%sm_%s%sILD.wav', num2str(angle), num2str(distance), num2str(label1), num2str(label2));
        else
            filename = sprintf('mcLR_%sdeg_%sm_%s%s.wav', num2str(angle), num2str(distance), num2str(label1), num2str(label2));
        end
        audiowrite(strcat(wavDir, filename), wavFileFinal, Fs);
    end
end

% generate right/left trials
for file = folder1'
    label1 = file.name(12:13);
    [wavFile, Fs] = audioread(strcat(wavDir, file.name));
    delay1 = Fs * .2;
    delay2 = Fs * .5;
    wavFile = [zeros(2, delay1) wavFile' zeros(2, delay2)];
    for file2 = folder2'
        label2 = file2.name(12:13);
        [wavFile2, Fs] = audioread(strcat(wavDir, file2.name));
        wavFileFinal = [wavFile wavFile2' zeros(2, delay1)];
        wavFileFinal = wavFileFinal';
        if ild
            filename = sprintf('mcRL_%sdeg_%sm_%s%sILD.wav', num2str(angle), num2str(distance), num2str(label1), num2str(label2));
        else
            filename = sprintf('mcRL_%sdeg_%sm_%s%s.wav', num2str(angle), num2str(distance), num2str(label1), num2str(label2));
        end
        audiowrite(strcat(wavDir, filename), wavFileFinal, Fs);
    end
end