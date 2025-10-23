function [prac_matrix] = rand_prac(subjectID, prac_stim_table, prac_path)

    % Create table to hold stim
    prac_matrix = table('Size', [24 9], 'VariableNames', {'subjectID', 'trialID', 'blockID', ...
        'cue', 'target','isWord', 'isCongruent', 'cue_img', 'target_img'}, ...
    'VariableTypes', {'double', 'double',  'double', 'string', 'string', 'double', ...
    'double', 'cell', 'cell'});
    
    % Create experiment conditons
    % congruent, incongruent, nonword
    ord1 = [1; 1; 0; 0; 2; 2];
    ord2 = [1; 1; 0; 0; 2; 2];
    mixed = [ord1; ord2];
    prac_matrix.isCongruent = [ord1; ord2; mixed];
    
    % Load stim imgs
    targetimg = cell(6,1);
    cueimg = cell(6,1);
    nonwordimg = cell(6,1);
    
    for i = 1:6
        targetimg{i} = imread([prac_path 'target/' num2str(i) '.png']);
        cueimg{i} = imread([prac_path 'cue/' num2str(i) '.png']);
        nonwordimg{i} = imread([prac_path 'nonword/' num2str(i) '.png']);
    end
    
    con_cue = [prac_stim_table.Cue(1:2); prac_stim_table.Cue(5:end); prac_stim_table.Cue(3:4)];
    con_target = [prac_stim_table.Target(1:2); prac_stim_table.Target(3:4); prac_stim_table.Nonword(5:6)];
    con_targetimg = {targetimg{1:4}, nonwordimg{5:6}}';
    con_word = [1; 1; 1; 1; 0; 0];
    
    uncon_cue = [prac_stim_table.Cue(3:4); prac_stim_table.Cue(1:2); prac_stim_table.Cue(5:end)];
    uncon_target = [prac_stim_table.Target(3:4); prac_stim_table.Target(5:end); prac_stim_table.Nonword(1:2)];
    uncon_targetimg = {targetimg{3:6}, nonwordimg{1:2}}';
    uncon_word = [1; 1; 1; 1; 0; 0];
    
    con_cueimg = {cueimg{1:2}, cueimg{5:6}, cueimg{3:4}}';
    uncon_cueimg = {cueimg{3:4}, cueimg{1:2}, cueimg{5:6}}';
    
    mixed_cue = [con_cue; uncon_cue];
    mixed_target = [con_target; uncon_target];
    mixed_targetimg = vertcat(con_targetimg, uncon_targetimg);
    mixed_cueimg = vertcat(con_cueimg, uncon_cueimg);
    mixed_word = [con_word; uncon_word];
    
    prac_matrix.cue = [con_cue; uncon_cue; mixed_cue];
    prac_matrix.target = [con_target; uncon_target; mixed_target];
    prac_matrix.cue_img = [con_cueimg; uncon_cueimg; mixed_cueimg];
    prac_matrix.target_img = [con_targetimg; uncon_targetimg; mixed_targetimg];
    prac_matrix.isWord = [con_word; uncon_word; mixed_word];
    prac_matrix.subjectID = repmat(subjectID, 24, 1);
    prac_matrix.trialID = (1:24)';

    % Randomization
    p1rand = randperm(6)';
    p2rand = randperm(6)' + 6;
    p3rand = randperm(12)' + 12;
    prac_rand = [p1rand; p2rand; p3rand];
    prac_matrix = prac_matrix(prac_rand, :);
end
