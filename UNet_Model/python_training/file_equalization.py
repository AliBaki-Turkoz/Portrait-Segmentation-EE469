# -*- coding: utf-8 -*-
"""
Created on Fri Dec 22 13:13:50 2023

@author: AliBakiTURKOZ
"""

import os
import shutil

# Klasör yollarını tanımla
rgb_folder = 'rgb_images'
segmented_folder = 'segmented_images'
backup_folder = 'backup'

# RGB ve maskelenmiş görüntü dosya uzantıları
rgb_extension = '.jpg'
mask_extension = '_mask.png'

# RGB ve maskelenmiş görüntü listelerini al
rgb_images = [file for file in os.listdir(rgb_folder) if file.endswith(rgb_extension)]
segmented_images = [file for file in os.listdir(segmented_folder) if file.endswith(mask_extension)]

# Eşleşmeyen görüntüleri ve yedekleme klasörünü oluştur
common_images = set([img.replace(rgb_extension, '') for img in rgb_images]) & set([img.replace(mask_extension, '') for img in segmented_images])
os.makedirs(backup_folder, exist_ok=True)

# Eşleşmeyen görüntüleri sil ve yedekleme klasörüne taşı
for img in rgb_images:
    if img.replace(rgb_extension, '') not in common_images:
        shutil.move(os.path.join(rgb_folder, img), os.path.join(backup_folder, img))

for img in segmented_images:
    if img.replace(mask_extension, '') not in common_images:
        shutil.move(os.path.join(segmented_folder, img), os.path.join(backup_folder, img))

# Güncellenmiş görüntü sayılarını yazdır
print(f"Eşleştirilmiş Görüntü Sayısı: {len(common_images)}")
print(f"Kalan Görüntü Sayısı: {len(os.listdir(rgb_folder))}")
print(f"Silinen Görüntü Sayısı: {len(os.listdir(backup_folder))}")
