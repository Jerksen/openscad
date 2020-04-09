/*

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>
*/

/********************************
includes
********************************/
include <threads.scad>

/********************************
globals
********************************/
d = 20;
e = 0.1;
h = 3;
t = 0.8;

/********************************
render
********************************/

//hole_through(name="M5", l=50+5, cld=0.1, h=10, hcld=0.4);

/*
linear_extrude(height=5)
import("/home/jeff/Documents/team-logos/amrita.dxf");
*/

allinone("YR");
/********************************
modules
********************************/
module base() {
  /*
    base of a magnetic team medalian
  */
  h = 5;
  
  //main body with magnet cavity
  difference () {
      
    union () {
      // threading
      intersection () {
        metric_thread(20,1,h-t);
        cylinder(h=2*h, d=d+e);
      }
      // small circular base
      cylinder(h=h/4, d=d+t);
    }
    
    translate([0,0,.4]) cylinder(h=1/16*25.4+e*3, d=1/4*25.4+e*2);
  }
  

}

module cap(lbl) {
  /*
  cap for a magnetic team medalian
  */
  //scale factor
  sf = (d+.2)/d;
  echo(sf=sf);
  
  translate([0,0,h+t*2])
  label(lbl);
  
  
  scale([1.02, 1.02, 1.02])
  difference() {
    //main cylinder
    cylinder(h=h+t*2, d=d+2*t);
    
    // threading
    
    translate([0,0,-e])
    metric_thread(d,1,h,internal=true);
  }
  
  //support
  
  difference() {
    cylinder(h=h-e, d=d/2);
    
    cylinder(h=h-e, d=d/2-1);
  }
  
}

module allinone(lbl) {
  translate([0,0,h])
  label(lbl);
  
  difference () {
    // main cylinder
    cylinder(h=h, d=d);
    
    
    translate([0,0,.4])
    cylinder(h=1/16*25.4+e*3, d=1/4*25.4+e*2);
  }
  
}

module label(lbl) {
  
  linear_extrude(t)
  text(lbl, halign="center", valign="center", size=d*.5, font="Courier");
}

module threading () {
  translate([0,0,h-30]) 
  rotate ([0,180,0])
  screw("M20x30", thread="modeled");
}
