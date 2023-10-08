include <turtle.scad>


// One can draw shapes just like using turtle
draw([
    left(30),
    forward(50),
    left(30),
    forward(50),
    right(40),
    forward(50),
    left(50),
    forward(50),
]);

// In order to start in another position, initial_state can be provided.
slot_2 = update_state(position=[500, 0]);

// There are loops also!
draw([
    loop(3, [
        left(120),
        forward(100),
    ])
], slot_2);


slot_3 = update_state(position=[1000, 0]);

// Figures might be reused
hex = figure(
        loop(6, [
            left(60),
            forward(100),
        ])
    );

// Solid shapes are available too
draw([
    loop(8, [
        forward(300),
        paint(hex),
        left(45),
    ]),
], slot_3);


// If needed, state may be set to absolute position.
slot_4 = update_state(position=[2000, 0]);
draw([
    hex,
    goto(2500, 0),
    paint(hex),
    goto(2250, 400),
    hex
], slot_4);


// Line width can be changed too. Corners will be rounded. To get sharper edges consider
// smaller line_width with `paint`.
slot_5 = update_state(position=[3000, 0]);
draw([
    hex,
    forward(500),
    line_width(100),
    hex
], slot_5);
