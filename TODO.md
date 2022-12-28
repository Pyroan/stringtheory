## TODO
- Tweaks
  - maybe mess with the evaluation algorithm so it's nicer to colors that are closer together and meaner to ones that are further away (it's already like that, but even more so)
  - have a value being too low punished more strongly than being too high
  - favor states which use fewer strings but result in nearly the same error.
    - this will hopefully stop the overall image from getting too dark as the agent can't figure out the difference when an extraneous string is turned off
  - a lot of time is currently wasted on impossible wires...
  - try setting it to find/prioritize edges (oh boy time to write a sobel filter)
    - we definitely need to try weighting points of greatest change way heavier than things that are smooth, to help us pick out details.
      which means yes, finding the gradient of the image. which means yes, sobel filter. But it's not as simple as just layering a sobel on top of the regular image.
      In general our biggest problem is having no way to prioritize some pixels over others.
      Maybe it's more a matter of comparing the sobel of our result to the sobel of the target?
- Massive amounts of refactoring this codebase is a big plate of spaghetti.
- Be able to open/align non-square images before running the simulation.
- Process a StringState into a series of instructions so the images can be made in real life.
- Usability Improvements
- Aesthetic improvements.

- Let the user make edits/toggle individual strings/maybe indicate "important" area of an image.