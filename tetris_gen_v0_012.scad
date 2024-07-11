
model_view = 1;
// 1 == 3d assembled view
// 2 == 2d flat projection for laser cutting
// 3 == 3d parts disasembled

// use model_view = 2, then render (F6),
// then export as e.g. .pdf to get outlines for cutting


// Global variables
material_thickness = 3.00; // material thickness in mm
kerf_thickness = 0.1; // kerf or adjustment to cutouts; this may need to be set differently for different material types or thicknesses
combined_thickness = material_thickness+kerf_thickness; // combined thickness

cube_section_length = 100.00; // mm length of individual cube sections

num_finger_cutouts = 5; //  total connectors per side, use odd numbers

// start modules

sec_len = cube_section_length;

mat_thic = material_thickness;


module finger_cutout(start_index, total_fingers, section_length, thickness, kerf) {
    // Create a 2D finger pattern
    module finger_pattern() {
        for (i = [0 : total_fingers - 1]) {
            if ((i + start_index) % 2 == 0) {
                translate([i * (section_length / total_fingers), 0]) {
                    square([(section_length / total_fingers) + kerf, thickness+kerf], center=false);
                }
            }
        }
    }
    
    // Extrude the 2D pattern to 3D
    linear_extrude(height = thickness + kerf) {
        finger_pattern();
    }
}

module finger_addon(start_index, total_fingers, section_length, thickness, kerf) {
    // Create a 2D finger pattern
    module finger_pattern() {
        for (i = [0 : total_fingers - 1]) {
            if ((i + start_index) % 2 == 0) {
                translate([i * (section_length / total_fingers), 0]) {
                    square([(section_length / total_fingers) -1* kerf, thickness+kerf], center=false);
                }
            }
        }
    }
    
    // Extrude the 2D pattern to 3D
    linear_extrude(height = thickness ) {
        finger_pattern();
    }
}



module flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, finger_sides) {
    difference() {
        create_colored_square(mat_thic, sec_len, sec_len, color_value);
        
        
                // Calculate the start position to center the fingers
        finger_length = sec_len / num_finger_cutouts;
        start_pos = (sec_len - finger_length * num_finger_cutouts) / 2-kerf_thic/2;
        
        
        

if (finger_sides == 1 || finger_sides == 2 || finger_sides == 3 || finger_sides == 4) {
        // Finger cutouts on one edge
        translate([start_pos, -kerf_thic, -kerf_thic/2]) {
            finger_cutout(0, num_finger_cutouts, sec_len, mat_thic, kerf_thic);
        }
    }

if ( finger_sides == 2 || finger_sides == 3 || finger_sides == 4) {
        // Finger cutouts on the opposite edge
        translate([start_pos, sec_len - mat_thic, -kerf_thic/2]) {
            finger_cutout(0, num_finger_cutouts, sec_len, mat_thic, kerf_thic);
        }
    }

if ( finger_sides == 3 || finger_sides == 4) {
        // Finger cutouts on another edge
        translate([mat_thic, start_pos, -kerf_thic/2]) {
            rotate([0, 0, 90]) {
                finger_cutout(1, num_finger_cutouts, sec_len, mat_thic, kerf_thic);
            }
        }
    }

if (finger_sides == 4) {
        // Finger cutouts on the opposite edge
        translate([sec_len+kerf_thic , start_pos, -kerf_thic/2]) {
            rotate([0, 0, 90]) {
                finger_cutout(1, num_finger_cutouts, sec_len, mat_thic, kerf_thic);
            }
        }
    }
    
    if (finger_sides == 5|| finger_sides == 6|| finger_sides == 7|| finger_sides == 8) {  // alt version of one sided
        // Finger cutouts on the opposite adjacent edge (rotated 90 degrees)
        // Finger cutouts on another edge
        translate([mat_thic, start_pos, -kerf_thic/2]) {
            rotate([0, 0, 90]) {
                finger_cutout(1, num_finger_cutouts, sec_len, mat_thic, kerf_thic);
            }
        }
    }
    
    if (  finger_sides == 6|| finger_sides == 7) { // alt two sided
        // Finger cutouts on the adjacent edge (rotated 90 degrees)
        // Finger cutouts on the opposite edge
        translate([sec_len+kerf_thic , start_pos, -kerf_thic/2]) {
            rotate([0, 0, 90]) {
                finger_cutout(1, num_finger_cutouts, sec_len, mat_thic, kerf_thic);
            }
        }
    }
    
    if ( finger_sides == 7|| finger_sides == 8) { // alt three sides
        // Finger cutouts on the opposite edge
        translate([start_pos, sec_len - mat_thic, -kerf_thic/2]) {
            finger_cutout(0, num_finger_cutouts, sec_len, mat_thic, kerf_thic);
        }
    }
    
    }
}




module single_sec(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value) {
    // Bottom face
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,4);
    
    // Top face
    translate([0, 0, sec_len - mat_thic]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,4);
    }
    
    // Front face
    rotate([90, 0, 90]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,4);
    }
    
    // Back face
    rotate([90, 0, 90]) {
        translate([0, 0, sec_len - mat_thic]) {
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,4);
        }
    }
    
    // Left face
    rotate([0, 90, 90]) {
        translate([-sec_len, -sec_len, 0]) {
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,4);
        }
    }
    
    // Right face
    rotate([0, 90, 90]) {
        translate([-sec_len, -sec_len, sec_len - mat_thic]) {
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,4);
        }
    }
}

module create_colored_square(thickness, x, y, color_value) {
    color(color_value, 0.75) {
        create_square(thickness, x, y);
    }
}

module create_square(thickness, x, y) {
        points = [[0,0], [x,0], [x,y], [0,y], [0,0]];
       linear_extrude(height = thickness , center = false)  polygon(points=points);
    
}

module tetris_O_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value) {
    // Base
    translate([sec_len*0, sec_len*1, 0])  {
        rotate([0, 180, 180]) {
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,8); }}
    
    // Side 1
        translate([sec_len*1, sec_len*0, 0])  {
    rotate([0, 180, -90]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,8);
    }
}
    
    // Side 2
    translate([sec_len*1 , sec_len*2,0]) {
            rotate([0, 180, 90]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,8);
    }
}
    
    // Top
    translate([sec_len*2 , sec_len*1, 0]) {
        rotate([0, 180, 0]) {
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,8);
        }
    }
}

module tetris_Z_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value) {
    // Base
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,3);
    
    // Side 1
        translate([sec_len*1, sec_len*0, 0])  {
    rotate([0, 180, -90]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,8);
    }
}
    
    // Side 2
    translate([sec_len*1 , sec_len,0]) {
            rotate([0, 0, 00]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,8);
    }
}
    
    // Top
    translate([sec_len*2 , sec_len*2, 0]) {
        rotate([0, 0, -90]) {
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,7);
        }
    }
}


module tetris_L_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value) {
    // Base
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,3);
    
    // Side 1
        translate([sec_len*2, 0, 0])  {
    rotate([0, 0, 90]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,6);
    }
}
    
    // Side 2
    translate([sec_len*3 , sec_len,0]) {
            rotate([0, 0, 180]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,8);
    }
}
    
    // Top
    translate([sec_len*2 , sec_len*2, 0]) {
        rotate([0, 0, -90]) {
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,3);
        }
    }
}


module tetris_T_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value) {
    // Base
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,3);
    
    // Side 1
        translate([sec_len*2, 0, 0])  {
    rotate([0, 0, 90]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,5);
    }
}
    
    // Side 2
    translate([sec_len*3 , sec_len,0]) {
            rotate([0, 0, 180]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,3);
    }
}
    
    // Top
    translate([sec_len , sec_len, 0]) {
        rotate([0, 0, 0]) {
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,7);
        }
    }
}

module tetris_3_side(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value) {
    // Base
            translate([sec_len, 0, 0])  {
    rotate([0, 0, 90]) {
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,7);
            }
}
    
    // Side 1
        translate([sec_len*2, sec_len+3, 0])  {
    rotate([0, 0, 180]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,2);
    }
}
    
    // Side 2
    translate([sec_len*2 , sec_len+3,0]) {
            rotate([0, 0, -90]) {
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value,7);
    }
}
    

}

module tetris_o(){
    tetris_O_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow");
    
    }

module tetris_z(){
    tetris_Z_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green");
    
    }

module tetris_l(){
    tetris_L_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange");
    
    }


module tetris_t(){
    tetris_T_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "blue");
    translate([0, 0,mat_thic*2]) {
  rotate([-90, 0, 0]) {
tetris_3_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "purple");
  }
  }
  
  
              translate([sec_len*3, 0, mat_thic])  {
    rotate([-90, 0, 90]) {
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green",4);    }}
    
    
                  translate([mat_thic, 0, mat_thic])  {
    rotate([-90, 0, 90]) {
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green",4);    }}
    
                   translate([sec_len*2, sec_len*2-mat_thic, mat_thic])  {
    rotate([0, 90, 90]) {
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "red",4);    }}
    
    
        //corner sides 
    
     translate([sec_len, sec_len-mat_thic, mat_thic])  {
    rotate([-90, 90, 0]) {
        corner_side_2();
     }}
     
          translate([sec_len*2, sec_len, mat_thic])  {
    rotate([90, 90, 0]) {
        corner_side_2();
     }}
     
    

    
    
    //corner sides 90 degree
    
     translate([sec_len+mat_thic, sec_len*2, -sec_len+mat_thic])  {
    rotate([-90, 180, 90]) { 
      corner_side_1();  }}
      
           translate([sec_len*2, sec_len*2, -sec_len+mat_thic])  {
    rotate([-90, 180, 90]) { 
      corner_side_1();  }}
    
    
    
}


module corner_side_1(){
                    // Calculate the start position to center the fingers
        finger_length = sec_len / num_finger_cutouts;
        start_pos = (sec_len - finger_length * num_finger_cutouts) / 2-kerf_thickness/2;
    
     difference(){
    union(){

         translate([sec_len+mat_thic,-start_pos, 0]){
        rotate([0, 0, 90]){
        finger_addon(0, num_finger_cutouts, sec_len, mat_thic, +1*kerf_thickness);}}
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow",3);    }
    
    rotate([-90, 0, 0]){
    translate([sec_len-0*kerf_thickness,-mat_thic-mat_thic/2, sec_len-mat_thic]){
    cube([combined_thickness*2,combined_thickness*2,combined_thickness*2]);
    }
        translate([sec_len-kerf_thickness,-mat_thic-mat_thic/2, -kerf_thickness])
    cube([combined_thickness*2,combined_thickness*2,combined_thickness]);
    }
    }   
    }
    
    
module corner_side_2(){
    
                        // Calculate the start position to center the fingers
        finger_length = sec_len / num_finger_cutouts;
        start_pos = (sec_len - finger_length * num_finger_cutouts) / 2-kerf_thickness/2;
    
       union(){
        translate([-start_pos,-mat_thic, 0]){
        finger_addon(1, num_finger_cutouts, sec_len, mat_thic, +1*kerf_thickness);}
    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "red",7);    }
    
    }

// end modules

// start render parts

//flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "pink",7);
//    flat_section2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "pink");

//single_sec(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "pink");
//projection(cut = false) {


//tetris_t();
    tetris_o();

  //tetris_L_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "blue");

//}