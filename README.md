## General info
This library provides set of tools to make OpenSCAD models using Turtle-Graphics-like commands ([`Turtle graphics`](https://en.wikipedia.org/wiki/Turtle_graphics)).

Shapes are produced using by moving a `turtle` with a series of commands. Each command changes the `turtle` relative to the previous one. 
Intuitively it's like drawing on a paper.

E.g. equilateral triangle may be created by:
```
draw([
    left(120),
    forward(100),
    left(120),
    forward(100),
    left(120),
    forward(100),
]);
```

Note that there are other, more developed solutions of this kind, like [dotSCAD](https://github.com/JustinSDK/dotSCAD#turtle). This is just another approach, mostly to play around with the language.


## How to use
- Clone this repository inside the OpenSCAD library directory, according to your platform:
    - Windows: My Documents\OpenSCAD\libraries\
    - Linux: $HOME/.local/share/OpenSCAD/libraries/
    - Mac OS X: $HOME/Documents/OpenSCAD/libraries/

- Restart OpenSCAD.

- Add `include <open-scad-turtle/turtle.scad>` at the top of your file.
- Look at examples and write your own models.

## Examples
Examples are provided in [`examples.scad`](https://github.com/AdiNar/open-scad-turtle/blob/main/examples.scad). All keywords that you can use are listed and described in [`turtle.scad`](https://github.com/AdiNar/open-scad-turtle/blob/main/turtle.scad).

## How it works?
In order to make this library I had to mimic a complex typesystem using very loosely typed language like OpenSCAD.
Those are described in details in [`types.scad`](https://github.com/AdiNar/open-scad-turtle/blob/main/types.scad).
Whole thing is written in haskell-like style.

