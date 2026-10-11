% IMPORTANT TO CHANGE THIS PART
% CHANGE THIS PART
% you need to change this datafolder to the one on your computer
% this datafolder must contain the subfolder titled
% ground_truth_segmentations which contains binary segmentation ground truths in
% png format of each jpg image, in the segmentation file, the 1's indicate
% foreground and 0's indicate background pixels.
root = fileparts(mfilename('fullpath'));  % folder of this script
load(fullfile(root, 'Unet_Model_2.mat'))

datafolder_rgb    = fullfile(root, 'data', 'rgb_images');
datafolder_mask   = fullfile(root, 'data', 'segmented_images');   % ground truth
datafolder_mymask = fullfile(root, 'outputs', 'masks');          % predictions
datafolder_err    = fullfile(root, 'outputs', 'err');
if ~exist(datafolder_err, 'dir'), mkdir(datafolder_err); end

% to perform automatic segmentation, this step should write a subfolder
% with name groupname which will contain png format segmentations in datafolder
perform_segmentation(datafolder_rgb,datafolder_mymask,model);
% to do evaluation of the performed segmentations
evaluate_segmentation(datafolder_mask,datafolder_mymask,datafolder_err);