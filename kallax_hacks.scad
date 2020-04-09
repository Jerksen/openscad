/*

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>
*/

/**********************
globals
**********************/
e = 0.1;

//kallax dimensions
kallax_h = (13 + 3/16)*25.4;

/**********************
renders
**********************/
//bottom holder
//kallax_hardboard_holders(kallax_h/2, 6);

//top holder
kallax_hardboard_holders(kallax_h/2*5/6, 5);

/**********************
modules
**********************/
module kallax_hardboard_holders(h, num) {
  // vars
  hb_w = 1/8*25.4 + e*2;
  w = 10;
  
  
  hole_d = .138*25.4;
  cs_D = .307*25.4;
  cs_H = .097*25.4;
  
  t = 0.4*3;
  
  screw_hole_loop = [h/num*.5, h-h/num*.5];
  support_size = 3;
  
  difference () {
    union () {
      // main strip
      cube([h, w, t]);
      
      // supports
      for (i=[0:num-1]) {
        translate([hb_w+support_size-e+(h/num)*i,0,t])
        rotate([0,0,90])
        prism(w,support_size, support_size);
      }
      
      // supports for screws
      for (i=screw_hole_loop) {
        translate([i, w/2, 0]) cylinder(h=e+cs_H, d=cs_D+t);
      }
    }
    
    // cutouts for shelves
    for (i=[0:num-1]) {
        translate ([i*h/num-e, -e/2, t/2])
        cube([hb_w, w+e, t]);
    }
    
    // holes for screws
    for (i=screw_hole_loop) {
      translate([i,w/2,0]){
        translate([0,0,-cs_H*1.5]) cylinder(h=3*cs_H, d=hole_d); // screw hole
        translate([0,0,2*e]) cylinder(h=cs_H, d1=hole_d, d2=cs_D); // counter sink
      }
    }
  }
  
}

module prism(l, w, h){
       polyhedron(
               points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
               faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
               );
 }
