// ZLAPS
// mvl_updater.ij
// 2019-2020 Martin H. Dominguez
// Gladstone Institutes



//script:
// check to see that we have most recent MIPs
// register the two most recent MIPs and create an alignment matrix
// open MVL file and update with alignment matrix, save new MVL file



file_sep = File.separator();
channel_to_use = 0; //0=green, 1=red for typical live setup


function return_timestamp_text() {
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
	TimeString ="Date: "+DayNames[dayOfWeek]+" ";
	if (dayOfMonth<10) {TimeString = TimeString+"0";}
	MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+"\nTime: ";
	if (hour<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+hour+":";
	if (minute<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+minute+":";
	if (second<10) {TimeString = TimeString+"0";}
	return TimeString+second;
}


function update_MVL(directory,input_array) { //,this_file_number) {
	if ( directory == "" || !File.exists(directory) ) { //this should not happen
		//Ask user to choose the input and output directories
		directory = getDirectory("Choose input directory");
	}

	baseDirectory = directory + file_sep + "MVL_Updater" + file_sep;

	//first, open input MVL file
	input_MVL = File.openAsString(directory + file_sep + input_array[3] + ".mvl");
	input_MVL_lines = split(input_MVL, "\n");
	view_line_numbers = newArray(0);
	view_line_view = newArray(0);
	delta_line = -1;
	old_deltas_parsed = newArray(0);

	for ( l=0; l<input_MVL_lines.length; l++ ) {
		if (indexOf(input_MVL_lines[l], "<Entry") >= 0) {
		//if ( matches(input_MVL_lines[l],".*<Entry.*") {
			//okay we have a view line represented here
			view_line_numbers = Array.concat( view_line_numbers, l );
			//view_line_text = Array.concat( view_line_text, l );
		} else if (indexOf(input_MVL_lines[l], "<!--OldDeltas:") >= 0) {
		//if ( matches(input_MVL_lines[l],".*<Entry.*") {
			//okay we have a view line represented here
			delta_line = l;
			//view_line_text = Array.concat( view_line_text, l );
		}
	}

	//get individual old deltas but will need to parse each again to get x,y,z,r old deltas for each view setup
	old_deltas_prefix = "    <!--OldDeltas:"; //default four spaces
	old_deltas_suffix = "-->"; //default is XML formatted comment
	if( delta_line >= 0 ) {
		//there is a delta line here
		start_index = indexOf(input_MVL_lines[delta_line], "<!--OldDeltas:");
		subline = substring(input_MVL_lines[delta_line], start_index + 14 );
		stop_index = indexOf(subline, "-->" );
		old_deltas_suffix = substring(subline, stop_index );
		subline = substring(subline, 0, stop_index );
		old_deltas_parsed = split( subline, "|" );
		old_deltas_prefix = substring(input_MVL_lines[delta_line], 0, start_index + 14);
	}

	if ( old_deltas_parsed.length == view_line_numbers.length ) {
		//do nothing
	} else {
		//there is a discrepancy between old_deltas_parsed and view_line_numbers, therefore, just set old deltas to 0
		old_deltas_parsed = newArray(view_line_numbers.length);
		for ( i=0; i<view_line_numbers.length; i++ ) {
			old_deltas_parsed[i] = "0,0,0,0"; //set old deltas to zero for this view setup
		}
	}

	//now, scan directory for files matching
	fileList = getFileList(directory + file_sep + "MVL_Updater");
	Array.sort(fileList);


	recent_images = newArray(0);
	older_images = newArray(0);

	for (i=0; i<fileList.length; i++) {
		if (endsWith(fileList[i], ".tif") ) {
			if ( startsWith(fileList[i], input_array[0] )) {
				recent_images = Array.concat( recent_images, fileList[i] );
			} else if (startsWith(fileList[i], input_array[1] )) {
				older_images = Array.concat( older_images, fileList[i] );
			}
		}
	}

	//go back to MVL data, and for each view setup entry, find corresponding files, register, and update MVL text
	logoutput = "";
	to_continue = true;

	for ( i=0; i<view_line_numbers.length; i++ ) {
		//print( "viewline " + i + " :" + input_MVL_lines[view_line_numbers[i]] );
		line = input_MVL_lines[view_line_numbers[i]]; //"    <Entry0 PositionX=\"105.415000\" PositionY=\"1979.956000\" PositionZ=\"200.383000\" PositionR=\"348.000028\">";
		start_index = indexOf(line, "<Entry");
		subline = substring(line, start_index );
		line_elements = split( subline );
		line = substring(line, 0, start_index);
		stop_index = indexOf(subline, " " );
		subline = substring(subline, 6, stop_index );
		//print( "Subline: " + subline );
		this_view_suffix = IJ.pad(d2s(parseInt(subline),0),2); //match the numbers at the end of the filename "LSFM_XXXX_TXXXX_C0_V**"

		//read the view positions from MVL file
		valueR = NaN;
		valueX = NaN;
		valueY = NaN;
		valueZ = NaN;
		for ( l=0; l<line_elements.length; l++ ) {
			if(startsWith(line_elements[l], "PositionR=") ) {
				this = split(line_elements[l],"=");
				this[1] = replace( this[1], "\"", "" );
				valueR = parseFloat(this[1]);
				//print ("Position R:" + valueR[1] );
			} else if(startsWith(line_elements[l], "PositionX=") ) {
				this = split(line_elements[l],"=");
				this[1] = replace( this[1], "\"", "" );
				valueX = parseFloat(this[1]);
				//print ("Position X:" + valueX[1] );
			} else if(startsWith(line_elements[l], "PositionY=") ) {
				this = split(line_elements[l],"=");
				this[1] = replace( this[1], "\"", "" );
				valueY = parseFloat(this[1]);
				//print ("Position Y:" + valueY[1] );
			} else if(startsWith(line_elements[l], "PositionZ=") ) {
				this = split(line_elements[l],"=");
				this[1] = replace( this[1], "\"", "" );
				valueZ = parseFloat(this[1]);
				//print ("Position Z:" + valueZ[1] );
			}
		}

		if ( isNaN(valueR)|| isNaN(valueX) || isNaN(valueZ) || isNaN(valueY) ) {
			continue;
		}

		//get old deltas here
		old_deltas_this = split( old_deltas_parsed[i], "," );
		old_delta_x = 0;
		old_delta_y = 0;
		old_delta_z = 0;
		old_delta_r = 0;
		old_delta_x = parseFloat( old_deltas_this[0] );
		old_delta_y = parseFloat( old_deltas_this[1] );
		old_delta_z = parseFloat( old_deltas_this[2] );
		old_delta_r = parseFloat( old_deltas_this[3] );

		valueR *= PI / 180; //convert to rad

		//okay, now find corresponding image files for this view suffix
		this_start_image_a = ""; //front
		this_finish_image_a = ""; //front
		this_start_image_b = ""; //side
		this_finish_image_b = ""; //side

		for ( j=0; j<recent_images.length; j++ ) {
			if ( startsWith(recent_images[j], input_array[0] + this_view_suffix ) ) {
				if (endsWith(recent_images[j], "a.tif") ) {
					this_finish_image_a = recent_images[j];
				} else if (endsWith(recent_images[j], "b.tif") ) {
					this_finish_image_b = recent_images[j];
				}
			}
		}
		for ( j=0; j<older_images.length; j++ ) {
			if ( startsWith(older_images[j], input_array[1] + this_view_suffix ) ) {
				if (endsWith(older_images[j], "a.tif") ) {
					this_start_image_a = older_images[j];
				} else if (endsWith(older_images[j], "b.tif") ) {
					this_start_image_b = older_images[j];
				}
			}
		}

		if ( this_start_image_a == "" || this_finish_image_a == "" ) {
			//exception
			to_continue = false;
			logoutput = logoutput + "exception created by null image name a:" + this_start_image_a + " or " + this_finish_image_a + "!\n";
			break;
		}
		if ( this_start_image_b == "" || this_finish_image_b == "" ) {
			//exception
			to_continue = false;
			logoutput = logoutput + "exception created by null image name b:" + this_start_image_b + " or " + this_finish_image_b + "!\n";
			break;
		}

		/*
		 * Process front views
		 *
		 */
		run("TIFF Virtual Stack...", "open=[" + baseDirectory + this_start_image_a + "]");
		run("TIFF Virtual Stack...", "open=[" + baseDirectory + this_finish_image_a + "]");

		//Measure center of mass on newer images -- not in pixels but will be in units of measurement
		ctr_of_mass_x = NaN;
		ctr_of_mass_y = NaN;
		run("Set Measurements...", "area center redirect=None decimal=3");
		run("Measure");
		row_num = nResults() - 1;
		ctr_of_mass_x = getResult("XM", row_num);
		ctr_of_mass_y = getResult("YM", row_num);

		logoutput = logoutput + "view line " + i + ", line number " + view_line_numbers[i] + ":\n" + "  a analysis:\n";

		//get voxel and image scaling factors
		getVoxelSize(vox_width, vox_height, vox_depth, vox_unit);

		//determine center of the image in length units (not pixels or voxels, then figure out if we are above, below, left, or right of that center
		getDimensions(dim_width, dim_height, dim_channels, dim_slices, dim_frames);
		logoutput = logoutput + "   ctr_of_mass_xy (image units): " + d2s(ctr_of_mass_x,2) + " x " + d2s(ctr_of_mass_y,2) + ", ctr_of_mass_movement_xy (pixels): ";
		if ( isNaN(ctr_of_mass_x) ) {
			ctr_of_mass_x = 0;
		} else {
			ctr_of_mass_x /= vox_width;
			ctr_of_mass_x = (dim_width / 2) - ctr_of_mass_x;
		}
		if ( isNaN(ctr_of_mass_y) ) {
			ctr_of_mass_y = 0;
		} else {
			ctr_of_mass_y /= vox_height;
			ctr_of_mass_y = (dim_height / 2) - ctr_of_mass_y;
		}
		logoutput = logoutput + d2s(ctr_of_mass_x,2) + " x " + d2s(ctr_of_mass_y,2) + "\n";

		//make all units micron
		if (vox_unit=="nm" || vox_unit=="nanometers" || vox_unit=="nanometer") {
			vox_width /= 1000;
			vox_height /= 1000;
			vox_depth /= 1000;
		} else if (vox_unit==getInfo("micrometer.abbreviation") || vox_unit=="um" || vox_unit=="microns" || vox_unit=="micron") {
			//do nothing
		} else if (vox_unit=="mm" || vox_unit=="millimeters" || vox_unit=="millimeter"){
			vox_width * = 1000;
			vox_height * = 1000;
			vox_depth * = 1000;
		} else if (vox_unit=="cm" || vox_unit=="centimeters" || vox_unit=="centimeter"){
			vox_width * = 10000;
			vox_height * = 10000;
			vox_depth * = 10000;
		} else if (vox_unit=="m" || vox_unit=="meters" || vox_unit=="meter"){
			vox_width * = 1000000;
			vox_height * = 1000000;
			vox_depth * = 1000000;
		} else {
			print ( "Cannot interpret voxel unit " + vox_unit + " for " + this_finish_image_a + "!" );
			logoutput = logoutput + "   exception created by cannot interpret voxel unit " + vox_unit + " for " + this_finish_image_a + "!\n";
			to_continue = false;
			break;
		}
		//how many microns are we off-center?
		ctr_of_mass_x *= vox_width;
		ctr_of_mass_y *= vox_height;

		print("\\Clear");
		print( "viewline " + i + " :" + input_MVL_lines[view_line_numbers[i]] );
		//print( "About to concatenate: " + img_id_array[0] + " " + img_id_array[1]  );
		run("Concatenate...", "open image1=[" + this_start_image_a + "] image2=[" + this_finish_image_a + "]");
		concat_stack = getImageID();
		run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.1 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=12 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.96 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Translation interpolate show_transformation_matrix");
		log_lines = split(getInfo("log"), "\n");
		close();

		if(isOpen(concat_stack)) {
			selectImage(concat_stack);
			close();
		}
		close("*");

		//Look at transformation matrix and extra delta pixel / delta micron transformations in 2D
		delta_y = 0;
		delta_z = 0;
		delta_x = 0;
		num_features = NaN;
		features_corresponding = newArray(2);
		for ( l=log_lines.length-1; l>=0; l-- ) {
			if (indexOf(log_lines[l], "AffineTransform") >= 0) {
				start_index = indexOf(log_lines[l], "[[");
				subline = substring(log_lines[l], start_index );
				subline = replace(subline,"\\[","");
				subline = replace(subline,"\\]","");
				subline = replace(subline,"\\ ","");
				//subline = replace(subline,",","");
				matrix = split(subline, ",");
				delta_x = parseFloat(matrix[2]) * vox_width;
				delta_y = 0 - (parseFloat(matrix[5]) * vox_height);

				//print( "Delta X: " + d2s(delta_x,5) + ", Delta Y: " + d2s(delta_y,5) );
				if (indexOf(log_lines[l-1], "potentially corresponding features identified") >= 0) {
					features_corresponding = split(log_lines[l-1], " ");
					num_features = parseInt( features_corresponding[0] );
					if ( isNaN(num_features) ) {
						//no number detected -- do nothing
					} else if ( num_features < 5 ) {
						//very few features detected, probably should take the transform with a grain of salt
						logoutput = logoutput + "   old_delta_x,old_delta_y: " + d2s(old_delta_x,3) + "," + d2s(old_delta_y,3) + "\n" + "   delta_x,delta_y: " + d2s(delta_x,3) + "," + d2s(delta_y,3) + "\n    probably should take this with a grain of salt since few corresponding features...";
						delta_x = 0;
						delta_y = 0;
					}
				}
				break;
			}
		}

		//update positions with transforms -- do not need trigonomety because X and Z coordinates are relative to the actual view angle, not to absolute positions
		//in imageJ: y goes from top-down, x goes from left-right
			//so if the object imaged moves down, it will have a negative delta Y transform
			//so if the object imaged moves to the right, it will have a negative delta X transform
		//in ZEN MVL file, which has relative positions (not absolute): y goes from down-up, x goes from left-right
			//so if you adjust y-position to move the object down, y-coordinate will go down
			//so if you adjust x-position to move the object right, x-coordinate will go up
			//so if you adjust z-position to move the z-section more in focus (end of z-stack), z-coordinate will go up
		//only adjust X and Y here, since we don't know anything about Z

		//add our old deltas since we will try to subtract the previous movement when images are compared -- only if there is a legitimate new delta though, versus don't ever add these deltas before we save the old deltas
		logoutput = logoutput + "   old_delta_x,old_delta_y: " + d2s(old_delta_x,3) + "," + d2s(old_delta_y,3) + "\n" + "   delta_x,delta_y: " + d2s(delta_x,3) + "," + d2s(delta_y,3) + "\n";
		delta_x += old_delta_x;
		delta_y += old_delta_y;

		//move center of mass of image toward center of screen -- rather than doing vectors and trigonomety, will just move 1um in each cardinal direction (x,y,z) to get center of mass toward the center of the image
		if ( ctr_of_mass_x > 5 ) { //at least 5 microns off-center to the left, need to move right
			delta_x += 1.5;
		} else if ( ctr_of_mass_x < -5 ) { //at least 5 microns off-center to the right, need to move left
			delta_x -= 1.5;
		}
		if ( ctr_of_mass_y > 5 ) { //at least 5 microns off-center above, need to move down
			delta_y -= 1.5;
		} else if ( ctr_of_mass_y < -5 ) { //at least 5 microns off-center, need to move up
			delta_y += 1.5;
		}
		logoutput = logoutput + "   start valueX,valueY: " + d2s(valueX,3) + "," + d2s(valueY,3) + "\n";
		valueX += delta_x;
		valueY += delta_y;
		logoutput = logoutput + "   finish valueX,valueY: " + d2s(valueX,3) + "," + d2s(valueY,3) + "\n" + "   final delta_x,final delta_y: " + d2s(delta_x,3) + "," + d2s(delta_y,3) + "\n";;

		//work on our new old deltas line
		old_deltas_this[0] = d2s(delta_x,4);
		old_deltas_this[1] = d2s(delta_y,4);


		//valueZ += delta_z; //Z: positive is closer to front of stack, negative is closer to back of stack

		/*
		 * Process side views
		 *
		 */
		run("TIFF Virtual Stack...", "open=[" + baseDirectory + this_start_image_b + "]");
		run("TIFF Virtual Stack...", "open=[" + baseDirectory + this_finish_image_b + "]");

		//Measure center of mass on newer images -- not in pixels but will be in units of measurement
		ctr_of_mass_z = NaN;
		run("Set Measurements...", "area center redirect=None decimal=3");
		run("Measure");
		//row_num = getValue("results.count")-1;
		row_num = nResults() - 1;
		ctr_of_mass_z = getResult("XM", row_num);

		//get voxel and image scaling factors
		getVoxelSize(vox_width, vox_height, vox_depth, vox_unit);

		logoutput = logoutput + "  b analysis:\n";

		//determine center of the image in length units (not pixels or voxels, then figure out if we are above, below, left, or right of that center
		getDimensions(dim_width, dim_height, dim_channels, dim_slices, dim_frames);
		logoutput = logoutput + "   ctr_of_mass_z (image units): " + d2s(ctr_of_mass_z,2) + ", ctr_of_mass_movement_z (pixels): ";
		if ( isNaN(ctr_of_mass_z) ) {
			ctr_of_mass_z = 0;
		} else {
			ctr_of_mass_z /= vox_width;
			ctr_of_mass_z = (dim_width / 2) - ctr_of_mass_z;
		}

		//make all units micron
		if (vox_unit=="nm" || vox_unit=="nanometers" || vox_unit=="nanometer") {
			vox_width /= 1000;
			vox_height /= 1000;
			vox_depth /= 1000;
		} else if (vox_unit==getInfo("micrometer.abbreviation") || vox_unit=="um" || vox_unit=="microns" || vox_unit=="micron") {
			//do nothing
		} else if (vox_unit=="mm" || vox_unit=="millimeters" || vox_unit=="millimeter"){
			vox_width * = 1000;
			vox_height * = 1000;
			vox_depth * = 1000;
		} else if (vox_unit=="cm" || vox_unit=="centimeters" || vox_unit=="centimeter"){
			vox_width * = 10000;
			vox_height * = 10000;
			vox_depth * = 10000;
		} else if (vox_unit=="m" || vox_unit=="meters" || vox_unit=="meter"){
			vox_width * = 1000000;
			vox_height * = 1000000;
			vox_depth * = 1000000;
		} else {
			print ( "Cannot interpret voxel unit " + vox_unit + " for " + this_finish_image_b + "!" );
			logoutput = logoutput + "   exception created by cannot interpret voxel unit " + vox_unit + " for " + this_finish_image_b + "!\n";
			to_continue = false;
			break;
		}

		//how many microns are we off-center?
		ctr_of_mass_z *= vox_width;
		logoutput = logoutput + d2s(ctr_of_mass_z,2) + "\n";

		print("\\Clear");
		//print( "viewline " + i + " :" + input_MVL_lines[view_line_numbers[i]] );
		//print( "About to concatenate: " + img_id_array[0] + " " + img_id_array[1]  );
		run("Concatenate...", "open image1=[" + this_start_image_b + "] image2=[" + this_finish_image_b + "]");
		concat_stack = getImageID();
		//run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.60 steps_per_scale_octave=10 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=8 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Translation interpolate show_transformation_matrix");
		run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.1 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=2048 feature_descriptor_size=12 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.96 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Translation interpolate show_transformation_matrix");
		log_lines = split(getInfo("log"), "\n");
		close();

		if(isOpen(concat_stack)) {
			//print("IsOpen");
			selectImage(concat_stack);
			close();
		}
		close("*");

		//Look at transformation matrix and extra delta pixel / delta micron transformations in 2D
		delta_y = 0;
		delta_z = 0;
		delta_x = 0;
		num_features = NaN;
		for ( l=log_lines.length-1; l>=0; l-- ) {
			if (indexOf(log_lines[l], "AffineTransform") >= 0) {
				start_index = indexOf(log_lines[l], "[[");
				subline = substring(log_lines[l], start_index );
				subline = replace(subline,"\\[","");
				subline = replace(subline,"\\]","");
				subline = replace(subline,"\\ ","");
				//subline = replace(subline,",","");
				matrix = split(subline, ",");
				delta_x = 0 - (parseFloat(matrix[2]) * vox_width);
				delta_y = 0 - (parseFloat(matrix[5]) * vox_height);

				//print( "Delta X: " + d2s(delta_x,5) + ", Delta Y: " + d2s(delta_y,5) );
				if (indexOf(log_lines[l-1], "potentially corresponding features identified") >= 0) {
					features_corresponding = split(log_lines[l-1], " ");
					num_features = parseInt( features_corresponding[0] );
					if ( isNaN(num_features) ) {
						//no number detected -- do nothing
					} else if ( num_features < 4 ) {
						//very few features detected, probably should take the transform with a grain of salt
						logoutput = logoutput + "   old_delta_z: " + d2s(old_delta_z,3) + "\n" + "   delta_z: " + d2s(delta_x,3) + "\n    probably should take this with a grain of salt since few corresponding features...";
						delta_x = 0;
						delta_y = 0;
					}
				}
				break;
			}
		}

		//update positions with transforms -- do not need trigonomety because X and Z coordinates are relative to the actual view angle, not to absolute positions
		//in imageJ: x goes from left-right
			//so if the object imaged moves to the right(aka closer to the end of Z-stack), it will have a negative delta X transform
		//in ZEN MVL file, which has relative positions (not absolute): y goes from down-up, x goes from left-right
			//so if you adjust z-position to move the z-section more in focus (end of z-stack), z-coordinate will go up -- so to move

		//add our old deltas since current transformation will try to move back to old position
		logoutput = logoutput + "   old_delta_z: " + d2s(old_delta_z,3) + "\n" + "   delta_z: " + d2s(delta_x,3) + "\n";
		delta_x += old_delta_z;

		//move center of mass of image toward center of screen -- rather than doing vectors and trigonomety, will just move 1um in each cardinal direction (x,y,z) to get center of mass toward the center of the image
		if ( ctr_of_mass_z > 5 ) { //at least 5 microns off-center to the x-left (i.e. end of z-stack is moved closer to the beginning)
			delta_x -= 1.5;
		} else if ( ctr_of_mass_x < -5 ) { //at least 5 microns off-center to the x-right (i.e. beginning of z-stack is moved closer to the end)
			delta_x += 1.5;
		}

		logoutput = logoutput + "   start valueZ: " + d2s(valueZ,3) + "\n";
		valueZ += delta_x; //Z: positive is closer to front of stack, negative is closer to back of stack
		logoutput = logoutput + "   finish valueZ: " + d2s(valueZ,3) + "\n" + "   final delta_z: " + d2s(delta_x,3) + "\n";

		//work on our new old deltas line
		old_deltas_this[2] = d2s(delta_x,4);
		old_deltas_this[3] = "0"; //delta_r should be zero since we are not yet advanced enough to modify rotation angle in lightsheet


		/*
		 * Update MVL text
		 *
		 */

		line = line + line_elements[0]; // first line element is "<Entry", so don't add space to beginning of that
		for ( l=1; l<line_elements.length; l++ ) {
			if(startsWith(line_elements[l], "PositionX=") ) {
				line_elements[l] = "PositionX=\"" + d2s(valueX,8) + "\"";
			} else if(startsWith(line_elements[l], "PositionY=") ) {
				line_elements[l] = "PositionY=\"" + d2s(valueY,8) + "\"";
			} else if(startsWith(line_elements[l], "PositionZ=") ) {
				line_elements[l] = "PositionZ=\"" + d2s(valueZ,8) + "\"";
			}

			line = line + " " + line_elements[l];
		}

		//replace the view setup line
		input_MVL_lines[view_line_numbers[i]] = line;

		//take care of reporting old deltas
		old_deltas_parsed[i] = old_deltas_this[0];
		for (l=1; l<old_deltas_this.length; l++ ) {
			old_deltas_parsed[i] = old_deltas_parsed[i] + "," + old_deltas_this[l];
		}
	}

	if ( to_continue == true ) {
		//take care of old delta reporting
		delta_line_out = old_deltas_prefix + old_deltas_parsed[0];
		for ( i=1; i<view_line_numbers.length; i++ ) {
			delta_line_out = delta_line_out + "|" + old_deltas_parsed[i];
		}
		delta_line_out = delta_line_out + old_deltas_suffix;

		//write the new MVL file
		output_file = "";

		//update output file text
		if ( delta_line >= 0 ) {
			//replace old delta line
			input_MVL_lines[delta_line] = delta_line_out;
			for ( l=0; l<input_MVL_lines.length; l++ ) {
				output_file = output_file + input_MVL_lines[l] + "\n";
			}
		} else {
			written = false;
			for ( l=0; l<input_MVL_lines.length; l++ ) {
				output_file = output_file + input_MVL_lines[l] + "\n";
				if (indexOf(input_MVL_lines[l], "<Comment") >= 0) {
					//we located the designated comment section of the MVL file
					output_file = output_file + delta_line_out + "\n";
					written = true;
				}
			}

			if ( written == false ) {
				//no designated comment section, so place at very end of file
				output_file = output_file + delta_line_out + "\n";
			}
		}

		print( "Saving updated MVL to: " + directory + file_sep + input_array[2] + ".mvl" );
		logoutput = logoutput + "   saving updated MVL to: " + directory + file_sep + input_array[2] + ".mvl\n";
		delete_result = File.delete( directory + file_sep + input_array[2] + ".mvl" ); //throw away result
		filehandle = File.open(directory + file_sep + input_array[2] + ".mvl");
		print( filehandle, output_file );
		File.close( filehandle);
	} else {
		print( "Exception, MVL " + directory + file_sep + input_array[2] + ".mvl not saved!" );
		logoutput = logoutput + "   exception, MVL " + directory + file_sep + input_array[2] + ".mvl not saved!\n";
	}

	//log activity of this function
	File.append( "------------" + return_timestamp_text()  + "------------\n" + directory + file_sep + input_array[2] + ".mvl:\n" + logoutput, baseDirectory + "MVL_update.log" );
}

function return_most_recent_MVL(directory) {
	if ( directory == "" || !File.exists(directory) ) { //this should not happen
		//Ask user to choose the input and output directories
		directory = getDirectory("Choose input directory");
	}
	fileList = getFileList(directory);
	Array.sort(fileList);
	i = fileList.length-1; //counter for actual file index to process in fileList -- start at the end of the list
	for (j=0; j<fileList.length; j++) {
		if (endsWith(fileList[i], ".mvl") && startsWith(fileList[i], "LSFM_")) {
			//now, remove .mvl from end of filename
			name_ext = split(fileList[i],".");

			filepaddedname = "";
			for (n=0; n<name_ext.length-1; n++) {
				filepaddedname += name_ext[n];
			}

			return filepaddedname;
		}
		i--; //work from last name backward
	}
	return "";
}

function return_two_most_recent_MIPs(directory,current_MVL_identity) { //,this_file_number) {

	if ( directory == "" || !File.exists(directory) ) { //this should not happen
		//Ask user to choose the input and output directories
		directory = getDirectory("Choose input directory");
	}
	fileList = getFileList(directory);
	Array.sort(fileList);

	outputDirectory = directory + file_sep + "MVL_Updater" + file_sep;
	File.makeDirectory(outputDirectory);

	//Count the maximum number of positions and slices in dataset
	run("Bio-Formats Macro Extensions");

	newPosition = 0;
	newSlice = 0;
	maxPosition = 0;
	maxSlice = 0;
	add_this_file = false;

	processList = newArray(0);
	unique_PSF_filenames = newArray(0);
	unique_PSF_parameters = newArray(0);

	//here is the output of this function
	output_array = newArray(3); //will be of the format (last timepoint, second-to-last timepoint, next MVL file identity)
	output_array[0] = "";
	output_array[1] = "";
	output_array[2] = "";
	output_array_pointer = 0; //when this counter reaches 2, we have processed the final two timepoints and are ready to move on to the registration and MVL file stuff


	i = fileList.length-1; //counter for actual file index to process in fileList -- start at the end of the list
	for (j=0; j<fileList.length; j++) {
		//print( "Loop j: " + j + "/" + i + "::" + fileList[j]);
		//when this counter reaches 2, we have processed the final two timepoints and are ready to move on to the registration and MVL file stuff
		if ( output_array_pointer > 1 ) {
			break;
		}

		if (endsWith(fileList[i], ".czi") && startsWith(fileList[i], "LSFM_")) {
			//now, remove .czi from end of filename
			name_ext = split(fileList[i],".");

			filepaddedname = "";
			for (n=0; n<name_ext.length-1; n++) {
				filepaddedname += name_ext[n];
			}
			file = directory + file_sep + fileList[i];

			//figure out time number by parsing filename "LSFM_XXXX", where XXXX is the timepoint number
			name_ext = split(filepaddedname,"_");
			this_time =  parseInt(name_ext[1]);

			//print( "Interrogating: " + file );
			Ext.setId(file);
			Ext.getSeriesCount(nPositions);

			//get lightsheet data for each channel
			num_channels = 0;
			max_channels = 0;
			num_time = 0;
			max_time = 0;
			for(a=0; a<nPositions; a++) {
				Ext.setSeries(a);
				Ext.getSizeC(num_channels);
				Ext.getSizeT(num_time);

				if ( num_channels > max_channels ) {
					max_channels = num_channels;
				}
				if ( num_time > max_time ) {
					max_time = num_time;
				}
			}

			this_channel = channel_to_use;

			//establish naming conventions for the MIPs, and increment most recent timepoint number to generate the name of the next MVL
			fileoutname = "LSFM_" + IJ.pad(this_time,4) + "_T" + IJ.pad(max_time-1,4) + "_C0_V"; // + IJ.pad(d2s(a,1));
			if ( output_array_pointer == 0 ) { //this is the absolute most recent timepoint seen
				output_array[2] = "LSFM_" + IJ.pad(this_time+1,4);
			}
			output_array[output_array_pointer] = fileoutname;
			output_array_pointer++; //if this view is represented in the final files, assume all other views are either there now or will be created on successive passes of the for a=0 loop
			t = max_time -1;  //actual index of time positions to use when opening files -- start with the last timepoint

			for(a=0; a<nPositions; a++) {
				//establish this file name
				this_view_outname = fileoutname + IJ.pad(d2s(a,0),2);
					//if this view exists, dont waste time processing or even opening the CZI file
				if ( File.exists(outputDirectory + this_view_outname + "a.tif") && File.exists(outputDirectory + this_view_outname + "b.tif" ) ) {
					continue;
				}

				//print ("About to open " + "Bio-Formats", "open=[" + file + "] color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_"+ d2s(a+1,0) + " t_begin_" + d2s(a+1,0) + "=" + d2s(t+1,0) + " t_end_" + d2s(a+1,0) + "=" + d2s(t+1,0) + " t_step_" + d2s(a+1,0) + "=1" );
				if ( nPositions == 1 ) {
					run("Bio-Formats", "open=[" + file + "] color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT " + " t_begin=" + d2s(t+1,0) + " t_end=" + d2s(t+1,0) + " t_step=1" + " c_begin=" + d2s(this_channel+1,0) + " c_end=" + d2s(this_channel+1,0) + " c_step=1"  );
				} else {
					run("Bio-Formats", "open=[" + file + "] color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_"+ d2s(a+1,0) + " t_begin_" + d2s(a+1,0) + "=" + d2s(t+1,0) + " t_end_" + d2s(a+1,0) + "=" + d2s(t+1,0) + " t_step_" + d2s(a+1,0) + "=1" + " c_begin_" + d2s(a+1,0) + "=" + d2s(this_channel+1,0) + " c_end_" + d2s(a+1,0) + "=" + d2s(this_channel+1,0) + " c_step_" + d2s(a+1,0) + "=1");
				}

				//Get name and basic data of opened stack
				title = getTitle();
				getDimensions(dim_width, dim_height, dim_channels, dim_slices, dim_frames);
				getVoxelSize(vox_width, vox_height, vox_depth, vox_unit);
				img_id_orig = getImageID();

				//count back and delete blank images
				setSlice(dim_slices);
				getStatistics( area, mean );
				if ( mean < 10 ) { //we potentially have a
					//print( "Mean is : " + d2s(mean,4) + " on slice " + d2s(dim_slices,0) );

					final_slice = dim_slices-1;

					for (ss=dim_slices-10; ss>0; ss-=10 ) { //decrement 10 to find the first slice with data
						setSlice(ss);
						getStatistics( area, mean );
						//print( " ...checking mean: " + d2s(mean,4) + " on slice " + d2s(ss,0) );
						if ( mean > 10 ) {
							//okay pinpoint exact end of stack now
							for (tt=ss+9; tt>=ss; tt-- ) { //decrement individual slices to find the first slice with data
								setSlice(tt);
								getStatistics( area, mean );
								//print( "    ...checking mean: " + d2s(mean,4) + " on slice " + d2s(tt,0) );
								if ( mean > 10 ) { //okay we found the end
									final_slice = tt;
									break;
								}
							}
							break;
						}
					}

					//delete black images: for backward compatibility with older ImageJ (preferred since faster to start than Fiji), use "Make Substack" and delete rather than "Slice Remover"
					//run("Slice Remover", "first=" + d2s(final_slice+1,0) + " last=" + d2s(dim_slices,0) + " increment=1");
					run("Make Substack...", "delete slices=" + d2s(final_slice+1,0) + "-" + d2s(dim_slices,0) );
					close();
				}

                //remove background within the stack
                run("Z Project...", "projection=[Min Intensity]");
				average_img = getTitle();
				imageCalculator("Subtract stack",img_id_orig,average_img);
				selectWindow(average_img);
				close();

				//create MIP -- from front
				run("Z Project...", "projection=[Max Intensity] all");
				run("Enhance Contrast...", "saturated=0.001 normalize");
				run("8-bit");
				setVoxelSize(vox_width, vox_height, vox_depth, vox_unit);

				//okay write TIF file
				delete_result = File.delete( outputDirectory + this_view_outname + "a.tif" ); //throw away result
				saveAs("Tiff", outputDirectory + this_view_outname + "a.tif" );
				close();

				//create MIP -- from side
				selectImage(img_id_orig);
				run("Reslice [/]...", "output=2.000 start=Top rotate avoid");
				img_id_reslice = getImageID();
				run("Z Project...", "projection=[Max Intensity]");
				run("Enhance Contrast...", "saturated=0.001 normalize");
				run("8-bit");
				delete_result = File.delete( outputDirectory + this_view_outname + "b.tif" ); //throw away result
				saveAs("Tiff", outputDirectory + this_view_outname + "b.tif" );
				close();

				//close original image
				selectImage(img_id_orig);
				close();

				//close the reslice image
				selectImage(img_id_reslice);
				close();

			}

			close("*");   //Close original concatenated stack
			t--;//work from most recent back
		}
		i--; //work from end, then backward

		Ext.close();
		call("java.lang.System.gc");
	}

	return output_array;
}


/*
 * Main here
 *
 */

//parse/process command line
arglist = getArgument();
if (arglist == "" ) {
	in_directory = getDirectory("Choose input directory");
} else {
	list = split(arglist,"###");
	in_directory = list[0];
	if ( in_directory == "" || !File.exists(in_directory) ) {
		//Ask user to choose the input and output directories
		in_directory = getDirectory("Choose input directory");
	}
	if ( list.length > 1 ) {
		suggested_channel = parseInt(list[1]);
		if ( isNaN(suggested_channel) || suggested_channel < 0 ) {
			//do nothing
		} else {
			channel_to_use = suggested_channel;
		}
	}
}

//now do the work of main section
setBatchMode(true);
name_of_this_MVL = return_most_recent_MVL(in_directory);
if ( name_of_this_MVL == NaN || name_of_this_MVL == "" ) {
	exit();
}
files_to_compare = return_two_most_recent_MIPs(in_directory,name_of_this_MVL);
if ( files_to_compare[0] != "" && files_to_compare[1] != "" && files_to_compare[2] != "" ) {
	files_to_compare = Array.concat( files_to_compare, name_of_this_MVL );
	update_MVL( in_directory, files_to_compare );
} else {
	print( "Unable to run update_MVL" );
	print( files_to_compare[0] + "::" + files_to_compare[1] + "::" + files_to_compare[2] + "::" + name_of_this_MVL );
	exit();
}

//exit program
run("Quit");
eval("script", "System.exit(0);");
