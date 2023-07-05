include <types.scad>
include <primitives.scad>
include <utils.scad>
include <draw.scad>


hex = Figure(fill(loop(6, [
    right(60),
    forward(100),
]))); 

draw(ops=[
    loop(9, [
        forward(300),
        hex,
        right(45),
    ]),
]);
