include <types.scad>

/* Basic helpers */

// init_state: () -> State 
function init_state() = State(
    [ // rotation_matrix
       [1, 0],
       [0, 1]
    ], 
    [0, 0], // position
    5 // line_width
);

// Allows to easily update single (or more) attribute of the state
function update_state(old_state, rotation_matrix=undef, position=undef, line_width=undef) =
    State(
        coalesce(rotation_matrix, old_state[1]),
        coalesce(position, old_state[2]),
        coalesce(line_width, old_state[3])
    );
    
// make_steps: [State] ->, [Operation] -> [Step]
function make_steps(states, ops) = map(
    zip(states, ops),
    function (x) Step(x[0], x[1])
);

// op_to_mode: OperationType -> ModeType
function op_to_mode(op_type) =
    assert(is_op_type(op_type))
    op_type == fill_mode_type ? mode_fill :
    op_type == normal_mode_type ? mode_normal :
    assert(false, op_type);


// get_op_fun: OperationType -> Fun
function get_op_fun(op_type) =
    assert(is_op_type(op_type))
    op_type == right_type ? right_fun :
    op_type == left_type ? left_fun :
    op_type == forward_type ? forward_fun :
    op_type == goto_type ? goto_fun :
    op_type == move_type ? move_fun :
    op_type == noop_type ? noop_fun :
    op_type == fill_mode_type ? mode_fill_fun :
    op_type == normal_mode_type ? mode_normal_fun :
    assert(false, op_type);
    
function get_mode_fun(mode_type) =
    assert(is_mode_type(op_type))
    mode_type == mode_fill ? mode_fill_fun :
    mode_type == mode_normal ? mode_normal_fun :
    assert(false, mode_type);
    
    
is_mode_op_type = function (type) 
    assert(is_op_type(type), type)
    type == normal_mode_type || type == fill_mode_type;


/* Higher order helpers */    
    
/* Turns list of possibly nested Operations into a flat list of Operations.

   Motivation: 
       Due to use of Nested, manipulators or vectors list of Operations may be nested.
       Rendering requires flat list of Operations.
*/    
// flatten_ops: Operation | [Operation | Nested ...] -> [Operation]
function flatten_ops(ops) = _flatten_ops(ops, 0);
function _flatten_ops(ops, index) =
    index == len(ops) ? undef :
        is_nested(ops) ? _flatten_ops(flatten(ops), 0) :
            let (
                op = ops[index],
                _1 = assert(is_op(op) || is_nested(op), op),
                head = is_nested(op) ? 
                        _flatten_ops(flatten(op), 0) : 
                        [op],
                tail = _flatten_ops(ops, index+1)
            )
            tail == undef ? head : concat(head, tail);


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