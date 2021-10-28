// This script has been originally used for photoreceptor patterning analysis of human retinal organoids 
// Organoids were immunostained before for SLC1A3+RLBP1 and imaged en face at the level of the outer limiting membrane
// For this macro, images were manually thresholded before
// To make this script run in Fiji, please activate the clij and clij2 update sites in your Fiji installation. 
// Read more: https://clij.github.io 
// Generator version: 0.4.2.2
// before you run this macro, you have to train the Weka pixel and label classifier to recognize your cells and classify them to a
// specific cell type.
// Read more: https://clij.github.io/assistant/clijx_weka_pixel_classifier.html 
// Read more: https://clij.github.io/assistant/clijx_weka_label_classifier.html 
//
// Authors: Felix Wagner (felix.wagner@dzne.de), Robert Haase
// January 2021
// License: BSD3
//
// Copyright 2021 Felix Wagner, Center for Regenerative Therapies TU Dresden (CRTD)
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following 
// conditions are met:
// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
// in the documentation and/or other materials provided with the distribution.
// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products 
// derived from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS 
// OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
// OF SUCH DAMAGE.
//
// ------------------------------------------------------------------------------------------------------------------

// Initiate GPU
run("Close All");
run("Clear Results");
roiManager("reset");
run("CLIJ2 Macro Extensions", "cl_device=");

// Insert the origin of your input folder in between the ““ signs
folder="";

//Limits results to 2 decimal places
run("Set Measurements...", "area area_fraction limit redirect=None decimal=2");

// Set to true if all cells should be included, set to false if small cells should be removed from the analysis and processing ; 
// see "exclude labels outside range" part
analyze_all=true;

// Loop to process all tif files within a folder
fileList = getFileList(folder);
numFiles = lengthOf(fileList);

for (i=0;i<lengthOf(fileList);i++){
    file = fileList[i];

	if (endsWith(file, "tif")) {

		// Load image from disc 
		print(folder + file);
		open(folder + file);
		image1 = getTitle();
		Ext.CLIJ2_push(image1);
		
		// Copy
		Ext.CLIJ2_copy(image1, image2);
		Ext.CLIJ2_release(image1);
		Ext.CLIJ2_pull(image2);
		
		/* # Binary Weka Pixel Classifier */
		features = "original gaussianblur=1 gaussianblur=5 sobelofgaussian=1 sobelofgaussian=5";
			
		// add the name of your classification model file in between the ““ signs
		modelfilename = "";
		Ext.CLIJx_binaryWekaPixelClassifier(image2, image3, features, modelfilename);
		Ext.CLIJ2_release(image2);
		
		Ext.CLIJ2_pull(image3);
		
		/*  # Opening Box */
		number_of_erotions_and_dilations = 2;
		Ext.CLIJ2_openingBox(image3, image4, number_of_erotions_and_dilations);
		Ext.CLIJ2_release(image3);
		
		Ext.CLIJ2_pull(image4);
		
		/* # Connected Components Labeling Box */
		Ext.CLIJ2_connectedComponentsLabelingBox(image4, all_labels);
		Ext.CLIJ2_release(image4);
		
		Ext.CLIJ2_pull(all_labels);
		run("glasbey_on_dark");

		// Display label IDs on the connected components labeling image
		roiManager("reset");
		Ext.CLIJ2_pullLabelsToROIManager(all_labels);
		Ext.CLIJ2_pull(all_labels);
		roiManager("Show All with labels");
		run("glasbey_on_dark");
		run("Flatten");
		
		saveAs("PNG", folder + file + "_label_map.png");
		roiManager("reset");

		// else function is active if "analyze_all" is set to false above which means small cells will be removed before // analysis
		if (analyze_all) {
			labels_corrected_size=all_labels;
		} 
		else {
			/* # Exclude Labels Outside Size Range */
			minimum_size = 300.0;
			maximum_size = 6000.0;
			Ext.CLIJx_excludeLabelsOutsideSizeRange(all_labels, labels_corrected_size, minimum_size, m	aximum_size);
			Ext.CLIJ2_pull(labels_corrected_size); 
			run("glasbey_on_dark");
		}
		
		
		/* # Draw average distance of n nearest neighbors map */
		// Insert the number of neighbors that should be analyzed and plotted below:
		n = 1.0;
		Ext.CLIJx_averageDistanceOfNClosestNeighborsMap(labels_corrected_size, image7, n);
		Ext.CLIJ2_pull(image7);
		
		//Distances are shown in pixels, the colors range between these two numbers:
		setMinAndMax(10, 90);
		run("Green Fire Blue");
		run("Calibration Bar...", "location=[Upper Right] fill=White label=Black number=5 decimal=0 font=12 zoom=1 overlay");
		
		/* # Exclude all labels/cells on the displayed image (not the results table) that cross the image border */
		Ext.CLIJ2_excludeLabelsOnEdges(labels_corrected_size, labels_without_edges);
		
		/* Measure average distance of all */
		run("Clear Results");
		Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(image7, labels_corrected_size);
		
		// Sets the "background label" as 0, means the first row with the cell#0 needs to be removed for further analysis!
		// Important: "MEAN_INTENSITY" is only the column label here, it does not measure intensities but 
		// distances!
		setResult("MEAN_INTENSITY", 0, 0);

		// Measurement of center to center distances
		// Renaming of the "MEAN_INTENSITY" column into the proper name
		Ext.CLIJ2_pushResultsTableColumn(distance_vector, "MEAN_INTENSITY");
		Table.renameColumn("MEAN_INTENSITY", "Average_Distance_of_" + n + "_neighbors");

		
		// remove all columns but one
		headings = split(Table.headings(), "	");
		for (i = 0; i < lengthOf(headings); i++) {
			column_name = headings[i];
			if (column_name != "Average_Distance_of_" + n + "_neighbors" && column_name != "IDENTIFIER" && column_name != " ") {
				Table.deleteColumn(column_name);
			}
		}
	
		// Save table as csv file in the same folder 
		Table.save(folder + file + "_2_NND.csv");

		// The following part creates another table that only displays the cell areas
			//* Measure average distance of all */
			run("Clear Results");
			Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(image7, labels_corrected_size);
		
			// Sets the "background label" as 0, means the first row with the cell#0 needs to be removed for further analysis!
			// Important: "MEAN_INTENSITY" is only the column label here, it does not measure intensities but distances!
			setResult("MEAN_INTENSITY", 0, 0);

			// remove all columns but one
			headings = split(Table.headings(), "	");
			for (i = 0; i < lengthOf(headings); i++) {
				column_name = headings[i];
				if (column_name != "PIXEL_COUNT" && column_name != "IDENTIFIER" && column_name != " ") {
					Table.deleteColumn(column_name);
				}
			}
	
			// Save table as csv file in the same folder
			Table.save(folder + file + "_3_area.csv");

		
		Ext.CLIJ2_getSumOfAllPixels(distance_vector, sum_distance);

		/* # Count of overall cell number, displayed in the Log window */
		Ext.CLIJ2_getMaximumOfAllPixels(labels_corrected_size, Number_of_labels);
		print(Number_of_labels + " cells detected");

		/* # Calculate mean neighbor distance within image */
		mean=sum_distance/Number_of_labels;
		print("Mean distance to " + n + " closest neighbors (in pixels): " + mean);

		/* # Adjustment of the distance map to the image with removed edge cells */
		Ext.CLIJ2_replaceIntensities(labels_without_edges, distance_vector, distance_map);
		Ext.CLIJ2_pull(distance_map);
		setMinAndMax(0, 80);
		run("Green Fire Blue");
		run("Calibration Bar...", "location=[Upper Right] fill=White label=Black number=5 decimal=0 font=12 zoom=1 overlay");
		
		// Save  image with removed edge cells
		run("Flatten");
		saveAs("PNG", folder + file + "_NND_map.png");


		// FOLLOWING PART IS FOR NEIGHBOR ANALYSIS
		/* # Voronoi label map
		*/
		Ext.CLIJ2_extendLabelingViaVoronoi(labels_corrected_size, voronoi_map);
		Ext.CLIJ2_pull(voronoi_map);
		run("glasbey_on_dark");
		
		/* # Visualize number of neighbors (iwith LUT cool)
		*/
		Ext.CLIJx_touchingNeighborCountMap(voronoi_map, voronoi_neighbors);
		Ext.CLIJ2_pull(voronoi_neighbors);

		
		setMinAndMax(3, 10);
		run("cool");
		run("Calibration Bar...", "location=[Upper Right] fill=White label=Black number=8 decimal=0 font=12 zoom=1 overlay");

		// Save  image with voronoi neighbor visualization
		run("Flatten");
		saveAs("PNG", folder + file + "_voronoi_neighbors.png");

		/* # Count number of voronoi neighbors
		 */
		Ext.CLIJ2_generateTouchMatrix(voronoi_map, labels_touch_matrix);
		Ext.CLIJ2_countTouchingNeighbors(labels_touch_matrix, count_vector);
		
		// Move results to Excel table
		run("Clear Results");
		Ext.CLIJ2_transposeXY(count_vector, count_vector_transposed);
		Ext.CLIJ2_pullToResultsTable(count_vector_transposed);
	
		//Ext.CLIJ2_pushResultsTableColumn(count_vector, "MAXIMUM_INTENSITY");
		//Table.renameColumn("MAXIMUM_INTENSITY", "TOUCHING_NEIGHBORS");

		
		// Save table as xls file in the same folder
		Table.save(folder + file + "_4_neighbor-number.xls");
		
		// NEIGHBOR ANALYSIS PART ENDS HERE

		
		/* # Weka Label Classifier */
		// add the name of your classification model file in between the ““ signs

		features = "PIXEL_COUNT";
		modelfilename = "";
		Ext.CLIJx_wekaLabelClassifier(all_labels, all_labels, labels_classified, features, modelfilename);
		Ext.CLIJ2_pull(labels_classified);
		// Adjust the number of labels (inlcluding background = 0) that should be displayed
		setMinAndMax(0, 3); 
		run("glasbey_on_dark");

		/* # Create table with cell identities for each cell/label according to Weka Label Classifier
		 */
		run("Clear Results");
		Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(labels_classified, all_labels);
		Table.renameColumn("MEAN_INTENSITY", "Label_Classification");
		
		// remove all columns but one
		headings = split(Table.headings(), "	");
		for (i = 0; i < lengthOf(headings); i++) {
			column_name = headings[i];
			if (column_name != "Label_Classification" && column_name != "IDENTIFIER" && column_name != " ") {
				Table.deleteColumn(column_name);
			}
		}

		// determine whether labels are on image edge
		Ext.CLIJx_flagLabelsOnEdges(labels_corrected_size, flag_vector);
		append_new_rows = false;
		Ext.CLIJx_pullToResultsTableColumn(flag_vector, "is_on_image_edge", append_new_rows);
		Table.save(folder + file + "_1_cell-types-and-edge-cells.xls");

		// Save image (including edge cells)
		run("Flatten");
		saveAs("PNG", folder + file + "_label_classifier.png");

		// Count number of all cell types individually, displayed in the Log window
		count_cells_of_type(labels_classified, 1);
		count_cells_of_type(labels_classified, 2);
		count_cells_of_type(labels_classified, 3);

		// Remove the next two lines if you do not want to clear the images from the screen
		Ext.CLIJ2_clear();
		close("*");
	}
	

}
// Save Log window as text file
selectWindow("Log");
saveAs("TXT", folder + "_LOG-WINDOW_" + file + ".txt" );

		
function count_cells_of_type(image, type_number) { 
// Count all cells of one cell type based on the label classification
	Ext.CLIJ2_equalConstant(image, binary_image, type_number);
	Ext.CLIJ2_connectedComponentsLabeling(binary_image, labels);
	Ext.CLIJ2_getMaximumOfAllPixels(labels, number_of_labels);
	print("there are " + number_of_labels + " with type" + type_number);
}

