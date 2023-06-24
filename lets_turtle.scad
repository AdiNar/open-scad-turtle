function coalesce(a1, a2, a3=undef) =
  (a1 != undef) ? a1 :
  (a2 != undef) ? a2 :
  a3;

function make_state(old_state, rotation_matrix=undef, position=undef, line_width=undef) =
    [
        coalesce(rotation_matrix, old_state[0]),
        coalesce(position, old_state[1]),
        coalesce(line_width, old_state[2]),
    ];

function init_state() = make_state(
    undef,
    [ // rotation_matrix
       [1, 0],
       [0, 1]
    ], 
    [0, 0], // position
    5 // line_width
);

function rotation_matrix(state) = state[0];
function position(state) = state[1];
function line_width(state) = state[2];

module _a(left, right) {
    assert(str(left) == str(right), str("Expected: ", right, ", got: ", left));
}

function _right(current_rotation, angle) =
    let (new_rotation = [
            [cos(angle), -sin(angle)],
            [sin(angle), cos(angle)]
        ])
    
        current_rotation * new_rotation;

module test_right() {
    state = init_state();
    _rotation_matrix = rotation_matrix(state);
    echo(state);
    _a(_right(_rotation_matrix, 360), _rotation_matrix);
    rot_45 = _right(_rotation_matrix, 45);
    _a(rot_45, [[cos(45), -sin(45)], [sin(45), cos(45)]]);
    _a(_right(rot_45, 15), [[cos(60), -sin(60)], [sin(60), cos(60)]]);
}

function _move(current_rotation, current_position, delta) =
    current_position + current_rotation * delta;

module test_move() {
    state = init_state();
    _rotation_matrix = rotation_matrix(state);
    
    _a(_move(_rotation_matrix, [0, 0], [10, 20]), [10, 20]);
    
    f100 = _move(_rotation_matrix, [0, 0], [100, 0]);
    rot90 = _right(_rotation_matrix, 90);
    f100_2 = _move(rot90, f100, [100, 0]);
    _a(f100_2, [100, 100]);
}

function right(state, angle) =
    make_state(state, rotation_matrix=_right(rotation_matrix(state), angle));

function left(angle) = right(-angle);

module draw_move(state, delta) {
    w = line_width(state) / 2;
    
    start_1 = [0, w/2];
    start_2 = [0, -w/2];
    
    translate(position(state)) multmatrix(rotation_matrix(state)) {
        polygon([start_1, start_2, start_2 + delta, start_1 + delta]);
    }
}


module draw_forward(state, x_delta) {
    draw_move(state, [x_delta, 0]);
}

function forward(state, x_delta) = move(state, [x_delta, 0]);
function move(state, delta) = make_state(state, position=_move(rotation_matrix(state), position(state), delta));

test_right();
test_move();

state = init_state();
state2 = right(state, 45);

draw_forward(state2, 80);
state3 = forward(state2, 80);

state4 = right(state3, 30);

draw_forward(state4, 80);
state5 = forward(state4, 80);


