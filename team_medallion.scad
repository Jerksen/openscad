/********************************
includes
********************************/
include <threads.scad>

/********************************
globals
********************************/
d = 20;
e = 0.1;
h = 5;
t = 0.8;

/********************************
render
********************************/

//hole_through(name="M5", l=50+5, cld=0.1, h=10, hcld=0.4);

base();

//cap();

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
        metric_thread(20,1,h);
        cylinder(h=10, d=d+e);
      }
      // small circular base
      cylinder(h=h/4, d=d+t);
    }
    
    #translate([0,0,1]) cylinder(h=1/16*25.4, d=1/4*25.4, center=true);
  }
  

}

module cap() {
  /*
  cap for a magnetic team medalian
  */
  //scale factor
  sf = (d+.2)/d;
  echo(sf=sf);
  
  difference() {
    //main cylinder
    cylinder(h=h+t, d=d+2*t);
    
    // threading
    
    translate([0,0,-e])
    metric_thread(d,1,h,internal=true);
  }
  
}

module threading () {
  translate([0,0,h-30]) 
  rotate ([0,180,0])
  screw("M20x30", thread="modeled");
}