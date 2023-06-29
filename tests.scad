use <lets_turtle.scad>
include <utils.scad>
include <types.scad>
include <primitives.scad>
include <types_utils.scad>
include <manipulators.scad>

module test_utils() {
    p2 = function (x) x + 2;
    _a(map([1, 2, 3], p2), [3, 4, 5]);
    
    _a(zip([1, 2], ["a", "b"]), [[1, "a"], [2, "b"]]);
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
    _a(fill([Move(forward, 10)]), 
        [NEST_MARKER,
            [Move(ModeFill), Move(forward, 10), Move(ModeNormal)]
        ]
    );
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
    step_fill = Step(undef, Move(ModeFill));
    step = Step(undef, Move(right, 30));
    step2 = Step(undef, Move(forward, 30));
    
    _a(take_mode([
        [1], [2], step_fill
    ], 0), [[1], [2]]);
    
    _a(split_by_modes([
        step,
    ]), [
        [ModeNormal, [step]]
    ]);
    
    fill_steps = [step, step_fill, step2];
    _a(split_by_modes(fill_steps), [
        [ModeNormal, [step]], [ModeFill, [step2]]
    ], echo_fun=echo_modes);
}

module test_loop() {
    _a(loop(3, [1]), [NEST_MARKER, [1, 1, 1]]);
    _a(loop(0, [1]), [NEST_MARKER, []]);
    _a(loop(3, [1, 2]), [NEST_MARKER, [1, 2, 1, 2, 1, 2]]);
}
/*
test_utils();
test_right();
test_move();*/
test_split_modes();/*
test_nest();
test_fill();
test_flatten_moves();
test_loop();*/
