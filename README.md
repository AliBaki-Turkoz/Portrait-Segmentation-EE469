# Portrait Segmentation (EE469 Image Processing)

Course project for **EE469 Image Processing** (Yeditepe University, Fall 2023), carried out as a two-person team project.

The goal is to separate the person from the background in portrait photographs (binary foreground/background segmentation). Two approaches were compared:

1. **U-Net** (main model): trained in Python/Keras on Google Colab, then imported into MATLAB for inference and evaluation.
2. **Baseline semantic segmentation network**: a small encoder–decoder trained directly in MATLAB.

## Results

Both models were evaluated with the course's MATLAB evaluation script on a separate test set of portrait images (file IDs 02221–02632). Values are averages over the images; the per-image results are in [`results/`](results).

| Model | Test images | Accuracy | Precision | Recall | F-score | Time / image (s) |
|---|---|---|---|---|---|---|
| U-Net | 333 | 0.91 | 0.90 | 0.95 | **0.92** | 0.37 |
| Baseline semantic segmentation | 333* | 0.81 | 0.85 | 0.88 | 0.85 | 0.07 |

\* The baseline was evaluated on 334 images. One ground-truth mask (`02299_mask.png`) is completely empty, which makes recall and F-score undefined (NaN) for that image. The same image was removed from the U-Net evaluation. The baseline averages above are computed from the per-image CSV without the NaN rows; the CSV's own `Avg` row shows NaN for these columns. See [`examples/faulty_ground_truth_02299`](examples/faulty_ground_truth_02299).

In addition, on the Keras side the U-Net reached a **pixel accuracy of 0.948** (binary cross-entropy 0.152) on its own 130-image test split (10 % of the 1,296-image training set).

**Notes on interpreting the results**

- Accuracy and F-score are pixel-level measures. Because a large part of each image is background, accuracy alone overstates quality; F-score is the more informative number.
- Image IDs in the training notebook's recorded outputs go up to the 021xx range, and the test images are 02221–02632, so the test set looks separate from the training data. The full training file list was not saved, so this cannot be fully verified.
- For the MATLAB baseline, the contents of the training folder (`rgb_images_for_semantic`) were not saved either, so it is not known whether any test images were in it.
- The original folder for the baseline was named "Dilated Convolutions", but the network in the code uses ordinary (non-dilated) convolutions. It was renamed to `Semantic_Segmentation_Baseline` to avoid confusion.

## Examples

[`examples/`](examples) contains three test images with low, median and high U-Net F-score:

| Image | U-Net F-score | Baseline F-score |
|---|---|---|
| 02339 | 0.98 | 0.94 |
| 02458 | 0.94 | 0.84 |
| 02550 | 0.85 | 0.92 |

Each folder holds the input image (`image.jpg`), the ground truth (`ground_truth.png`), the U-Net and baseline predictions, and the U-Net error map.

## U-Net model

- Input 256×256×3, four encoder blocks (32→256 filters, each two 3×3 convolutions with batch normalization), a 512-filter bottleneck, four decoder blocks with transposed convolutions and skip connections, and a 1×1 sigmoid output. About 7.8 M parameters.
- Data: 1,296 portrait images with masks, split 1,037 / 129 / 130 (train / validation / test) with seed 69.
- Training: Adam with exponential learning-rate decay (initial 1e-3, decay 0.87 every 200 steps), batch size 32, binary cross-entropy, up to 40 epochs with early stopping on validation loss (stopped at epoch 30).
- Augmentation (imgaug): horizontal flip, brightness and contrast changes, Gaussian noise, pixel dropout.
- For MATLAB, the predicted map is thresholded at 0.5 and resized back to the original 800×600 resolution.

## Repository structure

```
UNet_Model/
  python_training/EE469_Project.ipynb   # Keras U-Net training (Google Colab)
  python_training/file_equalization.py  # moves images that have no matching mask to a backup folder
  model_best.h5                          # trained Keras U-Net
  Unet_Model_2.mat                       # the same network imported into MATLAB
  UNet_Segmentation.m                    # runs the U-Net on a folder of images
  main_segmentation.m                    # segmentation + evaluation pipeline (entry point)
  perform_segmentation.m, evaluate_segmentation.m
Semantic_Segmentation_Baseline/
  Semantic_Segmentation.m                # trains the baseline network in MATLAB
  semantic.mat                           # trained baseline network
  main_segmentation.m, perform_segmentation.m, evaluate_segmentation.m
results/                                 # per-image metrics on the test set (CSV)
examples/                                # a few input / ground truth / prediction samples
```

## How to run

The dataset is not included in this repository. Put the images in a `data/` folder next to the script you want to run:

```
UNet_Model/data/rgb_images/          # test images (.jpg)
UNet_Model/data/segmented_images/    # ground-truth masks (<id>_mask.png)
```

Then run `main_segmentation.m` in MATLAB (Deep Learning Toolbox; the Keras importer support package is needed for `UNet_Segmentation.m`). Predictions are written to `outputs/masks` and per-image error maps and metrics to `outputs/err`. The baseline uses the same layout inside `Semantic_Segmentation_Baseline/`.

The training notebook reads the data from Google Drive (`/content/drive/MyDrive/EE469_Project`, with `rgb_images/` and `segmented_images/` subfolders); change `directory` in the notebook to point to your own copy.

## Tag

`v1.0-course-submission` marks the state of the project as submitted for the course.
