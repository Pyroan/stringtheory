# StringTheory
A thing for turning strings into pictures

Ideally using Simulated Annealing, but we'll see if I can even get that far.

Next step: figuring out how to make an image of the strings in the same
resolution as the image for the evaluator.

Each string is identified by its source node (always less than its destination node), its destination node, and type

|`type`|corresponding string|
|---:|-|
|1| "right" outer tangent|
|2| "left" outer tangent|
|3| "right" inner tangent|
|4| "left" inner tangent|

uses [LÖVE-Nuklear](https://github.com/keharriso/love-nuklear) for UI