/*

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>
*/

/**********************
includes
**********************/
use <common.scad>

/**********************
globals
**********************/
e = 0.1;
DEBUG=0;
$fn=60;
t_wall = 0.45*3;

/**********************
renders
**********************/
forum_trajanum_buildings("bottom");
forum_trajanum_buildings("lid");


/**********************
part modules
**********************/
module forum_trajanum_buildings(type="bottom") {
  /* bins for forum trajanum buildings*/
  sm_side = 25 + .25;
  lg_side = 49.8 + .25;
  size_sm = [sm_side, sm_side, 29];
  size_lg = [sm_side, lg_side, 25.5];
  size_shell = [sm_side*4+t_wall*5, sm_side+lg_side+t_wall*3, max(size_sm.z,size_lg.z)+t_wall];
  e_lid = .25; // printed at .175 and it was a bit tight
  size_lid = size_shell + [t_wall*2+e_lid, t_wall*2+e_lid, e_lid-t_wall];
  
  if (type=="bottom") {
    translate([t_wall,t_wall,0])
    difference () {
      // main shell
      r_fcube(size_shell,t_wall);
      
      // part compartments
      for (i=[0:3]) {
        for (j=[0:1]) {
          // bins
          translate([t_wall + i*(size_sm.x+t_wall), t_wall + j*(size_sm.y+t_wall), size_shell.z])
          translate([0,0,-(j==0 ? size_sm.z : size_lg.z)]) {
            // bins
            cube((j==0 ? size_sm : size_lg));
            
            //front cutouts
            translate([sm_side/6,lg_side/2*(j==0?-1:1),0])
            scale ([2/3,1,1])
            cube((j==0 ? size_sm: size_lg));
          }
        }
      }
    }
    
    r_fcube([size_lid.x, size_lid.y,t_wall], t_wall);
  }
  else if (type == "lid") {
    translate([0,-size_lid.y-10,0])
    difference() {
      r_fcube(size_lid, t_wall*2);
      
      translate([t_wall+e_lid/2, t_wall+e_lid/2, t_wall+e_lid])
      r_fcube(size_shell, t_wall);
    }
  }
}