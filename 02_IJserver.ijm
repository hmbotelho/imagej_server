/*
**************************************
ImageJ cell counting server
**************************************

Monitors a folder in the computer and counts nuclei in TIF images.
 
Hugo Botelho
hmbotelho@ciencias.ulisboa.pt
6-June-2023
v0.1> 

*/

#@ File (label="Folder to be monitored", style="directory") dir_in
#@ File (label="Folder with results", style="directory") dir_out
#@ Integer (label="Time interval between folder scans, in seconds", min=0, max=60, value=3) delta_t


// Initialize
setBatchMode(true);
print("ImageJ cell counting server");
print("Monitoring this folder: " + dir_in);
print("");
print("Press SPACEBAR to stop the server");
print("");


// Monitor folder
while(true){
	
	// Find files
	all_files = getFileList(dir_in);
	if(lengthOf(all_files) > 0){
		
		// Find TIF files
		for(i=0; i<lengthOf(all_files); i++){
			if(endsWith(all_files[i], ".tif")){
				
				print("Found new image: " + all_files[i]);
				
				// Compute file paths
				img_raw_in = dir_in + "/" + all_files[i];
				img_raw_out = dir_out + "/" + all_files[i];
				img_seg_out = replace(img_raw_out, ".tif$", "_segmented.tif");
				txt_seg_out = replace(img_raw_out, ".tif$", "_ncells.txt");
				
				// Move image
				File.rename(img_raw_in, img_raw_out);

				// Segment cells
				open(img_raw_out);
				img = getTitle();
				segment_nuclei();
				close(img);
				n_cells = nResults;
				close("Results");
								
				// Output
				
					// Segmented image
					save(img_seg_out);
					close();
				
					// Text result
					filehandle = File.open(txt_seg_out);
					print(filehandle, n_cells + " cells");
					File.close(filehandle);
			}
		}
	}
		
	
	// Ckeck if server should be stopped
	if(isKeyDown("space")) break;
	
	
	// Wait until the next folder scan
	wait(delta_t * 1000);
}

print("");
print("Server stopped");






function segment_nuclei() { 
// Segments cells in the active image

	// Preprocessing
	run("Gaussian Blur...", "sigma=2");
	
	// Thresholding
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	
	// Post-processing
	run("Watershed");
	
	// Count cells
	run("Analyze Particles...", "  show=[Count Masks] display exclude clear");
	run("glasbey_on_dark");
}