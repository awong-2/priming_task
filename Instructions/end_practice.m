function end_practice(window)
    clear PsychHID;
    clear KbCheck;

    RestrictKeysForKbCheck(32);
    
    instructions = {
        'Thank you for completing the practice!\n\npress SPACE to continue.', ...
        'Press SPACE when you are ready to begin part 1 of the task.'
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