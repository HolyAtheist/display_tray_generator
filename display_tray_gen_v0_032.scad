//laser cut display tray
// for hanging or standing
// v0 by t b mosich

// script for generating hanging/standing display/tool/spicerack trays for laser cutting
// work in progress; code is not exemplary
// todo: alternate press-fit connector instead of hooks? 
// todo: some modules use thickness but should use material_thickness


model_view = 1;
// 1 == 3d assembled view
// 2 == 2d flat projection for laser cutting
// 3 == 3d parts disasembled

// use model_view = 2, then render (F6),
// then export as e.g. .pdf to get outlines for cutting


// units millimeters
// smallest functional tray ~4cm wide x ~2cm deep depending on thickness

//example measurements
//business card eu 54 x 85 mm
//magazine a4 210 × 297 mm


material_thickness = 3.00; // material thickness in mm
kerf_thickness = 0.5; // kerf or adjustment to cutouts; this may need to be set differently for different material types or thicknesses
thickness = material_thickness+kerf_thickness; // combined thickness

bottom_depth=50; // depth of the base plate; 
                 // usable depth will be less due to back and front being inset
inside_width=190; // inside width of tray; total width should be inside_width+4*thickness

side_height=50;
side_hanging_hook=true; // set to false if you do not want the hooks or the brackets
side_hook_z_offset_mult=1; //position of hanging hook, 0=top
screw_diam=3; // for the bracket

front_lip_height=20;
front_lip_angle=22;
front_lip_offset_z=thickness;
front_lip_offset_x=bottom_depth-thickness*1;
front_lip_extra_height=20; // height of optional extra front lip part

back_height=30; // the "inside" back part should be less than side_height 
back_angle=0;
back_offset_z=thickness;
back_offset_x=thickness*2;
back_extra_height=20; // height of optional extra back part

// optional divider
divider=false;
divider_height=60;
divider_angle=5;
divider_offset_z=thickness;
divider_offset_x=bottom_depth/2+thickness;
divider_extra_height=40;
divider_extra_shape = "rounded2";

// side panel shape options -- "square", "triangle", "curved", "house", "forward_slant"
side_shape = "curved";

// back panel & front lip extra shape options -- "square", "rounded", "rounded2", "rounded3", "angular", "arrow", "trapezoid"
back_extra_shape = "rounded3";
front_lip_extra_shape = "rounded3";

// global $fn value for circle smoothness; high values will make rendering SLOW
$fn = 20;

//experimental wip
mirror=false;






module bottom_plate() {  
union(){
    translate([0,thickness,thickness])
    create_square(thickness=thickness, x=bottom_depth, y=inside_width);
    
    translate([thickness,inside_width+thickness,thickness]) 
    cube([3*thickness, thickness, thickness]);
    
    translate([bottom_depth-4*thickness,inside_width+thickness,thickness]) 
    cube([3*thickness, thickness, thickness]);

    translate([thickness,0,thickness]) 
    cube([3*thickness, thickness, thickness]);
    
    translate([bottom_depth-4*thickness,0,thickness]) 
    cube([3*thickness, thickness, thickness]);
 }
}


module create_bracket() {
    color("brown", 0.75) {
        create_square_w_screwholes(thickness, 4 * thickness, inside_width + 6 * thickness, screw_diam, inside_width);
    }
}

module bracket() {
    if (side_hanging_hook) {
        if (model_view == 1) {
            translate([0, -2 * thickness, side_height - 6 * thickness - side_hook_z_offset_mult * thickness]) {
                rotate([0, -90, 0]) {
                    create_bracket();
                }
            }
        } else {
            create_bracket();
        }
    }
}



module create_bracket2() {
    difference() {
        color("grey", 0.65) {
            create_square_w_screwholes(thickness, 4 * thickness, inside_width + 6 * thickness, screw_diam, inside_width);
        }
        translate([2 * thickness, thickness,  - 2 * thickness]) {
            create_colored_square(4 * thickness, 6 * thickness, 3 * thickness, "pink");
        }
        translate([2 * thickness, inside_width+2*thickness,  - 2 * thickness]) {
            create_colored_square(4 * thickness, 6 * thickness, 3 * thickness, "pink");
        }
    } 
}

module bracket2() {
    if (side_hanging_hook) {
        if (model_view == 1) {
            translate([-thickness, -2 * thickness, side_height - 6 * thickness - side_hook_z_offset_mult * thickness]) {
                rotate([0, -90, 0]) {
                    create_bracket2();
                }
            }
        } else {
            create_bracket2();
        }
    }
}





module back_plate(shape_type) {
    if (model_view == 1) {
        translate([2 * thickness, thickness, 2 * thickness + thickness / 2]) {
            rotate([0, -90, 0]) {
                create_back_plate(shape_type);
            }
        }
    } else {
                create_back_plate(shape_type);
    }
}

module create_back_plate(shape_type) {
    union() {
        create_colored_square(thickness, back_height, inside_width, "green");

        place_hook_connector(thickness, 0, 0, thickness, 0, 180, -90, "green");
        place_hook_connector(thickness, 0, back_height - 2 * thickness, thickness, 0, 180, -90, "green");
        place_hook_connector(thickness, -inside_width, 0, 0, 0, 0, -90, "green");
        place_hook_connector(thickness, -inside_width, back_height - 2 * thickness, 0, 0, 0, -90, "green");

        color("green", 0.65) {
            translate([back_height, 0, 0]) {
                extra_part_shape(thickness, back_extra_height, inside_width, shape_type);
            }
        }
    }
}






module extra_part_shape(thickness, x, y, shape_type) {
    if (shape_type == "square") {
        lasercutoutSquare(thickness = thickness, x = x, y = y);
    } else if (shape_type == "rounded") {
        union() {
            linear_extrude(thickness) {
                square([x/2, y]);
            }
translate([x/2, y/2]) {
    scale([x/y, 1, 1]) {
        linear_extrude(thickness) {
            circle(d = y);
        }
    }
}
        }
    } else if (shape_type == "rounded2") {

translate([0, y/2]) {
    scale([x/y, 1, 1]) {
        difference() {
            linear_extrude(thickness) {
                circle(d = y);
            }
            // Create a cube to cut off the bottom half of the circle
            translate([-x, -y/2, -thickness]) cube([x, y, thickness*3]);
        }
    }
}
      
    }
     else if (shape_type == "rounded3") {
difference() {
       //union() {
            linear_extrude(thickness) {
                square([x/2, y]);
            }
translate([x/2, y/2, -thickness]) {
    scale([x/y, 1, 1]) {
        linear_extrude(thickness*3) {
            circle(d = y);
        }
    }
}
        }
//}
      
    }
    
    else if (shape_type == "angular") {
        linear_extrude(thickness) {
            polygon(points = [[x/2, thickness], [0, 0], [0, y], [x/2, y-thickness], [x, y-y/3], [x, y/3]]);
        }

}else if (shape_type == "arrow") {
        linear_extrude(thickness) {
polygon(points = [[x/4, y/3], [-thickness*1, y/2], [x/4, y-y/3], [x, y-y/3], [x/2, y/2], [x, y/3]   ]);
        }
    } else if (shape_type == "trapezoid") {
        linear_extrude(thickness) {
            polygon(points = [[x, thickness*2], [0, 0], [0, y], [x, y-thickness*2]]);
        }
    }
}

///// side plate
/// this is a bit of a mess,
// but hard to refactor as we are positioning the holes in 3d space,
// according to the other parts
// this means there are several nested translates

module side_platev2(pos, shape_type) {    
 union(){
    
    difference(){   
    color("blue",0.75) 
    translate([0,pos+thickness,0]) 
    rotate([90,0,0]) 

    //shape of the side panel
    // Generate a side with a 'shape' edge
    side_shape(thickness = thickness, bottom_depth = bottom_depth, side_height = side_height, shape_type = shape_type);


   //cutouts
        //front lip
    translate([thickness,pos-thickness/2,thickness]) 
    cube([3*thickness, 2*thickness, thickness]);
    
    translate([bottom_depth-4*thickness,pos-thickness/2,thickness]) 
    cube([3*thickness, 2*thickness, thickness]);
    
    translate([front_lip_offset_x,pos+thickness,2*thickness+thickness/2+front_lip_offset_z])   
    rotate([0,-90-front_lip_angle,0])
  
    translate([0,-2*thickness,thickness]) 
    rotate([0,180,-90]) 
    cube([3*thickness, 2*thickness, thickness]);

    translate([front_lip_offset_x,pos+thickness,2*thickness+thickness/2+front_lip_offset_z])   
    rotate([0,-90-front_lip_angle,0])

    translate([front_lip_height-2*thickness,-2*thickness,thickness]) 
    rotate([0,180,-90]) 
    cube([3*thickness, 2*thickness, thickness]);
    
       // divider
    if (divider==true){
    translate([thickness,pos-thickness/2,thickness]) 
    cube([3*thickness, 2*thickness, thickness]);
    
    translate([bottom_depth-4*thickness,pos-thickness/2,thickness]) 
    cube([3*thickness, 2*thickness, thickness]);
    
    translate([divider_offset_x,pos+thickness,2*thickness+thickness/2+divider_offset_z])   
    rotate([0,-90-divider_angle,0])
    
    translate([0,-2*thickness,thickness]) 
    rotate([0,180,-90]) 
    cube([3*thickness, 2*thickness, thickness]);

    translate([divider_offset_x,pos+thickness,2*thickness+thickness/2+divider_offset_z])   
    rotate([0,-90-divider_angle,0])

    translate([divider_height-2*thickness,-2*thickness,thickness]) 
    rotate([0,180,-90]) 
    cube([3*thickness, 2*thickness, thickness]);
    }
       //back

    translate([thickness,pos-thickness/2,thickness]) 
    cube([3*thickness, 2*thickness, thickness]);
    
    translate([bottom_depth-4*thickness,pos-thickness/2,thickness]) 
    cube([3*thickness, 2*thickness, thickness]);
    
    translate([back_offset_x,pos+thickness,2*thickness+thickness/2+back_offset_z])   
    rotate([0,-90-back_angle,0])
    
    translate([0,-2*thickness,thickness]) 
    rotate([0,180,-90]) 
    cube([3*thickness, 2*thickness, thickness]);

    translate([back_offset_x,pos+thickness,2*thickness+thickness/2+back_offset_z])   
    rotate([0,-90-back_angle,0])

    translate([back_height-2*thickness,-2*thickness,thickness]) 
    rotate([0,180,-90]) 
    cube([3*thickness, 2*thickness, thickness]);
    
   }
   //side back part hook
if (side_hanging_hook == true) {
    color("blue", 0.55)
    translate([-2 * thickness - kerf_thickness, pos, 0])
        cube([2 * thickness + kerf_thickness, thickness, side_height - 8 * thickness - thickness * side_hook_z_offset_mult]);
    
    color("blue", 0.65)
    translate([-2 * thickness - kerf_thickness, pos, side_height - 4 * thickness - thickness * side_hook_z_offset_mult])
        cube([thickness, thickness, 4 * thickness + thickness * side_hook_z_offset_mult]);
    
    color("blue", 0.75)
    translate([-thickness - kerf_thickness, pos, side_height - 2 * thickness - thickness * side_hook_z_offset_mult])
        cube([thickness + kerf_thickness, thickness, 2 * thickness + thickness * side_hook_z_offset_mult]);
}
   }
}


module side_shape(thickness, bottom_depth, side_height, shape_type = "triangle") {
        if (shape_type == "square") {
        square_edge_shape(thickness, bottom_depth, side_height); 
        } else if (shape_type == "triangle") {
        straight_edge_shape(thickness, bottom_depth, side_height);
    } else if (shape_type == "curved") {
        curved_edge_shape(thickness, bottom_depth, side_height);
    } else if (shape_type == "forward_slant") {
        rounded_edge_shape(thickness, bottom_depth, side_height);
    } else if (shape_type == "house") {
        house_edge_shape(thickness, bottom_depth, side_height);
    } else {
        echo("Invalid shape type specified.");
    }
}

module straight_edge_shape(thickness, bottom_depth, side_height) {
    hull() {
        linear_extrude(thickness) {
            square([bottom_depth, 3 * thickness]);
        }
        translate([0, 5]) {
            linear_extrude(thickness) {
                square([3 * thickness, side_height - 5]);
            }
        }
    }
}

module square_edge_shape(thickness, bottom_depth, side_height) {
    hull() {
        linear_extrude(thickness) {
            square([bottom_depth, side_height]);
        }
    }
}

module curved_edge_shape(thickness, bottom_depth, side_height) {
    num_points = 50; // Increase this number to make the curve smoother
    points = [
        [0, 0],
        [bottom_depth, 0],
        [0, side_height]
    ];

    hull() {
        // Extrude the base square
        linear_extrude(thickness) {
            square([bottom_depth, 3 * thickness]);
        }
        
        // Create a circular arc to form the curved hypotenuse
        for (i = [0 : num_points]) {
            angle = 90 * i / num_points;
            translate([bottom_depth * cos(angle), side_height * sin(angle)]) {
                linear_extrude(thickness) {
                    circle(d = 1);
                }
            }
        }
    }
}

// rounded forward slant
module rounded_edge_shape(thickness, bottom_depth, side_height) {
    hull() {
        linear_extrude(thickness) {
            square([bottom_depth, 3 * thickness]);
        }
        translate([0, side_height]) {
            union() {
                linear_extrude(thickness) {
                    square([bottom_depth, thickness]);
                }
                translate([bottom_depth, -side_height/3, 0]) {
                    linear_extrude(thickness) {
                        circle(d = thickness*12);
                    }
                }
            }
        }
    }
}



// house edge shape 
module house_edge_shape(thickness, bottom_depth, side_height) {
       difference() {
    hull() {
        linear_extrude(thickness) {
            square([bottom_depth, 3 * thickness]);
        }
        translate([0, side_height]) {
            linear_extrude(thickness) {
                polygon(points = [[0, 0], [bottom_depth / 2, side_height / 2], [bottom_depth, 0]]);
            }
        }
    }

    // Define window-like cutout shape (four squares)
 
    translate([bottom_depth / 2, side_height / 4* 3, -thickness]) cube([thickness * 3, thickness * 3, thickness * 3]); 
    translate([bottom_depth / 2, side_height / 4* 3 -thickness * 3.4, -thickness]) cube([thickness * 3, thickness * 3, thickness * 3]);
    translate([bottom_depth / 2-thickness * 3-thickness/3, side_height / 4* 3, -thickness]) cube([thickness * 3, thickness * 3, thickness * 3]); 
    translate([bottom_depth / 2-thickness * 3-thickness/3, side_height / 4* 3 -thickness * 3.4, -thickness]) cube([thickness * 3, thickness * 3, thickness * 3]);
    }
}

// front lip / divider

module front_lip(height, angle, offset_z, offset_x, extra_height, shape_type) {
    if (model_view == 1) {
    union() {
        translate([ offset_x + angle / 20, thickness, 2 * thickness + thickness / 2 + offset_z - thickness]) {
            rotate([0, -90 - angle, 0]) {
                create_font_lip_main(thickness, inside_width, height=height);    
                  color("purple", 0.55)
                    translate([height, 0, 0])
                    extra_part_shape(thickness, extra_height, inside_width, shape_type = shape_type);
                
            }
        }
    }
    } else {
        // If not model_view == 1, do not do fancy rotate and translate
        union() {
         create_font_lip_main(thickness, inside_width, height);
          color("purple", 0.55)
                    translate([height, 0, 0])
                    extra_part_shape(thickness, extra_height, inside_width, shape_type = shape_type);
    }
}
}

module create_font_lip_main(thickness, inside_width, height) {
    union() {
        color("purple", 0.75) {
            create_square(thickness = thickness, x = height, y = inside_width);
        }
        place_hook_connector(thickness, 0, 0, thickness, 0, 180, -90, "purple");
        place_hook_connector(thickness, 0, height-2*thickness, thickness, 0, 180, -90, "purple");
        place_hook_connector(thickness, -inside_width, 0, 0, 0, 0, -90, "purple");
        place_hook_connector(thickness, -inside_width, height-2*thickness, 0, 0, 0, -90, "purple");
    }
}




module create_square_w_screwholes(thickness, x, y, screw_diam, inside_width) {
    difference() {
    // Create the square base
    create_square(thickness, x, y);

    // Create the symmetrical round cutouts
    // Calculate the positions for the holes
    hole_offset_x = x / 2;
    hole_offset_y = y / 3;

    // Create the holes
 
        // Left hole
        translate([hole_offset_x, hole_offset_y, thickness / 2]) {
            cylinder(h = thickness * 3, d = screw_diam, center = true);
        }

        // Right hole (symmetrical to the left hole)
        translate([x - hole_offset_x, hole_offset_y*2, thickness / 2]) {
            cylinder(h = thickness * 3, d = screw_diam, center = true);
        }
    }
}

module create_colored_square(thickness, x, y, color_value) {
    color(color_value, 0.75) {
       // lasercutoutSquare(thickness = thickness, x = x, y = y);
        create_square(thickness, x, y);
    }
}

module create_square(thickness, x, y) {
        points = [[0,0], [x,0], [x,y], [0,y], [0,0]];
       linear_extrude(height = thickness , center = false)  polygon(points=points);
    
}


module place_hook_connector(thickness, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, color_value) {
    color(color_value, 0.75) {
        // First, apply the initial translation and rotation
        translate([0, 0, pos_z]) {
            rotate([rot_x, rot_y, rot_z]) {
                // Then, apply the translation along the local x-axis
                translate([pos_x, pos_y, 0]) {
                    // Finally, place the hook connector
                    hook_connector(thickness);
                }
            }
        }
    }
}

// Function to create a hook connector
module hook_connector(thickness) {
    // The length of the part that connects to the object
    length_connect = 2 * thickness;
    // The width of the hook (can be adjusted as needed)
    width = thickness;

    // Part that connects to the object
    translate([-length_connect, 0, 0])
    cube([width, thickness, thickness]);

    // Hook part (rotated by 90 degrees and translated)
    translate([0, thickness, 0])
    rotate([0, 0, 90])
    cube([width, length_connect, thickness]);
}




// Example usage

//3d assembled model
if (model_view == 1 && mirror==false) {
    bottom_plate();
    side_platev2(pos=inside_width+thickness, shape_type = side_shape);
    side_platev2(pos=0, shape_type = side_shape);

    front_lip(height = front_lip_height, angle = front_lip_angle, offset_z = front_lip_offset_z, offset_x = front_lip_offset_x, extra_height = front_lip_extra_height, shape_type = front_lip_extra_shape);
    if (divider==true){
        front_lip(height = divider_height, angle = divider_angle, offset_z = divider_offset_z, offset_x = divider_offset_x, extra_height = divider_extra_height, shape_type = divider_extra_shape);
    }
    
    
front_lip(height = back_height, angle = back_angle, offset_z = back_offset_z, offset_x = back_offset_x, extra_height = back_extra_height, shape_type = back_extra_shape);
    //back_plate(shape_type = back_extra_shape);
    
    
    
    bracket();  
    bracket2();
    } 
    
    
    // wip
    else if(model_view == 1 && mirror==true) {
        
     side_platev2(pos=0, shape_type = side_shape);       
        
    translate([0 , thickness, 0])
    rotate([0, 0, 180])
    side_platev2(pos=0, shape_type = side_shape);
    
    //translate([-bottom_depth+thickness/2 , 0, 0])    
    front_lip(height = back_height, angle = back_angle, offset_z = back_offset_z, offset_x = back_offset_x, extra_height = back_extra_height, shape_type = back_extra_shape);
        
    }
    

    
//3d disassembled
else if (model_view == 3) {
    // Bottom plate
    translate([0 , thickness, -thickness]) {
        bottom_plate();
    }

    // Side plate 1
   // translate([2 * thickness, inside_width  + 5 * thickness, -side_height - 3*thickness]) {
     //   rotate([90, 0, 0]) {
           // side_platev2(pos = inside_width + thickness, shape_type = side_shape);
      //  }
  //  }

    // Side plate 2
    translate([0, inside_width + 12 * thickness, 0]) {
        rotate([90, 0, 90]) {
            side_platev2(pos = 0, shape_type = side_shape);
        }
    }
    
        translate([side_height+thickness, inside_width + 12 * thickness, 0]) {
        rotate([90, 0, 90]) {
            side_platev2(pos = 0, shape_type = side_shape);
        }
    }

    // Front lip
    translate([bottom_depth + back_height + back_extra_height + 2*thickness, 2*thickness, 0])
    front_lip(height = front_lip_height, angle = front_lip_angle, offset_z = front_lip_offset_z, offset_x = front_lip_offset_x, extra_height = front_lip_extra_height, shape_type = front_lip_extra_shape);
    
    if (divider==true){
         translate([bottom_depth + back_height + back_extra_height + front_lip_height + front_lip_extra_height + 3*thickness, 2*thickness, 0])
        front_lip(height = divider_height, angle = divider_angle, offset_z = divider_offset_z, offset_x = divider_offset_x, extra_height = divider_extra_height, shape_type = divider_extra_shape);
    }

    // Back plate
translate([bottom_depth + thickness, 2*thickness, 0])
          //  back_plate(shape_type = back_extra_shape);
    front_lip(height = back_height, angle = back_angle, offset_z = back_offset_z, offset_x = back_offset_x, extra_height = back_extra_height, shape_type = back_extra_shape);


    // Bracket 1
    translate([0, inside_width + 9 * thickness, 0]) {
        rotate([0, 0, -90]) {
            bracket();
        }
    }

    // Bracket 2
    translate([inside_width+7*thickness, inside_width + 9 * thickness, 0]) {
        rotate([0, 0, -90]) {
            bracket2();
        }
    }
}


 //   
 // 2d projected flat
else if (model_view == 2) {
    
    projection(cut = false) {
    
    
        translate([0, thickness, -thickness]) {
            bottom_plate();
        }

    translate([0, inside_width + 12 * thickness, 0]) {
        rotate([90, 0, 90]) {
            side_platev2(pos = 0, shape_type = side_shape);
        }
    }

    translate([side_height + thickness*10, inside_width + 12 * thickness, 0]) {
        rotate([90, 0, 90]) {
            side_platev2(pos = 0, shape_type = side_shape);
        }
    }

    translate([bottom_depth + back_height + back_extra_height + 2 * thickness, 2 * thickness, 0]) {
        front_lip(
            height = front_lip_height,
            angle = front_lip_angle,
            offset_z = front_lip_offset_z,
            offset_x = front_lip_offset_x,
            extra_height = front_lip_extra_height,
            shape_type = front_lip_extra_shape
        );
    }

    if (divider == true) {
        translate([bottom_depth + back_height + back_extra_height + front_lip_height + front_lip_extra_height + 3 * thickness, 2 * thickness, 0]) {
            front_lip(
                height = divider_height,
                angle = divider_angle,
                offset_z = divider_offset_z,
                offset_x = divider_offset_x,
                extra_height = divider_extra_height,
                shape_type = divider_extra_shape
            );
        }
    }

    translate([bottom_depth + thickness, 2 * thickness, 0]) {
       /// back_plate(shape_type = back_extra_shape);
        front_lip(height = back_height, angle = back_angle, offset_z = back_offset_z, offset_x = back_offset_x, extra_height = back_extra_height, shape_type = back_extra_shape);
    }

        // Bracket 1
    translate([0, inside_width + 9 * thickness, 0]) {
        rotate([0, 0, -90]) {
            bracket();
        }
    }

    // Bracket 2
    translate([inside_width + 7 * thickness, inside_width + 9 * thickness, 0]) {
        rotate([0, 0, -90]) {
            bracket2();
        }
    }
    }
}


