function [main_stim_matrix] = rand_main_task(id, ntrials, stim_table)
    %% Create template table to hold randomized stimuli matrix
    % Main stim table
    main_stim_matrix = table('Size', [ntrials 13], 'VariableNames', {'subjectID', 'trialID', 'blockID', 'cue', 'target', ...
     'isWord', 'isCongruent', 'cs', 'bin', 'mean_target_cs', 'mean_cue_cs', 'cue_img', 'target_img'}, ...
    'VariableTypes', {'double', 'double', 'double', 'string', 'string', ...
    'double', 'double', 'double', 'double', 'double', 'double', 'cell', 'cell'});
    
    % Template condition trials
    % 2 conditions
    % Conditions CODE: 
    % isWord => Word(=1); Nonword(=0)
    % isCongruent => Congruent(=1); Incongruent(=0)
    ncond_trial = ntrials/2;
    template_cond = table('Size', [ncond_trial 13], 'VariableNames', {'subjectID', 'trialID', 'blockID', 'cue', 'target', ...
     'isWord', 'isCongruent', 'cs', 'bin', 'mean_target_cs', 'mean_cue_cs', 'cue_img', 'target_img'}, ...
    'VariableTypes', {'double', 'double', 'double', 'string', 'string', ...
    'double', 'double', 'double', 'double', 'double', 'double', 'cell', 'cell'});
    
    %% Generate conditions templates 
    % 1_Word 
    wordTrial = template_cond;
    wordTrial.isWord = ones(ncond_trial, 1);

    % 2_Nonword
    nwordTrial = template_cond;

    %% Assign stims to nonword condition
    % Randomize nonword stims
    nonword_rand1 = randperm(ntrials/2);
    nonword_cue = stim_table.NONWORDCUE(nonword_rand1);
    nwcue_img = stim_table.nwcue_img(nonword_rand1);

    nonword_rand2 = randperm(ntrials/2);
    nonword = stim_table.NONWORD(nonword_rand2);
    nwtarget_img = stim_table.nwtarget_img(nonword_rand2);
    

    % Assign to nonword conditon
    nwordTrial.cue = nonword_cue;
    nwordTrial.target = nonword;
    nwordTrial.cue_img = nwcue_img;
    nwordTrial.target_img = nwtarget_img;

    %% Assign stims to word conditions
    % Extract word pairs from stim table
    word_pairs = table(stim_table.CUE, stim_table.TARGET, stim_table.cs, ...
        stim_table.cs_bin, stim_table.mean_target_sim, stim_table.mean_cue_sim, ...
        stim_table.cue_img, stim_table.target_img);
    word_pairs.Properties.VariableNames(1) = "cue";
    word_pairs.Properties.VariableNames(2) = "target";
    word_pairs.Properties.VariableNames(3) = "cs";
    word_pairs.Properties.VariableNames(4) = "bin";
    word_pairs.Properties.VariableNames(5) = "mean_target_cs";
    word_pairs.Properties.VariableNames(6) = "mean_cue_cs";
    word_pairs.Properties.VariableNames(7) = "cue_img";
    word_pairs.Properties.VariableNames(8) = "target_img";

    % Pseudorandomize word pairs in 8s
    rand_idx = 0;
    ini = 1;
    e = 4;

    for i = 1:42
        word_rand(ini:e) = randperm(4) + rand_idx;
        rand_idx = rand_idx + 4;
        ini = ini + 4;
        e = e + 4;
    end

    word_pairs = word_pairs(word_rand, :);

    % Assign to word conditon
    wordTrial.cue = word_pairs.cue;
    wordTrial.target = word_pairs.target;
    wordTrial.cs = word_pairs.cs;
    wordTrial.bin = word_pairs.bin;
    wordTrial.mean_target_cs = word_pairs.mean_target_cs;
    wordTrial.mean_cue_cs = word_pairs.mean_cue_cs;
    wordTrial.cue_img = word_pairs.cue_img;
    wordTrial.target_img = word_pairs.target_img;

    %% Randomize congruency

    rand_incong = randperm(84)';
    rand_cong = randperm(84)' + 84;

    j = 1;
    for i = 1:84
        r1(j) = rand_incong(i);
        r1(j + 1) = rand_cong(i);
        j = j + 2;
    end
    
    wordTrial = wordTrial(r1, :);
    %% Build full stim matrix
    table_idx = 1;
    for i = 1:168
        main_stim_matrix(table_idx, :) = wordTrial(i, :);
        main_stim_matrix(table_idx + 1, :) = nwordTrial(i, :);
        table_idx = table_idx + 2;
    end

    %% Add congruency index
    for i = 1:ntrials
        if main_stim_matrix.bin(i) > 3
            main_stim_matrix.isCongruent(i) = 1;
        elseif main_stim_matrix.bin(i) == 0
            main_stim_matrix.isCongruent(i) = 2;
        end
    end

    %% Pseudorandomize in 4s
    rand_idx = 0;
    ini = 1;
    e = 4;

    for i = 1:84
        stim_rand(ini:e) = randperm(4)' + rand_idx;
        ini = ini + 4;
        e = e + 4;
        rand_idx = rand_idx + 4;
    end

    main_stim_matrix = main_stim_matrix(stim_rand, :);
    %% Add id info
    main_stim_matrix.subjectID = repmat(id, ntrials, 1);
    main_stim_matrix.trialID = (1:ntrials)';
    main_stim_matrix.blockID = [ones(ntrials/3, 1); repmat(2, ntrials/3, 1); repmat(3, ntrials/3, 1)];
end