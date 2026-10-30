// One object builds every room after the survey: Eli's bedroom, the hallway, the fake hallway and the fake room.
rname = room_get_name(room);
if (!variable_global_exists("fun")) { global.fun = irandom_range(1, 100); global.gatser_seen = false; }
if (!variable_global_exists("from")) global.from = "";
// the globals of the save system, in case the game was started from this room (tests)
if (!variable_global_exists("chapter")) global.chapter = 1;
if (!variable_global_exists("slot")) global.slot = 1;
if (!variable_global_exists("playtime")) global.playtime = 0;
if (!variable_global_exists("pname")) global.pname = "";
if (!variable_global_exists("vhead")) { global.vhead = 0; global.vtorso = 0; global.vlegs = 0; }
if (!variable_global_exists("answers")) global.answers = [];
if (!variable_global_exists("load_pos")) global.load_pos = undefined;

// the player (Eli's body): feet position and facing (0 down, 1 up, 2 left, 3 right)
px = 683; py = 620; pdir = 0; moving = false;
minx = 200; maxx = 1166; miny = 340; maxy = 690;     // where the feet can go

walls = [];     // solid rectangles [x1, y1, x2, y2]
things = [];    // things you can talk to
dlg = [];       // the dialog that is open (array of lines), empty = none
dline = 0; dchars = 0; dspeaker = ""; after = "";
goto_name = ""; fade = 1; fading_out = false;

// the mystery man of the fake room
man_state = 0;  // 0 he is here, 1 he vanishes, 2 he is gone
man_t = 0;
man_lines = ["...", "YOU ARE EARLY.", "THIS ROOM IS NOT FINISHED.", "NEITHER ARE YOU.", "GO BACK, BEFORE THE OPERATOR HEARS YOU."];

// ------------------------------------------------------------------ helpers
// text with a pixel-font look: every letter on a fixed grid
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

add_wall = function(_x1, _y1, _x2, _y2) { array_push(walls, [_x1, _y1, _x2, _y2]); };
add_thing = function(_x1, _y1, _x2, _y2, _lines, _act) {
    array_push(things, { x1: _x1, y1: _y1, x2: _x2, y2: _y2, lines: _lines, act: _act });
    array_push(walls, [_x1, _y1, _x2, _y2]);
};
say = function(_lines, _speaker, _after) { dlg = _lines; dline = 0; dchars = 0; dspeaker = _speaker; after = _after; };
overlap = function(_a1, _b1, _a2, _b2, _c1, _d1, _c2, _d2) { return (_a1 < _c2 && _a2 > _c1 && _b1 < _d2 && _b2 > _d1); };

// what happens when a dialog ends, or when a door is used
run_after = function(_act) {
    if (string_copy(_act, 1, 5) == "goto:") {
        var _target = string_delete(_act, 1, 5);
        if (_target == "FUN") _target = (global.fun >= 65 && !global.gatser_seen) ? "Room_FakeHallway" : "Room_Hallway";   // the fun value
        global.from = rname;
        goto_name = _target;
        fading_out = true;
    } else if (_act == "vanish") {
        man_state = 1; man_t = 0; global.gatser_seen = true;
    } else if (_act == "save") {
        ask = true; ask_sel = 0;
    } else if (_act == "motif") {
        var _s = asset_get_index("snd_leitmotif");
        if (_s != -1) audio_play_sound(_s, 1, false);
    }
};

// ------------------------------------------------------------------ Eli's body (pixel art, drawn from maps)
p_head  = ["...HHHHHH...", "..HHHHHHHH..", ".HHHHHHHHHH.", ".HSSSSSSSSH.", ".SSESSSSESS.", ".SSSSSSSSSS.", ".SSSSMMSSSS.", "..SSSSSSSS..", "...SSSSSS..."];
p_back  = ["...HHHHHH...", "..HHHHHHHH..", ".HHHHHHHHHH.", ".HHHHHHHHHH.", ".HHHHHHHHHH.", ".HHHHHHHHHH.", ".HHHHHHHHHH.", "..HHHHHHHH..", "...HHHHHH..."];
p_torso = [".TTTTTTTTTT.", "TTTTTTTTTTTT", "TTTTTTTTTTTT", "TTTTTTTTTTTT", "TTTWWWWWTTTT", "TTTTTTTTTTTT", ".TTTTTTTTTT.", "..TTTTTTTT.."];
p_legs  = [".PPPPPPPPPP.", ".PPPP..PPPP.", ".PPPP..PPPP.", ".PPPP..PPPP.", ".PPPP..PPPP.", ".BBBB..BBBB.", "BBBBB..BBBBB"];

pal = function(_ch) {
    switch (_ch) {
        case "S": return make_color_rgb(232, 190, 160);
        case "H": return make_color_rgb(120, 70, 60);
        case "E": return make_color_rgb(30, 20, 30);
        case "M": return make_color_rgb(170, 70, 70);
        case "T": return make_color_rgb(190, 55, 75);
        case "W": return make_color_rgb(245, 245, 245);
        case "P": return make_color_rgb(60, 70, 130);
        case "B": return make_color_rgb(60, 40, 45);
    }
    return c_black;
};

map_draw = function(_m, _x, _y, _s, _pass) {
    for (var r = 0; r < array_length(_m); r++) {
        var _row = _m[r];
        for (var c = 0; c < 12; c++) {
            var _ch = string_char_at(_row, c + 1);
            if (_ch == ".") continue;
            var _px = _x + c * _s;
            var _py = _y + r * _s;
            if (_pass == 0) {
                draw_set_color(c_white);
                draw_rectangle(_px - _s, _py, _px + 2 * _s - 1, _py + _s - 1, false);
                draw_rectangle(_px, _py - _s, _px + _s - 1, _py + 2 * _s - 1, false);
            } else {
                draw_set_color(pal(_ch));
                draw_rectangle(_px, _py, _px + _s - 1, _py + _s - 1, false);
            }
        }
    }
};

// feet at (_x, _y)
draw_eli = function(_x, _y) {
    var _s = 3;
    var _bob = moving ? round(sin(current_time / 90) * 2) : 0;
    draw_set_alpha(0.35); draw_set_color(c_black);
    draw_ellipse(_x - 22, _y - 6, _x + 22, _y + 6, false);
    draw_set_alpha(1);
    var _x0 = _x - 6 * _s;
    var _y0 = _y - 24 * _s + _bob;
    for (var _pass = 0; _pass < 2; _pass++) {
        map_draw(p_legs, _x0, _y0 + 17 * _s - _bob, _s, _pass);
        map_draw(p_torso, _x0, _y0 + 9 * _s, _s, _pass);
        map_draw((pdir == 1) ? p_back : p_head, _x0, _y0, _s, _pass);
    }
};

// the mystery man: a tall black coat and a blank white mask. _a = how much of him is still there.
draw_man = function(_x, _y, _a) {
    var _strips = 10;
    for (var i = 0; i < _strips; i++) {
        var _top = _y - 150 + i * 15;
        var _off = (_a < 1) ? irandom_range(-14, 14) * (1 - _a) : 0;
        if (_a < 1 && random(1) > _a + 0.15) continue;      // pieces of him disappear
        draw_set_color(make_color_rgb(8, 8, 12));
        draw_rectangle(_x - 34 + _off, _top + 70, _x + 34 + _off, _top + 70 + 16, false);
        if (i < 5) {
            draw_set_color(make_color_rgb(235, 235, 240));
            draw_rectangle(_x - 20 + _off, _top, _x + 20 + _off, _top + 16, false);
        }
    }
    // the eyes and the crack, only while he is whole enough
    if (_a > 0.5) {
        draw_set_color(c_black);
        draw_rectangle(_x - 12, _y - 128, _x - 5, _y - 112, false);
        draw_rectangle(_x + 5, _y - 128, _x + 12, _y - 112, false);
        draw_line_width(_x - 2, _y - 150, _x + 3, _y - 104, 2);
    }
};

// ------------------------------------------------------------------ saving
ask = false;        // the "save?" question is open
ask_sel = 0;        // 0 = YES, 1 = NO

// writes file_<chapter>_<slot>.ini in the save area of the game
save_game = function() {
    var _file = game_save_id + "file_" + string(global.chapter) + "_" + string(global.slot) + ".ini";
    var _ans = "";
    for (var i = 0; i < array_length(global.answers); i++) _ans += string(global.answers[i]) + ",";
    ini_open(_file);
    ini_write_real("save", "chapter", global.chapter);
    ini_write_real("save", "slot", global.slot);
    ini_write_string("save", "room", rname);
    ini_write_real("save", "x", px);
    ini_write_real("save", "y", py);
    ini_write_real("save", "fun", global.fun);
    ini_write_real("save", "gatser_seen", global.gatser_seen ? 1 : 0);
    ini_write_string("save", "name", global.pname);
    ini_write_real("save", "head", global.vhead);
    ini_write_real("save", "torso", global.vtorso);
    ini_write_real("save", "legs", global.vlegs);
    ini_write_string("save", "answers", _ans);
    ini_write_real("save", "playtime", global.playtime);
    ini_write_string("save", "time", date_datetime_string(date_current_datetime()));
    ini_close();
    show_debug_message("SAVED: " + _file);
};

// ------------------------------------------------------------------ the music
audio_stop_all();
var _track = "";
switch (rname) {
    case "Room_Bedroom": _track = "bgm_bedroom"; break;
    case "Room_Hallway": _track = "bgm_hall"; break;
    case "Room_FakeHallway": _track = "bgm_hall"; break;
    case "Fake_Room_Mystery_Man": _track = "snd_secret"; break;
}
if (_track != "") {
    var _snd = asset_get_index(_track);
    if (_snd != -1) audio_play_sound(_snd, 1, true);
}

// ------------------------------------------------------------------ the rooms
switch (rname) {
    case "Room_Bedroom":
        px = 560; py = 560; minx = 200; maxx = 1166; miny = 340; maxy = 690;
        add_thing(210, 330, 470, 520, ["ELI'S BED.", "STILL WARM.", "(YOU ARE NOT SURE WHOSE WARMTH IT IS.)"], "");
        add_thing(935, 330, 1010, 415, ["GRANDPA'S RADIO.", "A DIAL, A SPEAKER AND A DUSTY ANTENNA.", "IT HUMS. SOMETHING IS TRYING TO GET THROUGH...", "(IT PLAYS FOUR SOFT NOTES.)"], "motif");
        add_thing(1020, 330, 1130, 430, ["DRAWINGS IN THE MARGINS OF A NOTEBOOK.", "RAIN. ANTENNAS. A SMALL RED HEART.", "EVERY PAGE ENDS WITH THE SAME FOUR NOTES."], "");
        add_wall(880, 330, 935, 430);
        add_thing(560, 150, 640, 315, ["A MIRROR.", "A PALE KID WITH MESSY BROWN HAIR AND GREEN EYES.", "COLD HANDS. TIRED EYES.", "A STICKER ON THE FRAME SAYS: ELI HART.", "THIS IS WHO YOU ARE NOW."], "");
        add_thing(700, 150, 860, 315, ["IT IS RAINING.", "OF COURSE IT IS."], "");
        add_thing(300, 150, 470, 315, ["POSTERS OF OLD PIXEL GAMES.", "ONE OF THEM IS A HAND-DRAWN RADIO TOWER."], "");
        add_thing(620, 695, 740, 770, ["TIME TO LEAVE THE ROOM."], "goto:FUN");
        say(["YOU OPEN YOUR EYES.", "A BEDROOM. RAIN ON THE WINDOW.", "THE HANDS ARE COLD. THEY ARE NOT YOURS.", "THEY ARE ELI'S.", "(ARROW KEYS: MOVE.   Z: LOOK, TALK.   X: RUN.)"], "", "");
        break;

    case "Room_Hallway":
    case "Room_FakeHallway":
        px = 300; py = 450; minx = 130; maxx = 1236; miny = 350; maxy = 700;
        if (global.from == "Fake_Room_Mystery_Man") { px = 670; py = 450; }
        add_thing(250, 150, 350, 315, ["ELI'S BEDROOM."], "goto:Room_Bedroom");
        add_thing(655, 505, 711, 555, ["A WARM, STEADY HUM COMES FROM THIS SPOT.", "IT FEELS LIKE A SAFE PLACE.", "(SAVE POINT)"], "save");
        add_thing(1000, 150, 1100, 315, ["THE WAY OUT OF THE HOUSE.", "THE RAIN IS LOUDER HERE."], "goto:Room_Game");
        add_thing(420, 170, 520, 285, ["A FAMILY PHOTO.", "A KID AND AN OLD MAN IN FRONT OF A RADIO TOWER.", "THE OLD MAN IS SMILING. THE KID IS NOT."], "");
        add_thing(850, 170, 950, 285, ["A CALENDAR.", "EVERY DAY IS CROSSED OUT.", "EXCEPT TODAY."], "");
        if (rname == "Room_FakeHallway" && !global.gatser_seen) {
            add_thing(620, 150, 720, 315, ["A GRAY DOOR.", "IT WAS NOT HERE YESTERDAY.", "MAYBE IT WAS NEVER HERE."], "goto:Fake_Room_Mystery_Man");
        }
        break;

    case "Fake_Room_Mystery_Man":
        px = 683; py = 650; minx = 410; maxx = 956; miny = 400; maxy = 690;
        add_thing(620, 695, 740, 770, ["GO BACK."], "goto:Room_FakeHallway");
        break;

    case "Room_Game":
        px = -1000; py = -1000;
        break;
}

window_set_caption("Soul Signal");

// a loaded save file: Eli stands where he was saved, and the introduction of the room is not played again
if (variable_global_exists("load_pos") && is_array(global.load_pos)) {
    px = global.load_pos[0];
    py = global.load_pos[1];
    global.load_pos = undefined;
    dlg = [];
}
