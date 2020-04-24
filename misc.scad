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
pool_filter_handle();

/**********************
part modules
**********************/
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