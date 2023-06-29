include <types.scad>
include <types_utils.scad>

/* FUNCTIONS */

function _right(current_rotation, angle) =
    let (new_rotation = [
            [cos(angle), -sin(angle)],
            [sin(angle), cos(angle)]
        ])
    
        current_rotation * new_rotation;

function _move(current_rotation, current_position, delta) =
    current_position + current_rotation * delta;

right = function (state, angle) make_state(
    state, rotation_matrix=_right(get_rotation_matrix(state), angle)
);

left = function (state, angle) right(state, -angle);

goto = function (state, position) make_state(state, position=position);

forward = function (state, x_delta) move(state, [x_delta, 0]);
move = function (state, delta) make_state(
    state, position=_move(get_rotation_matrix(state), get_position(state), delta)
);

/* MODULES */

module draw_move(state, delta) {
    w = get_line_width(state) / 2;
    
    start_1 = [0, w/2];
    start_2 = [0, -w/2];
    
    translate(get_position(state)) multmatrix(get_rotation_matrix(state)) {
        polygon([start_1, start_2, start_2 + delta, start_1 + delta]);
    }
}


module draw_forward(state, x_delta) {
    draw_move(state, [x_delta, 0]);
}
