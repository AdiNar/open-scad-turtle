use<lets_turtle.scad>

module _a(left, right) {
    assert(str(left) == str(right), str("Expected: ", right, ", got: ", left));
}

module test_right() {
    state = init_state();
    _rotation_matrix = get_rotation_matrix(state);
    
    _a(_right(_rotation_matrix, 360), _rotation_matrix);
    rot_45 = _right(_rotation_matrix, 45);
    _a(rot_45, [[cos(45), -sin(45)], [sin(45), cos(45)]]);
    _a(_right(rot_45, 15), [[cos(60), -sin(60)], [sin(60), cos(60)]]);
}

module test_move() {
    state = init_state();
    _rotation_matrix = get_rotation_matrix(state);
    
    _a(_move(_rotation_matrix, [0, 0], [10, 20]), [10, 20]);
    
    f100 = _move(_rotation_matrix, [0, 0], [100, 0]);
    rot90 = _right(_rotation_matrix, 90);
    f100_2 = _move(rot90, f100, [100, 0]);
    _a(f100_2, [100, 100]);
}


module test_nest() {
    _a(nest([1, 2, 3]), [NEST_MARKER, [1, 2, 3]]);
}

module test_fill() {
    _a(fill([
        [right, 30],
        [forward, 100]
    ]), [NEST_MARKER, [
        mode_fill,
        [right, 30], 
        [forward, 100],
        mode_normal
    ]]);
}

module test_flatten_moves() {
    _a(flatten_moves([
        [1],
        [2],
    ]), [[1], [2]]);
    
    _a(flatten_moves([
        [1],
        [2],
        [NEST_MARKER, [[3], [4]]]
    ]), [[1], [2], [3], [4]]);
    
    _a(flatten_moves([
        [1],
        [2],
        [NEST_MARKER, [
            [3], [4], [NEST_MARKER, [[5], [6]]]
        ]]
    ]), [[1], [2], [3], [4], [5], [6]]);
}

module test_split_modes() {
    _a(take_mode([
        [1], [2], make_step(undef, [mode_fill])
    ], 0), [[1], [2]]);
    
    _a(split_by_modes([
        [right, 30],
    ]), [
        [mode_normal, [[right, 30]]]
    ]);
    
    /*_a(split_by_modes(flatten_moves([
        [right, 30],
        fill([forward, 10]),
    ])), [
        [mode_normal, [[right, 30]]],
        [mode_fill, [forward, 10]]
    ]);*/
}

module test_loop() {
    _a(loop(3, [1]), [NEST_MARKER, [1, 1, 1]]);
    _a(loop(0, [1]), [NEST_MARKER, []]);
    _a(loop(3, [1, 2]), [NEST_MARKER, [1, 2, 1, 2, 1, 2]]);
}

test_right();
test_move();
test_split_modes();
test_nest();
test_fill();
test_flatten_moves();
test_loop();
