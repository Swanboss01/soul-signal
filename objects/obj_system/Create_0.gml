// The "fun value": a number from 1 to 100 drawn once when the game starts. It decides rare events.
// 65-100: after the bedroom the hallway is the FAKE hallway, with a gray door.
global.fun = irandom_range(1, 100);
global.gatser_seen = false;
global.from = "";
show_debug_message("FUN VALUE = " + string(global.fun));

window_set_caption("Soul Signal");

// what a save file keeps (see the save point in the hallway): file_<chapter>_<slot>
global.chapter = 1;
global.slot = 1;
global.playtime = 0;          // seconds
global.pname = "";            // the name chosen in the survey
global.vhead = 0; global.vtorso = 0; global.vlegs = 0;
global.answers = [];
global.load_pos = undefined;  // where Eli stands when a file is loaded
