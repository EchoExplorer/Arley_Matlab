function [soundout] = concatenate(click, echo)

% concatenates a variable number of input sounds
% make sure each sound only has 2 channels (numRows x 2)

soundout = [];

if size(click, 2) ~= 2 || size(echo, 2) ~= 2
    disp('Sound file must have exactly 2 channels');
    return
end
if size(click, 1) < size(echo, 1)
    diff = size(echo, 1) - size(click, 1);
    click = [click', zeros(2, diff)];
    click = click';
elseif size(click, 1) > size(echo, 1)
    diff = size(click, 1) - size(echo, 1);
    echo = [echo', zeros(2, diff)];
    echo = echo';
end
soundout = click + echo;
soundout = soundout';

% check for constructive interference clipping
if (~isempty(find(abs(soundout)>1)))
        clippedsamples=length(find(abs(soundout)>1));
        if clippedsamples > 5
            error('\n\tWarning! This sound now has %1.0f clipped samples!\n\n', clippedsamples);    
        end
end