// header
	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction display redirect=None decimal=3");	
	thresholdMethods=getList("threshold.methods");	
	projectType=newArray("[Average Intensity]", "[Max Intensity]", "[Min Intensity]", "Median", "[Standard Deviation]", "[Sum Slices]");
	lutA=getList("LUTs");
	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction display redirect=None decimal=3");
	setOption("BlackBackground", true);
	setPasteMode("Max");
	setOption("ScaleConversions", true);

	
// Dialoge Settings for analysis
	Dialog.create("Analysis Setup");
	Dialog.addNumber("Gaussian Blur radius in um", 0.5);
	Dialog.addSlider("Nucleus Threshold minimum", 0, 254, 30);
	Dialog.addSlider("Nucleus Threshold maximum", 1, 255, 255);
	Dialog.addSlider("Cytosol Threshold minimum", 0, 254, 164);
	Dialog.addSlider("Cytosol Threshold maximum", 1, 255, 255);
	Dialog.addNumber("Nucleus Circularity minumum", 0.50);
	Dialog.addNumber("Nucleus Circularity maximum", 1);
	Dialog.addNumber("Cytosol Circularity minumum", 0.30);
	Dialog.addNumber("Cytosol Circularity maximum", 1);
	Dialog.addNumber("minimal Nucleus size (in micron^2)", 50);
	Dialog.addNumber("maximal Nucleus size (in micron^2)", 600);
	Dialog.addNumber("minimal Cell size (in micron^2)", 200);
	Dialog.addNumber("maximal Cell size (in micron^2)", 5000);
	Dialog.show();
	blurRadius=Dialog.getNumber();
	minNucThreshold=Dialog.getNumber();
	maxNucThreshold=Dialog.getNumber();
	minCytThreshold=Dialog.getNumber();
	maxCytThreshold=Dialog.getNumber();
	minNucCircularity=Dialog.getNumber();
	maxNucCircularity=Dialog.getNumber();
	minCytoCircularity=Dialog.getNumber();
	maxCytoCircularity=Dialog.getNumber();
	minNucleusSize=Dialog.getNumber();
	maxNucleusSize=Dialog.getNumber();
	minCytosolSize=Dialog.getNumber();
	maxCytosolSize=Dialog.getNumber();

	
// Load in files	
	chosenDir=getDir("Choose the base directory");
		
	processImages(chosenDir);
		
	function processImages(dir) { 	
		fileList=getFileList(dir);   
			
		outputDirName = dir + "_Analysis"
		folderCount=1;					
		while (File.exists(outputDirName)) {
			outputDirName=outputDirName + "_" + folderCount; 
			folderCount++; 
		}
			
		outputDirPath=outputDirName + File.separator;
		
		File.makeDirectory(outputDirName);
		
		// Printing Log file with analysis parameters
		print ("LogFile Analysis Parameters \n\nRadius of Gaussian Blur in um = " + blurRadius +  "\nNuclear Threshold minimum = " + minNucThreshold + "\nNuclear Threshold maximum = " + maxNucThreshold + "\nCytosol Threshold minimum = " + minCytThreshold + "\nCytosol Threshold maximum = " + maxCytThreshold + "\nNucleus Circularity minimum = " + minNucCircularity + "\nNucleus Circularity maximum = " + maxNucCircularity +  "\nCytosol Circularity minimum = " + minCytoCircularity + "\nCytosol Circularity maximum = " + maxCytoCircularity + "\nMinimum Nucleus Size in um² = " + minNucleusSize + "\n Maximum Nucleus Size in um² = " + maxNucleusSize + "\nMinimum Cytosol Size in um² = " + minCytosolSize + "\nMaximum Cytosol Size in um² = " + maxCytosolSize);
		f = File.open(outputDirPath + "AnalysisParameters.txt");
		selectWindow("Log");
		content = getInfo();
		print(f,content);
		File.close(f);
	
	
		for (file = 0; file < fileList.length; file++) {
			if (endsWith(fileList[file], ".tif")) {		
				open(fileList[file]);
	
			// Macro
				roiManager("reset");
				originalImageName = getTitle();
				run("Split Channels");
				GFP = "C1-" + originalImageName; 			// This Channel should be the cytosol staining
				Nucleus = "C2-" + originalImageName; 		// This Channel should be your nucleus
				
			// counting nuclei
				selectWindow(Nucleus);
				run("8-bit");
				run("Gaussian Blur...", "sigma=" + blurRadius + " scaled");
				run("Duplicate...", "title=["+originalImageName+Nucleus+"]");
				setMinAndMax(minNucThreshold, maxNucThreshold);
				run("Apply LUT");
				run("Convert to Mask");
				run("Watershed");
				run("Analyze Particles...", "size="+minNucleusSize+"-"+maxNucleusSize+" circularity="+minNucCircularity+"-"+maxNucCircularity+" show=Nothing exclude clear include add");
				saveAs("Results", outputDirPath + Nucleus + "Results" + "_Nucleus.tsv");
				saveAs("tif", outputDirPath + Nucleus + "_Nucleus.tif");
				roiManager("Save", outputDirPath + Nucleus + "Results" + "_Nucleus.roi");
				
				
			// counting infected cells
				selectWindow(GFP);
				run("8-bit");
				run("Gaussian Blur...", "sigma=" + blurRadius + " scaled");
				run("Duplicate...", "title=["+originalImageName+GFP+"]");
				setMinAndMax(minCytThreshold, maxCytThreshold);
				run("Apply LUT");
				run("Convert to Mask");
				run("Watershed");
				run("Analyze Particles...", "size="+minCytosolSize+"-"+maxCytosolSize+" circularity="+minCytoCircularity+"-"+maxCytoCircularity+" show=Nothing exclude clear include add");
				saveAs("Results", outputDirPath + GFP + "Results" + "_GFP.tsv");
				saveAs("tif", outputDirPath + GFP + "_GFP.tif");
				roiManager("Save", outputDirPath + GFP + "Results" + "_GFP.roi");
				run("Close All");
			}
		}	
				
	}
	
run("Close All");

