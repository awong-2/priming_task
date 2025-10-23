%% Launch Experiment
% IMPORTANT: CHECK PATHS AND SCREEN SETTINGS BEFORE RUNNING!!
clear all
clear mex

% Define paths - DOUBLE-CHECK!
root_path = '/Users/awong1/Desktop/priming_task/';
prac_path = '/Users/awong1/Desktop/priming_task/Practice/';
output_path = '/Users/awong1/Desktop/priming_task/DATA/';

% Debug mode?
debug = true;

%% Constant settings 
% Opacity settings
globalAlpha = 1;

% Text parameters
textSize = 25;
textFont = 'Arial';
textColor = [255 255 255];

% Cue duration
stimOnset = 0.9; % 900 msec

% Number of trials for each phaseSs
ntrial_main = 336;
ntrial_block = 112;

%% Input participant information
subjectID = input('Enter Subject ID:');

% phases: 1 = Practice; 2 = block 1; 3 = block 2; 4 = block 3
nphase = input('Enter Phase Number:'); 

%% Randomisation
rng(0); % reset seed
rng(subjectID) % seed with subjectID

% Load stims table
main_stim_table = load([root_path '/main_stim_table.mat']);
prac_stim_table = load([prac_path '/prac_stim_table.mat']);

% Randomise
[main_stim_matrix] = rand_main_task(id, ntrials, stim_table);
[prac_matrix] = rand_prac(subjectID, prac_stim_table, prac_path);

%% utils
% Output folder
output_folder = [output_path 'P' num2str(subjectID)];

% Load Fixation, Prompt, Splash screens
[utils_img] = utils();

%% Constant screen settings
Screen('Preference', 'SuppressAllWarnings', 1);
screens = Screen('Screens');

if debug == true
    % For DEBUGGING
    screenNumber = max(screens);
    smallscreen = [0 0 800 800];
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], smallscreen);
else
    % For ACTUAL TESTING
    screenNumber = 1;
    [window,windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);
    HideCursor;
end

%% Task code
while nphase < 5
    %% Practice trials
    if nphase == 1
        welcome(window);

        % Practice
        [prac_results] = prac_trial(ntrial_block, utils_img, prac_stim, globalAlpha, blockID, stimOnset, window);
        save(fullfile(output_folder, ['prac_results_' num2str(subjectID) '.mat']), 'prac_results');

        end_practice(window);

    %% Main Task Block 1
    elseif nphase == 2
        
        mainStim = main_stim_table;
        blockID = 1;
        ntrial_block = ntrial_main/3;
        
        [main_results] = main_trial(ntrial_block, utils_img, mainStim, globalAlpha, globalAlpha2, blockID, ISI, window);
        b1_result = main_results;
        save(fullfile(output_folder, ['b1_result_' num2str(subjectID) '.mat']), 'b1_result');

        end_block(window);
           
    %% Main Task Block 2
    elseif nphase == 3
        
        mainStim = main_stim_table;
        blockID = 2;
        ntrial_block = ntrial_main/3;

        [main_results] = main_trial(ntrial_block, utils_img, mainStim, globalAlpha, globalAlpha2, blockID, ISI, window);
        b2_result = main_results;
        save(fullfile(output_folder, ['b2_result_' num2str(subjectID) '.mat']), 'b2_result');
        end_block(window, instruction_img);

    %% Main Task Block 3
    elseif nphase == 4
        
        mainStim = main_stim_table;
        blockID = 3;
        ntrial_block = ntrial_main/3;
        [main_results] = main_trial(ntrial_block, utils_img, mainStim, globalAlpha, globalAlpha2, blockID, ISI, window);
        b3_result = main_results;
        save(fullfile(output_folder, ['b3_result_' num2str(subjectID) '.mat']), 'b3_result');

        %% Save results
        main_result = [b1_result; b2_result; b3_result];
        save(fullfile(output_folder, ['main_result_' num2str(subjectID) '.mat']), 'main_result');

    end
    nphase = nphase + 1;

end

%% End of experiment
exp_End(window);

%% Shut down experiment
ShowCursor;
sca