function welcome(window)
    clear PsychHID;
    clear KbCheck;

    RestrictKeysForKbCheck(32);
    
    instructions = {
        'Welcome to the experiment!\n\nPress SPACE to continue.', ...
        'In this experiment, you will complete a task responding to words.\n\nPress SPACE to continue.', ...
        'On each trial, you will see a word.\n\nAfter the word, a white box will appear,\n\nfollowed by a NEW word inside the box.\n\nWhen you see the NEW word in the white box:\n\nPress LEFT if it is an English word\n\nPress RIGHT if it is a fake word.\n\nPress SPACE to continue.', ...
        'We will start with some practice trials.\n\nPress SPACE to continue.', ...
        'Press SPACE to start the task.'
    };
    
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    Screen('TextSize', window, 20);
    Screen('TextFont', window, 'Arial');

    for i = 1:5
        DrawFormattedText(window, instructions{i}, 'center', 'center', [255 255 255]);
        Screen('Flip', window);
        KbStrokeWait;
    end
    
end