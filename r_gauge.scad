
// range for the gauge to follow
radii = [ for (i = [2 : 16]) i ];

// rendering
r_gauge(radii);


// modules
module r_gauge(radii) {
/*
create a gauge for a specific set of radii  
*/
  
  // gauge dimensions
  // TODO: scale this based on the radii?
  disk_r = 75;
  hgt = 3;
  
  // figure some stuff out
  count = len(radii);
  sum = add(radii);
  
  // bring disk to the top of the xy plane
  translate([0,0,hgt/2])
  
  // create the gauge
  difference() {
    // main disk
    cylinder(h=hgt, r=disk_r, center=true);
    
    // remove center hole
    cylinder(h=hgt*2, r=disk_r/4, center=true);
    
    // remove all the radii and imprint text labels
    for (i=[0:count-1]) {
      rotate([0,0,(345*sum_to_index(radii, i+1)/sum)]) {
        translate([disk_r,0,0])
        rotate([0,0,180])
        cywtangents(h=hgt*2, r=radii[i], center=true,a=40);
        
        translate([disk_r*.75,-2,hgt/2])
        rotate([0,0,90])
        linear_extrude(hgt)
        text(str(radii[i]), size=5, font="Courier:style=Bold", halign="Right");
      }
    }
  }
    
}

module cywtangents(h, r, center, a) {
  union() {
    cylinder(h=h, r=r, center=center);
    
    rotate([0,0,a])
    translate([r/2,r,0])
    cube([r,2*r,h], center=center);
    
    rotate([0,0,-1*a])
    translate([r/2,-r,0])
    cube([r,2*r,h], center=center);
  }
}

module test(radii) {
  echo(a=sum_to_index(radii, len(radii)));
}

function add(array, i=0, r=0) = sum_to_index(array, len(array), i, r);
function sum_to_index(array, m, i=0, r=0) = (i < len(array) && i < m) ? sum_to_index(array, m, i+1, r+array[i]) : r;