function end_block(window)
    clear PsychHID;
    clear KbCheck;

    RestrictKeysForKbCheck(32);
    
    instructions = {
        'Well done! You completed a part of the task! \n\npress SPACE to continue.', ...
        'Press SPACE when you are ready to begin the next part of task.'
    };
        
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    Screen('TextSize', window, 20);
    Screen('TextFont', window, 'Arial');

    for i = 1:2
        DrawFormattedText(window, instructions{i}, 'center', 'center', [255 255 255]);
        Screen('Flip', window);
        KbStrokeWait;
    end

end