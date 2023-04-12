// parameter setup
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=3");
setOption("BlackBackground", true);


// Macro start
	run("Collect Garbage");
	selectedImage = getTitle();
	run("CLIJ2 Macro Extensions", "cl_device=[AMD]");		// For NVIDIA cards set cl_device=[NVIDIA]
	Ext.CLIJ2_clear();

for (count = 1; count < 782; count += 1) {  	// count = number of timepoints in measurement
		
		setBatchMode("hide");
		print(count + "img");
		selectWindow(selectedImage);
		run("Duplicate...", "duplicate channels=1 frames=count");
		rename("img");
		
		// Background subtraction 
		for (i=1; i<=nSlices; i++) {
	          setSlice(i); 
	          max=170;  
	          run("Subtract...", "value="+max);   
	      }
			
		getDimensions(width, height, channels, slices, frames);
		totes = slices * frames;
		run("Properties...", "channels=1 slices=totes frames=0 pixel_width=0.1449920 pixel_height=0.1449920 voxel_depth=0.100 frame=[1.15 sec]");

		blobs = getTitle();
		
		// Filter 
		Ext.CLIJ2_push(blobs);
		sigma1 = 4;
		sigma2 = 9;
		Ext.CLIJ2_differenceOfGaussian2D(blobs, DoG_image, sigma1, sigma1, sigma2, sigma2);
		scalar = -10.0;
		Ext.CLIJ2_addImageAndScalar(DoG_image, image8, scalar);
		radius = 1;
		// detect maxima
		Ext.CLIJ2_detectMaxima3DBox(image8, maxima, radius, radius,radius);
		Ext.CLIJ2_pull(maxima);
		run("Properties...", "channels=1 slices=slices frames=frames pixel_width=0.1449920 pixel_height=0.1449920 voxel_depth=0.100");
		run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=slices frames=frames display=Color");
		print(count + "max_T");
		
		if (count == 1){
			rename("max_T");
			}
		
		else {
			rename("max");
			selectWindow("max");
			run("Concatenate...", "open image1=max_T image2=max");
			rename("max_T");
			}
		
		// combine with input image
		Ext.CLIJx_visualizeOutlinesOnOriginal(image8, maxima, visualization);
		
		// visulize result
		Ext.CLIJ2_pull(visualization);
		
		// configure visualization
		Ext.CLIJ2_getMaximumOfAllPixels(visualization, max_intensity);
		setMinAndMax(-1, max_intensity);
		run("HiLo");
		run("Properties...", "channels=1 slices=slices frames=frames pixel_width=0.1449920 pixel_height=0.1449920 voxel_depth=0.100");
		run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=slices frames=frames display=Color");
		
		print(count + "verify_T");
		if(count == 1){
			rename("verify_T");
			}
		
		else {	
			rename("verify");
			selectWindow("verify");
			run("Concatenate...", "open image1=verify_T image2=verify");	
			rename("verify_T");
			}
				
	selectWindow("img");
	close("img");	
	print(count +"end");
	run("Collect Garbage");	
}
// Save processed files
selectImage(selectedImage);
setBatchMode("show");
selectImage("max_T");
saveAs("Tiff", "your-file-path/file_max-4-9-10.tif"); // "save detected maxima image as a tif, replace your-file-path/file with your output path"
setBatchMode("show");
selectImage("verify_T");
saveAs("Tiff", "your-file-path/file_verify-4-9-10.tif"); // "save visualization image as a tif, replace your-file-path/file with your output path"
setBatchMode("show");