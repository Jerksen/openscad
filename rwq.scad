/*

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>
*/

e = 0.1;
r = 100;
h = 10;
w = 10;

sf = max(h+.15, w+.15) / max(h, w);

$fs = 0.01;
$fa = 0.1;



echo(sf=sf);

// text
//text("red willow quilts", size=10, font="Pinyon Script");

// TODO: trim outide edges of each (look at the corners)


color("purple") top();
color("yellow") l();
color("red") r();
color("red") bot();
//l_raw();

module l() {
  difference () {
    l_raw();
    
    translate([0,0,-h/2])
    scale([sf, sf, sf]) {
      bot_raw();
      top_raw();
    }
    
    cube([3*r, w*2+e*2, h], center=true);
  }
}

module r() {
  rotate([0,0,180]) l();
}

module top() {
  
  difference () {
    top_raw();
    
    translate([0,0,h/2])
    scale([sf,sf,sf]) {
      l_raw();
      r_raw();
    }
    
    translate([0,0,h]) cube([w*2+e*2, 3*r, h], center=true);
    
  }
  
}

module bot() {
  rotate([0,0,180]) top();
}

module top_raw() {
  translate ([0,r,0]) half_band();
}

module bot_raw() {
  rotate([0,0,180]) top_raw();
}

module l_raw() {
  rotate ([0,0,90]) top_raw();
}

module r_raw() {
  rotate ([0,0,-90]) top_raw();
}

module half_band() {
  difference () {
    band(h,w,r);
    translate([-r, 0, -e]) cube(2*r+e);
  }
}

module band(h, w, r) {
  /*
  creates a band
  param h: height (z-axis)  
  param w: width of the band
  param r: radius of the outer circle
  */
  difference () {
    cylinder(h, r=r);
    
    translate([0,0,-e/2])
    cylinder(h+e, r=(r-w));
    
  }
}
