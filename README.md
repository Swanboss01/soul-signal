# Soul Signal

A story game by **Sinar Studio**, made with GameMaker. Currently in production: this repository holds the first playable demo of **Chapter 1: The Signal**.

> The world hums with signals. Everyone is born with one. Nobody chooses it.
> One night, a signal that belongs to no one finds a way in.

## Play the demo

Download `SoulSignal-demo.zip` from the *Releases* page, unzip it and run `SoulSignal.exe`. Keep the `.ogg` files and `data.win` next to the exe.

| Key | Action |
| --- | --- |
| Arrow keys / WASD | Move, choose |
| Z / Enter | Confirm, talk, look |
| X / Shift | Cancel, go back, run |
| F4 | Fullscreen |

Test keys for the *fun value* (a number from 1 to 100 drawn at the start of the game): **F8** sets it to 65, **F7** sets it to 10, **F9** shows it in the window title.

## Save files

The game keeps three files per chapter, named `file_<chapter>_<slot>`: `file_1_1`, `file_1_2`, `file_1_3`. They are written in `%LOCALAPPDATA%\SOULSIGNAL\` when you use the **save point** (the yellow star) in the hallway.

## Open the project

Open `SOULSIGNAL.yyp` with GameMaker (made with IDE 2026.0.0.16, runtime 2026.0.0.23).

- `objects/obj_chapters`: the chapter select and the save slots
- `objects/obj_intro`: the creation of your vessel
- `objects/obj_scene`: the bedroom, the hallway and the other rooms (movement, dialogs, the save point)
- `objects/obj_system`: F4 for fullscreen, the fun value, the test keys
- `sounds/`: the leitmotif **E - C - B - E** and the background music

## Credits

Made by Sinar Studio. Music and pixel art were generated for this project.
