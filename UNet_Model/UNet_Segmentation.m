%% ANA KOD Yedek (ilk modelde çalışıyor)
clear all
close all
clc

% Görüntülerin bulunduğu klasörü belirtin
root = fileparts(mfilename('fullpath'));  % folder of this script
inputFolder = fullfile(root, 'data', 'rgb_images');
outputFolder = fullfile(root, 'outputs', 'output_images_Unet');
if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end

% Klasördeki tüm görüntü dosyalarını alın
imageFiles = dir(fullfile(inputFolder, '*.jpg'));

% Eğitilmiş modeli yükleyin
model = importKerasNetwork(fullfile(root, 'model_best.h5'));

threshold = 0.5;

% Görüntülerin üzerinde döngü
for i = 1:length(imageFiles)
    % Görüntüyü yükle
    imagePath = fullfile(inputFolder, imageFiles(i).name);
    image = imread(imagePath);
    grayimg = im2gray(image);

    % Görüntüyü yeniden boyutlandır
    resized_image = imresize(image, [256, 256]);

    %Eğer model_best kullanacaksak bunu commend yapmamız gerekiyor.
    %resized_image=resized_image/255;

   % Görüntü RGB ise
    if size(resized_image, 3) == 3
        disp(['RGB Image: ' imageFiles(i).name]);
        processed_image = predict(model, resized_image);
    else
        disp(['Grayscale Image: ' imageFiles(i).name]);
        % Eğer Görüntü grayscale ise, RGB'ye dönüştürür
        rgbImg = cat(3, resized_image, resized_image, resized_image); % Grayscale'i RGB'ye dönüştürme
        % Burada RGB görüntüyü modelle işler
        processed_image = predict(model, rgbImg);
    end
     %Treshold uygula
    binary_image = processed_image > threshold;

    % İşlenmiş görüntüyü orijinal boyuta ayarla
    processed_image_resized = imresize(binary_image, size(grayimg));
    
    % İşlenmiş görüntüyü başka bir klasöre kaydet
     [~, name, ~] = fileparts(imageFiles(i).name);
    outputImagePath = fullfile(outputFolder, [name '_processed.png']); % PNG uzantısı
    imwrite(processed_image_resized, outputImagePath);

    close all;
end