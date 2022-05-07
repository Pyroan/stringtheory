# StringTheory
A thing for turning strings into pictures

Ideally using Simulated Annealing, but we'll see if I can even get that far.

## TODO
- **Next step**: generate evaluation canvas image every frame & calculate error
- Initialize random string states
- Load/Save StringStates
- Process a StringState into a series of instructions so the images can be made in real life.
- Actual evaluation
- The Annealing Part

Each string is identified by its source node (always less than its destination node), its destination node, and type

|`type`|corresponding string|
|---:|-|
|1| "right" outer tangent|
|2| "left" outer tangent|
|3| "right" inner tangent|
|4| "left" inner tangent|

## Limitations
- Can currently only handle images larger than `evaluatorResolution`
- Can also only "correctly" handle images with square aspect ratios
  - Will scale non-square images to be square, rather than crop.
- Hoop size is clipped to the half the height of the screen, which is arbitrary and unnecessary.

uses [LÖVE-Nuklear](https://github.com/keharriso/love-nuklear) for UI