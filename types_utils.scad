include <types.scad>
include <primitives.scad>

// move_to_name: MoveType -> str
function move_to_name(type) = 
    let (str_type = str(type))
    str_type == right_str ? "right" : 
    str_type == left_str ? "left" : 
    str_type == forward_str ? "forward" : 
    str_type == move_str ? "move" : 
    str_type == goto_str ? "goto" :
    str_type == mode_fill_str ? "MODE_FILL" :
    str_type == mode_normal_str ? "MODE_NORMAL" :
    concat("Invalid move type", type);
   
// is_mode: MoveType -> bool
is_mode_type = function (type) 
    let (str_type = str(type)) 
        str_type == mode_fill_str || str_type == mode_normal_str;
   
/* 
   Utility functions to print various types.
   Usage: _ = _echo_<type>(<type>);
   Assignment is required as otherwise OpenSCAD looks for module with this name.   
*/

// echo_move_type: Move -> ()
echo_move_type = function (move) echo("MoveType", move_to_name(get_move_type(move)));  

// echo_move_type: MoveType -> ()
echo_type = function (move_type) echo("MoveType", move_to_name(move_type));   
    
// echo_move: Move -> ()
echo_move = function (move) echo("Move", move_to_name(move[0]), move[1]);

// echo_moves: [Move] -> ()
echo_moves = function(moves) map(moves, echo_move);

// echo_step: Step -> ()
echo_step = function (step) echo(
    "Step", move_to_name(get_step_type(step)), get_step_args(step) 
);

// echo_steps: [Step] -> ()
echo_steps = function (steps) echo ("Steps") map(steps, echo_step);


// echo_mode: Mode -> ()
echo_mode = function (mode) 
    let(
        _1 = echo(
            "Mode", move_to_name(get_mode_type(mode)) 
            ),
        _2 = echo_steps(get_mode_steps(mode))
    ) undef;

// echo_modes: [Mode] -> ()
echo_modes = function (modes) map(modes, echo_mode);

// echo_state: State -> ()
echo_state = function (state) echo(get_position(state));
// echo_states: [State] -> ()
echo_states = function (states) map(states, echo_state);

/* End of print functions */

// flatten_moves: [Move | Nested[Move] ...] -> [Move]
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