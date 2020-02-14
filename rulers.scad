/**********************
renders
**********************/
ruler(6);


/**********************
modules
**********************/
module ruler(li) {
  l = li*25.4;
  w = 10;
  t = 0.4*4;
  e = 0.01;
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
      cube([tickw, w*1, t*t_ratio]);
    }
  }
}
