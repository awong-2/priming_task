function [utils_img] = utils()
    % Store images into a data structure
    utils_img.fixation = imread('utils/fixation.png');
    utils_img.prompt = imread('utils/prompt.png');
    utils_img.splash = imread('utils/splash.png');
end