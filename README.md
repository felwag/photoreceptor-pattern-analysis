# Overview
...

# Repo Contents
...

# System Requirements
## Hardware Requirements
...
## Software Requirements
This macro is supported for macOS and Windows. It has been tested on macOS Mojave (10.14), macOS Catalina (10.15) and Windows 10.

# Installation Guide
Install ImageJ or FIJI software: https://imagej.net/downloads.

Install the Weka pixel and label classifier packages via the FIJI update site by selecting the following update sites and re-starting FIJI:
- clij
- clij2
- clijx-assistant

# Workflow for a demo run
1. To perform a test run with demo data from our dataset, the classifier files (.model files) from the GitHub folder /demo/1_classifier-files need to be moved to the ImageJ/FIJI program folder on your computer.
2. Copy the GitHub folder /demo/2_input to your computer.
3. Open the macro file "HROHT_PhotoreceptorPatternAnalysis.ijm" from the GitHub folder /FIJI macro file.
4. Adjust the following lines of the macro text:
- line 43: insert the path of where you saved the GitHub folder /demo/2_input on your computer in between the "" signs.
- line 76: insert the name of the pixel classifier model used. If you want to use our classifier files, insert "pixel_classification_photoreceptor-pattern_Voelkner.model"
- line 251: insert the name of the label classifier model used. If you want to use our classifier files, insert "label_classification_photoreceptor-pattern_Voelkner.model"
- line 50: set to "true" if all cells should be included, set to "false" to exclude labels outside the size range indicated in lines 113+114.
5. Start macro by clicking Run.
6. The output files and excel tables will be saved in the same folder that has been used as inout (see step 4).
7. Compare the results with the expected output files in GitHub folder /demo/3_expected-output.

# Macro Adjustments
- line 43: insert the path of where the input files are saved
- 
