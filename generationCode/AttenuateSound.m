function [ soundout ] = AttenuateSound( soundin, att_dB )

    % attenuates or amplifies input sound by input dB

    ratio = 10^(att_dB/20);
    soundout = ratio*soundin;
    if (~isempty(find(abs(soundout)>1)))
        clippedsamples=length(find(abs(soundout)>1));
        error('\n\tWarning! This sound has now %1.0f clipped samples!\n\n', clippedsamples);
    end
end