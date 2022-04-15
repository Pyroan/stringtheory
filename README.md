# StringTheory
A thing for turning strings into pictures

Ideally using Simulated Annealing, but we'll see if I can even get that far.

Next step: Make the strings individually addressable/identifiable and track their `active` state in a table
- each node has an id (1..n)
- each pair of nodes has 4 total strings...
- we could say that each node is only responsible for its "right" outer string
- for both nodes the inner tangents are the same so I'm not sure how to track which is which.
    - could make it use the node with the greatest id which would make some other stuff easier but feels nasty..
    - could also store pairs of nodes as tuples/sets in which case they're equivalent but i need to know which node is which so that seems like the same thing but less readable

so if we have two nodes [1,2]...
the strings are...
'11' - 'right' outer string
'12' - 'left' outer string
'13' - 'right' inner string
'14  - 'left' inner string...

struct string = {
    id: int // actually not important
    source_node_id: int
    dest_node_id: int
    type: int[1..4]
    active: bool
}

we don't really care *that* much what the list looks like so long as the algorithm can do its job.

uses [LÖVE-Nuklear](https://github.com/keharriso/love-nuklear) for UI