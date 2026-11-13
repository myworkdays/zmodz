# UI interaction regressions

Install the [official Luau CLI](https://github.com/luau-lang/luau/releases), then run:

```sh
python3 tests/run.py
# Or: LUAU=/path/to/luau python3 tests/run.py
```

The harness executes `esp.lua` with lightweight Roblox service and UI doubles.
It checks launch/hide, minimize/restore, drag-versus-click, release outside the
handle, small click jitter, keyboard activation, multi-touch ownership, color-slider centering, and ESP
toggle/close behavior.
It does not simulate Roblox input routing or rendering; confirm mouse and touch
interactions in the Roblox client before release.
