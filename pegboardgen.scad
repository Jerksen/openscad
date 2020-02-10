// PEGSTR - Pegboard Wizard
// Design by Marius Gheorghescu, November 2014
// Update log:
// November 9th 2014
//		- first coomplete version. Angled holders are often odd/incorrect.
// November 15th 2014
//		- minor tweaks to increase rendering speed. added logo. 
// November 28th 2014
//		- bug fixes

// September 29th 2019
//      - added x and y offset customization       

// TODO - update to make an option for screw mounts instead of pegs

// preview[view:north, tilt:bottom diagonal]

// size of the the orifices
holder_x_size = 50;
holder_y_size = 60;
holder_height = 25;

// how thick are the walls. Hint: 6*extrusion width produces the best results.
wall_thickness = 1.85;

// how many times to repeat the holder on each axis
holder_x_count = 1;
holder_y_count = 1;

// how much space to put between the orifices
holder_x_space = 0;
holder_y_space = 0;

// orifice corner radius (roundness). if > min(x, y)/2 and x == y, you get a circle
// if > min(x,y)/2, you get a hockey rink shape
corner_radius = 30;

// Use values less than 1.0 to make the bottom of the holder narrow
// this is the ratio of the opening at the top to the opening at the bottom
// 1 = straing edges, 0 = a cone
taper_ratio = .25;

/* [Advanced] */

// offset from the peg board, typically 0 unless you have an object that needs clearance
holder_offset = 5;

// added re-enforcements
// adds extra height to the pegboard side, 
strength_factor = 1;

// should the height of the holder be adjusted to line up with pegs?
snap_to_pegs = true;

// for bins: what ratio of wall thickness to use for closing the bottom
// if 0, there will be a hole
// if between 0 and 1, it will only have an impact if strength_factor = 0
closed_bottom = 0;

// what percentage to cut in the front (example to slip in a cable or make the tool snap from the side)

holder_cutout_side = 0;

// set an angle for the holder to prevent object from sliding or to view it better from the top
holder_angle = 0;


/* [Hidden] */

// what is the $fn parameter
holder_sides = max(50, min(20, holder_x_size*2));

// dimensions the same outside US?
hole_spacing = 25.4;
hole_size = 6.0035;
board_thickness = 5;

// calc some vars
holder_total_x = wall_thickness + holder_x_count*(wall_thickness+holder_x_size) + (holder_x_count-1)*holder_x_space;
holder_total_y = wall_thickness + holder_y_count*(wall_thickness+holder_y_size) + (holder_y_count-1)*holder_y_space;
holder_total_z = snap_to_pegs ? ceil(holder_height/hole_spacing + strength_factor)*hole_spacing : (holder_height/hole_spacing + strength_factor)*hole_spacing;
holder_roundness = min(corner_radius, holder_x_size/2, holder_y_size/2);

echo("total_x = ", holder_total_x);
echo("total_y = ", holder_total_y);
echo("total_z = ", holder_total_z);
echo("roundness = ", holder_roundness);

// what is the $fn parameter for holders
fn = 32;

epsilon = 0.1;

clip_height = 2*hole_size + 2;
$fn = fn;

module round_rect_ex(x1, y1, x2, y2, z, r1, r2)
{
  /*
    x1, x2
  */
	$fn=holder_sides;
	brim = z/10;
  
  // this will prevent funny business when holder_angles are high.
  top_brim = z;

	//rotate([0,0,(holder_sides==6)?30:((holder_sides==4)?45:0)])
	hull() {
        translate([-x1/2 + r1, y1/2 - r1, z/2-brim/2])
            cylinder(r=r1, h=top_brim,center=true);
        translate([x1/2 - r1, y1/2 - r1, z/2-brim/2])
            cylinder(r=r1, h=top_brim,center=true);
        translate([-x1/2 + r1, -y1/2 + r1, z/2-brim/2])
            cylinder(r=r1, h=top_brim,center=true);
        translate([x1/2 - r1, -y1/2 + r1, z/2-brim/2])
            cylinder(r=r1, h=top_brim,center=true);

        translate([-x2/2 + r2, y2/2 - r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([x2/2 - r2, y2/2 - r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([-x2/2 + r2, -y2/2 + r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([x2/2 - r2, -y2/2 + r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);

    }
}

module pin(clip)
{
/* make a pin - the peice that gets inserted into the pegboard holes
  
  param clip: boolean
        if true, make a top clip, if false, make a standard peg
*/
	rotate([0,0,15])
	cylinder(r=hole_size/2, h=board_thickness*1.5+epsilon, center=true, $fn=12);

	if (clip) {
		//
		rotate([0,0,90])
		intersection() {
			translate([0, 0, hole_size-epsilon])
				cube([hole_size+2*epsilon, clip_height, 2*hole_size], center=true);

			// [-hole_size/2 - 1.95,0, board_thickness/2]
			translate([0, hole_size/2 + 2, board_thickness/2]) 
				rotate([0, 90, 0])
				rotate_extrude(convexity = 5, $fn=20)
				translate([5, 0, 0])
				 circle(r = (hole_size*0.95)/2); 
			
			translate([0, hole_size/2 + 2 - 1.6, board_thickness/2]) 
				rotate([45,0,0])
				translate([0, -0, hole_size*0.6])
					cube([hole_size+2*epsilon, 3*hole_size, hole_size], center=true);
		}
	}
}

module pinboard_clips(width, height) 
{
/* make all the pins based on the size of the holder.
  
  param width, height: float
    what are the dimensions of the holder
    
*/
	rotate([0,90,0])
	for(i=[0:round(width/hole_spacing)]) {
		for(j=[0:(holder_total_z/hole_spacing)]) {

			translate([
				j*hole_spacing, 
				-hole_spacing*(round(width/hole_spacing)/2) + i*hole_spacing, 
				0])
					pin(j==0);
		}
	}
}

module pinboard(width, height)
{
/*
    create the plate that the pins and clips attach to
    pins and clips and plate holding it all together
  
  param width, height: float
    what are the dimensions of the holder
*/
	rotate([0,90,0])
	translate([-epsilon, 0, -wall_thickness - board_thickness/2 + epsilon])
	hull() {
		translate([-clip_height/2 + hole_size/2, 
			-hole_spacing*(round(width/hole_spacing)/2),0])
			cylinder(r=hole_size/2, h=wall_thickness);

		translate([-clip_height/2 + hole_size/2, 
			hole_spacing*(round(width/hole_spacing)/2),0])
			cylinder(r=hole_size/2,  h=wall_thickness);

		translate([holder_total_z,
			-hole_spacing*(round(width/hole_spacing)/2),0])
			cylinder(r=hole_size/2, h=wall_thickness);

		translate([holder_total_z,
			hole_spacing*(round(width/hole_spacing)/2),0])
			cylinder(r=hole_size/2,  h=wall_thickness);

	}
}

module holder(negative)
{
/*
    create the actual holder, but no bottoms or anything
  
  param negative: int
    0 makes the actual holder
    1 makes an inner cavity to hollow everything out
    2 makes an extra tall inner cavity matching the smallest opening
      if taper_ratio != 1 that is used for open bottoms
*/
	for(x=[1:holder_x_count]){
		for(y=[1:holder_y_count]) 
/*		render(convexity=2)*/ {
            // translate to the last 
			translate([
				-holder_total_y /*- (holder_y_size+wall_thickness)/2*/ + y*(holder_y_size+wall_thickness) + wall_thickness + (y-1)*holder_y_space,

				-holder_total_x/2 + (holder_x_size+wall_thickness)/2 + (x-1)*(holder_x_size+wall_thickness) + wall_thickness/2 + (x-1)*holder_x_space,
				 0]) {
        rotate([0, holder_angle, 0])
        translate([
          -wall_thickness*abs(sin(holder_angle))-0*abs((holder_y_size/2)*sin(holder_angle))-holder_offset-(holder_y_size + 2*wall_thickness)/2 - board_thickness/2,
          0,
          -(holder_height/2)*sin(holder_angle) - holder_height/2 + clip_height/2
          ])
        difference() {
          if (!negative) {
            // if neg = 0, this will form the outer shell of the 
            // holder

            round_rect_ex(
              (holder_y_size + 2*wall_thickness), 
              holder_x_size + 2*wall_thickness, 
              (holder_y_size + 2*wall_thickness)*taper_ratio, 
              (holder_x_size + 2*wall_thickness)*taper_ratio, 
              holder_height, 
              holder_roundness + epsilon, 
              holder_roundness*taper_ratio + epsilon);
          }
          
          translate([0,0,closed_bottom*wall_thickness])
          if (negative>1) {
            // if neg = 2, this creates a triple high cavity of the holder
            round_rect_ex(
              holder_y_size*taper_ratio, 
              holder_x_size*taper_ratio, 
              holder_y_size*taper_ratio, 
              holder_x_size*taper_ratio, 
              3*max(holder_total_z, hole_spacing),
              holder_roundness*taper_ratio + epsilon, 
              holder_roundness*taper_ratio + epsilon);
          } else {
            // if neg = 0, this creates a cavity of the holder
            round_rect_ex(
              holder_y_size, 
              holder_x_size, 
              holder_y_size*taper_ratio, 
              holder_x_size*taper_ratio, 
              holder_height+2*epsilon,
              holder_roundness + epsilon, 
              holder_roundness*taper_ratio + epsilon);
          }

          if (!negative && holder_cutout_side > 0) {
            hull() {
              scale([1.0, holder_cutout_side, 1.0])
                round_rect_ex(
                holder_y_size, 
                holder_x_size, 
                holder_y_size*taper_ratio, 
                holder_x_size*taper_ratio, 
                holder_height+5*epsilon,
                holder_roundness + epsilon, 
                holder_roundness*taper_ratio + epsilon);
      
              translate([0-(holder_y_size + 2*wall_thickness), 0,0])
              scale([1.0, holder_cutout_side, 1.0])
                round_rect_ex(
                holder_y_size, 
                holder_x_size, 
                holder_y_size*taper_ratio, 
                holder_x_size*taper_ratio, 
                holder_height+2*epsilon,
                holder_roundness + epsilon, 
                holder_roundness*taper_ratio + epsilon);
            }
          }
        } // diff
      } // positioning
    } // for y
	} // for X
}


module pegstr() 
{
  /*
    build the full shebang
  */
  
	difference() {
    // make the holder and remove the cavity
		union() {
      // create the overall outer shape of the holder + pinboard
      color([1,0,0]);
      hull() {
        pinboard(holder_total_x, holder_total_z);
        holder(0);
      }
      
      // add the pins to the board
      color([0,0,1])
			pinboard_clips(holder_total_x, holder_total_z);

      // TODO, what does this do?
			*color([0,1,0])
			*difference() {
				holder(0);
				holder(2);
			}
		}
    
    // this is the cavity
		holder(1);
    
    // and the hole in the bottom
    if (closed_bottom*wall_thickness < epsilon) {
      holder(2);
    }
	}
}

rotate([180,0,0]) pegstr();
