include <types.scad>
include <primitives.scad>
include <type_utils.scad>
include <draw_utils.scad>

/* Only modules can draw in OpenSCAD. Those are modules that draw turtle moves. */

module draw_move(state, delta) {
    w = get_state_line_width(state) / 2;
    
    start_1 = [0, w/2];
    start_2 = [0, -w/2];
    
    translate(get_state_position(state)) multmatrix(get_state_rotation_matrix(state)) {
        polygon([start_1, start_2, start_2 + delta, start_1 + delta]);
    }
}


module draw_forward(state, x_delta) {
    draw_move(state, [x_delta, 0]);
}

module draw_step(state, type, args) {
    assert(is_op_type(type));
    
    if (type == forward_type) {
        draw_forward(state, args);
    } else if (type == move_type) {
        draw_move(state, args);
    }
}

module draw_steps(steps) {
    for (step = steps) {
        state = get_step_state(step);
        fun = get_step_type(step);
        args = get_step_args(step);
        
        draw_step(state, fun, args);
    }
}

// Renders Operation list from given initial state.
// draw: State -> [Operation] -> ()
module _draw(initial_state=undef, ops) {
    state = initial_state == undef ? init_state() : initial_state;
    
    // To flat loops, figures and fills
    flat_ops = flatten_ops(ops);
    ops_with_ending = concat(flat_ops, [_noop()]);
    
    states = generate_states(state, flat_ops);
    steps = make_steps(states, ops_with_ending);
    modes = split_by_modes(steps);
    
    for (mode = modes) {
        mode_type = get_mode_type(mode);
        mode_steps = get_mode_steps(mode);
        
        if (mode_type == mode_fill) {
            hull() {
                draw_steps(mode_steps);
            }
        } else {
            draw_steps(mode_steps);
        }
    }
}