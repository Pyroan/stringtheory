## TODO
- Tweaks
  - maybe mess with the evaluation algorithm so it's nicer to colors that are closer together and meaner to ones that are further away (it's already like that, but even more so)
  - have a value being too low punished more strongly than being too high
  - favor states which use fewer strings but result in nearly the same error.
    - this will hopefully stop the overall image from getting to dark as the agent can't figure out the difference when an extraneous string is turned off
  - a lot of time is currently wasted on impossible wires...
  - try setting it to find/prioritize edges (oh boy time to write a sobel filter)
- Massive amounts of refactoring this codebase is a big plate of spaghetti.
- Be able to open/align non-square images before running the simulation.
- Process a StringState into a series of instructions so the images can be made in real life.
- Usability Improvements
- Aesthetic improvements.

- Let the user make edits/toggle individual strings/maybe indicate "important" area of an image.