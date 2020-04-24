/*

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>
*/

/**********************
includes
**********************/
include <ScrewsMetric/ScrewsMetric/ScrewsMetric.scad>
use <common.scad>

/**********************
globals
**********************/
e = 0.1;
DEBUG=0;
GHOST=true;
gap=0.15;

// switch params
max_r = 0.3; // max radius in the hole
sw_size = [14,14,1.5]; // hole size

/**** top plate params ****/
array = [6,4]; // how many keys?

// how offset are the columns (right handed, starting with inside col)
stagger = [-5,0,10,6,-10,-12]; // how do we offset the columns?
assert(array[0]==len(stagger),"Incorrect number of column offsets in variable 'stagger'");

space = 5; //space between switches
ospace = space*2; // space between outside of the plate and switches

// plate size - total size of the top plate
tsize_plate = [ospace*2 + array.x*(sw_size.x+space), ospace*2 + array.y*(sw_size.y+space) + max(stagger) - min(stagger), sw_size.z];

/**** bolt params ****/
// where do we put the bolt holes? starting in the bottom right corner and going clock wise
bolt_pattern = [ [space,space+stagger[0],0],
                 [space,2*space+array.y*(sw_size.y+space)+stagger[2],0],
                 [.5*space+2*(sw_size.x+space),2*space+array.y*(sw_size.y+space)+stagger[2],0],
                 [2.5*space+4*(sw_size.x+space),2*space+array.y*(sw_size.y+space)+stagger[3],0],
                 [2*space+array.x*(sw_size.x+space), 2*space+array.y*(sw_size.y+space)+stagger[5],0],
                 [2*space+array.x*(sw_size.x+space),space+stagger[5],0],
                 [.5*space+4*(sw_size.x+space),space+stagger[5],0],
      
                 // and ending with some inside holes
                 [1.5*space+3*(sw_size.x+space),stagger[2],0],
                 [2.5*space+4*(sw_size.x+space),2*space+array.y*(sw_size.y+space)+stagger[4],0]];
                
                
l_bolt = 10; // how long are the bolts

/**** case params ****/
h_case=15;// total case height
t_case=.45*4;//case thickness, if less than 2.5, should be a multiple of .45

tsize_case = [2*ospace+array.x*(space+sw_size.x)-space, 2*ospace+array.y*(space+sw_size.y)+max(stagger)-min(stagger)-space, h_case];
tsize_protonc = [18,52,5];

// what is the shape of the case? start at the origin and work clock wise
case_extents = [[0,0],
                [0,(tsize_case.y+tsize_protonc.x)/2],
                [0,tsize_case.y+tsize_protonc.x],
                [ospace+1*(sw_size.x+space),tsize_case.y+tsize_protonc.x],
                [ospace+2*(sw_size.x+space),tsize_case.y+tsize_protonc.x],
                [ospace+4*(sw_size.x+space),tsize_case.y],
                [ospace+5*(sw_size.x+space),2*ospace+array.y*(space+sw_size.y)+max(stagger[4],stagger[5])-min(stagger)],
                [tsize_case.x,2*ospace+array.y*(space+sw_size.y)+max(stagger[4],stagger[5])-min(stagger)],
                [tsize_case.x,(2*ospace+array.y*(space+sw_size.y)+max(stagger[4],stagger[5])-min(stagger))/2],
                [tsize_case.x,0],
                [tsize_case.x/2,0]];
                
// for each corner in the case poly, should there be a bolt?
screw_pattern = [ true,
                  true,
                  true,
                  false,
                  true,
                  true,
                  false,
                  true,
                  true,
                  true,
                  true];

assert(len(screw_pattern)==len(case_extents), "screw_pattern and case_extents lengths must match");

/**** screw params ****/
d_out = 3;
d_in = 2;
$fn=30;

/**********************
renders
**********************/
//guides();
//case_shell();
full_test();

module guides() {
  /*put up some guides to aid trouble shooting*/
  guide_def = [e,e,h_case*2];
  tr_def = [0,0,-h_case];
  
  gds_tr = [[0,ospace,0],
            [0,tsize_case.y-ospace,0],
            [ospace,0,0],
            [tsize_case.x-ospace,0,0]];
  
  color("white", .5)
  for (i=gds_tr) {
    translate(i+tr_def) {
      if (i[0] == 0) cube(guide_def+[tsize_case.x,0,0]); else cube(guide_def+[0,tsize_case.y,0]);
      }
    }
}

module full_test() {
  translate([tsize_case.x,0,h_case])
  rotate([0,180,0]) {
    case_shell();
    protonc();
}
}
/**********************
functions
**********************/


/**********************
modules
**********************/

/**** electronics modlues ****/
module protonc(id="full", hole_depth=5) {
  size_pc = tsize_protonc - [0,0,3.25];
  size_arm = [6,6,3.5];
  size_usb = [9.25,5-1.75,7.85];
  size_armsup = [9,9,size_usb.y];
  d_mount_in = 1.5;
  d_mount_out = 3;
  mount_locs = [[1.5,50,0],[size_pc.x-1.5,50,0]];
  reset_loc = [size_pc.x/2,32,size_arm.z];
  d_reset = 1.75;
  
  // vectors to move usb and arm chips
  usb_tr = central_align_vector(size_usb, size_pc);
  arm_tr = central_align_vector(size_arm, size_pc);
  sup_tr = central_align_vector(size_armsup, size_pc);
  
  // move the part to the right place in the case
  translate([t_case*2,tsize_case.y-size_pc.x,t_case])
  rotate([0,0,90])
  translate([0,-size_pc.y,0]) {
    if (id == "full") {
      difference () {
        group() {
        color("orange", .75)
        r_fcube(size_pc, 1);
        
        color("silver", .75)
        translate([usb_tr.x,size_pc.y,1.75])
        rotate([90,0,0])
        r_fcube(size_usb,2);
        
        color("black",.9)
        translate([arm_tr.x+size_arm.x/2.1, arm_tr.y-2, e])
        rotate([0,0,45])
        cube(size_arm);
        }
        
        for (i=mount_locs) {
          translate(i+[0,0,-e/2])
          cylinder(h=size_pc.z+e, d=2.25);
        }
      }
    }
    if (id == "mount_holes" || id == "holes") {
      for (i=mount_locs) {
        translate(i-[0,0,hole_depth]) cylinder(h=(hole_depth*2+size_pc.z), d=d_mount_in);
      }
    }
    if (id == "usb_hole" || id == "holes") {
      translate([usb_tr.x, size_pc.y,1.75]) cube([size_usb.x,hole_depth,size_usb.y]);
      
    }
    if (id == "reset_hole" || id == "holes") {
      translate(reset_loc) cylinder(h=hole_depth, d=d_reset);
    }
    
    if (id == "support") {
      for (i=mount_locs) {
        translate(i+[0,0,size_pc.z]) cylinder(h=size_arm.z, d=d_mount_out);
      }
      
      translate([sup_tr.x, 20, size_pc.z])
      cube(size_armsup);
    }
  }
}

/**** case modules ****/
module case_poly(h) {
  //create a poly for the case
  
  linear_extrude(h)
  polygon(case_extents);
}

module case_shell() {
  
  protonc_tr = [2*space+3*(sw_size.x+space),tsize_plate.y-5,5+t_case];
  // make the case by scaling the shell of the top plate
  difference () {
    // main case shell
    case_poly(h_case);
    
    // remove the inside
    translate([t_case*2, t_case*2, h_case-t_case])
    scale(1/neg_scaling_vector(tsize_case, t_case*2))
    translate([0,0,-h_case*2])
    case_poly(h_case*2);
    
    // remove a spot for the bottom of the case
    translate([t_case, t_case, t_case])
    scale(1/neg_scaling_vector(tsize_case, t_case))
    translate([0,0,-t_case*2])
    case_poly(t_case*2);
    
    // remove the switch holes
    translate([ospace, ospace, h_case-t_case])
    sw_hole_array(true);
    
    // remove a bit of the case for the screws
    screw_mounts(true);
    
    // remove holes for the protonc
    protonc("holes");
  }
  
  // add in the screw mounts
  difference () {
    screw_mounts(false);
    screw_mounts(true);
  } 
  
//  
//  translate(protonc_tr)
//  rotate([0,180,0])
//  protonc("support");
}

module screw_mounts(neg=false) {
  // add supports and screw holes for the bottom of the case to mount into
  d = neg ? d_in : d_out;
  h = neg ? l_bolt+e : h_case-t_case;
  tr_base = neg ? [0,0, t_case-e] : [0,0,t_case];
  
  for (i=[0:len(case_extents)]) {
    if (screw_pattern[i]) {
      dir= [case_extents[i].x > tsize_case.x/2 ? -1 : 1, case_extents[i].y > tsize_case.y/2 ? -1 : 1];
      tr = [case_extents[i].x, case_extents[i].y, 0] + [dir.x*(t_case*2), dir.y*(t_case*2),0];
      echo(i=i, dir=dir, ce=case_extents[i]);
      
      translate (tr + tr_base)
      cylinder(h=h, d=d);
    }
  }
}
/**** top plate modules ****/
module case_profile(id="final") {
  /*
  generate the profile for the case, based on the id:
  param id: "final" = final bottom plate, with holes to screw it in to the case
            "shell" = no holes
            "neg" = no sw holes and a bit bit for cutting out holes
  */
  // scaling variable based on if this is a negative or not
  sc = (id=="neg") ? neg_scaling_vector(tsize_plate, gap) : [1,1,1];
  
  scale(sc)
  //translate([ospace,ospace-min(stagger),sw_size.z/2])
  difference () {
    cube(tsize_plate);
    
    if (id=="final") {
      // remove the holes for the switches
      sw_hole_array();
      
      // remove the holes for screws
      translate([-ospace,-ospace,2.25+sw_size.z/2])
      for (i=bolt_pattern) {
        translate(i) BoltFlushWithSurface(allenBolt, M3, length=20);
      }
    } // if id==final
  } // dif
} // top_plate module

module switch_hole() {
  cube(sw_size);
}

module sw_hole_array(neg=false) {
  sc = neg ? [1,1,2] : [1,1,1];
  tr = neg ? [0,-min(stagger),-sw_size.z/2] : [0,-min(stagger),0];
  
  translate(tr)
  scale(sc)
  for (i=[0:array.x-1]) {
    for (j=[0:array.y-1]) {
      if (DEBUG) {
        echo(ij=[i,j],x=i*(space+sw_size.x),y=j*(space+sw_size.y)+stagger[i]);
      }
      translate([i*(space+sw_size.x), j*(space+sw_size.y)+stagger[i],0])
      switch_hole();
    } // loop j - rows
  } // loop i - columns
}
