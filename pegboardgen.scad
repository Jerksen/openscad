// Holder Generator
// Based on an original Design by Marius Gheorghescu, November 2014
// Heavily modified to make it more maintainable and able to support screw and magnet mounts


// TODO - update to make an option for screw mounts instead of pegs

// TODO - offset seems to break it when holder_angle != 0

// TODO - strength factor of > 0.66 leaves gaps when there is a closed bottom (in a 55Rx30 test at least)

// preview[view:north, tilt:bottom diagonal]

epsilon = 0.1;

// magnet params
size_mag = [25.4/4+epsilon, 25.4/16+epsilon, 25.4/4+epsilon];
mag_edge_space = 2;
mag_space = 40;

// how thick are the walls. Hint: 6*extrusion width produces the best results.
wall_thickness = 1.85;

// how thick are the outer walls between magnet cavities and the metal surface
mag_wall_thickness = .9;

/* [Hidden] */

// set to 1 for a shallow debug, 2 for a deep debug
DEBUG = 1;

// dimensions the same outside US?
hole_spacing = 25.4;
hole_size = 6.0035;
board_thickness = 5;

// what is the $fn parameter for holders
fn = 32;

clip_height = 2*hole_size + 2;
$fn = fn;

/* [Helper Functions] */

// give the total dimensions for a given holder array
function total_width(size, count, spacers=[0,0]) = size.x*count.x + (count.x - 1)*(max(spacers.x, wall_thickness)) + 2*wall_thickness;
function total_depth(size, count, spacers=[0,0], row_offset=0) = size.y*count.y + (count.y - 1)*(max(spacers.y, wall_thickness)) + wall_thickness + max(wall_thickness, row_offset);
function total_height(size, sf=0) = size.z + val(sf, 0, 1);
function total_size(size, count, spacers=[0,0], row_offset=0, sf=0) = 
  [total_width(size, count, spacers),
   total_depth(size, count, spacers, row_offset),
   total_height(size, sf)];

// rounds p up to the min or down to the max
function val(p, minimum, maximum) = max(minimum, min(maximum, p));

module round_rect_ex(x1, y1, x2, y2, z, r1, r2, center=false) {
	$fn=50;
	brim = z/10;
  if (DEBUG >= 2) {
    echo(x1=x1, y1=y1, x2=x2, y2=y2, z=z, r1=r1, r2=r2);
  }
  trans = center ? [0,0,0] : [x1/2, y1/2, z/2];

  translate(trans)
	hull() {
        translate([-x1/2 + r1, y1/2 - r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([x1/2 - r1, y1/2 - r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([-x1/2 + r1, -y1/2 + r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([x1/2 - r1, -y1/2 + r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);

        translate([-x2/2 + r2, y2/2 - r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([x2/2 - r2, y2/2 - r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([-x2/2 + r2, -y2/2 + r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([x2/2 - r2, -y2/2 + r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);

    }
}

module pin(clip) {
/* param clip: boolean
        if true, make a top clip, if false, make a standard peg
*/
	translate([0,0, board_thickness*1.5/2])
  rotate([0,0,15])
	cylinder(r=hole_size/2, h=board_thickness*1.5+epsilon, center=true, $fn=12);

	if (clip) {
		//
		rotate([0,0,90])
		intersection() {
			translate([0, 0, hole_size-epsilon])
				cube([hole_size+2*epsilon, clip_height, 2*hole_size], center=true);

			// [-hole_size/2 - 1.95,0, board_thickness/2]
			translate([0, hole_size/2 + 2, board_thickness/2]) 
				rotate([0, 90, 0])
				rotate_extrude(convexity = 5, $fn=20)
				translate([5, 0, 0])
				 circle(r = (hole_size*0.95)/2); 
			
			translate([0, hole_size/2 + 2 - 1.6, board_thickness/2]) 
				rotate([45,0,0])
				translate([0, -0, hole_size*0.6])
					cube([hole_size+2*epsilon, 3*hole_size, hole_size], center=true);
		}
	}
}

module pinboard_clips() {
/*  make all the pins based on the size of the holder.
    
*/
	rotate([0,90,0])
	for(i=[0:round(total_width/hole_spacing)]) {
		for(j=[0:max(strength_factor, round(holder.z/hole_spacing))]) {

			translate([
				j*hole_spacing, 
				-hole_spacing*(round(total_width/hole_spacing)/2) + i*hole_spacing, 
				0])
					pin(j==0);
		}
	}
}

module pinboard() {
/*
    create the plate that the pins and clips attach to
    pins and clips and plate holding it all together
*/
	rotate([0,90,0])
	translate([-epsilon, 0, -wall_thickness + epsilon])
	hull() {
		translate([-clip_height/2 + hole_size/2, 
			-hole_spacing*(round(total_width/hole_spacing)/2),0])
			cylinder(r=hole_size/2, h=wall_thickness);

		translate([-clip_height/2 + hole_size/2, 
			hole_spacing*(round(total_width/hole_spacing)/2),0])
			cylinder(r=hole_size/2,  h=wall_thickness);

		translate([max(strength_factor, round(holder.z/hole_spacing))*hole_spacing,
			-hole_spacing*(round(total_width/hole_spacing)/2),0])
			cylinder(r=hole_size/2, h=wall_thickness);

		translate([max(strength_factor, round(holder.z/hole_spacing))*hole_spacing,
			hole_spacing*(round(total_width/hole_spacing)/2),0])
			cylinder(r=hole_size/2,  h=wall_thickness);

	}
}
module mag_holes(size, r) {
  /*
    make the holes for the magnets
  */

  //figure out count/spacing for holes  
  mag_count = [max(1, ceil((size.x-size_mag.x-2*max(r, wall_thickness))/mag_space)),
                0,
                max(1, ceil((size.z-2*mag_edge_space-size_mag.z)/mag_space))];
  
  mag_step = [(size.x-r*2-size_mag.x-2*wall_thickness)/mag_count.x,
              0,
              (size.z-mag_edge_space*2-size_mag.z)/mag_count.z];

  if (DEBUG) {
    echo(mag_count=mag_count, mag_step=mag_step);
  }
  
  for (i=[0:mag_count.x]) {
    for (j=[0:mag_count.z]) {
      if (DEBUG) {
        echo(mag=[i,j], x=r+i*mag_step.x, z=(mag_edge_space+j*mag_step.z));
      }
      translate([r+i*mag_step.x,0,mag_edge_space+j*mag_step.z])
      cube(size_mag);
    } // loop j over z
  } // loop i over x
}


module mag_holder_shell(size, negative=false) {
  /*
    create the shell of a special peice that is made to contain magnets
    and interface to a holder
  
  param negative: bool, return the normal shell or the negative hole for the holder
  
  */
  scl = !negative ? [1,1,1] : [(size.x+2*epsilon)/size.x,(size.y+2*epsilon)/size.y,1];
  sclbase = !negative ? [1,1,1] : [0,0,0];
  base_size = [size_mag.x+2*wall_thickness,
              size_mag.y+wall_thickness+mag_wall_thickness,
              size.z];
  
  echo(base_size=base_size);
  
  //flange dimensions
  fsize1 = [wall_thickness*2, epsilon, base_size.z-wall_thickness];
  fsize2 = [wall_thickness*6, fsize1.y, fsize1.z];
  
  scale(scl) {
    // make the base that contains the magnets
    scale(sclbase)
    cube(base_size);
    
    translate([(base_size.x-fsize1.x)/2,wall_thickness*2,0]) {
      
      // connect the base to the flange
      cube([fsize1.x, fsize1.x, fsize1.z]);
    
      // create the flange
      translate([0,fsize1.x,0])
      hull () {
        cube (fsize1);
        translate ([-(fsize2.x-fsize1.x)/2, (fsize2.x-fsize1.x)/2, 0])
        cube (fsize2);
      }
    }
  }
  
}

module holder_element(id, size, r, taper=1, cb=1, co=0, a=0, front = false) {
  /*
    create one of the elements of the holder:
    param id: str, type of element
      outer: outer shell
      inner: inner shell
      hole: through hole
    param r: corner radius of the holder
    param taper: float 0-1, ratio of bottom dimensions to top dimensions
    param cb: float 0-1, thickness of bottom as a % of wall_thickness.
                      0 = open bottom, 1 = solid bottom
    param co: float 0-1, cutout front as a % of the front dimension
    param a: float -45 to 45, angle of the holder with + to the front
    param front: bool, is the holder at the front. Only applicable if co > 0
  */
  if (id == "outer") {
    round_rect_ex(
					(size.x + 2*wall_thickness), 
					(size.y + 2*wall_thickness), 
					(size.x + 2*wall_thickness)*taper, 
					(size.y + 2*wall_thickness)*taper, 
					size.z, 
					r + epsilon, 
					r*taper + epsilon);
  } else if (id == "inner") {
    translate([wall_thickness,wall_thickness,cb*wall_thickness]) {
      round_rect_ex(
            size.x, 
            size.y, 
            size.x*taper, 
            size.y*taper, 
            size.z, 
            r + epsilon, 
            r*taper + epsilon);
      if (front && co > 0) {
        hull() {
            scale([1.0, co, 1.0])
              round_rect_ex(
              size.x, 
              size.y, 
              size.x*taper, 
              size.y*taper, 
              size.z+2*epsilon,
              r + epsilon, 
              r*taper + epsilon);

            translate([0-(holder.x + 2*wall_thickness), 0,0])
            scale([1.0, co, 1.0])
              round_rect_ex(
              size.x, 
              size.y, 
              size.x*taper, 
              size.y*taper, 
              size.z+2*epsilon,
              r+ epsilon, 
              r*taper+ epsilon);
            } //hull
          } // if (front)
      } // translate
      
      if (cb*wall_thickness < epsilon) {
      translate([wall_thickness, wall_thickness, -size.z/2]) {
        round_rect_ex(
              size.x*taper, 
              size.y*taper, 
              size.x*taper, 
              size.y*taper, 
              size.z*2, 
              r+ epsilon, 
              r+ epsilon);
        
        if (front && co > 0) {
          hull () {
            scale([1.0, co, 1.0])
            round_rect_ex(
              size.x*taper, 
              size.y*taper, 
              size.x*taper, 
              size.y*taper, 
              size.z*2,
              r*taper+ epsilon, 
              r*taper+ epsilon);
            
              translate([0-(size.y + 2*wall_thickness), 0,0])
              scale([1.0, co, 1.0])
              round_rect_ex(
                size.x*taper, 
                size.y*taper, 
                size.x*taper, 
                size.y*taper, 
                size.z*2,
                r*taper + epsilon, 
                r*taper + epsilon);
          } // hull
        } // if (front)
      } // if !closed bottom 
    } // translate
  } // switch
}

module holder(size, front=false) {
  
  /* create a holder
  param size: [width, depth, height]
  param front: if true, the front will be cutout based on holder_cutout_side value
  
  this shouldn't actually be used anymore...
  */
  
  cb = (closed_bottom*wall_thickness > epsilon);
  rotate([0, holder_angle, 0])
  difference() {
    //main outer shell is the base
    holder_element("outer", size);
    
    // cutout the cavity
    holder_element("inner", size, front);
    
    // cutout the bottom if we need to
    if (!cb)
      holder_element("hole", size, front);
  }
}

module holder_element_array(id, size, radius, count, taper=1, row_offset=0, spacers = [0,0], sf=0, cb=1, co=0, a=0) {
  /*
    create one element type for all holders in an array:
    param id: str, type of element
      outer: outer shell
      inner: inner shell
      hole: through hole
    param size: [width, depth, height] of each oriface
    param radius: corner radius of the holder
    param rows, cols: int, how many rows (total depth) and cols (total width)
    param taper: float 0-1, ratio of bottom dimensions to top dimensions
    param row_offset: float, how far the rear row should be from the mounts
    param spacers: [col space, row space] in mm
    param sf: float 0-1, strength factor adds a support under the whole structure
    param cb: float 0-1, thickness of bottom as a % of wall_thickness.
                      0 = open bottom, 1 = solid bottom
    param co: float 0-1, cutout front as a % of the front dimension
    param a: float -45 to 45, angle of the holder with + to the front
  */

  // do some math
  r = min(size.x/2, size.y/2, radius);
                                          
  // loop through rows and columns, adding bits as we go
  for(i=[0: count.x - 1]) {
    for (j=[0:count.y - 1]) {
      front = ((i==count.x)-1);
      trans = [i*(max(spacers.x, wall_thickness) + size.x), max(row_offset-wall_thickness,0) + j*(max(spacers.y, wall_thickness) + size.y), 0];
      if (DEBUG) {
        echo(holder=[i,j]);
        echo(trans=trans);
      }
      
      // move holder based on either spacer or wall thickness
      translate(trans)
      holder_element(id, size, r, taper, cb, co, a, j == (count.x-1));
      
      // if the first row and offset > 0, make sure the holder extends to the back
      if (j == 0 && id == "outer") {
        translate([i*(max(spacers.x, wall_thickness) + size.x),0,0])
        holder_element(id, size, r);
      }
    } // col loop
  } // row loop
}

module holder_array(size, radius, count, taper=1, row_offset=0, spacers = [0,0], sf=0, cb=1, co=0, a=0) {
  /*
    create an array of holders
    param id: str, type of element
      outer: outer shell
      inner: inner shell
      hole: through hole
    param size: [width, depth, height] of each oriface
    param radius: corner radius of the holder
    param count: [cols, rows], how many rows (total depth) and cols (total width)
    param taper: float 0-1, ratio of bottom dimensions to top dimensions
    param row_offset: float, how far the rear row should be from the mounts
    param spacers: [col space, row space] in mm
    param sf: float 0-1, strength factor adds a support under the whole structure
    param cb: float 0-1, thickness of bottom as a % of wall_thickness.
                      0 = open bottom, 1 = solid bottom
    param co: float 0-1, cutout front as a % of the front dimension
    param a: float -45 to 45, angle of the holder with + to the front
*/
  difference() {
    hull () holder_element_array("outer", size, radius, count, taper, row_offset, spacers, sf, cb, co, a);
    holder_element_array("inner", size, radius, count, taper, row_offset, spacers, sf, cb, co, a);
    
    if (cb*wall_thickness < epsilon) {
      holder_element_array("hole", size, radius, count, taper, row_offset, spacers, sf, cb, co, a);
    }
  }
}

module pegstr() {
	difference() {
		union() {
            
            // create the pinboard
			pinboard();


            // create the overall shape of the holder
			difference() {
				hull() {
					pinboard();
	
					intersection() {
                        // TODO - this didn't work when closed bottom was 1 and strength factor was < 0.5 - there would be no bottom. 
                        // old translate had (strength_factor-.5). look into it and make it more robust
                        // the current way with +.5 screws with the cutout
						translate([-holder_offset - (strength_factor+.5)*total_depth - wall_thickness/4 - col_space*(col_count-1),0,0])
						cube([
							total_depth + 2*wall_thickness, 
							total_width + wall_thickness, 
							2*holder.z
						], center=true);
	
						!holder(0);
	
					}	
				}

				if (closed_bottom*wall_thickness < epsilon) {
						holder(2);
				}

			}

			color([1,0,0])
			difference() {
				holder(0);
				holder(2);
			}

			color([1,0,0])
				pinboard_clips();
		}
        
		holder(1);

	}
}
module patboard_mags() {
  /*
  creates a magnetic card and marker holder for patboard stuff
  
  _m is for markers, _c is for cards
  */
  h = 40;
  count_m = [1, 4];
  count_c = [3, 1];
  offset_c = wall_thickness+size_mag.y+mag_wall_thickness;
  size_m = [11,11,h];
  tsize_m = total_size(size_m, count_m);
  size_c = [68, tsize_m.y-wall_thickness-offset_c, h];
  tsize_c = total_size(size_c, count_c, row_offset=offset_c);
  r_m = size_m.x/2;
  r_c = 2.5;
  
  echo(tsize_c=tsize_c, tsize_m=tsize_m);
  
  // create the card holder with embedded magnets
  translate([tsize_m.x, 0, 0])
  difference() {
    hull() {
      cube(tsize_c - [r_c,0,0]);
      holder_element_array("outer", size_c, r_c, count_c,row_offset=offset_c);
    }
    holder_element_array("inner", size_c, r_c, count_c,row_offset=offset_c);
    
    translate([0,mag_wall_thickness,0])
    mag_holes(tsize_c, r_c);
  }
  
  // create the marker holder with a flat edge on the joint to the card
  // holder
  difference() {
    hull() {
      translate ([r_m, 0,0])
      cube(tsize_m - [r_m, 0, 0]);
      holder_element_array("outer",size_m, r_m, count_m);
      
    }
    holder_element_array("inner",size_m, r_m, count_m, cb=0);
  }
  
}

//rotate([180,0,0]) pegstr();

//holder([holder.y,holder.x,holder.z]);
//patboard_mags();

mag_holder_shell([20,20,100]);

//holder_element_array("outer", [10,40,10], 2.5, [1,4]);
