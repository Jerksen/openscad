/*

    This program is free software: you can redistribute it and/or modify it under the terms of the Affero GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the Affero GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/agpl-3.0.txt>
*/

/**********************
includes
**********************/
include <ScrewsMetric/ScrewsMetric/ScrewsMetric.scad>

/**********************
globals
**********************/
e = 0.1;
DEBUG=0;
GHOST=true;

max_r = 0.3;
hole_size = [14,14,1.5];
space = 5;

// how to stager columns based on fingers, starting with index
finger_stagger=[0,0,18,13,-18,-18];

$fn=30;

/**********************
renders
**********************/
difference() {
  top_plate();
  
  
  screw_holes();
}

/**********************
modules
**********************/
module screw_holes() {
  base_move = [(hole_size.x+space), hole_size.y+space, 2.25*hole_size.z/2];
  
  translate([(hole_size.x+space)*1+space/2,(hole_size.y+space)*-.1+space/2,(2.25+hole_size.z/2)])
  BoltFlushWithSurface(allenBolt, M3, length=20);
  
  translate([(hole_size.x+space)*5+space/2,(hole_size.y+space)+finger_stagger[4]+space/2,(2.25+hole_size.z/2)])
  BoltFlushWithSurface(allenBolt, M3, length=20);
  
  translate([(hole_size.x+space)*1.5+space/2,(hole_size.y+space)*3+space*1.5,(2.25+hole_size.z/2)])
  BoltFlushWithSurface(allenBolt, M3, length=20);
  
  translate([(hole_size.x+space)*4.5+space/2,(hole_size.y+space)*2.75,(2.25+hole_size.z/2)])
  BoltFlushWithSurface(allenBolt, M3, length=20);
  
  translate([(hole_size.x+space)*3+space/2,0,(2.25+hole_size.z/2)])
  BoltFlushWithSurface(allenBolt, M3, length=20);
}

module top_plate() {
  count = [6,3];
  translate([5,5,0])
  difference () {
    // make the top plate
    scale([1,1,0.5])
    hull() {
      translate([-5,-5,0]) hole_array(count, finger_stagger);
      translate([5,-5,0]) hole_array(count, finger_stagger);
      translate([5,5,0]) hole_array(count, finger_stagger);
      translate([-5,5,0]) hole_array(count, finger_stagger); 
    }
    
    // remove the holes for the switches
    hole_array([6,3], finger_stagger);
    
    // remove the holes for screws
    
  }
}

module screw_hole() {
  // countersink
  cylinder(h=hole_size.z);
  
  cylinder();
}

module screw_holes() {
  
}

module hole() {
  translate([0,0,-hole_size.z])
  scale([1,1,2])  
  cube(hole_size);
}

module hole_array(count,stagger) {
  stgr = stagger ? stagger : ([for (i=[1:count.x]) [0]]);
  
  if (DEBUG) echo(stgr=stgr,stgr0=stgr[1]);
    
  for (i=[0:count.x-1]) {
    for (j=[0:count.y-1]) {
      if (DEBUG) {
        echo(ij=[i,j],x=i*(space+hole_size.x),y=j*(space+hole_size.y)+stgr[i]);
      }
      translate([i*(space+hole_size.x), j*(space+hole_size.y)+stgr[i],0])
      hole();
    } // loop j - rows
  } // loop i - columns
}