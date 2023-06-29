use <utils.scad>

is = function(obj, type) obj[0] == type;

// State: (State, RotMatrix, Position, LineWidth) -> State
function State(old_state, rotation_matrix=undef, position=undef, line_width=undef) =
    [
        "__State__",
        coalesce(rotation_matrix, old_state[1]),
        coalesce(position, old_state[2]),
        coalesce(line_width, old_state[3]),
    ];

function is_state(obj) = is(obj, "__State__");

// get_rotation_matrix: State -> RotMatrix
function get_rotation_matrix(state) = assert(is_state(state), state) state[1];

// get_position: State -> Position
function get_position(state) = assert(is_state(state), state) state[2];

// get_line_width: State -> LineWidth
function get_line_width(state) = assert(is_state(state), state) state[3];

// init_state: () -> State 
function init_state() = State(
    undef,
    [ // rotation_matrix
       [1, 0],
       [0, 1]
    ], 
    [0, 0], // position
    5 // line_width
);

// Operation: (OperationType, [Arg]) -> Operation
function Operation(type, args) = assert(is_op_type(type)) ["__Operation__", type, args];
function is_op(obj) = is(obj, "__Operation__");

// get_op_type: Operation -> fun
function get_op_type(op) = assert(is_op(op), op) op[1];

// get_op_args: Operation -> [Arg]
function get_op_args(op) = assert(is_op(op), op) op[2];

// Step: (State, Operation) -> Step
function Step(state, op) = assert(is_op(op), op) [
    "__Step__",
    state,
    op,
];

function is_step(obj) = is(obj, "__Step__");

// Step: (State, Operation)
// make_steps: [State] ->, [Operation] -> [Step]
function make_steps(states, ops) = map(
    zip(states, ops),
    function (x) Step(x[0], x[1])
);

// get_step_state: Step -> State
function get_step_state(step) = assert(is_step(step), step) step[1];

// get_step_op: Step -> Operation
function get_step_op(step) = assert(is_step(step), step) step[2];

// get_step_op: Step -> OperationType
function get_step_type(step) = assert(is_step(step), step) get_op_type(get_step_op(step));

// get_step_args: Step -> [Arg]
function get_step_args(step) = assert(is_step(step), step) get_op_args(get_step_op(step));

// Mode: (ModeType, [Step]) -> Mode
function Mode(op_type, states) = 
    assert(is_op_type(op_type))
    [
        "__Mode__", op_to_mode(op_type), states
    ];

function is_mode(obj) = is(obj, "__Mode__");

// get_mode_type: Mode -> ModeType
function get_mode_type(mode) = assert(is_mode(mode), mode) mode[1];

// get_mode_steps: Mode -> [Step]
function get_mode_steps(mode) = assert(is_mode(mode), mode) mode[2];

// mode_fill :: ModeType
function _ModeType(type_str) = ["__ModeType__", type_str]; 
mode_fill = _ModeType("__mode_fill__");
mode_normal = _ModeType("__mode_normal__");

is_mode_type = function (obj) is(obj, "__ModeType__");

function right(angle) = Operation(right_type, angle);
function left(angle) = Operation(left_type, angle);
function forward(delta) = Operation(forward_type, delta);
function goto(pos) = Operation(goto_type, pos);
function move(delta) = Operation(move_type, delta);
function noop() = Operation(noop_type);
function fill_mode() = Operation(fill_mode_type);
function normal_mode() = Operation(normal_mode_type);

// OperationType: str -> OperationType
function _OperationType(type_str) = ["__OperationType__", type_str]; 
right_type = _OperationType("__right__");
left_type = _OperationType("__left__");
forward_type = _OperationType("__forward__");
goto_type = _OperationType("__goto__");
move_type = _OperationType("__move__");
noop_type = _OperationType("__noop__");
fill_mode_type = _OperationType("__fill_mode_type__"); 
normal_mode_type = _OperationType("__normal_mode_type__");

is_op_type = function (obj) is(obj, "__OperationType__");
is_mode_op_type = function (type) assert(is_op_type(type), type)
    type == normal_mode_type || type == fill_mode_type;

function get_op_fun(op_type) =
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
    mode_type == mode_fill ? mode_fill_fun :
    mode_type == mode_normal ? mode_normal_fun :
    assert(false, mode_type);
    
// op_to_mode: OperationType -> ModeType
function op_to_mode(op_type) =
    assert(is_op_type(op_type))
    op_type == fill_mode_type ? mode_fill :
    op_type == normal_mode_type ? mode_normal :
    assert(false, op_type);
    
