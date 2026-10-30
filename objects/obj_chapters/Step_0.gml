if (leaving) {
    fade = min(1, fade + 0.06);
    if (fade >= 1) {
        if (goto_room != -1) room_goto(goto_room);      // a loaded file: back to where it was saved
        else room_goto_next();                          // a new game: the creation of your vessel
    }
    exit;
}
fade = max(0, fade - 0.05);
shake = max(0, shake - 1);
msg_t = max(0, msg_t - 1);

var _ok = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"));
var _back = keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift);
var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));

switch (state) {
    case 0: // the short story
        chars = min(string_length(story), chars + 0.8);
        if (_ok) {
            if (chars < string_length(story)) chars = string_length(story);
            else state = 1;
        }
        break;

    case 1: // the chapters
        var _n = array_length(chapter_names);
        if (_up) sel = (sel + _n - 1) mod _n;
        if (_down) sel = (sel + 1) mod _n;
        if (_ok) {
            if (unlocked[sel]) {
                chapter_sel = sel + 1;
                read_slots(chapter_sel);
                slot_sel = 0;
                state = 2;
            } else {
                shake = 14;
                msg = "THIS CHAPTER IS NOT READY YET.";
                msg_t = 120;
            }
        }
        break;

    case 2: // the save slots of the chapter: file_<chapter>_<slot>
        if (_up) slot_sel = (slot_sel + slot_count - 1) mod slot_count;
        if (_down) slot_sel = (slot_sel + 1) mod slot_count;
        if (_back) state = 1;
        if (keyboard_check_pressed(ord("D")) && slot_info[slot_sel] != undefined) {
            file_delete(save_path(chapter_sel, slot_sel + 1));
            read_slots(chapter_sel);
            msg = "FILE " + string(chapter_sel) + "-" + string(slot_sel + 1) + " DELETED.";
            msg_t = 120;
        }
        if (_ok) {
            if (slot_info[slot_sel] == undefined) {
                // an empty file: a new game in this slot
                global.chapter = chapter_sel;
                global.slot = slot_sel + 1;
                global.load_pos = undefined;
                leaving = true;
            } else {
                load_slot(chapter_sel, slot_sel + 1);
            }
        }
        break;
}
