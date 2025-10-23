function [main_results] = main_trial(ntrial_block, utils_img, mainStim, globalAlpha, blockID, stimOnset, window)

% TODO: CHECK ASCII CODE FOR "LEFT" AND "RIGHT" KEYS, DISABLE "UP" & "DOWN"

%% Load stimuli
    
    % Identify block based on blockID
    if blockID == 1
        block_stim = mainStim(mainStim.blockID == 1, :);
    elseif blockID == 2
        block_stim = mainStim(mainStim.blockID == 2, :);
    elseif blockID == 3
        block_stim = mainStim(mainStim.blockID == 3, :);
    end

    % Get stimName, cue, target, word/non-word conditions
    subjectID = block_stim.subjectID(1);
    cue_name = block_stim.cue;
    target_name = block_stim.target;
    cs = block_stim.cs;
    bin = block_stim.bin;
    mean_target_cs = block_stim.mean_target_cs;
    mean_cue_cs = block_stim.mean_cue_cs;
    cue = block_stim.cue_img;
    target = block_stim.target_img;
    isCongruent = block_stim.isCongruent;
    isWord = block_stim.isWord;

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
    main_results = table('Size', [ntrial_block 16], ...
        'VariableTypes', {'double','double', 'double', 'double', 'double', 'double',...
         'string', 'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'},...
        'VariableNames', {'subjectID', 'trialID', 'blockID','stimOnset', 'isWord', 'isCongruent', ...
        'cue', 'target', 'cs', 'bin', 'mean_target_cs', 'mean_cue_cs', 'ldt_correct', 'rt', 'missed_trial', 'key_pressed'});
    
    %% Constants to initate loop
    flipInterval = Screen('GetFlipInterval', window);
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
                    main_results.key_pressed(i) = 1;
                    main_results.rt(i) = time - LDT_timer; 
                elseif key == "right" % NoWord
                    key_pressed = 0;
                    main_results.key_pressed(i) = 0;
                    main_results.rt(i) = time - LDT_timer; 
                elseif key == "esc" % Quit Task
                    main_results.key_pressed(i) = 2;
                    ShowCursor;
                    sca
                    break;
                end

                 %% Compute choice outcome 
                % Word + Left key = correct choice
                if key_pressed == 1 && isWord(i) == 1 
                    main_results.ldt_correct(i) = 1;
                    break;
                % Nonword + Right key = correct choice
                elseif key_pressed == 0 && isWord(i) == 0
                    main_results.ldt_correct(i) = 1;
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
                main_results.missed_trial(i) = 1;
                main_results.rt(i) = NaN;
                WaitSecs(0.5);
                break;
            end

        end   

        %% Update trial data in results table
        main_results.subjectID(i) = subjectID;
        main_results.trialID(i) = (i);
        main_results.blockID(i) = blockID;
        main_results.stimOnset(i) = stimOnset*(100);
        main_results.isWord(i) = isWord(i);
        main_results.isCongruent(i) = isCongruent(i);
        main_results.cue(i) = cue_name(i);
        main_results.target(i) = target_name(i);
        main_results.cs(i) = cs(i);
        main_results.bin(i) = bin(i);
        main_results.mean_target_cs(i) = mean_target_cs(i);
        main_results.mean_cue_cs(i) = mean_cue_cs(i);
    end
end