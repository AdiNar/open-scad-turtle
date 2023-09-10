include <types.scad>

/*  ======== OPERATIONS ==========  */

right_type = _OperationType("__right__");
left_type = _OperationType("__left__");
forward_type = _OperationType("__forward__");
goto_type = _OperationType("__goto__");
move_type = _OperationType("__move__");
noop_type = _OperationType("__noop__");
fill_mode_type = _OperationType("__fill_mode_type__"); 
normal_mode_type = _OperationType("__normal_mode_type__");

/* This is actually the list of operations that are meant to be used by the user.
   Full interface for endusers is available in `turtle.scad`.
*/
function _right(angle) = Operation(right_type, angle);
function _left(angle) = Operation(left_type, angle);
function _forward(delta) = Operation(forward_type, delta);
function _goto(pos) = Operation(goto_type, pos);
function _move(delta) = Operation(move_type, delta);

function _loop(times, body) = Nested(__loop(times, body));
function __loop(times, body) =
    times == 0 ? [] : concat(body, __loop(times - 1, body));

/* Fills the inside of the drawing. */
// fill: [Operation] -> Nested
function _fill(body) = Nested([
    _fill_mode(),
    is_op(body) || is_nested(body) ? body : Nested(body),
    _normal_mode()
]);

/* Operations that are for internal use only */
function _noop() = Operation(noop_type);
function _fill_mode() = Operation(fill_mode_type);
function _normal_mode() = Operation(normal_mode_type);

mode_fill = _ModeType("__mode_fill__");
mode_normal = _ModeType("__mode_normal__");


/*  ======== OPERATIONS UNDER THE HOOD =========  */

/* Those are the the only functions that operate on state elements directly. */

function _rotate_left(current_rotation, angle) =
    let (new_rotation = [
            [cos(angle), -sin(angle)],
            [sin(angle), cos(angle)]
        ])
        current_rotation * new_rotation;

function _move_fun(current_rotation, current_position, delta) =
    current_position + current_rotation * delta;

left_fun = function (state, angle) update_state(
    state, rotation_matrix=_rotate_left(get_state_rotation_matrix(state), angle)
);

right_fun = function (state, angle) left_fun(state, -angle);

goto_fun = function (state, position) update_state(state, position=position);

move_fun = function (state, delta) update_state(
    state, position=_move_fun(get_state_rotation_matrix(state), get_state_position(state), delta)
);

forward_fun = function (state, x_delta) move_fun(state, [x_delta, 0]);

noop_fun = function (state, _) state;

mode_fill_fun = noop_fun;
mode_normal_fun = noop_fun;