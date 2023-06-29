include <types.scad>

/* FUNCTIONS */

function _left(current_rotation, angle) =
    let (new_rotation = [
            [cos(angle), -sin(angle)],
            [sin(angle), cos(angle)]
        ])
        current_rotation * new_rotation;

function _move(current_rotation, current_position, delta) =
    current_position + current_rotation * delta;

left_fun = function (state, angle) State(
    state, rotation_matrix=_left(get_rotation_matrix(state), angle)
);

right_fun = function (state, angle) left_fun(state, -angle);

goto_fun = function (state, position) State(state, position=position);

op_fun = function (state, delta) State(
    state, position=_move(get_rotation_matrix(state), get_position(state), delta)
);
forward_fun = function (state, x_delta) op_fun(state, [x_delta, 0]);

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

module draw(state, type, args) {
    assert(is_op_type(type));
    
    if (type == forward_type) {
        draw_forward(state, args);
    } else if (type == move_type) {
        draw_move(state, args);
    }
}
