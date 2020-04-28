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
$fn=360;
t_wall = 0.45*3;

/**********************
renders
**********************/
forum_trajanum_buildings();

/**********************
part modules
**********************/
module forum_trajanum_buildings(type="bottom") {
  /* bins for forum trajanum buildings*/
  size_sm = [25, 25, 30];
  size_lg = [25, 49, 25];
  size_shell = [size_sm.x*4+t_wall*5, size_sm.y+size_lg.y+t_wall*3, max(size_sm.z,size_lg.z)+t_wall];
  size_lid = size_shell + [t_wall*2+.15, t_wall*2+.15, t_wall+.15];
  
  if (type=="bottom") {
    difference () {
      // main shell
      r_fcube(size_shell,t_wall);
      
      for (i=[0:3]) {
        for (j=[0:1]) {
          // bins
          translate([t_wall + i*(size_sm.x+t_wall), t_wall + j*(size_sm.y+t_wall), size_shell.z])
          translate([0,0,-(j==0 ? size_sm.z : size_lg.z)+e/2]) {
            // bins
            cube((j==0 ? size_sm : size_lg));
            
            //front cutouts
            translate([size_sm.x/6,size_lg.y/2*(j==0?-1:1),0])
            scale ([2/3,1,1])
            cube((j==0 ? size_sm: size_lg));
          }
        }
      }
    }
  }
  else {
    difference() {
      f_rcube(size_lid);
      
      translate([t_wall+.15/2, t_wall+.15/2, t_wall+.15])
      f_rcube(size_shell);
    }
  }
}