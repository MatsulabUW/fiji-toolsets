// List of buttons for visualizing LLSM movies on FIJI
// especially making multi-color movies of max intensity projections

// Matt Akamatsu 2020
// most macros adapted from other work: 
// Akamatsu et al. eLife 2020

// See [[Protocol/Fiji macro toolset]] page for more documentation: https://roamresearch.com/#/app/akamatsulab/page/OaNeICnHv

var profileWidth   = 7;  // in pixels. The width of the line when you are making line profile ("M")
var LUTnb=1; // 1: Grays; 2: inverted grays; 3: fire

var sumProject = 0; // set this to 1 if you want your kymographs to be a sum projection instead of a max projection.
var kymographWidth = 5; //in pixels. The width of the region from which to make kymograph.
var profileWidth   = 7;  // in pixels. The width of the line when you are making line profile ("M")

var useSubset = 1; // Set this to 1 if you want to measure intitation densities for a (continuous) region smaller than the size of the kymograph.

macro "Color composite + contrast Action Tool - Cff0D63D64D65D71D72D73D74D75D81D82D83D84D85D93D94D95C0f0D90D91D92Da0Da1Da2Da3Da4Da5Da6Db0Db1Db2Db3Db4Db5Db6Dc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8De1De2De3De4De5De6De7De8Df3Df4Df5Df6Cf0fD39D47D48D49D57D58D59D67D68D69Cf00D03D04D05D06D11D12D13D14D15D16D17D18D21D22D23D24D25D26D27D28D30D31D32D33D34D35D36D37D38D40D41D42D43D44D45D46D50D51D52D53D54D55D56D60D61D62C00fD3aD3bD3cD4aD4bD4cD4dD4eD5aD5bD5cD5dD5eD6aD6bD6cD6dD6eD6fD79D7aD7bD7cD7dD7eD7fD89D8aD8bD8cD8dD8eD8fD9aD9bD9cD9dD9eD9fDaaDabDacDadDaeDbaDbbDbcDbdDbeDcaDcbDccCfffD66D76D77D78D86D87D88D96C0ffD97D98D99Da7Da8Da9Db7Db8Db9Dc9"
// This button sets contrast and color for a two-color composite image.

{
	if(isKeyDown("shift"))
		{yellowcyanred=0;
		print("order of channels is yellow-cyan-magenta");
		}
	else
		{
		yellowcyanred = 1;
		print("order of channels is magenta-cyan-yellow");
		}	

	getDimensions(w, h, channels, slices, frames);
	Stack.setPosition(1,1,1);
	// check if there is a selection
	if (selectionType() == -1)
	{
		// select all
		run("Select All");
		// print("No selection found. Please make a selection first.");
		print("Using the whole image. You can make a selection to set contrast on a specific region.");
		// exit();
	}
	// get number of ROIs
	
//print("channels: ")
//print(channels)
	if(channels<3){
	run("Make Composite");
	roiManager("Add");
	roi_nb = roiManager("count")-1;
	roiManager("Select", roi_nb);
	run("Enhance Contrast", "saturated=0.5");
//	run("Green");
	run("Yellow");
	roiManager("Select", roi_nb);
	run("Next Slice [>]");
	run("Enhance Contrast", "saturated=0.5");
//	run("Magenta");
	run("Cyan");
	roiManager("Select", roi_nb);
	roiManager("Delete");
	}
	if(channels==3){
		run("Make Composite");
		roiManager("Add");
		roi_nb = roiManager("count")-1;
		roiManager("Select", roi_nb);
		run("Enhance Contrast", "saturated=0.5");
		if(yellowcyanred==1)
			{run("Yellow");}
		else 
			{run("Magenta");}
		roiManager("Select", roi_nb);
		run("Next Slice [>]");
		run("Enhance Contrast", "saturated=0.5");
		run("Cyan");
		roiManager("Select", roi_nb);
		run("Next Slice [>]");
		run("Enhance Contrast", "saturated=0.5");
		if(yellowcyanred==1)
			{run("Magenta");}
		else 
			{run("Yellow");}
		roiManager("Select", roi_nb);
		roiManager("Delete");
	}

}

macro 'OptimizeContrast [o]'{

	// With this toolset installed, you can optimize the brightness/contrast by pressing the "o" key on your keyboard.

	if (LUTnb==1){
		LUTnb=2;
		run("Grays");
		run("Invert LUT"); //run("Rainbow RGB");
		run("Enhance Contrast", "saturated=0.5");
	}
	else if (LUTnb==2){
		LUTnb=3;
		run("Fire");
		//run("Enhance Contrast", "saturated=0.5");
	}
	else if (LUTnb==3){
		LUTnb=1;
		run("Grays");
		//run("Invert LUT"); //run("Rainbow RGB");
		run("Enhance Contrast", "saturated=0.5");
	}
}

// macro "Adjust registration Action Tool - C059T3e16R"{

macro "Adjust registration Action Tool - C0f0o3488Cf08o7488"{
	
	if(isKeyDown("shift"))
		{greenRed=1;
		print("You're making a green/red composite");
		}
	
	else
		{greenRed = 0;
		}
	
	regFile=File.openDialog("Select file to change registration");

	// Change "xShift" and "yShift" values to change registration of selected image, in pixels
	
	xShift = 5;
	yShift = 40;
	
	open(regFile);
	regImage = getTitle();
		
	dir=getInfo("image.directory");
	curID=getImageID();
	imageTitle=getTitle();
	shortImageTitle=replace(imageTitle,".tif","_");
	
	run("Translate...", "x="+xShift+" y="+yShift+" interpolation=None stack");
	
	// This sets the contrast of the two colors such that the red channel is 3x brighter than the green channel.
	
	saveAs("TIF", dir+shortImageTitle+"translateX"+xShift+"Y"+yShift+".tif");
	
}





macro "Bleach correct Action Tool - C059T3e16_" {
	
	// This tool will bleach correct based on exponential fit and save.
	
// if(isKeyDown("shift"))
// {fastmethod=1;
	
	dir=getInfo("image.directory");
	curID=getImageID();
	imageTitle=getTitle();
	shortImageTitle=replace(imageTitle,".tif","_");
	

			
	run("Bleach Correction", "correction=[Exponential Fit]");

// wait(10);

	bleachedID = getImageID();
	saveAs("TIF", dir+shortImageTitle+"_bleachCorrected.TIF");

	selectWindow("y = a*exp(-bx) + c");

	// run("Save", "save=[/Volumes/MATT4/Nanopillars/201611 Hsinya smiFH2 CK666 FBP17 Arp3/Drug test_U2OS_SMIFH2_50uM/d400_02_After_30min_w2TXR_bleachPlot.TIF]");
	saveAs("png", dir+shortImageTitle+"_bleachingPlot.png");

	// selectWindow(bleachedID);



	
}



macro "Maximum (+shift for Sum) Intensity Projection Action Tool - C902T3f18Z"
{
	if (Stack.isHyperStack)
	{
		getDimensions(w, h, channels, slices, frames);
		if(isKeyDown("shift"))
			{run("Z Project...", "start=1 stop="+slices+" projection=[Sum Slices] all");}
		else 
			{run("Z Project...", "start=1 stop="+slices+" projection=[Max Intensity] all");}
	}
	else
		
		if(isKeyDown("shift"))
		{run("Z Project...", "start=1 stop="+nSlices+" projection=[Sum Slices]");}
	else 
	{
		run("Z Project...", "start=1 stop="+nSlices+" projection=[Max Intensity]");
	}
	
	
}

macro "Make GIF (shift: set framerate) Action Tool - C059T3e16G"
// This macro automates the process of creating a GIF from a stack of images.
// To set the frame rate, hold down the shift key while running the macro.

{
	
	// for now, hard code the frame rate, in frames per second

	framerate = 15; 
	millisecondsperframe = 1000/framerate;

	// if shift key is down, popup asking for frame rate
	if(isKeyDown("shift"))
	{
		framerate = getNumber("Enter frame rate (frames per second):", 15);
		millisecondsperframe = 1000/framerate;
	}

	dir=getInfo("image.directory");
	curID=getImageID();
	imageTitle=getTitle();
	isCZI=false;
	
    if(endsWith(imageTitle,"nd2")) {

		shortImageTitle=replace(imageTitle,".nd2","_");
	}
	else if(endsWith(imageTitle,"czi")) {
		isCZI=true;
		shortImageTitle=replace(imageTitle,".czi","_");
	}
	else {
		shortImageTitle=replace(imageTitle,".tif","_");
	}

	getDimensions(whole_w, whole_h, whole_channels, whole_slices, whole_frames);

	run("Animation Options...", "speed="+framerate+" ");
	
	run("RGB Color", "frames keep");
	rgbID=getImageID();

	// this is the format: run("Animated Gif ... ", "name=20240809_MA3_Abhi410_65_510_202020_JFXON_15um_OS_41_0-5min-01_MIP set_global_lookup_table_options=[Do not use] optional=[] image=[No Disposal] set=66 number=-1 transparency=[No Transparency] red=0 green=0 blue=0 index=0 filename=/Volumes/home/Microscopy/Abhi/LLSM/2024-08-09_osmotic-shock/MA3_410_65_510_202020_JFXON_OS41_05min_15um/20240809_MA3_Abhi410_65_510_202020_JFXON_15um_OS_41_0-5min-01_MIP.gif");

	run("Animated Gif ... ", "name="+shortImageTitle+" set_global_lookup_table_options=[Do not use] optional=[] image=[No Disposal] set="+millisecondsperframe+" number=-1 transparency=[No Transparency] red=0 green=0 blue=0 index=0 filename="+dir+shortImageTitle+".gif");
	print("GIF saved as: "+dir+shortImageTitle+".gif");

}

// macro "Cut out box from composite Action Tool - C059T3e16B"
macro "Cut Out Box from composite Action Tool - C008R00ffR55aa"


{
	dir=getInfo("image.directory");
	curID=getImageID();
	imageTitle=getTitle();
	isCZI=false;
	
    if(endsWith(imageTitle,"nd2")) {

		shortImageTitle=replace(imageTitle,".nd2","_");
	}
	else if(endsWith(imageTitle,"czi")) {
		isCZI=true;
		shortImageTitle=replace(imageTitle,".czi","_");
	}
	else {
		shortImageTitle=replace(imageTitle,".tif","_");
	}
	count=roiManager("count");

	roiManager("deselect");
	roiManager("Remove Slice Info");
	roiManager("Save", dir+shortImageTitle+"boxROIs.zip");
	
	getDimensions(whole_w, whole_h, whole_channels, whole_slices, whole_frames);
	print("time poitns: ");
	print(whole_frames);
	for(i=0;i<count;i++){
		
		j = i+1;
		
		selectImage(curID);
		roiManager("select",i);
	
		run("Duplicate...", "duplicate title=["+shortImageTitle+"box"+j+".tif]");
		boxID=getImageID();
		saveAs("TIF", dir+shortImageTitle+"box"+j+".tif");
//		increase number pixels without interprolation to save a less lossy avi file
//		run("RGB Color", "frames keep");
		getDimensions(w, h, channels, slices, frames);
//		print("slices: ");
//		print(slices);
//		print("Frames: ");
//		print(frames);

		if(isCZI==false){
		run("Size...", "width="+d2s(w*8,0)+" height="+d2s(h*8,0)+" depth="+d2s(slices,0)+" constrain average interpolation=None");
		}
		else {
//			incerase size by 2x if it's an airyscan image (which has smaller pixels)
		run("Size...", "width="+d2s(w*2,0)+" height="+d2s(h*2,0)+" depth="+d2s(slices,0)+" constrain average interpolation=None");	
		}
//		chnange framerate dependingo on whether its a time lapse
		if(whole_frames>1){
			run("AVI... ", "compression=JPEG frame=12 save=["+dir+shortImageTitle+"box"+j+".avi]");
		}
		else{
			run("AVI... ", "compression=JPEG frame=8 save=["+dir+shortImageTitle+"box"+j+".avi]");
		}
		// this is where I Could save individual  BW channel avis.
		if(whole_frames==1){
			for(k=0;k<channels;k++){
				selectImage(boxID);
				cur_ch = d2s(k+1,0);
	//			print("channel ");
	//			print(cur_ch);
	//			selectImage(curID);
	//			run("Duplicate...", "duplicate channels="+cur_ch+"");
				run("Duplicate...", "duplicate title=["+shortImageTitle+"box"+j+"ch"+cur_ch+".tif] duplicate channels="+cur_ch+"");
				run("Grays");
				run("Invert LUT");
				run("AVI... ", "compression=JPEG frame=8 save=["+dir+shortImageTitle+"box"+j+"ch"+cur_ch+".avi]");
				run("Close");		
			}
		}
		selectImage(boxID);
		run("Close");
		// run("RGB Color", "frames keep");
//		run("Reslice [/]...", "output=1.000 start=Top rotate avoid");
//		run("AVI... ", "compression=JPEG frame=12 save=["+dir+shortImageTitle+"_reslice_box"+j+".avi]");

		
		

	}
	
	// Save image of regions + original movie file
	
	selectImage(curID);	
	roiManager("deselect");
	run("Select All");
	run("Duplicate...", "title="+shortImageTitle+"box1-"+count+"_regionOverlay.tif");
	curDupID=getImageID();
	
	//run("Enhance Contrast", "saturated=0.5");
	run("Stack to RGB");
	roiManager("Set Line Width", 5);
	roiManager("Remove Slice Info");
	roiManager("Set Color", "#4dffff00");
	roiManager("deselect");
	roiManager("Show None");
	roiManager("Show All with labels");
	run("From ROI Manager");
	saveAs("png", dir+shortImageTitle+"box1-"+count+"_regionOverlay..png");
	
	selectImage(curDupID);	
	run("Close");

	roiManager("deselect");
	roiManager("Delete");


}


// macro "four panel merge from composite Action Tool - C059T3e16P"
macro "four panel merge from composite Action Tool - C008R00a7R90a7R08a7R98a7"


// This ImageJ macro automates the process of extracting, processing, and merging specific regions of interest (ROIs) from multi-channel microscopy images. 
// Designed to work with .nd2, .czi, and .tif file formats, it streamlines tasks such as duplicating ROIs, converting them into different color spaces, and saving them in various formats including TIFF, AVI, and PNG. 
// The macro supports both single-time-point and time-lapse images, and allows for processing in either two-channel or multi-channel modes. 
// It is particularly useful for researchers who require consistent and efficient analysis of multiple image regions across different channels.
{
	twochannel=false;
	if(isKeyDown("shift"))
	{twochannel=true;
	print("You're making a panel for two channels");
	}

	// set to true if you want to save gifs
	// this is a little slow but higher resolution than the AVI
	savegifs = true;

	framespersecond=15;
	millisecondsperframe=1000/framespersecond;

	dir=getInfo("image.directory");
	curID=getImageID();
	imageTitle=getTitle();
	isCZI=false;
//	print("okay??");
	
    if(endsWith(imageTitle,"nd2")) {

		shortImageTitle=replace(imageTitle,".nd2","_");
	}
	else if(endsWith(imageTitle,"czi")) {
		isCZI=true;
		shortImageTitle=replace(imageTitle,".czi","_");
	}
	else {
		shortImageTitle=replace(imageTitle,".tif","_");
	}
	count=roiManager("count");

	roiManager("deselect");
	roiManager("Remove Slice Info");
	roiManager("Save", dir+shortImageTitle+"boxROIs.zip");
	
	getDimensions(whole_w, whole_h, whole_channels, whole_slices, whole_frames);
	print("time points: ");
	print(whole_frames);
	print("ROIs: ");
	print(count);
	for(i=0;i<count;i++){
		
		j = i+1;

		print("working on box:");
		print(j);
		
		selectImage(curID);
		roiManager("select",i);
	
		run("Duplicate...", "duplicate title=["+shortImageTitle+"box"+j+".tif]");
		boxID=getImageID();
		saveAs("TIF", dir+shortImageTitle+"box"+j+".tif");
//		increase number pixels without interprolation to save a less lossy avi file
//		run("RGB Color", "frames keep");
		getDimensions(w, h, channels, slices, frames);
//		print("slices: ");
//		print(slices);
//		print("Frames: ");
//		print(frames);
//
//		if(isCZI==false){
//		run("Size...", "width="+d2s(w*8,0)+" height="+d2s(h*8,0)+" depth="+d2s(slices,0)+" constrain average interpolation=None");
//		}
//		else {
////			incerase size by 2x if it's an airyscan image (which has smaller pixels)
//		run("Size...", "width="+d2s(w*2,0)+" height="+d2s(h*2,0)+" depth="+d2s(slices,0)+" constrain average interpolation=None");	
//		}
////		chnange framerate dependingo on whether its a time lapse
//		if(whole_frames>1){
//			run("AVI... ", "compression=JPEG frame=12 save=["+dir+shortImageTitle+"box"+j+".avi]");
//		}
//		else{
//			run("AVI... ", "compression=JPEG frame=8 save=["+dir+shortImageTitle+"box"+j+".avi]");
//		}
		// this is where I Could save individual  BW channel avis.
//		duplicate individual channels, make RGB, combine, save

//		chIDs = newArray("0");
		// if(whole_frames==1){
		for(k=0;k<channels;k++){
			selectImage(boxID);
			cur_ch = d2s(k+1,0);
			print("channel ");
			print(cur_ch);
//			selectImage(curID);
//			run("Duplicate...", "duplicate channels="+cur_ch+"");
			run("Duplicate...", "duplicate title=["+shortImageTitle+"box"+j+"ch"+cur_ch+".tif] duplicate channels="+cur_ch+"");
			run("Grays");
			run("Invert LUT");
			run("RGB Color");
//				run("Invert LUT");
//				run("AVI... ", "compression=JPEG frame=8 save=["+dir+shortImageTitle+"box"+j+"ch"+cur_ch+".avi]");
//				run("Close");		
			chID=getImageID();
//				Array.concat(chIDs,chID);
//				Array.print(chIDs);
			
		}
		// }
		selectImage(boxID);
//		here save multichannel as TIF
		saveAs("TIF", dir+shortImageTitle+"box"+j+".tif");
		
		mergeID = getImageID();
//		run("Duplicate...", "duplicate title=["+shortImageTitle+"box"+j+"_merge.tif]");
//		run("Close");

                if(twochannel==true){
                        run("RGB Color", "slices");
                }
                else {
                        if(frames==1){
                                run("RGB Color", "slices");
                        }
                        else {
                                run("RGB Color", "frames keep");
                        }

                        // run("Stack to RGB");
                }
//		selectImage(boxID);
//		run("Close");
//		wait(500);
//rename the image or else it'll get confused which image to take in the next step
		rename("merged.tif");	
		mergeTitle = getTitle();
		print(mergeTitle);

//		combine channels 1 and 2
		
		// run("Combine...", "stack1="+shortImageTitle+"box"+j+"ch1.tif stack2="+shortImageTitle+"box"+j+"ch2.tif");
		run("Combine...", "stack1=merged.tif stack2="+shortImageTitle+"box"+j+"ch1.tif");

		rename("combined_stacks_1.tif");

		//combine channels 1 and 2 with merge (2 color)
		if(twochannel==true){
			run("Combine...", "stack1=combined_stacks_1.tif stack2=merged.tif");
			
		}

		else {
//		combine channels 3 and 4

		// run("Combine...", "stack1="+shortImageTitle+"box"+j+"ch3.tif stack2=merged.tif");
		run("Combine...", "stack1="+shortImageTitle+"box"+j+"ch2.tif stack2="+shortImageTitle+"box"+j+"ch3.tif");

		rename("combined_stacks_2.tif");
		
		// run("RGB Color", "frames keep");
//		run("Reslice [/]...", "output=1.000 start=Top rotate avoid");
//		run("AVI... ", "compression=JPEG frame=12 save=["+dir+shortImageTitle+"_reslice_box"+j+".avi]");


//		combine both sets of channels

		run("Combine...", "stack1=combined_stacks_1.tif stack2=combined_stacks_2.tif combine");

		}
		saveAs("TIF", dir+shortImageTitle+"box"+j+"_channels_panel.tif");
		// if(twochannel==true){
		run("AVI... ", "compression=JPEG frame="+framespersecond+" save=["+dir+shortImageTitle+"box"+j+"_channels_panel.avi]");
		
		if(savegifs==true){
			// save as gif
			print("saving gif. This is a little slow but higher resolution than the AVI. To skip this step you can set savegifs to false in the source code");
			run("Animated Gif ... ", "name="+shortImageTitle+"box"+j+"_channels_panel set_global_lookup_table_options=[Do not use] optional=[] image=[No Disposal] set="+millisecondsperframe+" number=0 transparency=[No Transparency] red=0 green=0 blue=0 index=0 filename="+dir+shortImageTitle+"box"+j+"_channels_panel.gif");
		}

		// }
		saveAs("png", dir+shortImageTitle+"box"+j+"_channels_panel.png");	
		run("Close");

		if(twochannel==true){
			
		}
		else {
		selectImage(boxID);
		run("Close");
		}
	}
	
	// Save image of regions + original movie file
	
	selectImage(curID);	
	roiManager("deselect");
//	run("Select All");
//	run("Duplicate...", "title="+shortImageTitle+"box1-"+count+"_regionOverlay.tif");

	//run("Enhance Contrast", "saturated=0.5");
	// run("Stack to RGB");
        if(twochannel==true){
                run("RGB Color", "slices");
                roiManager("Set Line Width", 2);
        }
        else {
                // run("Stack to RGB");
                if(whole_frames==1){
                        run("RGB Color", "slices");
                }
                else {
                        run("RGB Color", "frames keep");
                }
                roiManager("Set Line Width", 2);
        }
	roiManager("Remove Slice Info");
	roiManager("Set Color", "magenta");
	roiManager("deselect");
	roiManager("Show None");
	roiManager("Show All with labels");
	run("From ROI Manager");
	saveAs("png", dir+shortImageTitle+"box1-"+count+"_regionOverlay..png");

	// if(twochannel==true){
		
	// }
	// else {
	// selectImage(curDupID);	
	// run("Close");
	// }
	roiManager("deselect");
	roiManager("Delete");


}



//macro "Temporal-Color Coder Action Tool C059T3e16T"
//{
/*

************* Temporal-Color Coder *******************************
Color code the temporal changes.

Kota Miura (miura@embl.de) +49 6221 387 404 
Centre for Molecular and Cellular Imaging, EMBL Heidelberg, Germany

!!! Please do not distribute. If asked, please tell the person to contact me. !!!
If you publish a paper using this macro, it would be cratedful if you could acknowledge. 

Edit MA 08/10/2015 to save image with file name
 
---- INSTRUCTION ----

1. Open a stack (8 bit or 16 bit)
2. Run the macro
3. In the dialog choose one of the LUT for time coding.
	select frame range (default is full).
	check if you want to have color scale bar.

History

080212	created ver1 K_TimeRGBcolorcode.ijm
080213	stack slice range option added.
		time color code scale option added.

		future probable addiition: none-linear assigning of gray intensity to color intensity
		--> but this is same as doing contrast enhancement before processing.
*****************************************************************************
*/


// macro "Make kymographs (shift: batch mode) Action Tool - C059T3e16K" {
macro "Make kymographs Action Tool - Cf0fF16c3C0ffF9665" {

	
	// This tool will make kymographs from line regions you create.
	getDimensions(w, h, channels, slices, frames);
	// get directory of open image
	dir=getInfo("image.directory");

	if(isKeyDown("shift"))
		{fastmethod=1;
		
		print("This is the batch method of making kymographs. All open images have been closed. Your kymographs will be saved in the same folder as your movie.");
		}
	
	else
		{fastmethod = 0;
		}
	
	if(fastmethod>0){
		
		// Close all windows without saving
		
		while (nImages>0) { 
			selectImage(floor(nImages*random)+1); 
			close(); 
		}
		
		
		imageFile=File.openDialog("Select your movie");
		setBatchMode(true);	
		open(imageFile);
		
		dir=getInfo("image.directory");
		curID=getImageID();
		imageTitle=getTitle();

// 		Remove the last four characters of imageTitle and replace them with _

		shortImageTitle = imageTitle.substring(0, lengthOf(imageTitle)-4) + "_";
		print("shortImageTitle: "+shortImageTitle);
		// shortImageTitle=replace(imageTitle,".tif","_");
		
		roiNb=roiManager("count");
		
		// save ROIs
		print(dir+shortImageTitle+"ROIs.zip");
		
		if(roiNb == 0 ){
			
			kymROIs = File.openDialog("Select ROI zip file to make kymographs");
			roiManager("Open", kymROIs); 
			roiNb=roiManager("count");
			
		}
		else {
			roiManager("deselect");
			roiManager("Remove Slice Info");
			roiManager("Save", dir+shortImageTitle+"w"+kymographWidth+"_r1-"+roiNb+"ROIs.zip");
		}
		
		// Iterate through ROIs
		for(i=0;i<roiNb;i++){		
			
			ii = i+1; // so the naming starts at 1 instead of 0
			
			selectImage(curID);
			roiManager("select",i);
			// straighten image - width defined above
//			run("Straighten...", "line="+kymographWidth+" process");
//			id1 = getImageID();
			// reslice
			
			run("Reslice [/]...", "output=1.000 start=Top avoid width="+kymographWidth);
			id2 = getImageID();
			
			
			
			if(sumProject)
			// sum project image
			
				{run("Z Project...", "projection=[Sum Slices]");
				id3 = getImageID();
				curKym = getTitle();
				}	
			
			else
			{
			
			// maximum project image
			
			run("Z Project...", "projection=[Max Intensity]");
			id3 = getImageID();
			curKym = getTitle();
			}
			// rotate 90 degrees left
			
			run("Rotate 90 Degrees Left");
			
			// Change color
			
			//run("Green Fire Blue"); // If you don't have this particular lookup table or want b & w, comment this out.
			
			// save
			
			//saveAs("TIF", dir+shortImageTitle+"r"+ii+"w"+kymographWidth+"_kymograph.tif");
			//saveAs("png", dir+shortImageTitle+"r"+ii+"w"+kymographWidth+"_kymograph.png");
			
			// close intermediate images
			
//			selectImage(id1);
//			run("Close");
			
			selectImage(id2);
			run("Close");
			
			// FOR BATCH MODE
			// Try to make a stack from both images, turn into composite, and change look up tables. to circumvent protblem from merging
			
			
			//wait(500);
			//mergedID = getImageID();
			
			selectImage(id3); 
			
			saveAs("TIF", dir+shortImageTitle+"_w"+kymographWidth+"r"+ii+"_kymograph.tif");
			saveAs("PNG", dir+shortImageTitle+"w"+kymographWidth+"r"+ii+"_kymograph.png");
			
			selectImage(shortImageTitle+"w"+kymographWidth+"r"+ii+"_kymograph.png");
			run("Close");
			
			
			
			
			
			
		}
		
		setBatchMode("exit and diplay");
	}
	
	else
	{

		dir=getInfo("image.directory");
		// print(dir);
		// print("^^directory");
		curID=getImageID();
		imageTitle=getTitle();
		// shortImageTitle=replace(imageTitle,".tif","_");
		// 		Remove the last four characters of imageTitle and replace them with _

		shortImageTitle = imageTitle.substring(0, lengthOf(imageTitle)-4) + "_";
		print("shortImageTitle: "+shortImageTitle);
		
		roiNb=roiManager("count");
		// save ROIs
		print(dir+shortImageTitle+"ROIs.zip");
		
		if(roiNb == 0 ){
			
			kymROIs = File.openDialog("Select ROI zip file to make kymographs");
			roiManager("Open", kymROIs); 
			roiNb=roiManager("count");
			
		}
		else {
			
			roiManager("deselect");
			roiManager("Remove Slice Info");
			roiManager("Save", dir+shortImageTitle+"w"+kymographWidth+"_r1-"+roiNb+"ROIs.zip");
		}
		
		// create duplicates of the file for each channel

		// run duplicate, channel = 1
		selectImage(curID);
		run("Duplicate...", "title="+shortImageTitle+"ch1.tif duplicate channels=1");
		// get image ID of the duplicate
		idch1 = getImageID();
		// run duplicate, channel = 2
		selectImage(curID);
		run("Duplicate...", "title="+shortImageTitle+"ch2.tif duplicate channels=2");
		// get image ID of the duplicate
		idch2 = getImageID();

		if (channels==3)
		{
			// run duplicate, channel = 3
			selectImage(curID);
			run("Duplicate...", "title="+shortImageTitle+"ch3.tif duplicate channels=3");
			// get image ID of the duplicate
			idch3 = getImageID();
		}

		// Iterate through ROIs
		
		for(i=1;i<=roiNb;i++){
			
			// ii = i+1; // so the naming starts at 1 instead of 0
			
			// for each channel
			for(j=0;j<channels;j++){
				// print("working on ROI: "+i+" channel: "+j);
				// select the image
				if(j==0)
					{selectImage(idch1);
					}
				else if(j==1)
					{selectImage(idch2);
					}
				else if(j==2)
					{selectImage(idch3);
					}
				
				roiManager("select",i-1);
				// straighten image - width defined above
				run("Straighten...", "line="+kymographWidth+" process");
				if(j==0)
					idch1_1 = getImageID();
				else if(j==1)
					idch2_1 = getImageID();
				else if(j==2)
					idch3_1 = getImageID();

				// reslice
				
				run("Reslice [/]...", "output=1.000 start=Top avoid");
				if(j==0){
					idch1_2 = getImageID();
					name_ch1_2 = getTitle();
					}
				else if(j==1){
					idch2_2 = getImageID();
					name_ch2_2 = getTitle();
					}
				else if(j==2){
					idch3_2 = getImageID();
					name_ch3_2 = getTitle();
					}	
			}

			// merge channels for idch1_2, idch2_2, idch3_2
			if (channels == 3)
				{
				run("Merge Channels...", "c1=["+name_ch1_2+"] c2=["+name_ch2_2+"] c3=["+name_ch3_2+"] create");
				idmerged = getImageID();
				}
			else
				{run("Merge Channels...", "c1=["+name_ch1_2+"] c2=["+name_ch2_2+"] create");
				idmerged = getImageID();
				}	

			// selectImage(curID);
			// roiManager("select",i);
			// // straighten image - width defined above
			// run("Straighten...", "line="+kymographWidth+" process");
			// id1 = getImageID();
			// // reslice
			
			// run("Reslice [/]...", "output=1.000 start=Top avoid");
			// id2 = getImageID();
			
			if(sumProject)
			// sum project image
			
				{run("Z Project...", "projection=[Sum Slices]");
				id3 = getImageID();
				curKym = getTitle();
				}	
			
			else
				{
			
				// maximum project image. If you prefer sum projection: comment this out and uncomment "Sum slices" line
				
				run("Z Project...", "projection=[Max Intensity]");
				id3 = getImageID();
				curKym = getTitle();
				//		run("Z Project...", "projection=[Sum Slices]");
				}
			
			
			// rotate 90 degrees left
			
			run("Rotate 90 Degrees Left");
			
			// Change color
			
			// run("Green Fire Blue"); 
			// If you prefer green/ blue kymographs, remove the "//" at the beginning of the line above.
			
			// save
			
			if(sumProject)
				{
			saveAs("TIF", dir+shortImageTitle+"_sum_w"+kymographWidth+"r"+i+"_kymograph.tif");
			saveAs("png", dir+shortImageTitle+"sumw"+kymographWidth+"r"+i+"_kymograph.png");
				}
			else
				{

			saveAs("TIF", dir+shortImageTitle+"_w"+kymographWidth+"r"+i+"_kymograph.tif");
			saveAs("png", dir+shortImageTitle+"w"+kymographWidth+"r"+i+"_kymograph.png");
				}
			// close intermediate images
			// print("Saved kymograph for ROI " + (i));

			selectImage(idch1_1);
			run("Close");
			// selectImage(idch1_2);
			// run("Close");
			selectImage(idch2_1);
			run("Close");
			// selectImage(idch2_2);
			// run("Close");

			if(channels==3)
			{
				selectImage(idch3_1);
				run("Close");
				// selectImage(idch3_2);
				// run("Close");
			}

			selectImage(idmerged);
			run("Close");

			// selectImage(id1);
			// run("Close");
			
			// selectImage(id2);
			// run("Close");
			
		}
	// close images of each channel
	selectImage(idch1);
	run("Close");
	selectImage(idch2);
	run("Close");
	if(channels==3)
	{
		selectImage(idch3);
		run("Close");

	}
	
	// Save image of regions + original movie file
	
	selectImage(curID);
	roiManager("deselect");
	run("Duplicate...", "title="+shortImageTitle+"w"+kymographWidth+"_r1-"+roiNb+"_regionOverlay.tif");
	run("Enhance Contrast", "saturated=0.5");
	roiManager("Set Line Width", kymographWidth);
	roiManager("Remove Slice Info");
	roiManager("Set Color", "#4dffff00");
	roiManager("Show All with labels");
	run("From ROI Manager");
	saveAs("png", dir+shortImageTitle+"w"+kymographWidth+"_r1-"+roiNb+"_regionOverlay.png");
	
	// close remaining images

	selectImage(curID);
	run("Close");
	
	print("kymograph width is "+kymographWidth+" pixels");
	}
	// while (nImages>0) { 
	// 	selectImage(floor(nImages*random)+1); 
	// 	curImageID = getImageID();
	// 	title = getTitle();
	// 	print(title);
	// 	print(curImageID);
	// 	// close(); 
	// }
	
	
	
	// get all ids of open images

	// for (i=0; i<nImages; i++)
	// 	selectImage(i);
	// 	id_cur = getImageID();
	// 	print(id_cur);
	// 	run("Close");
	// }
	// close all open images
	// for(i=0;i<openImages.length;i++)
	// {
	// 	selectImage(openImages[i]);
	// 	run("Close");
	// }
	
}

var Glut = "Fire";	//default LUT
var Gstartf = 1;
var Gendf = 10;
var GFrameColorScaleCheck=0;

macro "Time Lapse Color Coder Action Tool - C059T3e16T"{
		
	dir=getInfo("image.directory");
	curID=getImageID();
	imageTitle=getTitle();
	shortImageTitle=replace(imageTitle,".tif","_");
	
	
	Gendf = nSlices;
	Glut = ChooseLut();
	run("Duplicate...", "title=listeriacells-1.stk duplicate");
	run("Enhance Contrast", "saturated=0.5");

	hh = getHeight();
	ww = getWidth();
	totalslice = nSlices;
	calcslices = Gendf - Gstartf +1;
	run("8-bit");
	imgID = getImageID();

	newImage("colored", "RGB White", ww, hh, calcslices);
	newimgID = getImageID();

	setBatchMode(true);

	newImage("stamp", "8-bit White", 10, 10, 1);
	run(Glut);
	getLut(rA, gA, bA);
	close();
	nrA = newArray(256);
	ngA = newArray(256);
	nbA = newArray(256);

	for (i=0; i<calcslices; i++) {
		colorscale=floor((256/calcslices)*i);
		//print(colorscale);
		for (j=0; j<256; j++) {
			intensityfactor=0;
			if (j!=0) intensityfactor = j/255;
			nrA[j] = round(rA[colorscale] * intensityfactor);
			ngA[j] = round(gA[colorscale] * intensityfactor);
			nbA[j] = round(bA[colorscale] * intensityfactor);
		}
		newImage("temp", "8-bit White", ww, hh, 1);
		tempID = getImageID;

		selectImage(imgID);
		setSlice(i+Gstartf);
		run("Select All");
		run("Copy");

		selectImage(tempID);
		run("Paste");
		setLut(nrA, ngA, nbA);
		run("RGB Color");
		run("Select All");
		run("Copy");
		close();

		selectImage(newimgID);
		setSlice(i+1);
		run("Select All");
		run("Paste");
	}

	selectImage(imgID);
	close();
	selectImage(newimgID);
	op = "start=1 stop="+totalslice+" projection=[Max Intensity]";
	run("Z Project...", op);
	setBatchMode(false);	
	if (GFrameColorScaleCheck) CreatGrayscale256(Glut, Gstartf, Gendf);
	temporalColorID=getImageID();

	selectImage(newimgID);
	close();
		
	selectImage(temporalColorID);

	saveAs("TIF", dir+shortImageTitle+"temporalColor__t"+Gstartf+"-"+Gendf+".tif");
	saveAs("png", dir+shortImageTitle+"temporalColor_t"+Gstartf+"-"+Gendf+".png");
		
	
}

/*
run("Spectrum");
run("jet"); //MA
run("Fire");
run("Ice");
run("3-3-2 RGB");
run("brgbcmyw");
run("Green Fire Blue");
run("royal");
run("thal");
run("smart");
run("unionjack");
run("jet"); //MA 10-28-14
run("5_ramps");//MA 6-4-13
run("phase");//MA
14 luts
*/

function ChooseLut() {
	lutA=newArray(10);
	lutA[0] = "jet"; //MA
	lutA[1] = "Fire";
	lutA[2] = "Ice";
	lutA[3] = "3-3-2 RGB";
	lutA[4] = "brgbcmyw";
	lutA[5] = "Green Fire Blue";
	lutA[6] = "royal";
	lutA[7] = "Spectrum"; //MA
	//lutA[7] = "thal";
	lutA[8] = "smart";
	//lutA[9] = "unionjack";
	lutA[9] = "Red Hot";

 	Dialog.create("Color Code Settings");
	Dialog.addChoice("LUT", lutA);
	Dialog.addNumber("start frame", Gstartf);
	Dialog.addNumber("end frame", Gendf);
	Dialog.addCheckbox("create Time Color Scale Bar", GFrameColorScaleCheck);
 	Dialog.show();
 	Glut = Dialog.getChoice();
	Gstartf= Dialog.getNumber();
	Gendf= Dialog.getNumber();
	GFrameColorScaleCheck = Dialog.getCheckbox();
	print("selected lut:"+ Glut);
	return Glut;
}

function CreatGrayscale256(lutstr, beginf, endf){
	ww = 256;
	hh=32;
	newImage("color time scale", "8-bit White", ww, hh, 1);
	for (j=0; j<hh; j++) {
		for (i=0; i<ww; i++) {
			setPixel(i, j, i);
		}
	}
	run(lutstr);
	//setLut(nrA, ngA, nbA);
	run("RGB Color");
	op = "width="+ww+" height="+hh+16+" position=Top-Center zero";
	run("Canvas Size...", op);
	setFont("SansSerif", 12, "antiliased");
	run("Colors...", "foreground=white background=black selection=yellow");
	drawString("frame", round(ww/2)-12, hh+16);
	drawString(leftPad(beginf, 3), 0, hh+16);
	drawString(leftPad(endf, 3), ww-24, hh+16);

}

function leftPad(n, width) {
    s =""+n;
    while (lengthOf(s)<width)
        s = "0"+s;
    return s;
}
/*
macro "drawscale"{
	CreatGrayscale256("Fire", 1, 100);
}
*/




macro "Measure line from kymograph Action Tool - C059T3e16L"
// This tool measures lines you have drawn on kymographs and saves them with the same name as the kymograph.
// Option for measuring just between the top and bottom most lines. If you've measured just a subest of the tracks in the kymograph.
{
	
	dir=getInfo("image.directory");
	curID=getImageID();
	imageTitle=getTitle();
	shortImageTitle=replace(imageTitle,".tif","_");
	roiNb=roiManager("count");
	
	curSlice = getSliceNumber();
	channelImageTitle = shortImageTitle+"c"+curSlice+"_";
	
	roiManager("deselect");
	roiManager("Set Color", "#4dffff00");
	roiManager("Save", dir+channelImageTitle+"lineROIs.zip");
	print(dir+channelImageTitle+"lineROIs.zip saved");	
	
	run("Set Scale...", "distance=0");
	
	if(isOpen("Results")){;
		//			IJ.deleteRows(0,nResults);
		selectWindow("Results"); 
		run("Close"); 
	}
	
	
	
	roiManager("deselect");
	roiManager("Measure");
	
	saveAs("measurements", dir+channelImageTitle+"lineROIs.xls");
	saveAs("measurements", dir+channelImageTitle+"lineROIs.txt");
	
	print( dir+channelImageTitle+"lineROIs.xls and .txt saved");
	roiManager("deselect");
	roiManager("Delete");
	
	// Get all the Y coordinates of the lines measured in results
	
	ys = newArray(nResults);
	
	for(i=0;i<nResults;i++){ 
		ys[i] = getResult("Y", i);
	}
	
	Array.getStatistics(ys,ymin,ymax);
	
	
	//// Measure and save density of events. In units of events/um^2/minute.
	measureInitiations = 0;
	if(measureInitiations>0)
     	{
     		heightpx = getHeight();
     		widthpx  = getWidth();
     		nEvents = nResults;
     		
     		subsetheightpx = ymax-ymin; // This is the distance between the top and bottom line ROI
     		
     		unscaleddensity = nEvents/heightpx/widthpx/kymographWidth; // in events per pixels squared per time interval
     		unscaleddensitysubset = nEvents/subsetheightpx/widthpx/kymographWidth; // in events per pixels squared per time interval. For just region between top and botom line ROI, not entire kymograph.

     		// convert to microns, seconds
     		
     		heightmicron = heightpx * micronsperpixel; // e.g. .108 microns per pixel
     		subsetheightmicron = subsetheightpx * micronsperpixel;
     		widthminutes  = widthpx  * timeinterval /60;    // e.g. 2 seconds per time point (pixel) divided by 60 seconds/ min
     		kymographwidthmicron = kymographWidth * micronsperpixel;
     		
     		density = nEvents/heightmicron/widthminutes/kymographwidthmicron; // in events per pixels squared per time interval
     		
     		densitysubset = nEvents/subsetheightmicron/widthminutes/kymographwidthmicron; // in events per pixels squared per time interval
     		
     		
     		
     		//run("Text Window...", "name="+tableTitle+" width=72 height=8 menu");
     		
     		//print(f, "\\Clear");
     		//print(f, density);
     		
     		
     		if(isOpen("Results")){;	
     			selectWindow("Results"); 
     			run("Close"); 
     		}
		
     		if(useSubset>0){ // Report the initiation density for a subset between Y max and min of line ROIs, if "var useSubset" is 1 at top of this file
     		
     			setResult("Track density pixels", 0, unscaleddensitysubset);
     			setResult("Track density", 0, densitysubset);
     		}
     		else {	
			setResult("Track density pixels", 0, unscaleddensity);
			setResult("Track density", 0, density);
		}	
     		setResult("Number events", 0, nEvents);
     		setResult("Time interval (s)", 0, timeinterval);
     		setResult("Microns per pixel", 0, micronsperpixel);
     		setResult("Channel", 0, curSlice);
     		setResult("Kymograph width", 0, kymographWidth);
     		setResult("Subset or kymograph", 0, useSubset); 
     		
     		if(useSubset>0){
     			saveAs("measurements", dir+channelImageTitle+"eventDensitySubset.xls");
     			saveAs("measurements", dir+channelImageTitle+"eventDensitySubset.txt");	
     		}
     		else {	
			saveAs("measurements", dir+channelImageTitle+"eventDensity.xls");
			saveAs("measurements", dir+channelImageTitle+"eventDensity.txt");
     		}
	}
}

macro "Measure line profile from kymograph Action Tool - C059T3e16M"
// This tool measures lines you have drawn on kymographs and saves them with the same name as the kymograph.
// Option for measuring just between the top and bottom most lines. If you've measured just a subest of the tracks in the kymograph.
{
	
	dir=getInfo("image.directory");
	curID=getImageID();
	imageTitle=getTitle();
	shortImageTitle=replace(imageTitle,".tif","_");
	roiNb=roiManager("count");
	
	curSlice = getSliceNumber();
	setSlice(curSlice);		

	channelImageTitle = shortImageTitle+"c"+curSlice+"_";
	
	roiManager("deselect");
	roiManager("Set Color", "#4dffff00");
	roiManager("Save", dir+channelImageTitle+"lineROIs.zip");
	print(dir+channelImageTitle+"lineROIs.zip saved");	
	
	run("Set Scale...", "distance=0");
	
	if(isOpen("Results")){;
		//			IJ.deleteRows(0,nResults);
		selectWindow("Results"); 
		run("Close"); 
	}
	
	
	
	roiManager("deselect");
	roiManager("Measure");
	
	saveAs("measurements", dir+channelImageTitle+"lineROIs.txt");
	saveAs("measurements", dir+channelImageTitle+"lineROIs.xls");

	print (dir+channelImageTitle+"lineROIs.xls and .txt saved");

// Iterate through ROIs, save profile from kymograph

	if(isOpen("Results")){;
		//			IJ.deleteRows(0,nResults);
		selectWindow("Results"); 
		run("Close"); 
	}

	roiManager("Set Line Width", profileWidth);
	run("Set Measurements...", "  redirect=None decimal=5");


	for(j=0;j<roiNb;j++){	
	
	if(isOpen("Results")){;
		//			IJ.deleteRows(0,nResults);
		selectWindow("Results"); 
		run("Close"); 
	}
	
		k = j+1;
		//curROInb = d2s(k);
		//print(k);
		roiManager("Select", j);
		setSlice(curSlice);		

		profile = getProfile();
		
		for (i=0; i<profile.length; i++) { 
			setResult("Value", i, profile[i]); 
			} 
		updateResults;
		
//		saveAs("Results", "/Users/mathewakamatsu/Downloads/Plot Values"+k+".xls");
		saveAs("Results", dir+channelImageTitle+k+"profiles.xls");
		saveAs("Results", dir+channelImageTitle+k+"profiles.txt");
		
		
		//print ("we did it");
	}
	roiManager("deselect");
	print (dir+channelImageTitle+"profiles.xls and .txt saved");
	
	//print("the end");
	// roiManager("Delete");
	
	// Get all the Y coordinates of the lines measured in results
	
	
	
	
}

macro "Make multicolor Hyperstack Action Tool- C059T3e16H" {
	
	getDimensions(whole_w, whole_h, whole_channels, whole_slices, whole_frames);

	// ask how many channels?
	#@ Double nChannels
	
	run("Stack to Hyperstack...", "order=xyztc channels="+nChannels+" slices=1 frames="+d2s(whole_slices/nChannels)+" display=Composite");

}

