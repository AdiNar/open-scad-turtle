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


module test_nested() {
    _a(Nested([1, 2, 3]), [NEST_MARKER, [1, 2, 3]]);
    _a(Nested(Nested([1, 2, 3])), [NEST_MARKER, [NEST_MARKER, [1, 2, 3]]]);
    
    move = Move(right, 30);
    body = Nested([move]);
    _a(body, [NEST_MARKER, [move]]);
}

module test_fill() {
    _a(fill(Move(forward, 10)), 
        Nested(
            [Move(move_mode_fill), Move(forward, 10), Move(move_mode_normal)]
        )
    );
    
    _a(fill([Move(forward, 10)]), 
        Nested(
            [Move(move_mode_fill), Nested([Move(forward, 10)]), Move(move_mode_normal)]
        )
    );
}

module test_flatten_moves() {
    move1 = Move(right, 30);
    move2 = Move(forward, 10);
    move3 = Move(right, 45);
    move4 = Move(goto, 100);
    move5 = Move(right, 60);
    move6 = Move(goto, 10);
    
    _a(flatten_moves([
        move1,
        move2,
    ]), [move1, move2]);
    
    _a(flatten_moves([
        move1,
        move2,
        Nested([move3, move4])
    ]), [move1, move2, move3, move4]);
    
    _a(flatten_moves([
        move1,
        move2,
        Nested([
            move3, move4, Nested([move5, move6])
        ])
    ]), [move1, move2, move3, move4, move5, move6]);
    
    move = Move(forward, 10);
    _a(flatten_moves(fill(move)), 
        [Move(move_mode_fill), move, Move(move_mode_normal)],
        echo_fun=echo_moves
    );
}

module test_split_modes() {
    step_fill = Step(undef, Move(move_mode_fill));
    step = Step(undef, Move(right, 30));
    step2 = Step(undef, Move(forward, 30));
    
    _a(take_mode([
        step, step2, step_fill
    ], 0), [step, step2], echo_fun=echo_steps);
    
    _a(split_by_modes([
        step,
    ]), [
        Mode(move_mode_normal, [step])
    ]);
    
    fill_steps = [step, step_fill, step2];
    _a(split_by_modes(fill_steps), [
        Mode(move_mode_normal, [step]), Mode(move_mode_fill, [step2])
    ], echo_fun=echo_modes);
}

module test_loop() {
    _a(loop(3, [1]), [NEST_MARKER, [1, 1, 1]]);
    _a(loop(0, [1]), [NEST_MARKER, []]);
    _a(loop(3, [1, 2]), [NEST_MARKER, [1, 2, 1, 2, 1, 2]]);
}

module test_fill_loop_regression() {
    move1 = Move(right, 60);
    move2 = Move(forward, 50);
    
    loop_moves = loop(2, [move1, move2]);
    
    expected_loop = Nested([move1, move2, move1, move2]);
    
    _a(loop_moves, expected_loop);
    
    body = Nested([Move(right, 30)]);
    filled = fill(body);
    
    fill_loop_moves = fill(loop_moves);
    
    _a(fill_loop_moves, Nested([
        Move(move_mode_fill), expected_loop, Move(move_mode_normal)
    ]));
    
    _a(flatten_moves(fill_loop_moves), [
        Move(move_mode_fill), move1, move2, move1, move2, Move(move_mode_normal)   
    ]);
}

test_utils();
test_right();
test_move();
test_split_modes();
test_fill();
test_flatten_moves();
test_loop();
test_nested();
test_fill_loop_regression();