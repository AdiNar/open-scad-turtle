include<types.scad>

NEST_MARKER = "__Nested__";

// Nested: [Move] -> Nested
function Nested(body) = 
    ["__Nested__", body];

function flatten(body) = assert(is_nested(body)) body[1];
function is_nested(obj) = is(obj, "__Nested__");

function loop(times, body) = Nested(_loop(times, body));
function _loop(times, body) =
    times == 0 ? [] : concat(body, _loop(times - 1, body));

// fill: [Move] -> Nested
function fill(body) = Nested([
    Move(move_mode_fill),
    is_move(body) || is_nested(body) ? body : Nested(body),
    Move(move_mode_normal)
]);

// Figure: [Move] -> Nested
function Figure(moves) = Nested(moves);

// flatten_moves: Move | [Move | Nested[Move] ...] -> [Move]
function flatten_moves(moves) = echo("to_flatten", moves) _flatten_moves(moves, 0);
function _flatten_moves(moves, index) =
    index == len(moves) ? undef :
        is_nested(moves) ? _flatten_moves(flatten(moves), 0) :
            let (
                move = moves[index],
                _0 = echo("Moves", moves),
                _ = echo("move", move),
                _1 = assert(is_move(move) || is_nested(move), move),
                head = is_nested(move) ? 
                        _flatten_moves(flatten(move), 0) : 
                        [move],
                tail = _flatten_moves(moves, index+1)
            )
            tail == undef ? head : concat(head, tail);