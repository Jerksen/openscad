/*

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>

    This software is based on an original Design by Marius Gheorghescu, November 2014 and was
    heavily modified to make it more maintainable and able to support screw and magnet mounts


	TODO - update to make an option for screw mounts instead of pegs
*/

/**********************
includes
**********************/
include <common.scad>

/**********************
globals
**********************/
e = 0.1;

// magnet params
size_mag = [25.4/4+e, 25.4/16+e, 25.4/4+e];
mag_edge_space = 2;
mag_space = [40,0,20];

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

/**********************
renders
**********************/
s = [10,20,50];
c = [3,1];
pegboardgen(s,[true,false,true],count=c);
//rotate([0,90,0]) guide_plane(56.8035);
//patboard_mags();

//mag_holder_element([10,10,40]);

/**********************
functions
**********************/
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


/**********************
modules
**********************/
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
  rotate([0,-90,90])
	translate([clip?hole_size+1:hole_size/2,-hole_size/2, board_thickness*1.5/2]) {
    rotate([0,0,15])
    cylinder(r=hole_size/2, h=board_thickness*1.5+e, center=true, $fn=12);

    if (clip) {
      //
      rotate([0,0,90])
      intersection() {
        translate([0, 0, hole_size-e])
          cube([hole_size+2*e, clip_height, 2*hole_size], center=true);

        // [-hole_size/2 - 1.95,0, board_thickness/2]
        translate([0, hole_size/2 + 2, board_thickness/2]) 
          rotate([0, 90, 0])
          rotate_extrude(convexity = 5, $fn=20)
          translate([5, 0, 0])
           circle(r = (hole_size*0.95)/2); 
        
        translate([0, hole_size/2 + 2 - 1.6, board_thickness/2]) 
          rotate([45,0,0])
          translate([0, -0, hole_size*0.6])
            cube([hole_size+2*e, 3*hole_size, hole_size], center=true);
      }
    }
  }
}

module pinboard_clips(size) {
/*  make all the pins based on the size of the holder.
    
  param size: [x,y,z] the size of the holder arraya
  param aligned: [bool,bool,bool], should the height of the board align to the pegboard holes? aligned.y is not used
*/
  steps = [floor(size.x/hole_spacing),
          0,
          floor((size.z-hole_size-1)/hole_spacing)];
  
  xoffset = (size.x-hole_spacing*steps.x-hole_size)/4;
  
	for(i=[0:steps.x]) {
		for(j=[0:steps.z]) {
			translate([i*hole_spacing+xoffset,0,j*hole_spacing])
					pin(j==0);
		}
	}
}

module pinboard(size) {
/*
    create the plate that the pins and clips attach to
    pins and clips and plate holding it all together
  
    param size: what are the dimensions of the holder array?
    param aligned: should the height of the board alignt to the pegboard holes?
*/
	rotate([90,0,0])
  translate([0,0,-wall_thickness])
  r_fcube([size.x,size.z,wall_thickness],hole_size/2);
  
}
module mag_holes(size) {
  /*
    make the holes for the magnets
  */

  //figure out count/spacing for holes  
  mag_count = max(1, ceil((size.z-2*mag_edge_space-size_mag.z)/mag_space.z));
  
  mag_step = (size.z-mag_edge_space*2-size_mag.z)/mag_count;

  if (DEBUG) {
    echo(mag_count=mag_count, mag_step=mag_step);
  }
  
  for (j=[0:mag_count]) {
    if (DEBUG) {
      echo(mag=j, z=(mag_edge_space+j*mag_step));
    }
    translate([0,0,mag_edge_space+j*mag_step])
    cube(size_mag);
  } // loop j over z
}


module mag_holder_element(size, negative=false) {
  /*
    create the shell of a special peice that is made to contain magnets
    and interface to a holder
  
  param negative: bool, return the normal shell or the negative hole for the holder
  
  */
  scl = !negative ? [1,1,1] : [(size.x+2*e)/size.x,(size.y+2*e)/size.y,1];
  sclbase = !negative ? [1,1,1] : [0,0,0];
  base_size = [size_mag.x+2*wall_thickness,
              size_mag.y+wall_thickness+mag_wall_thickness,
              size.z];
  
  if (DEBUG) {
    echo(base_size=base_size);
  }
  
  //flange dimensions
  fsize1 = [wall_thickness*2, e, base_size.z-wall_thickness];
  fsize2 = [wall_thickness*6, fsize1.y, fsize1.z];
  
  scale(scl) {
    // make the base that contains the magnets
    scale(sclbase)
    difference () {
      cube(base_size);
      #translate ([(base_size.x-size_mag.x)/2,mag_wall_thickness,0])
      mag_holes(size);
      
    }
    
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

module mag_holder_array(size, r, negative=false) {
  /*
  an array of mag holder elements based on the size and spacing of the magnets
  */
  mag_holder_count = max(0,ceil((size.x-size_mag.x-2*max(r, wall_thickness))/mag_space.x));
  
  mag_holder_step = (size.x-r*2-size_mag.x-2*wall_thickness)/max(1,mag_holder_count);
  
  if (DEBUG) {
    echo(mag_hldr_count=mag_holder_count, mag_hldr_step=mag_holder_step);
  }
  
  for (i=[0:mag_holder_count]) {
    
    if (DEBUG) {
      echo(mag=i, x=(r+i*mag_holder_step));
    }
    
    translate([r+i*mag_holder_step,0,0])
    mag_holder_element(size, negative);
  } // loop i for each mag holder
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
					r + e, 
					r*taper + e);
  } else if (id == "inner") {
    translate([wall_thickness,wall_thickness,cb*wall_thickness]) {
      round_rect_ex(
            size.x, 
            size.y, 
            size.x*taper, 
            size.y*taper, 
            size.z, 
            r + e, 
            r*taper + e);
      if (front && co > 0) {
        hull() {
            scale([1.0, co, 1.0])
              round_rect_ex(
              size.x, 
              size.y, 
              size.x*taper, 
              size.y*taper, 
              size.z+2*e,
              r + e, 
              r*taper + e);

            translate([0-(holder.x + 2*wall_thickness), 0,0])
            scale([1.0, co, 1.0])
              round_rect_ex(
              size.x, 
              size.y, 
              size.x*taper, 
              size.y*taper, 
              size.z+2*e,
              r+ e, 
              r*taper+ e);
            } //hull
          } // if (front)
      } // translate
      
      if (cb*wall_thickness < e) {
      translate([wall_thickness, wall_thickness, -size.z/2]) {
        round_rect_ex(
              size.x*taper, 
              size.y*taper, 
              size.x*taper, 
              size.y*taper, 
              size.z*2, 
              r+ e, 
              r+ e);
        
        if (front && co > 0) {
          hull () {
            scale([1.0, co, 1.0])
            round_rect_ex(
              size.x*taper, 
              size.y*taper, 
              size.x*taper, 
              size.y*taper, 
              size.z*2,
              r*taper+ e, 
              r*taper+ e);
            
              translate([0-(size.y + 2*wall_thickness), 0,0])
              scale([1.0, co, 1.0])
              round_rect_ex(
                size.x*taper, 
                size.y*taper, 
                size.x*taper, 
                size.y*taper, 
                size.z*2,
                r*taper + e, 
                r*taper + e);
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
  
  cb = (closed_bottom*wall_thickness > e);
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

module holder_element_array(id, size, radius, count, taper, row_offset, spacers, sf, cb, co, a) {
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

module holder_array(size, radius=0, count=[1,1], taper=1, row_offset=0, spacers = [0,0], sf=0, cb=1, co=0, a=0) {
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
    
    if (cb*wall_thickness < e) {
      holder_element_array("hole", size, radius, count, taper, row_offset, spacers, sf, cb, co, a);
    }
  }
}

module pegboardgen(size, align=[false,false,false], radius=0, count=[1,1], taper=1, row_offset=0, spacers=[0,0], sf=0, cb=1, co=0, a=0) {
 /*
  create an array of holders with pegboard pins
  
  see holder_array for all params except the following
  
  param align: [x,__,z] bools - should the x/z dimensions of the holder align with the holes on the pegboard?
 */ 
  
  
  // figure out the final size of the holder based on alignment params
  tsize_holder = total_size(size, count, spacers, row_offset, sf);
  
  tsize = [align.x?ceil(tsize_holder.x/hole_spacing)*hole_spacing+hole_size:tsize_holder.x,
            tsize_holder.y,
            align.z?ceil((tsize_holder.z)/hole_spacing)*hole_spacing+hole_size+1:tsize_holder.z];
  
  xoffset = (tsize.x-tsize_holder.x)/2;
  echo(tsize1=tsize_holder,tsize=tsize);
  //create the holder (oriented down to make supports easier)
  difference () {
    hull () {
      translate([tsize_holder.x+xoffset,0,tsize_holder.z])
      rotate([0,180,0])
      holder_element_array("outer",size,radius,count,taper,row_offset,spacers,sf,cb,co,a);
      if (align.x || align.z) {
        pinboard(tsize);
      }
    }
    
    translate([tsize_holder.x+xoffset,0,tsize_holder.z])
    rotate([0,180,0])
    holder_element_array("inner",size,radius,count,taper,row_offset,spacers,sf,cb,co,a);
  }
  
  // create the array of pegs
  pinboard_clips(tsize);
  
}


module patboard_mags() {
  /*
  creates a magnetic card and marker holder for patboard stuff
  
  _m is for markers, _c is for cards
  */
  h = 40;
  count_m = [1, 4];
  count_c = [3, 1];
  offset_c = wall_thickness*5;
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
    
    translate ([0,-wall_thickness*2-e,-e])
    mag_holder_array(tsize_c, r_c, true);
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