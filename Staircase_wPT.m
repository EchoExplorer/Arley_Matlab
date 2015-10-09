function [ results ] = Staircase(subNo, levelStart, levelEnd, stepSize, letters1)

    % June 30, 2015

    % subNo: subject number
    % levelStart: sound level (dB or degrees) of softest/closest test stimulus
    % levelEnd: sound level (dB or degrees) of loudest/farthest test stimulus
    % stepSize: size (dB or degrees) of difference between steps of staircase
    % letters1: specify type of files to test
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
    %    LOUD: simple stimuli to test staircase - say which sounds are
    %       louder
    
    clc;
    close all
    % PsychDebugWindowConfiguration()
    DEBUG = 0;
    ListenChar(1);
    pause(1)
    %daq=DaqFind;
    KbIndex = GetKeyboardIndices('Apple Internal Keyboard / Trackpad');
    Screen('Preference','VisualDebugLevel', 0);
    
    results = zeros(100, 3);
    totalReversals = 11; % total number of reversals before staircase stops
    reversalAvg = 6; % number of reversals to be averaged for results
    reversals = zeros(totalReversals, 1);
    reversal = 0; % current reversal
    trialNum = 1;
    numDown = 3; % num trials (either 2 or 3) subj has to get correct before 
                 % moving 1 level down (only has to get 1 trial wrong to move back up)
    numCorrect = 0;
    numCorrectAtLevel = 0;
    extreme = 0;
    levels = levelStart:stepSize:levelEnd;
    
    if strcmp(letters1, 'PA') % Present/Absent
        prompt = 'Where did you hear an echo? (1 2)';
        graph = 'Trials vs Sound Level (dB)';
        yaxis = 'Sound Level (dB)';
    elseif strcmp(letters1, 'LM') % Left/Middle
        prompt = 'Where was the echo further to the left? (1 2)';
        graph = 'Trials vs Degrees from Center';
        yaxis = 'Degrees from Center';
    elseif strcmp(letters1, 'RM') % Right/Middle
        prompt = 'Where was the echo further to the right? (1 2)';
        graph = 'Trials vs Degrees from Center';
        yaxis = 'Degrees from Center';
    elseif strcmp(letters1, 'LR45') || strcmp(letters1, 'LR90') % Left/Right
        prompt = 'Was the echo moving left to right (1) \n or right to left (2)?';
        graph = 'Trials vs Sound Level (dB)';
        yaxis = 'Sound Level (dB)';
    elseif strcmp(letters1, 'artLR45') || strcmp(letters1, 'artLR90') % artificial Left/Right
        prompt = 'Was the echo moving left to right (1) \n or right to left (2)?';
        graph = 'Trials vs Sound Level (dB)';
        yaxis = 'Sound Level (dB)';
    elseif strcmp(letters1, 'artLR')
        prompt = 'Was the echo moving left to right (1) \n or right to left (2)?';
        graph = 'Trials vs Degrees from Center';
        yaxis = 'Degrees from Center';
    elseif strcmp(letters1, 'LOUD') % simple stimuli
        prompt = 'Which sound was louder? (1 2)';
        graph = 'Trials vs Sound Level (dB)';
        yaxis = 'Sound Level (dB)';
    else
        error('Please provide letters corresponding to the appropriate paradigm');
    end
    
    % write results into data file
    Screen('Preference', 'SkipSyncTests', 1); % added for Retina display issues
    ResultDir = 'Results/';
    resultfilename = strcat([ResultDir 'Staircase_'],num2str(subNo),'.mat');
    datafilename = strcat([ResultDir 'Staircase_'],num2str(subNo),'.log');

    if subNo < 99 && fopen(datafilename, 'rt') ~= -1
        fclose('all');
        error('Result data file already exists! Choose a different subject number.');
    else
        fid = fopen(datafilename, 'w');
    end
    
    fprintf(fid,'%s\n','--------------------------------------');
    fprintf(fid,'%s\n%s\n', ...
    ['Participant ' num2str(subNo)],...
    ['Beginning of the session: ' datestr(now)]);
    fprintf(fid,'%s\n','--------------------------------------');
    fprintf(fid, '%s\n', strcat('Staircase for question: ', prompt));
    fprintf(fid,'%s\n','--------------------------------------');
    
    % get stimuli - function for echo generation
    %trials = getStimuli(subNo, levelStart, levelEnd, stepSize, testDelay,
    %'SoundLevel'); 
    
    % these wav files are simple stimuli to test the staircase loop
    
    if strcmp(letters1, 'LOUD')
        trials = cell(2, 4);
        [sound1, Fs] = audioread('../WAVfiles/beep3db1.wav');
        trials(1, 1) = {sound1};
        [sound2, Fs] = audioread('../WAVfiles/beep3db2.wav');
        trials(2, 1) = {sound2};
        [sound3, Fs] = audioread('../WAVfiles/beep6db1.wav');
        trials(1, 2) = {sound3};
        [sound4, Fs] = audioread('../WAVfiles/beep6db2.wav');
        trials(2, 2) = {sound4};
        [sound5, Fs] = audioread('../WAVfiles/beep9db1.wav');
        trials(1, 3) = {sound5};
        [sound6, Fs] = audioread('../WAVfiles/beep9db2.wav');
        trials(2, 3) = {sound6};
        [sound7, Fs] = audioread('../WAVfiles/beep12db1.wav');
        trials(1, 4) = {sound7};
        [sound8, Fs] = audioread('../WAVfiles/beep12db2.wav');
        trials(2, 4) = {sound8};
    end
    
    % trials is a cell array in which the first two rows have trials (to be 
    % played). the correct response for trials in row 1 is 1, and the
    % correct response for trials in row 2 is 2.
    % there are two rows of trials because the order is counterbalanced.
    
    % Mapping of key press responses
    
    L2=zeros(1,256);
    L3=zeros(1,256);
    L2andL3=zeros(1,256);
    L2(KbName('1!'))=1;
    L3(KbName('2@'))=1;
    L2andL3(KbName('3#'))=1;

    %%%% INIT for psychtoolbox %%%%
    
    InitializePsychSound;
    %to prevent key pressed to show up in the Matlab window
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    % check for Opengl compatibility, abort otherwise:
    AssertOpenGL;
    AssertOpenGL;
    rand('state',sum(100*clock));
    WaitSecs(0.1);
    GetSecs;
    % Set priority for script execution to realtime priority:
    
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    black=BlackIndex(screenNumber);
    white=WhiteIndex(screenNumber);
    red=[white black black];
    KbName('UnifyKeyNames');
    % Init keyboard responses (caps doesn't matter)
    advancestudytrial=KbName('n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
try
    HideCursor;
    ListenChar(2);
    if DEBUG == 1
        w=Screen('OpenWindow',screenNumber, black, [0 0 640 480]);
    else
        w = Screen('OpenWindow', screenNumber, black);
    end
    % Set text size (Most Screen functions must be called after
    % opening an onscreen window, as they only take window handles 'w' as
    % input:
    
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    Screen('TextSize', w, 32);
    
    % Opening credits and starting of experiment
    message = 'Staircase \n\n\n\n\n\n\n\n Schenker - 2015 - CMU/Auditory Lab';
    DrawFormattedText(w, message, 'center', 'center', white);
    
    Screen('Flip', w);
    WaitSecs(2);
    
    message = 'Press g to get started, or wait 10s to exit';
    DrawFormattedText(w, message, 'center', 'center', white);
    Screen('Flip', w);
    GOresp=KbName('g');
    KeyCode(GOresp)=0;
    tic;
    while ( KeyCode(GOresp)==0)
        [KeyIsDown, endrt, KeyCode]=KbCheck(KbIndex);
        t=toc;
        if t>10
            Screen('CloseAll');
            error('within the loop')
        end
        
        WaitSecs('YieldSecs',0.005);
    end
    
    Screen('TextSize', w, 50);
    
    % wait for user to press key to start expt

    message = 'Place your finger on the 3 key,\nthen release.';
    DrawFormattedText(w, message, 'center', 'center', white);
    Screen('Flip', w);
    WaitForKey(L2andL3, KbIndex);
    
    
    DrawFormattedText(w, 'Get prepared\n(put your hands on the keyboard)', 'center', 'center', white);
    Screen('Flip', w);
    WaitSecs(1);
    
    DrawFormattedText(w, 'Ready?', 'center', 'center', white);
    Screen('Flip', w);
    WaitSecs(1);
    
    DrawFormattedText(w, 'Steady?', 'center', 'center', white);
    Screen('Flip', w);
    WaitSecs(1);
    
    DrawFormattedText(w, 'Go!', 'center', 'center', white);
    Screen('Flip', w);
    WaitSecs(0.8);
    
    
    % Clear screen to background color (our 'gray' as set at the
    % beginning):
    Screen('Flip', w);
    
    % Wait a second before starting trial
    WaitSecs(1.000);

    % main staircase loop
    while reversal < totalReversals
        if trialNum == 1
            level = levels(1, end);
        end
        
        % extreme cases
        if trialNum == 26 && (sum(results(:, 3)) < 12) % accuracy at chance
            DrawFormattedText(w, 'Please call in the experimenter', 'center', 'center', white);
            Screen('Flip', w);
            WaitSecs(5);
            Screen('Close', w);
            clc;
            disp(sprintf('\n%s\n', 'Participant performed at or below chance.'));
            ShowCursor
            ListenChar(1);
            plot(results(1:(trialNum - 1), 1), results(1:(trialNum - 1), 2));
            axis([0 (trialNum-1) levelStart levelEnd]);
            title(strcat(graph, ' for Subject #', num2str(subNo)));
            xlabel('Trials')
            ylabel(yaxis);
            fprintf(fid, sprintf('\n%s\n', 'Participant performed at or below chance.'));
            resp = input('Do you want to continue this staircase? 1 for yes, 0 for no: ');
            if isequal(resp, 1)
                HideCursor;
                ListenChar(2);
                screens=Screen('Screens');
                screenNumber=max(screens);
                w = Screen('OpenWindow', screenNumber, black);
                Screen('TextSize', w, 50);
                fprintf(fid, '\nStaircase continued.\n\n');
            else
                extreme = 1;
                break;
            end
        elseif trialNum == 51 && reversal < 4 % getting them all right
            DrawFormattedText(w, 'Please call in the experimenter', 'center', 'center', white);
            Screen('Flip', w);
            WaitSecs(5);
            Screen('Close', w);
            clc;
            disp(sprintf('\n%s\n', 'Participant has very few reversals.'));
            ShowCursor
            ListenChar(1);
            plot(results(1:(trialNum - 1), 1), results(1:(trialNum - 1), 2));
            axis([0 (trialNum-1) levelStart levelEnd]);
            title(strcat(graph, ' for Subject #', num2str(subNo)));
            xlabel('Trials')
            ylabel(yaxis);
            fprintf(fid, sprintf('\n%s\n', 'Participant has very few reversals.'));
            resp = input('Do you want to continue this staircase? 1 for yes, 0 for no: ');
            if isequal(resp, 1)
                HideCursor;
                ListenChar(2);
                screens=Screen('Screens');
                screenNumber=max(screens);
                w = Screen('OpenWindow', screenNumber, black);
                Screen('TextSize', w, 50);
                fprintf(fid, '\nStaircase continued.\n\n');
            else
                extreme = 1;
                break;
            end
        elseif trialNum == 76 % few reversals
            DrawFormattedText(w, 'Please call in the experimenter', 'center', 'center', white);
            Screen('Flip', w);
            WaitSecs(5);
            Screen('Close', w);
            clc;
            disp(sprintf('\n%s\n', 'Staircase has gone on for many trials.'));
            ShowCursor
            ListenChar(1);
            plot(results(1:(trialNum - 1), 1), results(1:(trialNum - 1), 2));
            axis([0 (trialNum-1) levelStart levelEnd]);
            title(strcat(graph, ' for Subject #', num2str(subNo)));
            xlabel('Trials')
            ylabel(yaxis);
            fprintf(fid, sprintf('\n%s\n', 'Staircase has gone on for many trials.'));
            resp = input('Do you want to continue this staircase? 1 for yes, 0 for no: ');
            if isequal(resp, 1)
                HideCursor;
                ListenChar(2);
                screens=Screen('Screens');
                screenNumber=max(screens);
                w = Screen('OpenWindow', screenNumber, black);
                Screen('TextSize', w, 50);
                fprintf(fid, '\nStaircase continued.\n\n');
            else
                extreme = 1;
                break;
            end
        end
        
        if strcmp('LOUD', letters1)
            index = find(levels == level);
            trueAcc = randi(2); % the row the trial is in is its accuracy
            trial = trials{trueAcc, index}; % counterbalanced trials
            
        else % one trial at a time, not preloading entire matrix of trials
            [trial, Fs, trueAcc, filename] = getTrial(level, letters1);
        end
        
        DrawFormattedText(w, prompt, 'center', 'center', white);
        Screen('Flip', w);
        
        % Prepares to play trial
        pahandle = PsychPortAudio('Open', [], [], 0, Fs, 2);
        PsychPortAudio('FillBuffer', pahandle, trial');
        PsychPortAudio('Start', pahandle, [], 0, 1);
        [B0 S1] = WaitForKey([L2; L3], KbIndex);
        if isequal(B0, L2) && (trueAcc == 1) % pressed 1, was correct
            acc = 1;
        elseif isequal(B0, L3) && trueAcc == 2 % pressed 2, was correct
            acc = 1;
        else
            acc = 0;
        end
        PsychPortAudio('Stop', pahandle, [], 0, 1); % Stops the test sound
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        
        fprintf(fid, 'Trial: %s, Level: %s, Filename: %s, Accuracy: %s\n', num2str(trialNum), num2str(level), filename, num2str(acc));
        results(trialNum, :) = [trialNum level acc];
        if acc == 1 && numCorrectAtLevel == (numDown - 1) && level > levelStart
            level = level - stepSize;
            disp(strcat('numCorrectAtLevel: ', num2str(numCorrectAtLevel)));
            numCorrectAtLevel = 0;
            numCorrect = numCorrect + 1;
            DrawFormattedText(w, 'You are correct!', 'center', 'center', white);
            Screen('Flip', w);
        elseif acc == 1 && numCorrectAtLevel == (numDown - 1) && level == levelStart % level doesn't change
            numCorrectAtLevel = 0;
            numCorrect = numCorrect + 1;
            DrawFormattedText(w, 'You are correct!', 'center', 'center', white);
            Screen('Flip', w);
        elseif acc == 1 && numCorrectAtLevel < (numDown - 1)
            if numCorrect == 0 && reversal > 0
                reversals(reversal + 1, 1) = level;
                reversal = reversal + 1;
                disp('Number of reversals increased');
            end
            numCorrect = numCorrect + 1;
            disp(strcat('numCorrectAtLevel: ', num2str(numCorrectAtLevel)));
            numCorrectAtLevel = numCorrectAtLevel + 1;
            DrawFormattedText(w, 'You are correct!', 'center', 'center', white);
            Screen('Flip', w);
        elseif acc == 0 && level < levels(1, end)
            if numCorrect > 0
                reversals(reversal + 1, 1) = level;
                reversal = reversal + 1;
                disp('Number of reversals increased');
            end
            level = level + stepSize;
            numCorrect = 0;
            numCorrectAtLevel = 0;
            DrawFormattedText(w, 'You are incorrect!', 'center', 'center', white);
            Screen('Flip', w);
        else % resp ~= trueAcc && level == levelEnd: level doesn't change
            DrawFormattedText(w, 'You are incorrect!', 'center', 'center', white);
            Screen('Flip', w);
            numCorrect = 0;
            numCorrectAtLevel = 0;
        end
        trialNum = trialNum + 1;
        pause(1);
    end
    % calculate threshold
    threshold = mean(reversals(((totalReversals - reversalAvg)+1):totalReversals));
    if extreme == 1 % one of the three extreme cases
        fprintf(fid, '\n Threshold cannot be calculated for this session because the data is inconclusive.\n');
    else
        fprintf(fid, '\nThreshold for this session: %s dB\n', num2str(threshold));
    end
    
    fprintf(fid,'%s\n','--------------------------------------');
    fprintf(fid,'%s\n',['End of the session: ' datestr(now)]);
    fprintf(fid,'%s\n','--------------------------------------');
    results = results(1:(trialNum - 1), :);
    plot(results(:, 1), results(:, 2));
    axis([0 (trialNum-1) levelStart levelEnd]);
    title(strcat(graph, ' for Subject #', num2str(subNo)));
    xlabel('Trials')
    ylabel(yaxis);
    print(gcf, '-dpng', sprintf('StaircasePlot_%s', num2str(subNo)));
catch
    fclose(fid);
    ShowCursor
    Screen('CloseAll')
    ListenChar(1);
    disp('Something happened');
    psychrethrow(psychlasterror);
    
end

Screen('CloseAll')

save(resultfilename, 'results', 'reversals', 'threshold');
ShowCursor
ListenChar(1);
fclose(fid);

end