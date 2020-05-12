/*

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>
*/

/**********************
includes
**********************/
include <common.scad>

/**********************
globals
**********************/
e = 0.1;
DEBUG=0;
$fn=360;
dout = 7*25.4;

/**********************
renders
**********************/
gap_test();

/**********************
part modules
**********************/
module router_plate() {
  $fn=720;
  /*plate for dwayne's router*/
  h = 6; // thickness is good
  d_plate = 6*25.4;
  d_sin = 6.5;
  d_sout = 10.5;
  d_jig = 30.15; // 30.1 was tight, 30.15 should be good
  d_jig_out = 34.85 + .15;
  screw_tr = [d_plate/2-d_sin/2-4.75,0,0];
  
  difference() {
    // main plate
    cylinder(h=h, d=d_plate, center=true);
    
    // inner center hole
    cylinder(h=h+e, d=d_jig, center=true);
    
    // outer center hole
    translate([0,0,h/2])
    cylinder(h=h, d=d_jig_out, center=true);
    
    // screw holes
    for (i=[0,120,240]) {
      rotate([0,0,i])
      translate(screw_tr) {
        cylinder(h=h+e, d=d_sin, center=true);
        
        translate([0,0,h-4])
        cylinder(h=h+e, d=d_sout, center=true);
      }
    }
  }
}

module gap_test() {
  /* some bits to test the gap*/
  d_base = 5;
  
  cylinder(h=10, d=5);
  
  for (i=[2:4]) {
    translate([(i-1)*15,0,0])
    difference () {
      cylinder(h=5, d=10);
      translate([0,0,-e/2])
      cylinder(h=5+e,d=5+i*0.05);
      for (j=[1:i]) {
        rotate([0,0,j*30])
        translate([d_base,0,-e/2])
        cube([1,1,11], center=true);
      }
    }
  }
}

module pool_filter_handle() {
  /*
  handle for a pool filter, with the pins and everything
  */
  handle();
  for (a=[0,180]) {
    translate([1,0,0])
    rotate([0,0,a])
    translate([0,-dout/2+5,0])
    pin();
  }
  
}

module handle() {
  /* the handle part, with no pins*/
  
  t=6;
  din = dout-t*2;
  h=5;
  
  
  difference () {
    translate([-dout/2,-dout/2,0])
    hull ()
    //base handle
    ring_arc(d_in=din, t=t, hgt=h, a=180,round_end=true);
    
    translate([-dout/2,-dout/2,0])
    translate([0,t,-e/2])
    hull()
    ring_arc(d_in=din-t*2, t=t, hgt=h+e,a=180);
    
    translate([64,0,-e/2])
    for (i=[[0,-36,0],[8,-12,0],[8,12,0],[0,36,0]]) {
      translate(i)
      cylinder(r=8,h=h+e);
    }
  }
    
  // tab
  translate([dout/2-7,0,h/4])
  hull() {
    for (i=[[0,-17,0],[12,-10,0],[12,10,0],[0,17,0]]) {
      translate(i)
      cylinder(r=2,h=h/2);
    }
  }
  
}

module pin() {
  cone_h=7;
  pin_h=15;
  rotate([90,90,0])
  translate([-5/2,0,cone_h+pin_h])
  difference () {
    group () {
      translate([0,0,-cone_h])
      cylinder(h=cone_h, d1=6, d2=1.75);
      
      translate([0,0,-cone_h-pin_h])
      cylinder(h=pin_h, d=5.5);
      
      translate([0,0,-cone_h*2])
      gizmo();
    }
    
    for (i=[-52.5,2.5]) {
      translate([i,-10,-25])
      cube([50,20,30]);
    }
    
    for (i=[-56.5,6.5]) {
      translate([-10,i,-25])
      cube([20,50,30]);
    }
  }
}

module gizmo() {
  /* not sure what to call this thing...*/
  diam=20;
  translate([0,0,diam/2])
  difference () {
    sphere(d=diam);
    translate([0,0,3.5])
    cube(diam,center=true);
  }
}