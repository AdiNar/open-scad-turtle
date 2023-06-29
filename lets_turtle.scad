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
            mode_type = is_mode_op_type(type) ? type : normal_mode_type,
            // We exclude Step with mode_type, so we must jump over one item
            inmode_offset = is_mode_op_type(type) ? 1 : 0,
            values_in_mode = take_mode(vector, index + inmode_offset), 
            next_index = index + len(values_in_mode) + inmode_offset
        )
            concat([Mode(mode_type, values_in_mode)], _split_by_modes(vector, next_index));
            

// take_mode: [Step] -> int -> [Step]
function take_mode(vector, index) =
    index == len(vector) ? [] :
        let (el = vector[index], type = get_step_type(el))
        is_mode_op_type(type) ? [] : concat([el], take_mode(vector, index+1));            
            
// generate_states: State -> [Operation] -> [State]
function generate_states(state, ops) = _generate_states(state, ops, 0);
function _generate_states(state, ops, index) =
    index == len(ops) ? [state] :
        let (
            next_op = ops[index],
            next_type = get_op_type(next_op),
            next_fun = get_op_fun(next_type),
            next_args = get_op_args(next_op),
            next_state = next_fun(state, next_args)
        ) 
            concat([state], _generate_states(next_state, ops, index+1));


module draw_steps(steps) {
    for (step = steps) {
        state = get_step_state(step);
        fun = get_step_type(step);
        args = get_step_args(step);
        
        draw(state, fun, args);
    }
}

module go_turtle(initial_state=undef, ops) {
    state = initial_state == undef ? init_state() : initial_state;
    
    // To flat loops, figures and fills
    //_0 = echo("wut", ops);
    flat_ops = flatten_ops(ops);
    ops_with_ending = concat(flat_ops, [noop()]);
    //_ = echo("Flat", flat_ops);
    
    states = generate_states(state, flat_ops);
    
    //_1 = echo("flt", ops_with_ending, "ops", len(states));
    
    steps = make_steps(states, ops_with_ending);
    
    // _ = echo_steps(steps);
    
    modes = split_by_modes(steps);
    
    // _ = echo_modes(modes);
    
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
hex = Figure(fill(loop(6, [
    right(60),
    forward(100),
]))); 

go_turtle(ops=[
    loop(9, [
        forward(300),
        hex,
        right(45),
    ]),
]);
/*
go_turtle(ops=[
    right(45),
    forward(100),
    right(30),
    forward(100),
    loop(2, [
        right(60),
        forward(30),
    ]),
    fill([  
        right(45),
        forward(100),
        right(30),
        forward(100)
    ]),
    fill(loop(6, [
        right(60),
        forward(50),
    ]))
]);/*
go_turtle(ops=[
    right(45),
]);*/
 /*
go_turtle(ops=[
    fill([  
        right(45),
    ]),
]);/*
go_turtle(ops=[
    fill([  
        right(45),
        forward(100),
        right(30),
        forward(100)
    ]),
    fill(loop(6, [
        right(60),
        forward(50),
    ]))
]);*/
