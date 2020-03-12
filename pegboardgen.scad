// Holder Generator
// Based on an original Design by Marius Gheorghescu, November 2014
// Heavily modified to make it more maintainable and able to support screw and magnet mounts


// TODO - update to make an option for screw mounts instead of pegs

// TODO - offset seems to break it when holder_angle != 0

// TODO - strength factor of > 0.66 leaves gaps when there is a closed bottom (in a 55Rx30 test at least)

// preview[view:north, tilt:bottom diagonal]

epsilon = 0.1;

// size of each orifice
// patboard cards
holder = [70, 40, 40];

// markers


// magnet params
magnet = [6+epsilon, 1+epsilon, 6+epsilon];
mag_edge_space = 2;
mag_space = 100;

// how thick are the walls. Hint: 6*extrusion width produces the best results.
wall_thickness = 1.85;

// how thick are the outer walls between magnet cavities and the metal surface
mag_wall_thickness = .4;

// how many times to repeat the holder on each axis
row_count = 3;
col_count = 1;

// how much space to put between the orifices
row_space = 0;
col_space = 0;

// orifice corner radius (roundness). Needs to be less than min(x,y)/2.
corner_radius = 2.5;

// Use values less than 1.0 to make the bottom of the holder narrow
taper_ratio = 1;

/* [Advanced] */

// offset from the peg board, typically 0 unless you have an object that needs clearance
holder_offset = 5;

// what ratio of the holders bottom is reinforced to the plate [0.0-1.0]
strength_factor = .66;

// for bins: what ratio of wall thickness to use for closing the bottom
closed_bottom = 1;

// what percentage to cut in the front (example to slip in a cable or make the tool snap from the side)
holder_cutout_side = 0.3;

// set an angle for the holder to prevent object from sliding or to view it better from the top
holder_angle = 0;


/* [Hidden] */

// set to true to print out stuff
DEBUG = false;

// what is the $fn parameter
holder_sides = max(50, min(20, holder.y*2));

// dimensions the same outside US?
hole_spacing = 25.4;
hole_size = 6.0035;
board_thickness = 5;

total_width = wall_thickness + row_count*(max(wall_thickness,row_space)+holder.x);
total_depth = wall_thickness + col_count*(max(wall_thickness,col_space)+holder.y);
total_height = round(holder.z/hole_spacing)*hole_spacing;
holder_roundness = min(corner_radius, holder.y/2, holder.x/2); 

if (DEBUG) {
  echo(tot_w=total_width, tot_d=total_depth);
  echo(roundness=holder_roundness);
}

// what is the $fn parameter for holders
fn = 32;

clip_height = 2*hole_size + 2;
$fn = fn;

module round_rect_ex(x1, y1, x2, y2, z, r1, r2, center=false) {
	$fn=holder_sides;
	brim = z/10;
  if (DEBUG) {
    echo(x1=x1, y1=y1, x2=x2, y2=y2, z=z, r1=r1, r2=r2);
  }
	//rotate([0,0,(holder_sides==6)?30:((holder_sides==4)?45:0)])
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

module mag_mount() {
  /*
    make a single vertical mount containing magnets
  
    magnets are top and bottom and spaced based on mag_spacing
  */
  w = magnet.x+2*wall_thickness;
  d = magnet.y+wall_thickness+mag_wall_thickness;
  h = holder.z;
  
  translate([w,0,0])
  rotate([0,0,180])
  difference () {
    cube([w,d,h]);
    
    translate([wall_thickness, mag_wall_thickness,0])
    mag_holes();
  }
}

module mag_holes() {
  /*
    make the holes for the magnets
  */

  
  // cavities
  mag_z_count = max(1, ceil((holder.z-2*mag_edge_space-magnet.z)/mag_space));
  mag_step = (holder.z-2*mag_edge_space-magnet.z)/mag_z_count;
  for (j=[0:mag_z_count]) {
    if (DEBUG) {
      echo(mag=j, z=(mag_edge_space+j*mag_step));
    }
    translate([0,0,mag_edge_space+j*mag_step])
    cube(magnet);
  } // loop j over z
}

module holder_element(id, size, front = false) {
  /*
    create one of the elements of the holder:
    param id: type of element
      outer: outer shell
      inner: inner shell
      hole: through hole
      f_inner: inner shell with partial front
      f_hole: through hole with partial front
  */
  if (id == "outer") {
    round_rect_ex(
					(size.y + 2*wall_thickness), 
					(size.x + 2*wall_thickness), 
					(size.y + 2*wall_thickness)*taper_ratio, 
					(size.x + 2*wall_thickness)*taper_ratio, 
					size.z, 
					holder_roundness + epsilon, 
					holder_roundness*taper_ratio + epsilon);
  } else if (id == "inner") {
    translate([wall_thickness,wall_thickness,closed_bottom*wall_thickness]) {
      round_rect_ex(
            size.y, 
            size.x, 
            size.y*taper_ratio, 
            size.x*taper_ratio, 
            size.z, 
            holder_roundness + epsilon, 
            holder_roundness*taper_ratio + epsilon);
      if (front && holder_cutout_side > 0) {
        hull() {
            scale([1.0, holder_cutout_side, 1.0])
              round_rect_ex(
              size.y, 
              size.x, 
              size.y*taper_ratio, 
              size.x*taper_ratio, 
              size.z+2*epsilon,
              holder_roundness + epsilon, 
              holder_roundness*taper_ratio + epsilon);

            translate([0-(holder.x + 2*wall_thickness), 0,0])
            scale([1.0, holder_cutout_side, 1.0])
              round_rect_ex(
              size.y, 
              size.x, 
              size.y*taper_ratio, 
              size.x*taper_ratio, 
              size.z+2*epsilon,
              holder_roundness + epsilon, 
              holder_roundness*taper_ratio + epsilon);
            } //hull
          } // if (front)
      } // translate
  } else if (id == "hole") {
    translate([wall_thickness, wall_thickness, 0]) {
      round_rect_ex(
            size.y*taper_ratio, 
            size.x*taper_ratio, 
            size.y*taper_ratio, 
            size.x*taper_ratio, 
            size.z*2, 
            holder_roundness + epsilon, 
            holder_roundness + epsilon);
      
      if (front && holder_cutout_side > 0) {
        hull () {
          scale([1.0, holder_cutout_side, 1.0])
          round_rect_ex(
            size.y*taper_ratio, 
            size.x*taper_ratio, 
            size.y*taper_ratio, 
            size.x*taper_ratio, 
            size.z*2,
            holder_roundness*taper_ratio + epsilon, 
            holder_roundness*taper_ratio + epsilon);
          
            translate([0-(size.y + 2*wall_thickness), 0,0])
            scale([1.0, holder_cutout_side, 1.0])
            round_rect_ex(
              size.y*taper_ratio, 
              size.x*taper_ratio, 
              size.y*taper_ratio, 
              size.x*taper_ratio, 
              size.z*2,
              holder_roundness*taper_ratio + epsilon, 
              holder_roundness*taper_ratio + epsilon);
        } // hull
      } // if (front)
    } // translate
  } // switch
}

module holder(size, front=false) {
  
  /* create a holder
  param size: [width, depth, height]
  param front: if true, the front will be cutout based on holder_cutout_side value
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

module holders_element(id) {
  
  // loop through rows and columns, adding bits as we go
  size = [holder.y, holder.x, holder.z];
  for(i=[0: row_count - 1]) {
    for (j=[0:col_count - 1]) {
      front = ((j==col_count)-1);
      trans = [i*(max(col_space, wall_thickness) + holder.x), j*(max(row_space, wall_thickness) + holder.y), 0];
      if (DEBUG) {
        echo(holder=[i,j]);
        echo(trans=trans);
      }
      
      // move holder based on either spacer or wall thickness
      translate(trans)
      holder_element(id, size, front);
    } // col loop
  } // row loop
}


module olders(negative, size) {
/*
    create an array of holders
    
*/
  
	for(x=[1:row_count]) {
		for(y=[1:col_count]) {
      x_pos = -total_depth + y*(holder.x+wall_thickness) + wall_thickness + (y-1)*col_space;
      y_pos = -total_width/2 + (holder.y+wall_thickness)/2 + (x-1)*(holder.y+wall_thickness) + wall_thickness/2 + (x-1)*row_space;
      
      xp2 = -wall_thickness*abs(sin(holder_angle))-0*abs((holder.x/2)*sin(holder_angle))-holder_offset-(holder.x + 2*wall_thickness)/2 - board_thickness/2;
      zp2 = -(holder.z/2)*sin(holder_angle) - holder.z/2 + clip_height/2;
      
      // translate to the last 
			translate([x_pos, y_pos, 0]) {
        rotate([0, holder_angle, 0]) translate([xp2,0,zp2]) cube(1);
		} // positioning
	} // for y
	} // for X
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
module magstr() {
  // create the holder
  difference () {
    hull() holders_element("outer");
    holders_element("inner");
  }
  
  mag_mount_count = max(1, ceil((total_width-holder_roundness*2-magnet.x-2*wall_thickness)/mag_space));
  mount_step = (total_width-holder_roundness*2-magnet.x-2*wall_thickness)/mag_mount_count;
  if (DEBUG) {
    echo(mount_count=mag_mount_count, step=mount_step);
  }
  
  if (mag_mount_count == 1) {
    if (DEBUG) {
      echo(single_mag_mnt=true, pos=total_width/2-magnet.x/2-wall_thickness);
    }
    translate([-magnet.x/2-wall_thickness,0,0])
    mag_mount();
  }
  
  for (i=[0:mag_mount_count]) {
    if (DEBUG) {
      echo(mag_mnt=i,pos=holder_roundness+i*mount_step);
    }
    translate([holder_roundness+i*mount_step, 0,0])
    mag_mount();
  } // for i over mag_mounts
}
//rotate([180,0,0]) pegstr();

//holder([holder.y,holder.x,holder.z]);
//mag_mount();

magstr();