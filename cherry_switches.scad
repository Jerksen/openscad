/*

    This program is free software: you can redistribute it and/or modify it under the terms of the Affero GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the Affero GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/agpl-3.0.txt>
*/


/**********************
globals
**********************/
e = 0.1;
DEBUG=0;

max_r = 0.3;
hole_size = [14,14,1.5];
space = 5;

// how to stager columns based on fingers, starting with index
finger_stagger=[0,18,13,-18];

/**********************
renders
**********************/
translate([10,0,0])
hole_array([4,4], finger_stagger);
translate([-10,0,0])
mirror() hole_array([4,4], finger_stagger);

/**********************
modules
**********************/
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