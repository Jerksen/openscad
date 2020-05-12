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
e = .1;
DEBUG = 2;


/**********************
renders (should be empty)
**********************/
//ring_arc(10,2,3,135,center=true,round_end=true);
echo(central_align_vector([1,1,1],[4,4,4]));

/**********************
functions
**********************/
// create a scale vector so that a part of <size> has some gaps around it
function neg_scaling_vector(size, gap=e) = [for(i=[0:2]) (size[i] + 2*gap) / size[i]];

// provide a scaling vector to make an object of size_o match the final size (size_f)
function linear_scaling_vector(size_o, size_f) = [for(i=[0:2]) (size_f[i])/size_o[i]];
  
// provide a vector to align the centers of o1 to o2, assuming they are located at the origin in the positive octant
function central_align_vector(o1, o2) = (o2-o1)/2;
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
  
  a_90s=floor(a/90);
  
  tran = !center ? [d_out/2,d_out/2,0] : [0,0,0];
  translate(tran) {
    difference() {
      cylinder(h=hgt, d=d_out);
      
      translate([0,0,-e/2]) {
        cylinder(h=hgt+e, d=d_in);
      
        // cut out 90 degree chunks first
        if (a_90s>0) {
          for (i=[1:a_90s]) {
            rotate([0,0,90*i])
            cube(d_out+e);
          }
        }
        
        //cutout the subchunks by putting cubes at 3 points
        if (a>0) {
          rotate([0,0,90*(a_90s)])
          linear_extrude(hgt+e)
          polygon([[0,0],[0,d_out],[-tan(a-90*a_90s)*d_out,d_out]]);
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

module guide_plane(d, l=500) {
  /* creates an xy plane lxl elevated d up from the origin*/
  color("gray",0.25)
  translate([0,0,d+e/2])
  cube([l,l,e],center=true);
}

function minr(r,size) = min(r, size.x/2, size.y/2);