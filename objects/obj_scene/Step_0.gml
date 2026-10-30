// fade in when a room starts; fade out and change room when asked
if (fading_out) {
    fade = min(1, fade + 0.06);
    if (fade >= 1) {
        var _r = asset_get_index(goto_name);
        if (_r != -1) room_goto(_r);
        else fading_out = false;
    }
    exit;
}
fade = max(0, fade - 0.05);

var _ok = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"));

// the mystery man vanishes
if (man_state == 1) {
    man_t++;
    if (man_t > 150) {
        man_state = 2;
        say(["...", "HE IS GONE.", "THE AIR STILL HUMS. FOUR SOFT NOTES, BACKWARDS."], "", "");
    }
    exit;
}

// a dialog is open: it blocks everything else
if (array_length(dlg) > 0) {
    var _cur = dlg[dline];
    dchars = min(string_length(_cur), dchars + 1);
    if (_ok) {
        if (dchars < string_length(_cur)) dchars = string_length(_cur);
        else {
            dline++;
            dchars = 0;
            if (dline >= array_length(dlg)) {
                dlg = [];
                var _a = after;
                after = "";
                if (_a != "") run_after(_a);
            }
        }
    }
    exit;
}

// movement (arrows or WASD, X to run)
var _dx = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var _dy = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));
var _sp = (keyboard_check(ord("X")) || keyboard_check(vk_shift)) ? 6 : 3.5;
moving = (_dx != 0 || _dy != 0);
if (_dx != 0) pdir = (_dx > 0) ? 3 : 2;
if (_dy != 0) pdir = (_dy > 0) ? 0 : 1;

var _hit = function(_x, _y) {
    if (_x < minx || _x > maxx || _y < miny || _y > maxy) return true;
    for (var i = 0; i < array_length(walls); i++) {
        var _w = walls[i];
        if (overlap(_x - 18, _y - 10, _x + 18, _y, _w[0], _w[1], _w[2], _w[3])) return true;
    }
    if (rname == "Fake_Room_Mystery_Man" && man_state == 0 && overlap(_x - 18, _y - 10, _x + 18, _y, 643, 400, 723, 455)) return true;
    return false;
};
if (_dx != 0 && !_hit(px + _dx * _sp, py)) px += _dx * _sp;
if (_dy != 0 && !_hit(px, py + _dy * _sp)) py += _dy * _sp;

// talk to what is in front of you
if (_ok) {
    var _x1 = px - 18, _y1 = py - 10, _x2 = px + 18, _y2 = py;
    switch (pdir) {
        case 0: _y1 = py; _y2 = py + 30; break;
        case 1: _y1 = py - 40; _y2 = py - 10; break;
        case 2: _x1 = px - 48; _x2 = px - 18; break;
        case 3: _x1 = px + 18; _x2 = px + 48; break;
    }
    if (rname == "Fake_Room_Mystery_Man" && man_state == 0 && overlap(_x1, _y1, _x2, _y2, 643, 400, 723, 455)) {
        say(man_lines, "???", "vanish");
    } else {
        for (var i = 0; i < array_length(things); i++) {
            var _t = things[i];
            if (overlap(_x1, _y1, _x2, _y2, _t.x1, _t.y1, _t.x2, _t.y2)) {
                if (array_length(_t.lines) > 0) say(_t.lines, "", _t.act);
                else if (_t.act != "") run_after(_t.act);
                break;
            }
        }
    }
}
