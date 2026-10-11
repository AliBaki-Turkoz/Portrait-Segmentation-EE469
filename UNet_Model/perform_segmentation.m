function res=perform_segmentation(folder,segfolder,model)
% res=perform_segmentation(folder,segfolder)
% perform very simple segmentaiton using matlab's built in functions
% segfolder is the subfolder within folder to which we write the
% segmentation files, folder should contain jpg images to be segmented
imext1='JPG';
imext='jpg';
segext='png';

if (~exist(folder,'dir'))
    fprintf('Folder %s does not exist, not doing anything.\n',folder);
    return;
end

D=dir(fullfile(folder,sprintf('*.%s',imext1)));
if (length(D) <= 0)
    fprintf('No %s images exist in the folder %s, doing nothing.\n',imext1,folder);
    return;
end

if (~exist(fullfile(segfolder),'dir'))
    mkdir(segfolder);
end

for i=1:length(D)
    fullFileName = fullfile(folder,D(i).name);
    [curfolder, curfilebase, curfileext] = fileparts(fullFileName);
    segFileName = fullfile(segfolder, sprintf('%s.%s',curfilebase, segext));
    timeFileName = fullfile(segfolder, sprintf('%s.%s',curfilebase, 'txt'));
    % we just overwrite files for now
    % Check if files exist.
    %if exist(segFileName, 'file')
    %    errorMessage = sprintf('Error: %s exists in given folder.', segFileName);
    %    disp(errorMessage);
    %    continue;
    %end
    org=imread(fullFileName); % original image
    [x,y, channel]=size(org);
        if channel ~=3  
        new_image=zeros([x,y, channel]);
        new_image(:,:,1)=image;
        new_image(:,:,2)=image;
        new_image(:,:,3)=image;
        org=new_image;
        end
        


    tic; % start timer
    %% Write your function name !!!
    C=imresize(org,[256,256]);
    C=predict(model,C);
    C=C(:,:,1)>=0.50;
    C=imresize(C,[800,600]);
    seg=C;
    
   %%
    timetaken=toc; % stop timer
%     seg=imbinarize(rgb2gray(seg));
    imwrite(seg,segFileName,'png','BitDepth',1); % write result in segfolder
    fid=fopen(timeFileName,'w'); % open file for writing time
    fprintf(fid,'%.5e',timetaken); % write time taken
    fclose(fid);
end

end