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
    
    _a(_left(_rotation_matrix, 360), _rotation_matrix);
    rot_45 = _left(_rotation_matrix, 45);
    _a(rot_45, [[cos(45), -sin(45)], [sin(45), cos(45)]]);
    _a(_left(rot_45, 15), [[cos(60), -sin(60)], [sin(60), cos(60)]]);
}

module test_move() {
    state = init_state();
    _rotation_matrix = get_rotation_matrix(state);
    
    _a(_move(_rotation_matrix, [0, 0], [10, 20]), [10, 20]);
    
    f100 = _move(_rotation_matrix, [0, 0], [100, 0]);
    rot90 = _left(_rotation_matrix, 90);
    f100_2 = _move(rot90, f100, [100, 0]);
    _a(f100_2, [100, 100]);
}


module test_nested() {
    _a(Nested([1, 2, 3]), [NEST_MARKER, [1, 2, 3]]);
    _a(Nested(Nested([1, 2, 3])), [NEST_MARKER, [NEST_MARKER, [1, 2, 3]]]);
    
    op = right(30);
    body = Nested([op]);
    _a(body, [NEST_MARKER, [op]]);
}

module test_fill() {
    _a(fill(forward(10)), 
        Nested(
            [Operation(fill_mode_type), forward(10), Operation(normal_mode_type)]
        )
    );
    
    _a(fill([forward(10)]), 
        Nested(
            [Operation(fill_mode_type), Nested([forward(10)]), Operation(normal_mode_type)]
        )
    );
}

module test_flatten_ops() {
    op1 = right(30);
    op2 = forward(10);
    op3 = right(45);
    op4 = goto(100);
    op5 = right(60);
    op6 = goto(10);
    
    _a(flatten_ops([
        op1,
        op2,
    ]), [op1, op2]);
    
    _a(flatten_ops([
        op1,
        op2,
        Nested([op3, op4])
    ]), [op1, op2, op3, op4]);
    
    _a(flatten_ops([
        op1,
        op2,
        Nested([
            op3, op4, Nested([op5, op6])
        ])
    ]), [op1, op2, op3, op4, op5, op6]);
    
    op = forward(10);
    _a(flatten_ops(fill(op)), 
        [fill_mode(), op, normal_mode()],
        echo_fun=echo_ops
    );
}

module test_split_modes() {
    step_fill = Step(undef, fill_mode());
    step = Step(undef, right(30));
    step2 = Step(undef, forward(30));
    
    _a(take_mode([
        step, step2, step_fill
    ], 0), [step, step2], echo_fun=echo_steps);
    
    _a(split_by_modes([
        step,
    ]), [
        Mode(normal_mode_type, [step])
    ]);
    
    fill_steps = [step, step_fill, step2];
    _a(split_by_modes(fill_steps), [
        Mode(normal_mode_type, [step]), Mode(fill_mode_type, [step2])
    ], echo_fun=echo_modes);
}

module test_loop() {
    _a(loop(3, [1]), [NEST_MARKER, [1, 1, 1]]);
    _a(loop(0, [1]), [NEST_MARKER, []]);
    _a(loop(3, [1, 2]), [NEST_MARKER, [1, 2, 1, 2, 1, 2]]);
}

module test_fill_loop_regression() {
    op1 = right(60);
    op2 = forward(50);
    
    loop_ops = loop(2, [op1, op2]);
    
    expected_loop = Nested([op1, op2, op1, op2]);
    
    _a(loop_ops, expected_loop);
    
    body = Nested([right(30)]);
    filled = fill(body);
    
    fill_loop_ops = fill(loop_ops);
    
    _a(fill_loop_ops, Nested([
        Operation(fill_mode_type), expected_loop, Operation(normal_mode_type)
    ]));
    
    _a(flatten_ops(fill_loop_ops), [
        Operation(fill_mode_type), op1, op2, op1, op2, Operation(normal_mode_type)   
    ]);
}

test_utils();
test_right();
test_move();
test_split_modes();
test_fill();
test_flatten_ops();
test_loop();
test_nested();
test_fill_loop_regression();