use <primitives.scad>
use <draw.scad>

/* Below is a set of operations available to users */
/* Examples are listed in `examples.scad` */

module draw(ops, initial_state=undef) {
    _draw(initial_state, ops);
}

/*  Turn right by angle in degrees */
right = function (angle) _right(angle);

/*  Turn left by angle in degrees */
left = function (angle) _left(angle);

/*  Go forward by delta in the direction given by current angle set by right/left.  */
forward = function (delta) _forward(delta);

/*  The same as forward, by allows movement in the direction perpendicular to current angle. */
move = function (x_delta, y_delta) _move([x_delta, y_delta]);

/*  Go to absolute x, y position, ignoring previous setting. */
goto = function (x, y) _goto([x, y]);

/*  Repeats <body> <times> times. The result is the same as one would copy-paste
   <body> content multiple times. */
loop = function (times, body) _loop(times, body);

/*  Paints shape interior with solid. Warning: as currently `fill` transformationi s not yet available in stable OpenSCAD version, this operation uses `hull`. `hull` makes the convex hull over the body, and paints this interior, which may give misleading results.
    See OpenSCAD docs to know the difference.
    
    NOTE: paint cannot be used nested, it will give undefined results.
*/
paint = function (body) _fill(body);

/*  Figure is an alias, it allow users to make variables with complex shapes, */    
//  Figure: [Operation] -> Nested
figure = function (ops) Figure(ops);
