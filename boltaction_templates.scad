/**********************
globals
**********************/
e = 0.01;
t = 0.4*4;

/**********************
renders
**********************/
//ruler(6);
//he_template (4, 3);
//pin_base();
//base(10,10,0.01,2,1.5);
//rcube([10,10,10], 2);

/**********************
modules
**********************/
module he_template (di1, di2) {
  /* a circular template for HE shots
    params di#: the outer and inner diameters
      di1 must be > di2!!!
  */
  r1 = di1*25.4/2;
  r2 = di2*25.4/2;

  difference () {
    cylinder(t, r=r1);
    
    translate([0,0,-e/2])
    cylinder(t+e, r=r2);
  }
}

module ruler (li) {
  /* a straight ruler for distance measuring
    param li: lenght in inches
  */
  l = li*25.4;
  w = 10;
  tickw = 1;
  d_ratio = .25;
  
  difference () {
    // main strip
    cube([w, l, t]);
    
    // halfway mark
    translate([-w/2, l/2, t*(1-d_ratio)+e])
    rotate([0,0,-90])
    cube([tickw, w*2, t*d_ratio]);
    
    //quarter marks
    if (li/4 == round(li/4)) {
      for (i=[l/4, l/4*3]) {
        translate([-w/2, i, t*(1-d_ratio)+e])
        rotate([0,0,-90])
        cube([tickw, w*1.25, t*t_ratio]);
      }
    }
    // inch marks
    for (i=[1:li-1]) {
      translate([-w/2, i*25.4, t*(1-d_ratio)+e])
      rotate([0,0,-90])
      cube([tickw, w*1, t*d_ratio]);
    }
  }
}

module pin_base () {
  /* a base to hold dice representing pin markers */
  d=25;
  w=10;
  union() {
    // start with the base
    round_base(d);
    
    // then add the cube
    translate([0,0,t])
    base(10,10,0.01,2,1.5);
  }
}

module round_base(d, thickness=undef, depth=undef) {
  base(d, d, d/2, thickness, depth);
}

module base(w, l, r, thickness=undef, depth=undef) {
  /* a base for units
    param w, l: the dimensions
    param r: the corner radius
  */
  th = thickness == undef ? t/2 : thickness;
  d = depth == undef ? t*.25 : (depth > t ? t : depth);
  
  difference() {
    rcube([w, l, t], r, true);
    
    translate([0,0, (t-d)])
    rcube([w-th, l-th, 20*t], r, true);
  }
  
}

module rcube(size, r=undef, center=false) {
  /* a cube that has rounded sides around the z axis
    param size: a vector with the size
    param r: the radius of the corners. If excluded, a normal cube is returned
  */
  if (r == undef) {
    cube(size, center);
  }
  else {
    rf = (r>min(size.x/2, size.y/2)) ? min(size.x/2, size.y/2) : r;
    echo(size=size, rf=rf);
    trans = (center) ? [0,0,0] : [size.x/2, size.y/2, 0];
    
    translate(trans)
    hull () {
      translate([size.x/2-rf, size.y/2-rf, size.z/2])
      cylinder(h=size.z, r=rf, center=true);
      
      translate([-size.x/2+rf, size.y/2-rf, size.z/2])
      cylinder(size.z, r=rf, center=true);
      
      translate([size.x/2-rf, -size.y/2+rf, size.z/2])
      cylinder(size.z, r=rf, center=true);
      
      translate([-size.x/2+rf, -size.y/2+rf, size.z/2])
      cylinder(size.z, r=rf, center=true);
    }
  }
  
  
}
