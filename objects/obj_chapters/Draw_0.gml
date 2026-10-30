var _t = current_time / 1000;
var _cx0 = room_width / 2;
var _blink = ((current_time div 500) mod 2 == 0);

// background: slow deep blue waves
draw_set_color(make_color_rgb(8, 8, 30));
draw_rectangle(0, 0, room_width, room_height, false);
for (var i = 0; i < 40; i++) {
    var _w = 260 + sin(_t * 0.7 + i * 0.35) * 160 + cos(_t * 0.4 + i * 0.2) * 80;
    draw_set_alpha(0.22);
    draw_set_color(make_color_rgb(38, 32, 96));
    draw_rectangle(_cx0 - _w, i * 20, _cx0 + _w, i * 20 + 9, false);
}
draw_set_alpha(1);

// a small shake when a locked chapter is picked
var _sx = (shake > 0) ? irandom_range(-6, 6) : 0;

var _heart = function(_x, _y) {
    var _c = draw_get_color();
    draw_set_color(c_red);
    draw_circle(_x - 6, _y - 4, 7, false);
    draw_circle(_x + 6, _y - 4, 7, false);
    draw_triangle(_x - 13, _y - 1, _x + 13, _y - 1, _x, _y + 14, false);
    draw_set_color(_c);
};

switch (state) {
    case 0:
        draw_set_color(c_white);
        para(_cx0, 190, string_copy(story, 1, floor(chars)), 2, 50, true);
        if (chars >= string_length(story) && _blink) { draw_set_color(c_yellow); para(_cx0, 700, "[ENTER] CONTINUE", 1.4, 30, true); }
        break;

    case 1:
        draw_set_color(c_white);
        para(_cx0, 60, "CHOOSE A CHAPTER.", 2.2, 50, true);
        for (var k = 0; k < array_length(chapter_names); k++) {
            var _y = 170 + k * 62;
            var _x = 330 + _sx;
            if (unlocked[k]) {
                draw_set_color((sel == k) ? c_yellow : c_white);
                para(_x, _y, "CHAPTER " + string(k + 1) + ":  " + chapter_names[k], 2, 40, false);
            } else {
                draw_set_color(make_color_rgb(90, 92, 112));      // greyed out
                para(_x, _y, "CHAPTER " + string(k + 1) + ":  " + chapter_names[k], 2, 40, false);
                draw_rectangle(_x + 640, _y + 10, _x + 664, _y + 30, false);         // a small padlock
                draw_rectangle(_x + 645, _y - 2, _x + 659, _y + 10, true);
            }
            if (sel == k) { draw_set_color(c_white); _heart(_x - 36, _y + 14); }
        }
        draw_set_color(c_gray);
        para(_cx0, 700, "UP / DOWN: CHOOSE   Z: START", 1.3, 30, true);
        if (msg_t > 0) { draw_set_color(c_red); para(_cx0, 640, msg, 1.5, 30, true); }
        break;

    case 2:
        draw_set_color(c_white);
        para(_cx0, 60, "CHAPTER " + string(chapter_sel) + ": CHOOSE A FILE.", 2.2, 50, true);
        for (var s = 0; s < slot_count; s++) {
            var _fy = 190 + s * 150;
            var _fx = 230;
            var _name = "FILE " + string(chapter_sel) + "-" + string(s + 1);
            draw_set_color((slot_sel == s) ? c_yellow : c_white);
            draw_rectangle(_fx, _fy, _fx + 900, _fy + 110, true);
            draw_rectangle(_fx + 3, _fy + 3, _fx + 897, _fy + 107, true);
            para(_fx + 30, _fy + 16, _name, 2, 40, false);
            var _info = slot_info[s];
            if (_info == undefined) {
                draw_set_color(make_color_rgb(110, 112, 132));
                para(_fx + 30, _fy + 62, "EMPTY  -  A NEW GAME", 1.6, 30, false);
            } else {
                var _mins = floor(_info.playtime / 60);
                var _secs = floor(_info.playtime) mod 60;
                draw_set_color((slot_sel == s) ? c_yellow : c_white);
                para(_fx + 30, _fy + 62, string_upper(_info.name) + "   " + string_upper(string_replace(_info.room, "Room_", "")) + "   " + string(_mins) + ":" + ((_secs < 10) ? "0" : "") + string(_secs), 1.6, 30, false);
            }
            if (slot_sel == s) { draw_set_color(c_white); _heart(_fx - 34, _fy + 30); }
        }
        draw_set_color(c_gray);
        para(_cx0, 700, "Z: PLAY   X: BACK   D: DELETE A FILE", 1.3, 30, true);
        if (msg_t > 0) { draw_set_color(c_red); para(_cx0, 650, msg, 1.5, 30, true); }
        break;
}

if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
}
draw_set_color(c_white);
draw_set_halign(fa_left);
