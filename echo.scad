include <types.scad>
   
/* 
   Utility functions to print various types.
   Usage: _ = _echo_<type>(<type>);
   Assignment is required as otherwise OpenSCAD looks for module with this name.
   
   The most important feature is that those functions check the types of things they print.
*/

// echo_op_type: Operation -> ()
echo_op_type = function (op) echo("OperationType", get_op_type(op));  

// echo_op_type: OperationType -> ()
echo_type = function (op_type) echo("OperationType", op_type);   
    
// echo_op: Operation -> ()
echo_op = function (op) echo("op", get_op_type(op), get_op_args(op));

// echo_ops: [Operation] -> ()
echo_ops = function(ops) map(ops, echo_op);

// echo_step: Step -> ()
echo_step = function (step) echo(
    "Step", get_step_type(step), get_step_args(step) 
);

// echo_steps: [Step] -> ()
echo_steps = function (steps) echo ("Steps", steps) map(steps, echo_step);


// echo_mode: Mode -> ()
echo_mode = function (mode) 
    let(
        _1 = echo(
            "Mode", get_mode_type(mode) 
            ),
        _2 = echo_steps(get_mode_steps(mode))
    ) undef;

// echo_modes: [Mode] -> ()
echo_modes = function (modes) map(modes, echo_mode);

// echo_state: State -> ()
echo_state = function (state) echo(get_position(state));
// echo_states: [State] -> ()
echo_states = function (states) map(states, echo_state);
