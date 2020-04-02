/*

    This program is free software: you can redistribute it and/or modify it under the terms of the Affero GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the Affero GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/agpl-3.0.txt>
*/

/**********************
includes
**********************/


/**********************
globals
**********************/
e = 0.1;
DEBUG=0;

hq_bar_diam = 38.5;
redsnapper_diam = 8;
msize = [25.4/4, 25.4/4, 25.4/16] + [e,e,e];
hq_bolt_in=9;
hq_bolt_out=18;
hq_frame_gap=5;

$fn=30;

/**********************
renders
**********************/
//red_snapper_mount_top();
red_snapper_mount_bottom();
//hq_bar_guide(false);

/**********************
part modules
**********************/
module hq_bar_guide(clips=false) {
  $fn=360;
  d_in=hq_bar_diam-5;
  t = 7.5;
  h = 10;
  a = 90;
  
  
  ring_arc(d_in,d_in+t,h,a,true,true);
  
  if (clips) {
    for (i=[0,a]) {
      rotate([0,0,i])
      translate([0,d_in/2+t*3/4,0])
      rotate([0,0,180+210*(i>0?1:0)])
      ring_arc(t/2,t*3/2,h,150,true,true);
    }
  }   
}



module red_snapper_mount_top() {
  $fn = 360;
  d = 75;
  t = .45*5;
  h = 20;
  
  isize = [hq_frame_gap,h,h];
  csize = [3.5+t+isize.x,h,t];
  
  rotate ([0,180,0]) {
    // main hoop
    ring_arc(d, d+2*t, h, 0, false);
    
    // interface to the hq
    translate([-csize.x+t,d/2-csize.y/2,h-t])
    cube(csize);
    
    translate([-csize.x+t,d/2-isize.y/2,0])
    cube(isize);
  }
}

module red_snapper_mount_bottom() {
  $fn = 360;
  d = 75;
  t = .45*5;
  h = 75;
  
  csize=[hq_bolt_out+t*2,t, hq_bolt_out+t*2];
  
  difference () {
    group () {cup(d, t, h, center=false);
    
    translate([-csize.x/2,d/2,h-csize.z])
    cube(csize);}
    
    translate([0,d/2+t/2,h-hq_bolt_out/2-t])
    rotate([90,0,0]) {
      cylinder(h=t, d=hq_bolt_out);
      translate([0,0,-t*2.5]) cylinder(h=t*5, d=hq_bolt_in);
    }
  }
}

module hq_side_cup(hgt) {
  $fn = 360;
  d = 75;
  t = .45*5;
  h = 20;
  
  isize = [hq_frame_gap,h,h];
  csize = [3.5+t+isize.x,h,t];
  
  rotate ([0,180,0]) {
    // main hoop
    ring_arc(d, d+2*t, h, 0, false);
    
    // interface to the hq
    translate([-csize.x+t,d/2-csize.y/2,h-t])
    cube(csize);
    
    translate([-csize.x+t,d/2-isize.y/2,0])
    cube(isize);
  }
}

// obsolete
module red_snapper_mount_v1() {
  $fn=360;
  d = 100;
  t = 10;
  h = 25;
  a = 90;
  wt=.45*3;
  mwt=0.3;
  
  sd_out=18;
  sd_in=9;
  
  translate([0,-(d+t*2),h/2])
  ring_arc(d, d+t*2, h, a, false, true);
  translate([55,-t/2,0])
  cube([t,40,h]);
  
  translate([45,40,h/2])
  rotate([90,0,0])
  difference() {
    cube([sd_out*2+t*2, h, t], true);
    
    translate([-sd_out/2,0,t/4]) cylinder(h=t, d=sd_out, center=true);
    translate([-sd_out/2,0,-e/2]) cylinder(h=t+e, d=sd_in, center=true);
    
  }
}

/**********************
helpers
**********************/
module ring_arc(d_in, d_out, hgt, a, center=false, round_end=false) {
  $fn=360;
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
  $fn=360;
  difference() {
    cylinder (h=hgt, r=d_in/2+t, center=center);
    translate([0,0,t]) cylinder (h=hgt, r=d_in/2, center=center);
  }
}