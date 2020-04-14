/*

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>
*/

/**********************
includes
**********************/


/**********************
globals
**********************/
e = (e == undef) ? 0.1 : e;
DEBUG = (DEBUG == undef) ? 0 : DEBUG;



/**********************
part modules
**********************/
module ring_arc(d_in, t, hgt, a=0, center=false, round_end=false) {
  /*
  param d_in: inner diameter of the ring
  param t: thickness of the ring
  param hgt: height of the ring
  param a: angle of the ring to cut out
  param center: bool
  param round_end: bool, should the cut ends of the ring be rounded?
  */
  d_out=d_in+2*t;
  tran = !center ? [d_out/2,d_out/2,0] : [0,0,0];
  translate(tran) {
    difference() {
      cylinder(h=hgt, d=d_out);
      
      translate([0,0,-e/2]) {
        cylinder(h=hgt+e, d=d_in);
        
        if (a>0) {
          hull () 
          for (i=[0,a]) {
            rotate([0,0,i]) cube([e,5*d_out,hgt+e]);
          }
        }
      }
    }
    
    // add rounded edges if we need them
    if (round_end) {
      for (i=[0,a]) {
        rotate([0,0,i])
        translate([0,d_in/2+(d_out-d_in)/4,0])
        cylinder(hgt, d=(d_out-d_in)/2, true);
      }
    }
  }
}

module cup (d_in, t, hgt, center=false) {
  /*
  param d_in: inner diameter of the cup
  param t: thickness of the floor and walls
  param hgt: height of the cup
  param center: bool, center the whole thing?
  */
  difference() {
    cylinder (h=hgt, r=d_in/2+t, center=center);
    translate([0,0,t]) cylinder (h=hgt, r=d_in/2, center=center);
  }
}

module r_fcube (size, rad, center=false) {
  /*
  flattened rounded cube - all of the edges around the z axis are rounded, the rest are square
  param size: [x,y,z] size
  parma rad: r for all corners [q1, q2, q3, q4] for the quandrant radii
  remember q1 is the positive x,y, q2 is +y, -x, ...
  */
  r = (len(rad) == undef) ?
        [for (i=[0:3]) minr(rad,size)] : [for (i=[0:3]) minr(rad[i], size)];
  tr = center ? [0,0,0] : size/2;
  q = [[+1, +1], [-1,1], [-1,-1], [1,-1]];
  translate(tr)
  hull () {
    for (i=[0:3]) {
      translate([q[i].x*size.x/2, q[i].y*size.y/2,0])
      if (r[i] == 0) {
        translate([-q[i].x*size.x/4, -q[i].y*size.y/4,0]) cube([size.x/2, size.y/2, size.z], center=true);
      } else {
        translate([-q[i].x*r[i],-q[i].y*r[i],0]) cylinder(h=size.z, r=r[i], center=true);
      }
    }
  }
}

function minr(r,size) = min(r, size.x/2, size.y/2);