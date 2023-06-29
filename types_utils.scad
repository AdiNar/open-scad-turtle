// move_to_name: (MoveType | ModeType) -> str
function move_to_name(type) = 
    type == right ? "right" : 
    type == left ? "left" : 
    type == forward ? "forward" : 
    type == move ? "move" : 
    type == goto ? "goto" :
    type == _mode_fill_str ? _mode_fill_str :
    type == _mode_normal_str ? _mode_normal_str :
    concat("Invalid move", type);
   
// is_mode: (ModeType | MoveType) -> bool
function is_mode(type) = type == mode_fill || type == mode_normal;
   
/* Utility functions to print various types.
   Usage: _ = _echo_<type>(<type>);
   Assignment is required as otherwise OpenSCAD looks for module with this name. 
        
*/
    
// echo_move: Move -> ()
echo_move = function (move) echo("Move", move_to_name(move[0]), move[1]);

// echo_moves: [Move] -> ()
function echo_moves(moves) = map(moves, echo_move);

// echo_step: Step -> ()
echo_step = function (step) echo(
    "Step", move_to_name(get_step_type(step)), get_step_args(step) 
);

// echo_steps: [Step] -> ()
function echo_steps(steps) = echo ("Steps") map(steps, echo_step);


// echo_mode: Mode -> ()
echo_mode = function (mode) 
    echo(
        "Mode", move_to_name(get_mode_type(mode[0])) 
        )
    echo_steps(get_mode_steps(mode));

// echo_modes: [Mode] -> ()
function echo_modes(modes) = map(modes, echo_mode);