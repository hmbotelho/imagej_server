/*
**************************************
ImageJ microscope
**************************************

Simulates a fluorescence microscope dumping nuclei images in a folder in the hard drive
A new image is generated every few seconds
 
Hugo Botelho
hmbotelho@ciencias.ulisboa.pt
6-June-2023
v0.1> 

*/

#@ Integer (label="Pixel size for x and y", min=0, max=1024, value=256) img_size
#@ Integer (label="Time interval between images, in seconds", min=0, max=60, value=10) delta_t
#@ Integer (label="Number of images to generate", min=0, max=100, value=10) n_images
#@ File (label="Folder where images will be dumped", style="directory") dir



// Initialize
setBatchMode(true);
print("ImageJ microscope");
print("Simulating " + n_images + " images")
print("");


// Generate images
for (i = 1; i <= n_images; i++) {
	
	// Create blank image
	newImage("Untitled", "8-bit black", img_size, img_size, 1);

	// Draw nuclei
	n_cells = floor(abs(random("gaussian")) * img_size / 20);
	for(j=0; j<n_cells; j++){
		
		// Simulate nuclei location, size and brightness
		x = floor(random*img_size);
		y = floor(random*img_size);
		diam = floor(img_size / 12 + random("gaussian") * 5);
		grayvalue = 150 + floor(random("gaussian") * 20);
		
		// Draw nuclei
		run("Specify...", "width=" + diam + " height=" + diam + " x=" + x + " y=" + y + " oval centered");
		run("Set...", "value=" + grayvalue);
		run("Select None");
	}
	
	// Add noise and blur
	run("Add Specified Noise...", "standard=25");
	run("Add Specified Noise...", "standard=25");
	run("Gaussian Blur...", "sigma=1");
	
	// Save image
	path = dir + "/" + String.pad(i, 3) + ".tif";
	print("Generated " + path);
	saveAs("Tiff", path);
	close();
	
	wait(delta_t * 1000);
}

print("");
print("Finished simulating images");