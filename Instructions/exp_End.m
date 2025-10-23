function exp_End(window)
    clear PsychHID;
    clear KbCheck;

    RestrictKeysForKbCheck(32);
    
    instructions = {
        'Well done, you completed the task!\n\nThank you for participating in the experiment!'
    };
        
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    Screen('TextSize', window, 20);
    Screen('TextFont', window, 'Arial');

    DrawFormattedText(window, instructions, 'center', 'center', [255 255 255]);
    Screen('Flip', window);
    KbStrokeWait;
end