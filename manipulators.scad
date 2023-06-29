include<types.scad>

NEST_MARKER = function(do_not_call_me) undef;

// nest: [Move] -> Nested[Move]
function nest(body) = concat(NEST_MARKER, [body]);
function is_nested(element) = element[0] == NEST_MARKER;

function loop(times, body) = nest(_loop(times, body));
function _loop(times, body) =
    times == 0 ? [] : concat(body, _loop(times - 1, body));

// fill: [Move] -> Nested[Move]
function fill(body) = nest(concat(
    [Move(ModeFill)],
    body,
    [Move(ModeNormal)]
));

// figure: [Move] -> Figure
function figure(moves) = nest(moves);