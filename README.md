# Photoreceptor pattern analysis FIJI macro

## Contents

- [Overview](#1_overview)
- [Repo Contents](#2_repo-contents)
- [System Requirements](#3_system-requirements)
- [Installation Guide](#4_installation-guide)
- [Software Training](#5_Software-training-for-pixel-and-label-classification)
- [Demo Run](#6_Workflow-for-a-demo-run)

# 1_Overview
This macro intends to analyze the photoreceptor pattern in the retina. It has been applied to human retinal organoids immunostained for Müller glia markers (SLC1A3+RLBP1) and imaged en face.

The following parameters of the pattern are analyzed by the macro:
- Cell classification into 3 types with different sizes
- Number of cells
- Cell sizes (area, in pixels)
- Number of voronoi neighbors
- Nearest neighbor distance (NND)
- Edge cells (touching the image border)

This macro generates the following image files:
- "label_classifier.png": label map showing all detected cells
- "label_map.png": label classifier image showing cell type classification by pseudocoloring
- "NND_map.png"
- "voronoi_neighbors.png"

This macro generates the following data tables:
- "1_cell-types-and-edge-cells.cls": displaying detected cells, cell type identity and whether they are edge cells
- "2_NND.csv": neareast neighbor distance for every detected cell (in pixel)
- "3_area.csv": size (area) for every detected cell (in pixel)
- "4_neighbor-number.xls": number of voronoi neighbors for every cell

# 2_Repo Contents
This repository contains the FIJI macro used for photoreceptor pattern analysis in human retinal organoids (folder "FIJI macro file"). 

In addition, there are demo data (folder "demo") to run the software on a sample input image. In this folder, the software training files are also saved, so the FIJI macro can be directly tested and no own software training on cell detection and classification is required. Meaning section 5 can be skipped and the demo run in section 6 can directly be performed.

# 3_System Requirements
This macro is supported for macOS and Windows. It has been tested on macOS Mojave (10.14), macOS Catalina (10.15) and Windows 10.

# 4_Installation Guide
Install ImageJ or FIJI software: https://imagej.net/downloads.

Install the Weka pixel and label classifier packages via the FIJI update site by selecting the following update sites and re-starting FIJI:
- clij
- clij2
- clijx-assistant

# 5_Software training for pixel and label classification
To train for detection of positive signal, the Weka pixel classifier from the CLIJx-assistant was used; to distinguish between different cell sizes, the Weka label classifier from the CLIJx-assistant was used.

For more information about usage and function of the CLIJx-assistant read here: 
- https://doi.org/10.1101/2020.11.19.386565
- https://clij.github.io/clijx-assistant/

To open the Weka pixel or label classifier, type in "Weka" in the ImageJ/FIJI search window and select:
- Pixel classifier: "Binary Weka Pixel Classifier (CLIJxWEKA, ijm, java)"
- Label classifier: "Weka Label Classifier (CLIJxWEKA, ijm, java)"

About usage of the:
- Pixel classifier: follow the commands in the Log window, otherwise usage is similar to the label classifier (see below) https://clij.github.io/assistant/clijx_weka_pixel_classifier.html
- Label classifier: https://clij.github.io/clijx-assistant/clijx_weka_label_classifier

# 6_Workflow for a demo run
To perform a test run with demo data from our dataset, our pixel and label classifier files can be used and no own software training is required (see section above).
1. To use our classifier files, the files from the GitHub folder "/demo/1_classifier-files" need to be moved to the FIJI program folder on your computer.
2. Copy the GitHub folder "/demo/2_input" to your computer.
3. Open the macro file "HROHT_PhotoreceptorPatternAnalysis.ijm" from the GitHub folder "/FIJI macro file".
4. Adjust the following lines of the macro text:
- Line 43: insert the path of where you saved the GitHub folder "/demo/2_input" on your computer in between the "" signs.
- Line 76: insert the name of the pixel classifier model used. If you want to use our classifier files, insert "pixel_classification_photoreceptor-pattern_Voelkner.model"
- Line 251: insert the name of the label classifier model used. If you want to use our classifier files, insert "label_classification_photoreceptor-pattern_Voelkner.model"
- Line 50: set to "true" if all cells should be included, set to "false" to exclude labels outside the size range indicated in lines 113+114.
5. Start macro by clicking Run. For a single image it should be completed within a few seconds.
- Note: If you get the error message "No Log window found" check whether the indicated path in line 43 is correct or whether any slash or backslash is missing. This is usually the reason.
7. The output files and excel tables will be saved in the same folder that has been used as inout (see step 4).
8. Compare the results with the expected output files in GitHub folder "/demo/3_expected-output". Note that for this expected output data, all cells were included (see step 4, Line 50 comment). The follwing cell type numbers are assigned:
- Type 1+2: large cell type (cones)
- Type 3: small cell type (rods)
