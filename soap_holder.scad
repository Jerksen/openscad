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
diam=20;
t=4;
hgt=65;
r_out=5+t;
r_in=5;
soap_size = [75,210,20];
razor_size = [(soap_size.x-3*t)/2, 20, soap_size.z+e];
$fn= !DEBUG ? 360: 25;

// how long is the angled stub?
stub_l = 40;
// how far is the ring from the shower wall?
oset = 12.5;
// what is the angle of the stub?
stub_a = asin(oset/stub_l);
stub_h = sqrt(pow(stub_l,2)-pow(oset,2));

/**********************
renders
**********************/
dish(true);
//modifier("bottom", true);


module test () {
  difference () {
    dish(true);
    modifier("bottom", true);
  }
}
  

/**********************
part modules
**********************/
module dish(razor_hole=false) {
  difference() {
    group () {
      rotate([0,-90,0])
      ikea_interface();

      translate([-t,-soap_size.y/2,0])
        r_fcube(soap_size, r_out);
    }
    
    // cutout the top part
    modifier("top", razor_hole);
    
    // if we want a razor hole, cut out the bottom part
    if (razor_hole) {
      for (i=[0,soap_size.x-razor_size.x-t*2]) {
        translate([i,soap_size.y/2-razor_size.y-t,-e/2])
        r_fcube(razor_size, r_in);
      }
    }
  }
}

module ikea_interface() {
  translate ([hgt,0,2*e-oset]){
    
    // main ring
    rotate ([0,0,45])
    translate ([0,-diam-2*t,0]) {
      ring_arc(diam, t, t, a=90, round_end=true);  
      translate([0,(diam+2*t)/2,0]) r_fcube([t,t*2,t],[t,t,0,0]);
      translate([(diam+2*t)/2-2*t,diam+t,0]) r_fcube([2*t,t,t],[0,t,t,0]);
    }
    
    // arms from ring down to the soap dish
    for (i=[-1,1]) {
      
      translate([0,-t/2+i*t,0]) {
        // short stubs from ring down
        r_fcube ([2.2*t,t,t],[t,0,0,t]);
        
        // angled stubs
        rotate ([0,stub_a-90,0])
        cube ([t,t,stub_l]);
        
        //final stubs down towards the dish
        translate([-hgt,0,oset-2*e])
        cube([hgt-stub_h+t*sin(stub_a),t,t]);
      }
    }
  }
}

module modifier(type, razor_hole=false) {
  id = (type == "bottom") ? 0 : 1;
  size = razor_hole ? soap_size - [0, razor_size.y+t,0]: soap_size;
  translate([0,t-soap_size.y/2,id*(size.z/2)-e/2])
  r_fcube(size-[2*t,2*t,size.z/2-e],r_in);
}