include <types.scad>

/* FUNCTIONS */

function _right(current_rotation, angle) =
    let (new_rotation = [
            [cos(angle), -sin(angle)],
            [sin(angle), cos(angle)]
        ])
    
        current_rotation * new_rotation;

function _move(current_rotation, current_position, delta) =
    current_position + current_rotation * delta;

right_fun = function (state, angle) State(
    state, rotation_matrix=_right(get_rotation_matrix(state), angle)
);

left_fun = function (state, angle) right(state, -angle);

goto_fun = function (state, position) State(state, position=position);

move_fun = function (state, delta) State(
    state, position=_move(get_rotation_matrix(state), get_position(state), delta)
);
forward_fun = function (state, x_delta) move(state, [x_delta, 0]);

noop_fun = function (state, _) state;

mode_fill_fun = noop_fun;
mode_normal_fun = noop_fun;
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

module draw(state, fun, args) { 
    if (fun == forward) {
        draw_forward(state, args);
    } else if (fun == move) {
        draw_move(state, args);
    }
}
