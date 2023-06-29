include <types.scad>
include <types_utils.scad>
include <utils.scad>
include <primitives.scad>

NEST_MARKER = function(do_not_call_me) undef;
function nest(body) = concat(NEST_MARKER, [body]);
function is_nested(element) = element[0] == NEST_MARKER;

function loop(times, body) = nest(_loop(times, body));
function _loop(times, body) =
    times == 0 ? [] : concat(body, _loop(times - 1, body));

function fill(body) = nest(concat(
    [mode_fill],
    body,
    [mode_normal]
));

function flatten_moves(moves) = _flatten_moves(moves, 0);
function _flatten_moves(moves, index) = 
    index == len(moves) ? undef :
        let (
            head = is_nested(moves[index]) ? 
                    flatten_moves(moves[index][1]) : 
                    [moves[index]],
            tail = index < len(moves) ? _flatten_moves(moves, index+1) : undef
            //echo("head", head),
            //echo("tail", tail)
        )
        head == undef ? 
            undef :
            tail == undef ? head : concat(head, tail);

// split_by_modes: [Step] -> [(Mode, [Step])]
function split_by_modes(vector) = _split_by_modes(vector, 0);
        
// take_mode: [Step] -> int -> [Step]
function take_mode(vector, index) =
    index == len(vector) ? [] :
        let (el = vector[index], type = get_step_move(el), _ = echo(el, type))
        is_mode(type) ? [] : concat([el], take_mode(vector, index+1));
        
// _split_by_modes: [Step] -> int -> [(Mode, [Step])]
function _split_by_modes(vector, index) = 
    index >= len(vector) ? [] :
        let (
            head = vector[index], 
            type = get_step_move(head),
            mode = is_mode(type) ? head : mode_normal,
            echo(mode),
            first_index_in_mode = is_mode(type) ? index+1 : index,
            values_in_mode = take_mode(vector, first_index_in_mode), 
            last_index = index + len(values_in_mode)
            // echo_steps(values_in_mode)
        )
            concat([[mode, values_in_mode]], _split_by_modes(vector, last_index+1));
              
function make_states(state, moves, index) =
    let (
        next_move = moves[index],
        next_fun = get_move_type(next_move),
        next_args = get_move_args(next_move),
        next_state = next_fun(state, next_args)
    ) 
        index < len(moves) ? 
            concat([state], make_states(next_state, moves, index+1)) 
            : 
            [state];

function figure(moves) = nest(moves);

module draw_steps(steps) {
    for (step = steps) {
        state = get_step_state(step);
        fun = get_step_type(step);
        args = get_step_args(step);
        
        _draw(state, fun, args);
    }
}

module go_turtle(initial_state=undef, moves) {
    state = initial_state == undef ? init_state() : initial_state;
    
    // To flat loops, figures and fills
    flat_moves = flatten_moves(moves);
    
    // _ = echo_moves(flat_moves);
    
    states = make_states(state, flat_moves, 0);
    
    steps = make_steps(states, flat_moves);
    
    // _ = echo_steps(steps);
    
    modes = split_by_modes(steps);
    
    // _ = echo_modes(modes);
    
    for (mode = modes) {
        mode = get_mode_type(modes);
        mode_steps = get_mode_steps(modes);
        
        if (mode == mode_fill) {
            hull() {
                draw_mode_steps(mode);
            }
        } else {
            draw_mode_steps(mode);
        }
    }
}

module _draw(state, fun, args) { 
    if (fun == forward) {
        draw_forward(state, args);
    } else if (fun == move) {
        draw_move(state, args);
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
