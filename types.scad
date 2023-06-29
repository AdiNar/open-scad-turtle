use <utils.scad>

// State: (State, RotMatrix, Position, LineWidth) -> State
function State(old_state, rotation_matrix=undef, position=undef, line_width=undef) =
    [
        coalesce(rotation_matrix, old_state[0]),
        coalesce(position, old_state[1]),
        coalesce(line_width, old_state[2]),
    ];

// get_rotation_matrix: State -> RotMatrix
function get_rotation_matrix(state) = state[0];

// get_position: State -> Position
function get_position(state) = state[1];

// get_line_width: State -> LineWidth
function get_line_width(state) = state[2];

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
function Move(type, args) = [type, args];

// get_move_type: Move -> fun
function get_move_type(move) = move[0];

// get_move_args: Move -> [Arg]
function get_move_args(move) = move[1];

// Step: (State, Move) -> Step
function Step(state, move) = [
    state,
    move,
];

// Step: (State, Move)
// make_steps: [State] ->, [Move] -> [Step]
function make_steps(states, moves) = map(
    zip(states, moves),
    function (x) Step(x[0], x[1])
);

// get_step_state: Step -> State
function get_step_state(step) = step[0];

// get_step_move: Step -> Move
function get_step_move(step) = step[1];

// get_step_move: Step -> MoveType
function get_step_type(step) = step[1][0];

// get_step_args: Step -> [Arg]
function get_step_args(step) = step[1][1];

// Mode: (ModeType, [Step]) -> Mode
function Mode(mode_type, states) = [mode_type, states];

// get_mode_type: Mode -> ModeType
function get_mode_type(mode) = mode[0];

// get_mode_steps: Mode -> [Step]
function get_mode_steps(mode) = mode[1];


_mode_fill_str = "MODE_FILL";
_mode_normal_str = "MODE_NORMAL";

// ModeType is MoveType
// mode_fill :: ModeType
ModeFill = function (state, _mode_fill_placeholder) state;

// mode_normal :: ModeType
ModeNormal = function (state, _mode_normal_placeholder) state;

mode_fill_str = str(ModeFill);
mode_normal_str = str(ModeNormal);
