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
function get_rotation_matrix(state) = assert(is_state(state)) state[1];

// get_position: State -> Position
function get_position(state) = assert(is_state(state))  state[2];

// get_line_width: State -> LineWidth
function get_line_width(state) = assert(is_state(state)) state[3];

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

// Move: (MoveType, [Arg]) -> Move
function Move(type, args) = assert(is_move_type(type)) ["__Move__", type, args];
function is_move(obj) = is(obj, "__Move__");

// get_move_type: Move -> fun
function get_move_type(move) = assert(is_move(move)) move[1];

// get_move_args: Move -> [Arg]
function get_move_args(move) = assert(is_move(move)) move[2];

// Step: (State, Move) -> Step
function Step(state, move) = assert(is_move(move)) [
    "__Step__",
    state,
    move,
];

function is_step(obj) = is(obj, "__Step__");

// Step: (State, Move)
// make_steps: [State] ->, [Move] -> [Step]
function make_steps(states, moves) = map(
    zip(states, moves),
    function (x) Step(x[0], x[1])
);

// get_step_state: Step -> State
function get_step_state(step) = assert(is_step(step)) step[1];

// get_step_move: Step -> Move
function get_step_move(step) = assert(is_step(step)) step[2];

// get_step_move: Step -> MoveType
function get_step_type(step) = assert(is_step(step)) get_move_type(get_step_move(step));

// get_step_args: Step -> [Arg]
function get_step_args(step) = assert(is_step(step)) get_move_args(get_step_move(step));

// Mode: (ModeType, [Step]) -> Mode
function Mode(move_type, states) = 
    assert(is_move_type(move_type))
    [
        "__Mode__", move_to_mode(move_type), states
    ];

function is_mode(obj) = is(obj, "__Mode__");

// get_mode_type: Mode -> ModeType
function get_mode_type(mode) = assert(is_mode(mode)) mode[1];

// get_mode_steps: Mode -> [Step]
function get_mode_steps(mode) = assert(is_mode(mode)) mode[2];

// ModeType is MoveType
// mode_fill :: ModeType
function _ModeType(type_str) = ["__ModeType__", type_str]; 
mode_fill = _ModeType("__mode_fill__");
mode_normal = _ModeType("__mode_normal__");

is_mode_type = function (obj) is(obj, "__ModeType__");

// MoveType: str -> MoveType
function _MoveType(type_str) = ["__MoveType__", type_str]; 
right = _MoveType("__right__");
left = _MoveType("__left__");
forward = _MoveType("__forward__");
goto = _MoveType("__goto__");
move = _MoveType("__move__");
noop = _MoveType("__noop__");
move_mode_fill = _MoveType("__move_mode_fill__"); 
move_mode_normal = _MoveType("__move_mode_normal__");

is_move_type = function (obj) is(obj, "__MoveType__");
is_mode_move = function (obj) obj == move_mode_fill || obj == move_mode_normal;

function get_move_fun(move_type) =
    move_type == right ? right_fun :
    move_type == left ? left_fun :
    move_type == forward ? forward_fun :
    move_type == goto ? goto_fun :
    move_type == move ? move_fun :
    move_type == noop ? noop_fun :
    mode_type == move_mode_fill ? mode_fill_fun :
    mode_type == move_mode_normal ? mode_normal_fun :
    assert(false, move_type);
    
function get_mode_fun(mode_type) =
    mode_type == mode_fill ? mode_fill_fun :
    mode_type == mode_normal ? mode_normal_fun :
    assert(false, mode_type);
    
function move_to_mode(move_type) =
    assert(is_move_type(move_type))
    move_type == move_mode_fill ? mode_fill :
    move_type == move_mode_normal ? mode_normal :
    assert(false, move_type);
    
