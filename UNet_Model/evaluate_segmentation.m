function [results,allscores]=evaluate_segmentation(folder,segfolder,errfolder)
% scores=evaluate_segmentation(folder,segfolder)
% folder contains jpg images which were segmented
% segfolder is the name of the subfolder under folder which contains
% performed segmentations
% ground_truth_segmentations subfolder should also exist under folder

imext='jpg';
segext='png';


if (~exist(folder,'dir'))
    fprintf('Folder %s does not exist, not doing anything.\n',folder);
    return;
end

D=dir(fullfile(segfolder,sprintf('*.%s',segext)));
Nimg=length(D);
if (Nimg <= 0)
    fprintf('No images with extension %s exist in the folder %s, doing nothing.\n',segext,folder);
    return;
end
k=0;
nogt=0;
noseg=0;
allscores=[];
% these could change later!!
timeconst=0.01; % time constant in the weighted score
pp=2;  % power for precision in weightedscore
rp=5;  % power for recall in weightedscore
%recallweight=0.75; % how much recall is weighted, 1-this for precision
csvFile=fullfile(errfolder,'result',sprintf('%s.csv'));

fidcsv=fopen(csvFile,'w');
fprintf(fidcsv,'group,file,precision,recall,fscore,accuracy,weightedscore,timetaken\n');
art="_mask";

for i=1:length(D)
    % Get the full filename, with path prepended.
    fullFileName = fullfile(segfolder,D(i).name);
    [curfolder, curfilebase, curfileext] = fileparts(fullFileName);
    gtsegFileName = fullfile(folder, sprintf('%s%s.%s',curfilebase,art, segext));
    segFileName = fullfile(segfolder, sprintf('%s.%s',curfilebase, segext));
    errFileName = fullfile(errfolder, sprintf('%s_err.%s',curfilebase, segext));
    timeFileName = fullfile(segfolder, sprintf('%s.%s',curfilebase, 'txt'));
    % Check if files exist.
    if ~exist(gtsegFileName, 'file')
        nogt=nogt+1;
        continue;
    end
    if ~exist(segFileName, 'file')
        noseg=noseg+1;
        continue;
    end
    k=k+1;
    org=imread(fullFileName);
    gtseg=(imread(gtsegFileName));
    seg=(imread(segFileName));
    if(length(size(gtseg))==3)
        gtseg=imbinarize(rgb2gray(gtseg));
    else
        gtseg=imbinarize(gtseg);
    end

    if(length(size(seg))==3)
       seg=imbinarize(rgb2gray(seg));
    else
        seg=(((seg)));
    end
    
    tpimg=seg & gtseg;
    fpimg=seg & ~gtseg;
    tnimg=~seg & ~gtseg;
    fnimg=~seg & gtseg;
    errimg=tnimg*1+fnimg*2+fpimg*3+tpimg*4; % error image showing fn and fp errors as red and blue
    colormap=[0 0 0;1 0 0; 0 0 1; 1 1 1]; % fn=2 is red, fp=3 is blue, tn=1 is black, tp=4 is white
    imwrite(errimg,colormap,errFileName,'png','BitDepth',4);
    tp=sum(tpimg(:));
    fp=sum(fpimg(:));
    %tpfp=sum(seg(:));
    tpfp=tp+fp;
    realp=sum(gtseg(:)); % the ground truth positives
    tn=sum(tnimg(:));
    fn=sum(fnimg(:));
    %tnfn=sum(~seg(:));
    tnfn=tn+fn;
    precision=tp/(tpfp+eps);
    recall=tp/realp;
    accuracy=(tp+tn)/(tpfp+tnfn);
    fscore=2*(precision*recall)/(eps+precision+recall);
    if exist(timeFileName)
        fid=fopen(timeFileName,'r');
        timetaken=str2double(fgetl(fid));
        fclose(fid);
    else
        timetaken=9.99; % by default assume it takes 9.99 seconds per image
    end
    % weighted score which will be used for ranking methods in EE469 project
    %weightedscore=((1-recallweight)*precision+recallweight*recall)*exp(-timeconst*timetaken);
    %weightedscore=min(recall,precision)*exp(-timeconst*timetaken);
    weightedscore=2*(precision^pp*recall^rp)/(precision^pp+recall^rp+eps)*exp(-timeconst*timetaken);
    curscore=[precision recall fscore accuracy weightedscore timetaken];
    fprintf('%s: precision %.2f recall %.2f fscore %.2f accuracy %.2f weightedscore %.2f timetaken %.2f\n',curfilebase,precision,recall,fscore,accuracy,weightedscore,timetaken);
    fprintf(fidcsv,'%s,%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n',segfolder,curfilebase,precision,recall,fscore,accuracy,weightedscore,timetaken);
    allscores(k,:)=curscore;
    results(k).score=curscore;
    results(k).segFileName=segFileName;
end
Nimg=k;
if (nogt>0)
    fprintf('%d of %d images did not have segmentations .\n',nogt,Nimg);
end
if (noseg>0)
    fprintf('%d of %d images did not have segmentations in subfolder %s.\n',noseg,Nimg,segfolder);
end

if (k > 0 && k < Nimg)
    fprintf('Only evaluated for %d of %d images.\n',k,k);
elseif (k==0)
    fprintf('No segmentations found, no evaluation done.\n');
    return;
end

if (size(allscores,1)>0)
    avgscore=mean(allscores);
    fprintf('Average precision %.2f recall %.2f F-score %.2f accuracy %.2f weightedscore %.2f timetaken %.2f over %d files\n',avgscore(1),avgscore(2),avgscore(3),avgscore(4),avgscore(5),avgscore(6),k+1);
    fprintf(fidcsv,'%s,%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n',segfolder,'Avg',avgscore(1),avgscore(2),avgscore(3),avgscore(4),avgscore(5),avgscore(6));
end
fclose(fidcsv);