// Chapter select: a short story, the list of chapters, then the save slots of the chapter.
// Only chapter 1 can be played for now. Save files are named file_<chapter>_<slot>, e.g. file_1_1, file_1_2, file_1_3.
window_set_caption("Soul Signal");
state = 0;          // 0 the short story, 1 the chapter list, 2 the save slots
chars = 0;
sel = 0;
chapter_sel = 1;
slot_sel = 0;
slot_count = 3;
slot_info = array_create(3, undefined);
shake = 0;          // the screen shakes a little when you pick a locked chapter
msg = "";
msg_t = 0;
fade = 1;
leaving = false;
goto_room = -1;

story = "THE WORLD HUMS WITH SIGNALS.\nEVERYONE IS BORN WITH ONE.\nNOBODY CHOOSES IT.\n\nONE NIGHT, A SIGNAL THAT BELONGS TO NO ONE\nFINDS A WAY IN.";

chapter_names = ["THE SIGNAL", "???", "???", "???", "???", "???", "???"];
unlocked = [true, false, false, false, false, false, false];   // chapter 1 only

// the path of a save file, in the save area of the game
save_path = function(_chapter, _slot) {
    return game_save_id + "file_" + string(_chapter) + "_" + string(_slot) + ".ini";
};

// read what is inside the slots of a chapter (to show them in the list)
read_slots = function(_chapter) {
    for (var s = 1; s <= slot_count; s++) {
        var _file = save_path(_chapter, s);
        if (file_exists(_file)) {
            ini_open(_file);
            slot_info[s - 1] = {
                name: ini_read_string("save", "name", "?"),
                room: ini_read_string("save", "room", ""),
                time: ini_read_string("save", "time", ""),
                playtime: ini_read_real("save", "playtime", 0)
            };
            ini_close();
        } else {
            slot_info[s - 1] = undefined;
        }
    }
};

// load a save file into the global variables, then go to the room where it was saved
load_slot = function(_chapter, _slot) {
    ini_open(save_path(_chapter, _slot));
    global.chapter = ini_read_real("save", "chapter", _chapter);
    global.slot = _slot;
    global.fun = ini_read_real("save", "fun", 1);
    global.gatser_seen = (ini_read_real("save", "gatser_seen", 0) == 1);
    global.pname = ini_read_string("save", "name", "");
    global.vhead = ini_read_real("save", "head", 0);
    global.vtorso = ini_read_real("save", "torso", 0);
    global.vlegs = ini_read_real("save", "legs", 0);
    global.playtime = ini_read_real("save", "playtime", 0);
    var _txt = ini_read_string("save", "answers", "");
    var _px = ini_read_real("save", "x", 683);
    var _py = ini_read_real("save", "y", 450);
    var _room = ini_read_string("save", "room", "Room_Hallway");
    ini_close();
    // the answers of the survey are stored as "0,3,1,..."
    global.answers = [];
    var _cur = "";
    for (var i = 1; i <= string_length(_txt); i++) {
        var _c = string_char_at(_txt, i);
        if (_c == ",") { array_push(global.answers, real(_cur)); _cur = ""; }
        else _cur += _c;
    }
    if (_cur != "") array_push(global.answers, real(_cur));
    global.load_pos = [_px, _py];
    goto_room = asset_get_index(_room);
    leaving = true;
};

para = function(_x, _y, _str, _s, _lh, _center) {
    var _adv = 8 * _s;
    var _n = string_length(_str);
    var _i = 1;
    var _row = 0;
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    while (_i <= _n) {
        var _e = _i;
        while (_e <= _n && string_char_at(_str, _e) != "\n") _e++;
        var _len = _e - _i;
        var _lx = _center ? _x - (_len * _adv) / 2 : _x;
        for (var k = 0; k < _len; k++) {
            draw_text_transformed(_lx + k * _adv, _y + _row * _lh, string_char_at(_str, _i + k), _s, _s, 0);
        }
        _row++;
        _i = _e + 1;
    }
};

var _snd = asset_get_index("snd_leitmotif");
if (_snd != -1) audio_play_sound(_snd, 1, false);
