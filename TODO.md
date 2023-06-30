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


# Branch stuff lol
ok hi in this branch i want to completely overhaul everything to instead evaluate the fitness for each individual line, and then turn off all lines below a settable threshold.
This involves basically rewriting the evaluator and UI from scratch and implementing
a line drawing algorithm instead of drawing to canvas, but should give us better results AND faster ones too. Hopefully.

(we don't need to recalculate the error to adjust the threshold, and it'd be silly to. We should just process it all and then adjust when the threshold changes.)

also i reallly wanna do that thing where i use a sobel filter to give more weight to areas
with higher detail but i'm soooo lazyyyy


I got it basically working so here's some more stuff to try:
- "fuzzy" threshold - basically make it so that strings that fail the threshold still have a chance of getting turned on and vice versa.