// Pegboard Generator
// Based on an original Design by Marius Gheorghescu, November 2014

// TODO - update to make an option for screw mounts instead of pegs

// TODO - offset seems to break it when holder_angle != 0

// preview[view:north, tilt:bottom diagonal]

// size of the the orifice
holder_x_size = 20;
holder_y_size = 20;

// hight of the holder
holder_height = 12;

// how thick are the walls. Hint: 6*extrusion width produces the best results.
wall_thickness = 1.85;

// how many times to repeat the holder on each axis
holder_x_count = 1;
holder_y_count = 1;

// how much space to put between the orifices
holder_x_space = 0;
holder_y_space = 0;

// orifice corner radius (roundness). Needs to be less than min(x,y)/2.
corner_radius = 20;

// Use values less than 1.0 to make the bottom of the holder narrow
taper_ratio = 1;

/* [Advanced] */

// offset from the peg board, typically 0 unless you have an object that needs clearance
holder_offset = 5;

// what ratio of the holders bottom is reinforced to the plate [0.0-1.0]
strength_factor = .66;

// for bins: what ratio of wall thickness to use for closing the bottom
closed_bottom = 0;

// what percentage to cut in the front (example to slip in a cable or make the tool snap from the side)
holder_cutout_side = 0.3;

// set an angle for the holder to prevent object from sliding or to view it better from the top
holder_angle = 0;


/* [Hidden] */

// what is the $fn parameter
holder_sides = max(50, min(20, holder_x_size*2));

// dimensions the same outside US?
hole_spacing = 25.4;
hole_size = 6.0035;
board_thickness = 5;


holder_total_x = wall_thickness + holder_x_count*(wall_thickness+holder_x_size) + (holder_x_count-1)*holder_x_space;
holder_total_y = wall_thickness + holder_y_count*(wall_thickness+holder_y_size) + (holder_y_count-1)*holder_y_space;
holder_total_z = round(holder_height/hole_spacing)*hole_spacing;
holder_roundness = min(corner_radius, holder_x_size/2, holder_y_size/2); 


// what is the $fn parameter for holders
fn = 32;

epsilon = 0.1;

clip_height = 2*hole_size + 2;
$fn = fn;

module round_rect_ex(x1, y1, x2, y2, z, r1, r2)
{
	$fn=holder_sides;
	brim = z/10;

	//rotate([0,0,(holder_sides==6)?30:((holder_sides==4)?45:0)])
	hull() {
        translate([-x1/2 + r1, y1/2 - r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([x1/2 - r1, y1/2 - r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([-x1/2 + r1, -y1/2 + r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([x1/2 - r1, -y1/2 + r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);

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
/* param clip: boolean
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

module pinboard_clips() 
{
/*  make all the pins based on the size of the holder.
    
*/
	rotate([0,90,0])
	for(i=[0:round(holder_total_x/hole_spacing)]) {
		for(j=[0:max(strength_factor, round(holder_height/hole_spacing))]) {

			translate([
				j*hole_spacing, 
				-hole_spacing*(round(holder_total_x/hole_spacing)/2) + i*hole_spacing, 
				0])
					pin(j==0);
		}
	}
}

module pinboard(clips)
{
/*
    create the plate that the pins and clips attach to
    pins and clips and plate holding it all together
*/
	rotate([0,90,0])
	translate([-epsilon, 0, -wall_thickness - board_thickness/2 + epsilon])
	hull() {
		translate([-clip_height/2 + hole_size/2, 
			-hole_spacing*(round(holder_total_x/hole_spacing)/2),0])
			cylinder(r=hole_size/2, h=wall_thickness);

		translate([-clip_height/2 + hole_size/2, 
			hole_spacing*(round(holder_total_x/hole_spacing)/2),0])
			cylinder(r=hole_size/2,  h=wall_thickness);

		translate([max(strength_factor, round(holder_height/hole_spacing))*hole_spacing,
			-hole_spacing*(round(holder_total_x/hole_spacing)/2),0])
			cylinder(r=hole_size/2, h=wall_thickness);

		translate([max(strength_factor, round(holder_height/hole_spacing))*hole_spacing,
			hole_spacing*(round(holder_total_x/hole_spacing)/2),0])
			cylinder(r=hole_size/2,  h=wall_thickness);

	}
}

module holder(negative)
{
/*
    create the actual holder, but no bottoms or anything
    
*/
	for(x=[1:holder_x_count]){
		for(y=[1:holder_y_count]) 
/*		render(convexity=2)*/ {
            // translate to the last 
			translate([
				-holder_total_y /*- (holder_y_size+wall_thickness)/2*/ + y*(holder_y_size+wall_thickness) + wall_thickness + (y-1)*holder_y_space,

				-holder_total_x/2 + (holder_x_size+wall_thickness)/2 + (x-1)*(holder_x_size+wall_thickness) + wall_thickness/2 + (x-1)*holder_x_space,
				 0])			
	{
		rotate([0, holder_angle, 0])
		translate([
			-wall_thickness*abs(sin(holder_angle))-0*abs((holder_y_size/2)*sin(holder_angle))-holder_offset-(holder_y_size + 2*wall_thickness)/2 - board_thickness/2,
			0,
			-(holder_height/2)*sin(holder_angle) - holder_height/2 + clip_height/2
		])
		difference() {
			if (!negative)

				round_rect_ex(
					(holder_y_size + 2*wall_thickness), 
					holder_x_size + 2*wall_thickness, 
					(holder_y_size + 2*wall_thickness)*taper_ratio, 
					(holder_x_size + 2*wall_thickness)*taper_ratio, 
					holder_height, 
					holder_roundness + epsilon, 
					holder_roundness*taper_ratio + epsilon);

				translate([0,0,closed_bottom*wall_thickness])

				if (negative>1) {
					round_rect_ex(
						holder_y_size*taper_ratio, 
						holder_x_size*taper_ratio, 
						holder_y_size*taper_ratio, 
						holder_x_size*taper_ratio, 
						3*max(holder_height, hole_spacing),
						holder_roundness*taper_ratio + epsilon, 
						holder_roundness*taper_ratio + epsilon);
				} else {
					round_rect_ex(
						holder_y_size, 
						holder_x_size, 
						holder_y_size*taper_ratio, 
						holder_x_size*taper_ratio, 
						holder_height+2*epsilon,
						holder_roundness + epsilon, 
						holder_roundness*taper_ratio + epsilon);
				}

			if (!negative)
				if (holder_cutout_side > 0) {

				if (negative>1) {
					hull() {
						scale([1.0, holder_cutout_side, 1.0])
		 					round_rect_ex(
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							3*max(holder_height, hole_spacing),
							holder_roundness*taper_ratio + epsilon, 
							holder_roundness*taper_ratio + epsilon);
		
						translate([0-(holder_y_size + 2*wall_thickness), 0,0])
						scale([1.0, holder_cutout_side, 1.0])
		 					round_rect_ex(
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							3*max(holder_height, hole_spacing),
							holder_roundness*taper_ratio + epsilon, 
							holder_roundness*taper_ratio + epsilon);
					}
				} else {
					hull() {
						scale([1.0, holder_cutout_side, 1.0])
		 					round_rect_ex(
							holder_y_size, 
							holder_x_size, 
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							holder_height+2*epsilon,
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

				}
			}
		} // positioning
	} // for y
	} // for X
}


module pegstr() 
{
	difference() {
		union() {
            
            // create the pinboard
			pinboard();


            // create the overall shape of the holder
			difference() {
				hull() {
					pinboard();
	
					intersection() {
                        // TODO - this didn't work when closed bottom was 1 and strength factor was < 0.5 - there would be no bottom. 
                        // old translate had (strength_factor-.5). look into it and make it more robust
                        // the current way with +.5 screws with the cutout
						translate([-holder_offset - (strength_factor+.5)*holder_total_y - wall_thickness/4 - holder_y_space*(holder_y_count-1),0,0])
						cube([
							holder_total_y + 2*wall_thickness, 
							holder_total_x + wall_thickness, 
							2*holder_height
						], center=true);
	
						!holder(0);
	
					}	
				}

				if (closed_bottom*wall_thickness < epsilon) {
						holder(2);
				}

			}

			color([1,0,0])
			difference() {
				holder(0);
				holder(2);
			}

			color([1,0,0])
				pinboard_clips();
		}
        
		holder(1);

	}
}


rotate([180,0,0]) pegstr();