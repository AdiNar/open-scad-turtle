include<types.scad>

NEST_MARKER = "__Nested__";

// Nested: [Operation] -> Nested
function Nested(body) = 
    ["__Nested__", body];

function flatten(body) = assert(is_nested(body)) body[1];
function is_nested(obj) = is(obj, "__Nested__");

function loop(times, body) = Nested(_loop(times, body));
function _loop(times, body) =
    times == 0 ? [] : concat(body, _loop(times - 1, body));

// fill: [Operation] -> Nested
function fill(body) = Nested([
    fill_mode(),
    is_op(body) || is_nested(body) ? body : Nested(body),
    normal_mode()
]);

// Figure: [Operation] -> Nested
function Figure(ops) = Nested(ops);

// flatten_ops: Operation | [Operation | Nested ...] -> [Operation]
function flatten_ops(ops) = _flatten_ops(ops, 0);
function _flatten_ops(ops, index) =
    index == len(ops) ? undef :
        is_nested(ops) ? _flatten_ops(flatten(ops), 0) :
            let (
                op = ops[index],
                _1 = assert(is_op(op) || is_nested(op), op),
                head = is_nested(op) ? 
                        _flatten_ops(flatten(op), 0) : 
                        [op],
                tail = _flatten_ops(ops, index+1)
            )
            tail == undef ? head : concat(head, tail);