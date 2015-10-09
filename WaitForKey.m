% Sept. 20 2011
% G. Lemaitre CMU
%
% Waits for the keyboard to change to a target state
% 
% [FinalSate time]=WaitForDaq(Target,KbIndex)



function [FinalState time]=WaitForKey(Target,KbIndex)


if nargin<2
    KbIndex = GetKeyboardIndices('Apple Internal Keyboard / Trackpad');
end

NTargets=size(Target,1);

EXITresp=KbName('q');


stop=0;
while stop==0;
    [KeyIsDown, time, FinalState]=KbCheck(KbIndex);
    %sum(prod(double(repmat(FinalState,NTargets,1)==Target),2))
    if sum(prod(double(repmat(FinalState,NTargets,1)==Target),2))~=0
        
        stop=1;
    end
    if FinalState(EXITresp)==1
         error('There you go');
    end
    WaitSecs(.002);

end

    
