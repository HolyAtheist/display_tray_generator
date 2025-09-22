// laser cut tetris blocks
// converted to openjscad v1
// by t b mosich 2025
// example script; work in progress; code is not exemplary
// todo: add cutouts/decorations; add open top variations

function getParameterDefinitions() {
    return [{
            name: 'model_view',
            type: 'choice',
            caption: 'Model View',
            values: [1, 2],
            initial: 1
        }, {
            name: 'tetris_shape',
            type: 'choice',
            caption: 'Shape',
            values: ['L', 'Z', 'T', 'O', 'I'],
            initial: 'L'
        }, {
            name: 'material_thickness',
            type: 'float',
            caption: 'Material Thickness (mm)',
            initial: 3.00
        }, {
            name: 'kerf_thickness',
            type: 'float',
            caption: 'Kerf (mm) (how tight/loose)',
            initial: 0.1,
            min: 0,
            step: 0.1
        }, {
            name: 'section_length',
            type: 'float',
            caption: 'Section Length (mm)',
            initial: 100.00
        }, {
            name: 'num_finger_cutouts',
            type: 'int',
            caption: 'Finger Cutouts per section',
            initial: 5,
            min: 3,
            step: 2
        }
    ];
}

function finger_cutout(start_index, total_fingers, section_length, thickness, kerf) {
    // Inner “module” to generate the 2D finger pattern
    function finger_pattern() {
        const fingers = [];
        for (let i = 0; i < total_fingers; i++) {
            if ((i + start_index) % 2 === 0) {
                const finger_width = (section_length / total_fingers) - kerf;
                const xPos = i * (section_length / total_fingers) + kerf;

                const sq = square({
                    size: [finger_width, thickness + kerf]
                });
                const moved = translate([xPos, 0], sq);

                fingers.push(moved);
            }
        }
        return union(...fingers); // union all 2D fingers
    }

    // Extrude the 2D pattern
    return linear_extrude({
        height: thickness + kerf
    }, finger_pattern());
}

function finger_addon(start_index, total_fingers, section_length, thickness, kerf) {
    // Inner 2D finger pattern
    function finger_pattern() {
        var fingers = [];
        for (var i = 0; i < total_fingers; i++) {
            if ((i + start_index) % 2 === 0) {
                var finger_width = (section_length / total_fingers) - kerf;
                var xPos = i * (section_length / total_fingers);

                var sq = square([finger_width, thickness + kerf], false);
                sq = translate([xPos, 0, 0], sq);

                fingers.push(sq);
            }
        }
        return union(fingers);
    }

    // Extrude 2D pattern to 3D
    return linear_extrude({
        height: thickness
    }, finger_pattern());
}

function flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, finger_sides) {
    return difference(
        create_colored_square(mat_thic, sec_len, sec_len, color_value),

        // Calculate start position to center fingers
        (function () {
            var finger_length = sec_len / num_finger_cutouts;
            var start_pos = (sec_len - finger_length * num_finger_cutouts) / 2 - kerf_thic / 2;
            var cutouts = [];

            if ([1, 2, 3, 4].includes(finger_sides)) {
                // Finger cutouts on one edge
                cutouts.push(translate([start_pos, -kerf_thic, -kerf_thic / 2],
                        finger_cutout(0, num_finger_cutouts, sec_len, mat_thic, kerf_thic)));
            }

            if ([2, 3, 4].includes(finger_sides)) {
                // Finger cutouts on opposite edge
                cutouts.push(translate([start_pos, sec_len - mat_thic, -kerf_thic / 2],
                        finger_cutout(0, num_finger_cutouts, sec_len, mat_thic, kerf_thic)));
            }

            if ([3, 4].includes(finger_sides)) {
                // Finger cutouts on another edge
                cutouts.push(translate([mat_thic, start_pos, -kerf_thic / 2],
                        rotate([0, 0, 90], finger_cutout(1, num_finger_cutouts, sec_len, mat_thic, kerf_thic))));
            }

            if (finger_sides === 4) {
                cutouts.push(translate([sec_len + kerf_thic, start_pos, -kerf_thic / 2],
                        rotate([0, 0, 90], finger_cutout(1, num_finger_cutouts, sec_len, mat_thic, kerf_thic))));
            }

            if ([5, 6, 7, 8].includes(finger_sides)) {
                cutouts.push(translate([mat_thic, start_pos, -kerf_thic / 2],
                        rotate([0, 0, 90], finger_cutout(1, num_finger_cutouts, sec_len, mat_thic, kerf_thic))));
            }

            if ([6, 7].includes(finger_sides)) {
                cutouts.push(translate([sec_len + kerf_thic, start_pos, -kerf_thic / 2],
                        rotate([0, 0, 90], finger_cutout(1, num_finger_cutouts, sec_len, mat_thic, kerf_thic))));
            }

            if ([7, 8].includes(finger_sides)) {
                cutouts.push(translate([start_pos, sec_len - mat_thic, -kerf_thic / 2],
                        finger_cutout(0, num_finger_cutouts, sec_len, mat_thic, kerf_thic)));
            }

            return union(cutouts);
        })());
}

function create_square(thickness, x, y) {
    var points = [[0, 0], [x, 0], [x, y], [0, y], [0, 0]];
    return linear_extrude({
        height: thickness,
        center: false
    },
        polygon({
            points: points
        }));
}

//function create_cyl(thickness, x, y, sec_len, mat_thic) {
// return translate([sec_len/2, sec_len/2, 0],
//                 linear_extrude({ height: thickness, center: false },
//                                  circle({ d: sec_len - mat_thic*3 })));
//}

function create_colored_square(thickness, x, y, color_value, overlay, sec_len, mat_thic) {
    //if (overlay === true) {
    // return color(color_value, 0.75, create_cyl(thickness, x, y, sec_len, mat_thic));
    // } else {
    return color(color_value, 0.75, create_square(thickness, x, y));
    //}
}

function single_sec(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, overlay) {
    return union(
        // Bottom face
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 4, overlay),

        // Top face
        translate([0, 0, sec_len - mat_thic],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 4, overlay)),

        // Front face
        rotate([90, 0, 90],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 4, overlay)),

        // Back face
        rotate([90, 0, 90],
            translate([0, 0, sec_len - mat_thic],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 4, overlay))),

        // Left face
        rotate([0, 90, 90],
            translate([-sec_len, -sec_len, 0],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 4, overlay))),

        // Right face
        rotate([0, 90, 90],
            translate([-sec_len, -sec_len, sec_len - mat_thic],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 4, overlay))));
}

function tetris_O_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, overlay) {
    return union(
        // Base
        translate([sec_len * 0, sec_len * 1, 0],
            rotate([0, 180, 180],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))),

        // Side 1
        translate([sec_len * 1, sec_len * 0, 0],
            rotate([0, 180, -90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))),

        // Side 2
        translate([sec_len * 1, sec_len * 2, 0],
            rotate([0, 180, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))),

        // Top
        translate([sec_len * 2, sec_len * 1, 0],
            rotate([0, 180, 0],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))));
}

function tetris_Z_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, overlay) {
    return union(
        // Base
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 3, overlay),

        // Side 1
        translate([sec_len * 1, sec_len * 0, mat_thic],
            rotate([0, 180, -90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))),

        // Side 2
        translate([sec_len * 1, sec_len, 0],
            rotate([0, 0, 0],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))),

        // Top
        translate([sec_len * 2, sec_len * 2, 0],
            rotate([0, 0, -90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 7, overlay))));
}

function tetris_L_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, overlay) {
    return union(
        // Base
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 3, overlay),

        // Side 1
        translate([sec_len * 2, 0, 0],
            rotate([0, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 6, overlay))),

        // Side 2
        translate([sec_len * 3, sec_len, 0],
            rotate([0, 0, 180],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))),

        // Top
        translate([sec_len * 2, sec_len * 2, 0],
            rotate([0, 0, -90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 3, overlay))));
}

function tetris_T_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, overlay) {
    return union(
        // Base
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 3, overlay),

        // Side 1
        translate([sec_len * 2, 0, 0],
            rotate([0, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 5, overlay))),

        // Side 2
        translate([sec_len * 3, sec_len, 0],
            rotate([0, 0, 180],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 3, overlay))),

        // Top
        translate([sec_len, sec_len, 0],
            rotate([0, 0, 0],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 7, overlay))));
}

function tetris_3_side(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, open, overlay) {
    var parts = [];

    if (open === false) {
        // Base
        parts.push(
            translate([sec_len, 0, 0],
                rotate([0, 0, 90],
                    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 7, overlay))));

        // Side 1
        parts.push(
            translate([sec_len * 2, sec_len, 0],
                rotate([0, 0, 180],
                    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 2, overlay))));

        // Side 2
        parts.push(
            translate([sec_len * 2, sec_len, 0],
                rotate([0, 0, -90],
                    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 7, overlay))));
    } else if (open === true) {
        // Base
        parts.push(
            translate([sec_len, 0, 0],
                rotate([0, 0, 90],
                    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))));

        // Side 1
        parts.push(
            translate([sec_len * 1, sec_len * 0, 0],
                rotate([0, 0, 0],
                    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 1, overlay))));

        // Side 2
        parts.push(
            translate([sec_len * 2, sec_len * 0, mat_thic],
                rotate([180, 0, 90],
                    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 8, overlay))));
    }

    return union(parts);
}

function tetris_I_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, overlay) {
    return union(
        // Base
        translate([0, 0, 0],
            rotate([0, 0, 0],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 3, overlay))),

        // Side 1
        translate([sec_len * 2, 0, 0],
            rotate([0, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 6, overlay))),

        // Side 2
        translate([sec_len * 2, 0, 0],
            rotate([0, 0, 0],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 2, overlay))),

        // End
        translate([sec_len * 3, sec_len, 0],
            rotate([0, 0, -90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 7, overlay))));
}

function tetris_4_side(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, overlay) {
    return union(
        // Base
        translate([sec_len, 0, 0],
            rotate([0, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 7, overlay))),

        // Side 1
        translate([sec_len * 2, sec_len, 0],
            rotate([0, 0, 180],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 2, overlay))),

        // Side 2
        translate([sec_len * 3, 0, 0],
            rotate([0, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 6, overlay))),

        // End
        translate([sec_len * 4, sec_len, 0],
            rotate([0, 0, 180],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 3, overlay))));
}

function tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, overlay) {
    return union(
        // Base
        translate([sec_len, 0, 0],
            rotate([0, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 7, overlay))),

        // Side 2
        translate([sec_len * 2, sec_len, 0],
            rotate([0, 0, 180],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thic, color_value, 3, overlay))));
}

function tetris_2_side_inside(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, color_value, open, overlay) {
    var parts = [];

    if (open === false) {
        // Base
        parts.push(
            translate([sec_len, 0, 0],
                rotate([0, 0, 90],
                    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, color_value, 7, overlay))));

        // Side 2
        parts.push(
            translate([sec_len * 1, 0, 0],
                rotate([0, 0, 0],
                    corner_side_1(1, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay))));
    }

    if (open === true) {
        // Base
        parts.push(
            translate([sec_len, sec_len, mat_thic],
                rotate([0, 180, 90],
                    flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, color_value, 8, overlay))));

        // Side 2
        parts.push(
            translate([sec_len * 1, 0, 0],
                rotate([0, 0, 0],
                    corner_side_1(1, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay))));
    }

    return union(parts);
}

function tetris_i(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay) {
    return union(
        tetris_I_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay),

        translate([0, 0, -sec_len + mat_thic],
            rotate([0, 0, 0],
                tetris_I_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay))),

        translate([0, mat_thic, -sec_len + mat_thic],
            rotate([90, 0, 0],
                tetris_4_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay))),

        translate([0, sec_len + mat_thic * 0, -sec_len + mat_thic],
            rotate([90, 0, 0],
                tetris_4_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay))),

        translate([sec_len * 4, sec_len * 1, mat_thic],
            rotate([-90, 90, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", 4, overlay))),

        translate([mat_thic, 0, mat_thic],
            rotate([-90, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", 4, overlay))));
}

function tetris_i_flat(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay) {
    return union(
        tetris_I_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay),

        translate([0, sec_len + mat_thic, 0],
            tetris_I_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay)),

        translate([0, sec_len * 2 + mat_thic * 2, 0],
            tetris_4_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay)),

        translate([0, sec_len * 3 + mat_thic * 3, 0],
            tetris_4_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay)),

        translate([sec_len * 4 + mat_thic, sec_len * 1 + mat_thic, mat_thic],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", 4, overlay)),

        translate([sec_len * 4 + mat_thic, 0, mat_thic],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", 4, overlay)));
}

function tetris_o_flat(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay) {
    return union(
        tetris_O_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay),

        translate([sec_len * 2 + mat_thic, 0, 0],
            tetris_O_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay)),

        translate([sec_len * 2 + mat_thic, sec_len * 2 + mat_thic, 0],
            tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)),

        translate([0, sec_len * 3 + mat_thic * 2, 0],
            tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)),

        translate([0, sec_len * 2 + 3, 0],
            tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)),

        translate([sec_len * 2 + mat_thic, sec_len * 3 + mat_thic * 2, 0],
            tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)));
}

function tetris_o(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay) {
    return union(
        tetris_O_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay),

        translate([0, 0, -sec_len + mat_thic],
            tetris_O_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", overlay)),

        translate([sec_len * 2, sec_len * 2, 0],
            rotate([90, 180, 0],
                tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay))),

        translate([0, mat_thic, -sec_len],
            rotate([90, 0, 0],
                tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay))),

        translate([0, sec_len * 2, 0],
            rotate([90, 180, 90],
                tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay))),

        translate([sec_len * 2 - mat_thic, 0, -sec_len],
            rotate([90, 0, 90],
                tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay))));
}

function tetris_z(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay) {
    return union(
        tetris_Z_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", overlay),

        translate([0, 0, -sec_len + mat_thic],
            tetris_Z_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", overlay)),

        translate([sec_len, sec_len * 2, -sec_len + mat_thic],
            rotate([90, 0, 0],
                tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay))),

        translate([0, mat_thic, -sec_len + mat_thic],
            rotate([90, 0, 0],
                tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay))),

        translate([sec_len, sec_len - mat_thic, mat_thic],
            rotate([-90, 90, 0],
                corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay))),

        translate([sec_len * 2, sec_len, mat_thic],
            rotate([180, 90, 0],
                corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay))),

        translate([sec_len + mat_thic, sec_len * 2, -sec_len + mat_thic],
            rotate([-90, 180, 90],
                corner_side_1(2, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay))),

        translate([sec_len * 3, sec_len, -sec_len + mat_thic],
            rotate([-90, 180, 0],
                corner_side_1(2, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay))),

        translate([sec_len * 3, sec_len * 2, mat_thic],
            rotate([-90, 90, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay))),

        translate([mat_thic, 0, mat_thic],
            rotate([-90, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay))));
}

function tetris_z_flat(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay) {
    return union(
        translate([mat_thic, mat_thic * 2, 0],
            tetris_Z_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", overlay)),

        translate([sec_len * 2 + mat_thic * 2, mat_thic, 0],
            tetris_Z_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", overlay)),

        translate([sec_len, sec_len + mat_thic * 3, 0],
            rotate([0, 0, 90],
                tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay))),

        translate([sec_len + mat_thic, sec_len * 2 + mat_thic * 3, 0],
            tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)),

        translate([sec_len * 3 + mat_thic * 2, sec_len * 2 + mat_thic * 3, 0],
            corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay)),

        translate([sec_len * 4 + mat_thic * 3, sec_len * 2 + mat_thic * 3, 0],
            corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay)),

        translate([sec_len * 5 + mat_thic * 4, sec_len * 2 + mat_thic * 2, 0],
            corner_side_1(2, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay)),

        translate([sec_len * 5 + mat_thic * 3, sec_len * 1 + mat_thic * 1, 0],
            corner_side_1(2, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay)),

        translate([sec_len * 4 + mat_thic * 3, 0, 0],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay)),

        translate([sec_len * 5 + mat_thic * 4, 0, 0],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay)));
}

function tetris_l(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, open, overlay) {
    return union(
        tetris_L_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay),

        open === false ? translate([0, 0, -sec_len + mat_thic],
            tetris_L_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)) : null,

        translate([0, 0, mat_thic],
            rotate([-90, 0, 0],
                tetris_3_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "purple", overlay))),

        translate([sec_len * 3 - mat_thic, sec_len * 2, mat_thic],
            rotate([90, 180, 90],
                tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay))),

        translate([0, sec_len, -sec_len + mat_thic],
            rotate([90, 0, 0],
                tetris_2_side_inside(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, "orange", overlay))),

        translate([sec_len * 2, sec_len * 1, mat_thic],
            rotate([0, 90, 0],
                corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay))),

        translate([mat_thic, 0, mat_thic],
            rotate([-90, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay))),

        translate([sec_len * 3, sec_len * 2, mat_thic],
            rotate([-90, 0, 180],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay))));
}

function tetris_l_flat(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay) {
    return union(
        translate([mat_thic, 0, 0],
            tetris_L_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)),

        translate([0, sec_len * 2 + mat_thic * 2, 0],
            tetris_L_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)),

        translate([sec_len * 4 + mat_thic * 2, 0, 0],
            rotate([0, 0, 90],
                tetris_3_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "purple", overlay))),

        translate([0, sec_len + mat_thic, 0],
            tetris_2_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "orange", overlay)),

        translate([sec_len * 5 + mat_thic * 3, sec_len * 2 + mat_thic * 2, 0],
            rotate([0, 0, 90],
                tetris_2_side_inside(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, "orange", overlay))),

        translate([sec_len * 3 + mat_thic, sec_len * 3 + mat_thic * 2, 0],
            corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay)),

        translate([sec_len * 4 + mat_thic * 3, 0, 0],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay)),

        translate([sec_len * 4 + mat_thic * 3, sec_len + mat_thic, 0],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay)));
}

function tetris_t(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, open, overlay) {
    return union(
        tetris_T_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "blue", overlay),

        translate([0, 0, -sec_len + mat_thic],
            tetris_T_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "blue", overlay)),

        translate([0, 0, mat_thic],
            rotate([-90, 0, 0],
                tetris_3_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "purple", overlay))),

        translate([sec_len * 3, 0, mat_thic],
            rotate([-90, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay))),

        translate([mat_thic, 0, mat_thic],
            rotate([-90, 0, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay))),

        translate([sec_len * 2, sec_len * 2 - mat_thic, mat_thic],
            rotate([0, 90, 90],
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "red", 4, overlay))),

        translate([sec_len, sec_len - mat_thic, mat_thic],
            rotate([-90, 90, 0],
                corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay))),

        translate([sec_len * 2, sec_len, mat_thic],
            rotate([90, 90, 0],
                corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay))),

        translate([sec_len + mat_thic, sec_len * 2, -sec_len + mat_thic],
            rotate([-90, 180, 90],
                corner_side_1(2, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay))),

        translate([sec_len * 2, sec_len * 2, -sec_len + mat_thic],
            rotate([-90, 180, 90],
                corner_side_1(2, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay))));
}

function tetris_t_flat(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, open, overlay) {
    return union(
        translate([mat_thic, 0, 0],
            tetris_T_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "blue", overlay)),

        translate([sec_len * 3 + mat_thic * 2, sec_len * 6 + mat_thic * 6, 0],
            rotate([0, 0, 180],
                tetris_T_bot(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "blue", overlay))),

        translate([0, sec_len * 2 + mat_thic * 2, 0],
            tetris_3_side(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "purple", open, overlay)),

        translate([sec_len * 2 + mat_thic * 2, sec_len + mat_thic, 0],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay)),

        translate([0, sec_len + mat_thic, 0],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "green", 4, overlay)),

        translate([sec_len * 2 + mat_thic * 2, sec_len * 3 + mat_thic * 4, 0],
            flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "red", 4, overlay)),

        translate([0, sec_len * 3 + mat_thic * 4, 0],
            corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay)),

        translate([sec_len + mat_thic, sec_len * 3 + mat_thic * 4, 0],
            corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay)),

        translate([0, sec_len * 4 + mat_thic * 5, 0],
            corner_side_1(2, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay)),

        translate([sec_len * 2 + mat_thic * 3, sec_len * 4 + mat_thic * 5, 0],
            corner_side_1(2, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay)));
}

function corner_side_1(version, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, overlay) {
    // Calculate the start position to center the fingers
    const finger_length = sec_len / num_finger_cutouts;
    const start_pos = (sec_len - finger_length * num_finger_cutouts) / 2 - kerf_thickness / 2;

    // Finger addon + flat section
    let base;
    if (version === 2) {
        base = union(
                translate([sec_len + mat_thic, -start_pos, 0],
                    rotate([0, 0, 90],
                        finger_addon(0, num_finger_cutouts, sec_len, mat_thic, kerf_thickness))),
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", 3, overlay));
    } else { // version 1
        base = union(
                translate([sec_len + mat_thic, -start_pos, 0],
                    rotate([0, 0, 90],
                        finger_addon(0, num_finger_cutouts, sec_len, mat_thic, kerf_thickness))),
                flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "yellow", 2, overlay));
    }

    // Cubes to subtract
    const cube1 = rotate([-90, 0, 0],
            translate([sec_len - 2 * kerf_thickness, -mat_thic - mat_thic / 2, sec_len - mat_thic],
                cube({
                    size: [combined_thickness * 2, combined_thickness * 2, combined_thickness * 2]
                })));

    const cube2 = rotate([-90, 0, 0],
            translate([sec_len - 2 * kerf_thickness, -mat_thic - mat_thic / 2, -kerf_thickness],
                cube({
                    size: [combined_thickness * 2, combined_thickness * 2, combined_thickness]
                })));

    // Difference: base minus cubes
    return difference(
        base,
        union(cube1, cube2));
}

function corner_side_2(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, overlay) {
    const finger_length = sec_len / num_finger_cutouts;
    const start_pos = (sec_len - finger_length * num_finger_cutouts) / 2 - kerf_thickness / 2;

    return union(
        translate([-start_pos, -mat_thic, 0],
            finger_addon(1, num_finger_cutouts, sec_len, mat_thic, kerf_thickness)),
        flat_section(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, "red", 7, overlay));
}

function flattenTo2D(shapeFn, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, open, overlay) {
    return shapeFn(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, open, overlay)
    .projectToOrthoNormalBasis(CSG.OrthoNormalBasis.Z0Plane());
}

function main() {
    let mat_thic = params.material_thickness;
    let sec_len = params.section_length;
    let num_finger_cutouts = params.num_finger_cutouts;
    let kerf_thickness = params.kerf_thickness;
    let model_view = Number(params.model_view);
    let combined_thickness = mat_thic + kerf_thickness;
    let tetris_shape = params.tetris_shape;
    let overlay = false;
    let open = false;

    // Lookup tables for shapes
    const shapes3D = {
        "Z": tetris_z,
        "L": tetris_l,
        "O": tetris_o,
        "T": tetris_t,
        "I": tetris_i
    };

    const shapesFlat = {
        "Z": tetris_z_flat,
        "L": tetris_l_flat,
        "O": tetris_o_flat,
        "T": tetris_t_flat,
        "I": tetris_i_flat
    };

    if (model_view === 1) {
        const shapeFn = shapes3D[tetris_shape];
        if (shapeFn) {
            return shapeFn(mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, open, overlay);
        }
    } else if (model_view === 2) {
        const shapeFn = shapesFlat[tetris_shape];
        if (shapeFn) {
            return flattenTo2D(shapeFn, mat_thic, sec_len, num_finger_cutouts, kerf_thickness, combined_thickness, open, overlay);
        }
    }
}
