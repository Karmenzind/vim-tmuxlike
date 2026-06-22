# Known Issues

## Window chooser labels `d` and `g` require another keypress

In some Neovim terminal sessions, selecting a window with the built-in
chooser label `d` or `g` does not visibly complete until another key is
pressed. The target window is selected after that additional input.

The issue occurs while the chooser uses `vim.on_key()` to consume input.
Synchronous selection, scheduling selection for the next event-loop
iteration, and explicitly flushing the UI did not make these labels reliable
in the affected environment.

## Current workaround

The labels `d` and `g` are reserved and excluded from the chooser. They are
filtered even when provided through `chooser.labels`. The label `q` is
reserved for cancelling the chooser, and digits are reserved for tab
selection.

## Follow-up

Investigate whether terminal key encoding, an existing mapping, or Neovim's
input processing causes these keys to remain pending while an `on_key()`
listener consumes input.

## Too many windows

Window labels are limited to the preset character sequence, which excludes
reserved or problematic letters. If a chooser scope contains more windows
than available characters, the chooser stays closed and displays:

> You've opened too many windows. Are you here to cause trouble?
