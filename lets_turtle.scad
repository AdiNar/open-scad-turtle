include <types.scad>
include <primitives.scad>
include <types_utils.scad>
include <utils.scad>
include <manipulators.scad>


// split_by_modes: [Step] -> [Mode = (ModeType, [Step])]
function split_by_modes(vector) = _split_by_modes(vector, 0);  
function _split_by_modes(vector, index) = 
    index == len(vector) ? [] :
        let (
            head_step = vector[index], 
            type = get_step_type(head_step),
            mode_type = is_mode_type(type) ? type : ModeNormal,
            // We exclude Step with mode_type, so we must jump over one item
            inmode_offset = is_mode_type(type) ? 1 : 0,
            values_in_mode = take_mode(vector, index + inmode_offset), 
            next_index = index + len(values_in_mode) + inmode_offset
        )
            concat([Mode(mode_type, values_in_mode)], _split_by_modes(vector, next_index));
            

// take_mode: [Step] -> int -> [Step]
function take_mode(vector, index) =
    index == len(vector) ? [] :
        let (el = vector[index], type = get_step_type(el))
        is_mode_type(type) ? [] : concat([el], take_mode(vector, index+1));            
            
// generate_states: State -> [Move] -> [State]
function generate_states(state, moves) = _generate_states(state, moves, 0);
function _generate_states(state, moves, index) =
    index == len(moves) ? [state] :
        let (
            next_move = moves[index],
            next_fun = get_move_type(next_move),
            next_args = get_move_args(next_move),
            next_state = next_fun(state, next_args)
        ) 
            concat([state], _generate_states(next_state, moves, index+1));


module draw_steps(steps) {
    _ = echo_steps(steps);
    for (step = steps) {
        state = get_step_state(step);
        fun = get_step_type(step);
        args = get_step_args(step);
        
        draw(state, fun, args);
    }
}

module go_turtle(initial_state=undef, moves) {
    state = initial_state == undef ? init_state() : initial_state;
    
    // To flat loops, figures and fills
    flat_moves = flatten_moves(moves);
    moves_with_ending = concat(flat_moves, noop);
    // _ = echo_moves(flat_moves);
    
    states = generate_states(state, flat_moves);
    
    // _ = echo("flt", len(moves_with_ending), "moves", len(states));
    
    steps = make_steps(states, moves_with_ending);
    
    // _ = echo_steps(steps);
    
    modes = split_by_modes(steps);
    
    // _ = echo_modes(modes);
    
    for (mode = modes) {
        mode_type = get_mode_type(mode);
        mode_steps = get_mode_steps(mode);
        
        if (mode_type == ModeFill) {
            hull() {
                draw_steps(mode_steps);
            }
        } else {
            draw_steps(mode_steps);
        }
    }
}

go_turtle(moves=[
    [right, 45],
    [forward, 100],
    [right, 30],
    [forward, 100],
    fill([  
        [right, 45],
        [forward, 100],
        [right, 30],
        [forward, 100]
    ]),
    loop(6, [
        [right, 60],
        [forward, 50],
    ])
]);
