# Terrestrial Instigator

## Description

- 2D Shoot-em-up game.
- Player controls a spaceship (moves in any direction) that can shoot lasers pointing towards the top of the screen.
- Enemy ships come down from the top of the screen and shoot lasers towards the bottom of the screen. Points earned for destroying enemies.
- Frequency of enemies increases over time.

## Non-functional properties:

- Bare metal game, built on the gamelib with some modifications to be able to:
  - utilise mode 13h
  - load more sectors from disk for kernel
- Ephemeral leaderboard.
- 2D sprites for graphics.
- Some music/sfx if I have time leftover to write a sound driver.
