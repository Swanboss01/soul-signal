// Character creation in the style of a "who are you" survey:
// 0 how to play, 1 dark lines, 2 head, 3 torso, 4 legs, 5 name, 6 is the name correct, 7 questions, 8 the end
state = 0;
prev_state = -1;
fade = 1;       // black fade between screens
chars = 0;
dline = 0;
sel = 0;

howto = "HOW TO PLAY\n\nARROW KEYS / WASD   MOVE\nZ / ENTER   CONFIRM, TALK\nX / SHIFT   CANCEL, GO BACK\nC / CTRL   OPEN THE MENU\nF4   FULLSCREEN";
dlines = ["ARE YOU THERE?", "CAN YOU HEAR THE SIGNAL?", "GOOD.", "YOU NEED A VESSEL.", "LET US BUILD ONE."];

// the vessel
head = 0; torso = 0; legs = 0;

// the name
letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
pname = "";
maxname = 8;
cursor = 0;     // 0-25 letters, 26 = BACK, 27 = DONE
yesno = 0;

// the questions
qs = [
    { q: "WHAT FOOD WILL IT LIKE?", o: ["SWEET", "SOFT", "SOUR", "SALTY", "BITTER", "COLD"] },
    { q: "WHICH BLOOD TYPE WILL IT HAVE?", o: ["A", "AB", "B", "C", "D", "E"] },
    { q: "WHAT COLOR WILL IT LOVE?", o: ["RED", "BLUE", "GREEN", "CYAN", "VIOLET"] },
    { q: "GIVE IT A GIFT.", o: ["KINDNESS", "MIND", "COURAGE", "PATIENCE", "VOICE"] },
    { q: "HOW DO YOU FEEL ABOUT\nYOUR VESSEL?\n(IT WILL NOT HEAR.)", o: ["LOVE", "HOPE", "DOUBT", "FEAR"] },
    { q: "HAVE YOU ANSWERED\nHONESTLY?", o: ["YES", "NO"] }
];
qi = 0;
answers = array_create(array_length(qs), 0);

// the end
fin = 0;
finpages = [];

// pixel art of the vessel: S skin, H hair, E eyes, M mouth, T shirt, W white, P trousers, B boots, . empty
heads = [
    ["...HHHHHH...", "..HHHHHHHH..", ".HHHHHHHHHH.", ".HSSSSSSSSH.", ".SSESSSSESS.", ".SSSSSSSSSS.", ".SSSSMMSSSS.", "..SSSSSSSS..", "...SSSSSS..."],
    ["HHHHHHHHHHHH", "HHHHHHHHHHHH", "HSSSSSSSSSSH", "SSESSSSSSESS", "SSSSSSSSSSSS", "SSSSSMMSSSSS", "SSSSSSSSSSSS", ".SSSSSSSSSS.", "............"],
    [".HH......HH.", "HHHHHHHHHHHH", "HHHHHHHHHHHH", "HHSSSSSSSSHH", "HHSESSSSESHH", "HHSSSSSSSSHH", "HHSSSMMSSSHH", ".HHSSSSSSHH.", "..HH....HH.."]
];
torsos = [
    [".TTTTTTTTTT.", "TTTTTTTTTTTT", "TTTTTTTTTTTT", "TTTTTTTTTTTT", "TTTWWWWWTTTT", "TTTTTTTTTTTT", ".TTTTTTTTTT.", "..TTTTTTTT.."],
    [".TTTTTTTTTT.", "WWWWWWWWWWWW", "TTTTTTTTTTTT", "WWWWWWWWWWWW", "TTTTTTTTTTTT", "WWWWWWWWWWWW", ".TTTTTTTTTT.", "..TTTTTTTT.."],
    [".TTTTTWTTTT.", "TTTTTTWTTTTT", "TTTTTTWTTTTT", "TTTTTTWTTTTT", "TTTTTTWTTTTT", "TTTTTTWTTTTT", ".TTTTTWTTTT.", "..TTTTWTTT.."]
];
legsmaps = [
    [".PPPPPPPPPP.", ".PPPP..PPPP.", ".PPPP..PPPP.", ".PPPP..PPPP.", ".PPPP..PPPP.", ".BBBB..BBBB.", "BBBBB..BBBBB"],
    [".PPPPPPPPPP.", ".PPPP..PPPP.", ".SSSS..SSSS.", ".SSSS..SSSS.", ".SSSS..SSSS.", ".BBBB..BBBB.", "BBBBB..BBBBB"],
    [".PPPPPPPPPP.", "PPPPPPPPPPPP", "PPPPPPPPPPPP", "PPPPPPPPPPPP", ".PPPPPPPPPP.", ".BBB....BBB.", "BBBB....BBBB"]
];

// colours of the pixel art
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

// one pixel-art map: pass 0 draws the white outline, pass 1 the colours
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

// the vessel: head (0-2), torso (0-2), legs (0-2); -1 = not shown yet. It breathes a little.
body_draw = function(_x, _y, _h, _tt, _l, _s) {
    var _bob = round(sin(current_time / 400) * 2);
    var _x0 = _x - 6 * _s;
    for (var _pass = 0; _pass < 2; _pass++) {
        if (_l >= 0) map_draw(legsmaps[_l], _x0, _y + 17 * _s, _s, _pass);
        if (_tt >= 0) map_draw(torsos[_tt], _x0, _y + 9 * _s + _bob, _s, _pass);
        if (_h >= 0) map_draw(heads[_h], _x0, _y + _bob * 2, _s, _pass);
    }
};

// the leitmotif (E - C - B - E, "ECHO") and the secret of another universe.
// Import the sounds in the IDE with these names: snd_leitmotif and snd_secret. Without them the game just stays silent.
motif_played = false;
secret_t = 0;
secret_lines = [
    "SIGNAL 000.0",
    "THIS IS NOT YOUR WORLD.",
    "WE WERE THE FIRST SIGNAL.",
    "THE OPERATOR DOES NOT KNOW US.",
    "DO NOT TUNE IN."
];
secret_stop = function() {
    var _s = asset_get_index("snd_secret");
    if (_s != -1) audio_stop_sound(_s);
};
play_sound_safe = function(_name, _loop) {
    var _s = asset_get_index(_name);
    if (_s != -1) audio_play_sound(_s, 1, _loop);
};

// during the survey the window says this
window_set_caption("hello im here");
