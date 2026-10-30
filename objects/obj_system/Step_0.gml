// Always present (persistent): F4 switches between window and fullscreen
if (keyboard_check_pressed(vk_f4)) {
    window_set_fullscreen(!window_get_fullscreen());
}

// test keys for the fun value (the number from 1 to 100 that decides rare events)
// F8 = 65, the value of Gatser: after the bedroom you get the fake hallway with the gray door
// F7 = 10, a normal hallway      F9 = show the current value
// The value is also shown in the title of the game window.
if (keyboard_check_pressed(vk_f8)) { global.fun = 65; global.gatser_seen = false; if (room_get_name(room) != "Room_Intro") window_set_caption("Soul Signal  -  FUN VALUE " + string(global.fun)); show_debug_message("FUN VALUE = 65"); }
if (keyboard_check_pressed(vk_f7)) { global.fun = 10; if (room_get_name(room) != "Room_Intro") window_set_caption("Soul Signal  -  FUN VALUE " + string(global.fun)); show_debug_message("FUN VALUE = 10"); }
if (keyboard_check_pressed(vk_f9)) { if (room_get_name(room) != "Room_Intro") window_set_caption("Soul Signal  -  FUN VALUE " + string(global.fun)); show_debug_message("FUN VALUE = " + string(global.fun)); }

// the time played, saved in the files
global.playtime += delta_time / 1000000;
