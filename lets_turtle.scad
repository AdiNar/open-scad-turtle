function coalesce(a1, a2, a3=undef) =
  (a1 != undef) ? a1 :
  (a2 != undef) ? a2 :
  a3;

function make_state(old_state, rotation_matrix=undef, position=undef, line_width=undef, fill=undef) =
    [
        coalesce(rotation_matrix, old_state[0]),
        coalesce(position, old_state[1]),
        coalesce(line_width, old_state[2]),
        coalesce(fill, old_state[3]),
    ];

// State
function init_state() = make_state(
    undef,
    [ // rotation_matrix
       [1, 0],
       [0, 1]
    ], 
    [0, 0], // position
    5, // line_width
    false // fill inside
);

// Move: (fun, list)
function get_move_type(move) = move[0];
function get_move_args(move) = move[1];

// Step: (State, Move)
function make_step(state, move) = [
    state,
    move,
];

// get_step_state: Step -> State
function get_step_state(step) = step[0];

// get_step_move: Step -> Move
function get_step_move(step) = step[1];

// get_step_move: Step -> MoveType
function get_step_type(step) = step[1][0];

// get_step_args: Step -> [Arg]
function get_step_args(step) = step[1][1];

// Mode: (ModeType, [Step])
function make_mode(states, mode_type) = [mode_type, states];

// get_mode_type: Mode -> ModeType
function get_mode_type(mode) = mode[0];

// get_mode_steps: Mode -> [Step]
function get_mode_steps(mode) = mode[1];

function get_rotation_matrix(state) = state[0];
function get_position(state) = state[1];
function get_line_width(state) = state[2];
function get_fill(state) = state[2];

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

_mode_fill_str = "MODE_FILL";
_mode_normal_str = "MODE_NORMAL";

mode_fill = [_mode_fill_str];
mode_normal = [_mode_normal_str];

function is_mode(type) = type == mode_fill || type == mode_normal;

goto = function (state, position) make_state(state, position=position);

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

forward = function (state, x_delta) move(state, [x_delta, 0]);
move = function (state, delta) make_state(
    state, position=_move(get_rotation_matrix(state), get_position(state), delta)
);

function move_to_name(type) = 
    type == right ? "right" : 
    type == left ? "left" : 
    type == forward ? "forward" : 
    type == move ? "move" : 
    type == goto ? "goto" :
    type == _mode_fill_str ? _mode_fill_str :
    type == _mode_normal_str ? _mode_normal_str :
    concat("Invalid move", type);
    

/* Utility function to print moves.
   Usage: _ = _echo_moves(moves);
   Assignment is required as otherwise OpenSCAD looks for module with this name. 
        
*/
map = function (v, f) [for(x=v) f(x)]; 

echo_move = function (move) echo("Move", move_to_name(move[0]), move[1]);
function echo_moves(moves) = map(moves, echo_move);

echo_step = function (step) echo(
    "Step", move_to_name(get_step_type(step)), get_step_args(step) 
);
function echo_steps(steps) = echo ("Steps") map(steps, echo_step);

echo_mode = function (mode) 
    echo(
        "Mode", move_to_name(get_mode_type(mode[0])) 
        )
    echo_steps(get_mode_steps(mode));

function echo_modes(modes) = map(modes, echo_mode);

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
        let (el = vector[index], type = get_step_move(el), echo(el, type))
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
            
    
function make_steps(states, moves) = 
    let (count = len(states))
    [for (index = [0 : count]) make_step(states[index], moves[index])];

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
    
    // To flat loops and figures
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
