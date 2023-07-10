# based on: https://dewitters.com/dewitters-gameloop/
# http://lspiroengine.com/?p=378

import std/monotimes

proc run(game: var Game) =
  const
    ticksPerSec = 25
    skippedTicks = 1_000_000_000 div ticksPerSec # to nanosecs per tick
    maxFramesSkipped = 5 # 20% of ticksPerSec

  var
    lastTime = getMonoTime().ticks
    accumulator = 0'i64

  while true:
    handleEvents(game)
    if not game.isRunning: break

    let now = getMonoTime().ticks
    accumulator += now - lastTime
    lastTime = now

    var framesSkipped = 0
    while accumulator >= skippedTicks and framesSkipped < maxFramesSkipped:
      game.update()
      accumulator -= skippedTicks
      framesSkipped.inc

    if framesSkipped > 0:
      let alpha = accumulator.float32 / skippedTicks / 1_000_000_000
      game.render(alpha)
