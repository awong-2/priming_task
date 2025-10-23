function [prac_results] = prac_trial(ntrial_block, utils_img, prac_stim, globalAlpha, blockID, stimOnset, window)

% TODO: CHECK ASCII CODE FOR "LEFT" AND "RIGHT" KEYS, DISABLE "UP" & "DOWN"

%% Load stimuli

    % Get stimName, cue, target, word/non-word conditions
    subjectID = prac_stim.subjectID(1);
    cue_name = prac_stim.cue;
    target_name = prac_stim.target;
    cue = prac_stim.cue_img;
    target = prac_stim.target_img;
    isCongruent = prac_stim.isCongruent;
    isWord = prac_stim.isWord;

    %% Prepare constant stims for PTB-3 presentation
    fixation = utils_img.fixation;
    prompt = utils_img.prompt;
    splash = utils_img.splash;

    %% PTB-3 Make Texture
    fixation = Screen('MakeTexture', window, fixation);
    prompt = Screen('MakeTexture', window, prompt);
    splash = Screen('MakeTexture', window, splash);
    
    for i = 1 : ntrial_block
        cue_img(i) = Screen('MakeTexture', window, cue{i});
        target_img(i) = Screen('MakeTexture', window, target{i});
    end

    %% Define response timing threshold
    choiceTime = 2.5; % choice interval (seconds)
    
    %% Create data table
    prac_results = table('Size', [ntrial_block 12], ...
        'VariableTypes', {'double','double', 'double', 'double', 'double', 'double',...
         'string', 'string', 'double', 'double', 'double', 'double'},...
        'VariableNames', {'subjectID', 'trialID', 'blockID','stimOnset', 'isWord', 'isCongruent', ...
        'cue', 'target', 'ldt_correct', 'rt', 'missed_trial', 'key_pressed'});
    
    %% Constants to initate loop
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);

    %% Trial loop
    for i = 1:ntrial_block
       
        RestrictKeysForKbCheck([37,39, 27]); % Check ASCII for UP and DOWN key

        %% Fixation
        Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        Screen('DrawTexture', window, fixation, [], [], [], [], 0.2);
        Screen('Flip', window);
        WaitSecs(0.5);
    
        %% Presentation #1 
        Screen('DrawTexture', window, cue_img(i), [], [], [], [], globalAlpha);
        Screen('Flip', window);
        WaitSecs(stimOnset);
        
        %% Choice
        % Clear keyboard events
        FlushEvents('KeyDown');

        % Display Visual Warning (WHITE BOX)
        Screen('DrawTexture', window, prompt, [], [], [], [], globalAlpha);
        Screen('Flip', window);
        WaitSecs(0.5); % prompt duration = 500msec
        
        % Display target
        Screen('DrawTexture', window, prompt, [], [], [], [], globalAlpha);
        Screen('DrawTexture', window, target_img(i), [], [], [], [], globalAlpha);
        Screen('Flip', window);

       % Wait for keyboard response
        LDT_timer = GetSecs;
        LDT_time = tic;

        while true
            [keyIsDown, time, keyCode] = KbCheck;

            if keyIsDown
                key = KbName(keyCode);
               
                if key == "left" %  Word
                    key_pressed = 1;
                    prac_results.key_pressed(i) = 1;
                    prac_results.rt(i) = time - LDT_timer; 
                elseif key == "right" % NoWord
                    key_pressed = 0;
                    prac_results.key_pressed(i) = 0;
                    prac_results.rt(i) = time - LDT_timer; 
                elseif key == "esc" % Quit Task
                    prac_results.key_pressed(i) = 2;
                    ShowCursor;
                    sca
                    break;
                end

                 %% Compute choice outcome 
                % Word + Left key = correct choice
                if key_pressed == 1 && isWord(i) == 1 
                    prac_results.ldt_correct(i) = 1;
                    break;
                % Nonword + Right key = correct choice
                elseif key_pressed == 0 && isWord(i) == 0
                    prac_results.ldt_correct(i) = 1;
                    break;
                % NonWord + Left key = incorrect choice
                elseif key_pressed == 1 && isWord(i) == 0
                    break;
                % Word + Right key = incorrect choice
                elseif key_pressed == 0 && isWord(i) == 1
                    break;                    
                end
            end

            if toc(LDT_time) > choiceTime
                Screen('DrawTexture', window, splash, [], [], [], [], globalAlpha);
                Screen('Flip', window);
                prac_results.missed_trial(i) = 1;
                prac_results.rt(i) = NaN;
                WaitSecs(0.5);
                break;
            end

        end   

        %% Update trial data in results table
        prac_results.subjectID(i) = subjectID;
        prac_results.trialID(i) = (i);
        prac_results.blockID(i) = blockID;
        prac_results.stimOnset(i) = stimOnset*(100);
        prac_results.isWord(i) = isWord(i);
        prac_results.isCongruent(i) = isCongruent(i);
        prac_results.cue(i) = cue_name(i);
        prac_results.target(i) = target_name(i);
    end
end