# Overview
...

# Repo Contents
...

# System Requirements
This macro is supported for macOS and Windows. It has been tested on macOS Mojave (10.14), macOS Catalina (10.15) and Windows 10.

# Installation Guide
Install ImageJ or FIJI software: https://imagej.net/downloads.

Install the Weka pixel and label classifier packages via the FIJI update site by selecting the following update sites and re-starting FIJI:
- clij
- clij2
- clijx-assistant

# Software training for pixel and label classification
To train for detection of positive signal, the Weka pixel classifier from the CLIJx-assistant was used; to distinguish between different cell sizes, the Weka label classifier from the CLIJx-assistant was used.

For more information about usage and function of the CLIJx-assistant read here: 
- https://doi.org/10.1101/2020.11.19.386565
- https://clij.github.io/clijx-assistant/

To open the Weka pixel or label classifier, type in "Weka" in the ImageJ/FIJI search window and select:
- Pixel classifier: "Binary Weka Pixel Classifier (CLIJxWEKA, ijm, java)"
- Label classifier: "Weka Label Classifier (CLIJxWEKA, ijm, java)"

About usage of the:
- Pixel classifier: follow the commands in the Log window, otherwise usage is similar to the label classifier (see below)
- Label classifier: https://clij.github.io/clijx-assistant/clijx_weka_label_classifier

# Workflow for a demo run
To perform a test run with demo data from our dataset, our pixel and label classifier files can be used and no own software training is required (see section above).
1. To use our classifier files, the files from the GitHub folder /demo/1_classifier-files need to be moved to the ImageJ/FIJI program folder on your computer.
2. Copy the GitHub folder /demo/2_input to your computer.
3. Open the macro file "HROHT_PhotoreceptorPatternAnalysis.ijm" from the GitHub folder /FIJI macro file.
4. Adjust the following lines of the macro text:
- Line 43: insert the path of where you saved the GitHub folder /demo/2_input on your computer in between the "" signs.
- Line 76: insert the name of the pixel classifier model used. If you want to use our classifier files, insert "pixel_classification_photoreceptor-pattern_Voelkner.model"
- Line 251: insert the name of the label classifier model used. If you want to use our classifier files, insert "label_classification_photoreceptor-pattern_Voelkner.model"
- Line 50: set to "true" if all cells should be included, set to "false" to exclude labels outside the size range indicated in lines 113+114.
5. Start macro by clicking Run.
6. The output files and excel tables will be saved in the same folder that has been used as inout (see step 4).
7. Compare the results with the expected output files in GitHub folder /demo/3_expected-output. Note that for this expected output data, all cells were included (see step 4, Line 50 comment).


