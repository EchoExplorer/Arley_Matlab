function [] = generateLevels(level, angle)

% first for loop: generate echoes for clicks at different angles/distances
% make sure you generate both positive and negative angles!
% second and third for loops: generate trials based on clicks
%
% if degree < 0: board is on the left
% if degree > 0: board is on the right
%
% When generating clicks: 
% When generating trials: only generate positive angles!

ild = 1; % 1 if you want to generate with ILDs; 0 if not

wavDir = '../WAVfiles/clicks/normalized';
file1 = 'LRnorm_mc986_**.wav';

folder1 = dir(strcat(wavDir, file1));
levelStart = 0;
levelEnd = 0;
stepSize = 1;
distance = 1.2192; % 4 feet

% generate clicks
for file = folder1'
    if ~strcmp(file.name, '.') && ~strcmp(file.name, '..') && ~strcmp(file.name, '.DS_Store')
        generateArtificial(file.name, levelStart, levelEnd, stepSize, angle, distance, ild);
    end
end

end

