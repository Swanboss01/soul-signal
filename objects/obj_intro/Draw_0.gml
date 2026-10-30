var _t = current_time / 1000;
var _cx0 = room_width / 2;
var _blink = ((current_time div 500) mod 2 == 0);

// ---------------------------------------------------------------- small helpers
// text with a pixel-font look: every letter on a fixed grid, several lines, optional centering
var _para = function(_x, _y, _str, _s, _lh, _center) {
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

// the red heart that points at the choice
var _heart = function(_x, _y) {
    var _c = draw_get_color();
    draw_set_color(c_red);
    draw_circle(_x - 6, _y - 4, 7, false);
    draw_circle(_x + 6, _y - 4, 7, false);
    draw_triangle(_x - 13, _y - 1, _x + 13, _y - 1, _x, _y + 14, false);
    draw_set_color(_c);
};

// ---------------------------------------------------------------- background
if (state <= 1 || state == 8 || state == 9) {
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
} else {
    // a slow, symmetrical, deep blue wave pattern
    draw_set_color(make_color_rgb(8, 8, 30));
    draw_rectangle(0, 0, room_width, room_height, false);
    for (var i = 0; i < 40; i++) {
        var _y = i * 20;
        var _w = 260 + sin(_t * 0.7 + i * 0.35) * 160 + cos(_t * 0.4 + i * 0.2) * 80;
        draw_set_alpha(0.30);
        draw_set_color(make_color_rgb(38, 32, 96));
        draw_rectangle(_cx0 - _w, _y, _cx0 + _w, _y + 9, false);
        draw_set_alpha(0.18);
        draw_set_color(make_color_rgb(90, 70, 170));
        draw_rectangle(_cx0 - _w * 0.55, _y + 9, _cx0 + _w * 0.55, _y + 12, false);
    }
    draw_set_alpha(0.25);
    draw_set_color(make_color_rgb(70, 60, 150));
    for (var j = 0; j < 4; j++) {
        var _r = 90 + j * 70 + sin(_t + j) * 12;
        draw_ellipse(_cx0 - _r * 2.2, room_height / 2 - _r, _cx0 + _r * 2.2, room_height / 2 + _r, true);
    }
    draw_set_alpha(1);
}
draw_set_color(c_white);

// ---------------------------------------------------------------- screens
switch (state) {
    case 0:
        _para(110, 90, string_copy(howto, 1, floor(chars)), 1.6, 46, false);
        if (chars >= string_length(howto) && _blink) { draw_set_color(c_yellow); _para(110, 690, "[ENTER] CONTINUE", 1.4, 30, false); }
        break;

    case 1:
        _para(_cx0, 250, string_copy(dlines[dline], 1, floor(chars)), 2.4, 50, true);
        if (dline >= 2) _heart(_cx0, 450);
        break;

    case 2:
    case 3:
    case 4:
        var _what = (state == 2) ? "HEAD" : ((state == 3) ? "TORSO" : "LEGS");
        _para(_cx0, 50, "SELECT THE " + _what + "\nTHAT YOU PREFER.", 2, 46, true);
        for (var i = 0; i < 3; i++) {
            var _cx = _cx0 + (i - 1) * 300;
            var _hh = (state == 2) ? i : head;
            var _tt = (state == 3) ? i : ((state == 4) ? torso : -1);
            var _ll = (state == 4) ? i : -1;
            // the options that are not chosen are dimmer
            body_draw(_cx, 270, _hh, _tt, _ll, 8);
            if (sel != i) { draw_set_alpha(0.55); draw_set_color(make_color_rgb(8, 8, 30)); draw_rectangle(_cx - 110, 230, _cx + 110, 560, false); draw_set_alpha(1); draw_set_color(c_white); }
            if (sel == i) _heart(_cx, 225);
        }
        draw_set_color(c_gray);
        _para(_cx0, 700, "LEFT / RIGHT: CHOOSE   Z: CONFIRM   X: BACK", 1.2, 24, true);
        break;

    case 5:
        body_draw(1020, 230, head, torso, legs, 8);
        _para(110, 50, "NOW, A NAME.", 2, 46, false);
        _para(110, 125, pname + ((_blink) ? "_" : " "), 3, 50, false);
        for (var i = 0; i < 26; i++) {
            var _gx = 150 + (i mod 9) * 80;
            var _gy = 260 + (i div 9) * 80;
            draw_set_color((cursor == i) ? c_yellow : c_white);
            _para(_gx, _gy, string_char_at(letters, i + 1), 2.4, 40, false);
            if (cursor == i) _heart(_gx - 24, _gy + 18);
        }
        draw_set_color((cursor == 26) ? c_yellow : c_white);
        _para(150 + 6 * 80 + 60, 260 + 2 * 80, "BACK", 1.8, 30, false);
        if (cursor == 26) _heart(150 + 6 * 80 + 36, 260 + 2 * 80 + 14);
        draw_set_color((cursor == 27) ? c_yellow : c_white);
        _para(150, 260 + 4 * 80, "DONE", 2.4, 40, false);
        if (cursor == 27) _heart(124, 260 + 4 * 80 + 18);
        draw_set_color(c_gray);
        _para(110, 700, "ARROWS: MOVE   Z: PICK   X: ERASE", 1.2, 24, false);
        break;

    case 6:
        body_draw(1020, 230, head, torso, legs, 8);
        _para(110, 150, "IS THIS NAME CORRECT?", 2, 46, false);
        _para(110, 250, pname, 4, 60, false);
        draw_set_color((yesno == 0) ? c_yellow : c_white);
        _para(200, 500, "YES", 2.4, 40, false);
        if (yesno == 0) _heart(170, 518);
        draw_set_color((yesno == 1) ? c_yellow : c_white);
        _para(500, 500, "NO", 2.4, 40, false);
        if (yesno == 1) _heart(470, 518);
        break;

    case 7:
        body_draw(1020, 230, head, torso, legs, 8);
        _para(110, 60, qs[qi].q, 1.9, 44, false);
        var _top = 250;
        for (var i = 0; i < array_length(qs[qi].o); i++) {
            draw_set_color((sel == i) ? c_yellow : c_white);
            _para(190, _top + i * 60, qs[qi].o[i], 2, 40, false);
            if (sel == i) _heart(156, _top + i * 60 + 16);
        }
        draw_set_color(c_gray);
        _para(110, 700, "UP / DOWN: CHOOSE   Z: CONFIRM", 1.2, 24, false);
        break;

    case 9:
        // glitch: the lines appear one after the other, flicker, and some letters are replaced by noise
        var _glyphs = "#%&@$0123456789<>?/\|";
        var _n = min(array_length(secret_lines), 1 + floor(secret_t / 70));
        for (var i = 0; i < _n; i++) {
            var _line = secret_lines[i];
            var _out = "";
            for (var k = 1; k <= string_length(_line); k++) {
                var _ch = string_char_at(_line, k);
                if (_ch != " " && random(1) < 0.06) _ch = string_char_at(_glyphs, irandom(string_length(_glyphs) - 1) + 1);
                _out += _ch;
            }
            var _jx = (random(1) < 0.1) ? irandom_range(-8, 8) : 0;
            draw_set_color((i == 0) ? c_red : make_color_rgb(200, 200, 210));
            _para(110 + _jx, 120 + i * 90, _out, (i == 0) ? 2.4 : 1.7, 40, false);
        }
        // the scan lines of a bad signal
        draw_set_alpha(0.12);
        draw_set_color(c_white);
        for (var y2 = 0; y2 < room_height; y2 += 6) draw_rectangle(0, y2, room_width, y2 + 1, false);
        draw_set_alpha(1);
        if (secret_t > 240 && _blink) { draw_set_color(c_gray); _para(110, 700, "[ENTER] TURN AWAY", 1.4, 30, false); }
        break;

    case 8:
        _para(110, 110, string_copy(finpages[fin], 1, floor(chars)), 1.8, 48, false);
        if (chars >= string_length(finpages[fin]) && _blink) { draw_set_color(c_yellow); _para(110, 700, "[ENTER] CONTINUE", 1.4, 30, false); }
        break;
}

// the fade between two screens
if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
