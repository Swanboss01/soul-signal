// The decor of the rooms (walls, floor, furniture) is now a picture on the Background layer of each room,
// so you can see it in the room editor. This event only draws what moves or changes:
// the rain, the lamp flicker, the gray door, the mystery man, Eli and the dialog.
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _t = current_time;

switch (rname) {
    case "Room_Bedroom":
        // rain behind the window
        draw_set_color(make_color_rgb(120, 150, 220));
        for (var d = 0; d < 40; d++) {
            var _rx = 708 + ((d * 37) mod 144);
            var _ry = 158 + (((d * 53) + _t * (0.15 + (d mod 5) * 0.04)) mod 110);
            draw_line(_rx, _ry, _rx - 2, _ry + 9);
        }
        draw_set_color(c_white); draw_line(780, 158, 780, 277); draw_line(708, 217, 852, 217);
        break;

    case "Room_Hallway":
    case "Room_FakeHallway":
        // the save point: a small star that pulses
        var _p = 1 + 0.12 * sin(_t / 220);
        var _sy = 520 + sin(_t / 400) * 4;
        draw_set_alpha(0.25); draw_set_color(make_color_rgb(255, 230, 120)); draw_circle(683, _sy, 34 * _p, false); draw_set_alpha(1);
        draw_set_color(make_color_rgb(255, 215, 60));
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(683, _sy);
        for (var q = 0; q <= 10; q++) {
            var _ang = q * 36 - 90;
            var _rad = ((q mod 2) == 0 ? 26 : 11) * _p;
            draw_vertex(683 + lengthdir_x(_rad, _ang), _sy + lengthdir_y(_rad, _ang));
        }
        draw_primitive_end();
        // the ceiling light flickers a little in the fake hallway
        if (rname == "Room_FakeHallway" && (_t mod 3000) < 90) {
            draw_set_alpha(0.35); draw_set_color(c_black);
            draw_rectangle(100, 321, 1266, 739, false);
            draw_set_alpha(1);
        }
        // the gray door, only in the fake hallway, and only until you have met the man
        if (rname == "Room_FakeHallway" && !global.gatser_seen) {
            draw_set_color(make_color_rgb(150, 150, 156)); draw_rectangle(620, 150, 720, 315, false);
            draw_set_color(make_color_rgb(120, 120, 126)); draw_rectangle(630, 160, 710, 305, true);
        }
        break;

    case "Fake_Room_Mystery_Man":
        // the mystery man: his name is never shown, only "???"
        if (man_state == 0) {
            draw_man(683, 455, 1);
            draw_set_color(c_gray); para(683, 262, "???", 1.6, 30, true);
        } else if (man_state == 1) {
            var _a = max(0, 1 - man_t / 140);
            draw_man(683, 455, _a);
            if (_a > 0.25) { draw_set_color(c_gray); para(683, 262, "???", 1.6, 30, true); }
        }
        break;

    case "Room_Game":
        draw_set_color(c_black);
        draw_rectangle(0, 0, room_width, room_height, false);
        draw_set_color(c_white);
        para(room_width / 2, 330, "TO BE CONTINUED...", 2.6, 60, true);
        draw_set_color(c_gray);
        para(room_width / 2, 430, "THANK YOU FOR PLAYING THE DEMO.", 1.5, 30, true);
        break;
}

// ------------------------------------------------------------------ the player
if (rname != "Room_Game") draw_eli(px, py);

// ------------------------------------------------------------------ the dialog box
if (array_length(dlg) > 0) {
    draw_set_color(c_black);
    draw_rectangle(80, 540, 1286, 740, false);
    draw_set_color(c_white);
    draw_rectangle(80, 540, 1286, 740, true);
    draw_rectangle(84, 544, 1282, 736, true);
    if (dspeaker != "") { draw_set_color(c_gray); para(110, 556, dspeaker, 1.4, 30, false); }
    draw_set_color(c_white);
    para(110, (dspeaker != "") ? 600 : 580, string_copy(dlg[dline], 1, floor(dchars)), 1.9, 48, false);
    if (dchars >= string_length(dlg[dline]) && ((current_time div 500) mod 2 == 0)) {
        draw_set_color(c_yellow);
        para(1230, 700, ">", 1.6, 30, false);
    }
}

// ------------------------------------------------------------------ the "save?" question
if (ask) {
    draw_set_color(c_black);
    draw_rectangle(80, 540, 1286, 740, false);
    draw_set_color(c_white);
    draw_rectangle(80, 540, 1286, 740, true);
    draw_rectangle(84, 544, 1282, 736, true);
    para(110, 575, "SAVE YOUR PROGRESS TO FILE " + string(global.chapter) + "-" + string(global.slot) + "?", 1.7, 40, false);
    draw_set_color((ask_sel == 0) ? c_yellow : c_white);
    para(330, 650, "YES", 2, 40, false);
    draw_set_color((ask_sel == 1) ? c_yellow : c_white);
    para(760, 650, "NO", 2, 40, false);
    var _hx = (ask_sel == 0) ? 296 : 726;
    draw_set_color(c_red);
    draw_circle(_hx - 6, 662, 7, false); draw_circle(_hx + 6, 662, 7, false);
    draw_triangle(_hx - 13, 665, _hx + 13, 665, _hx, 680, false);
    draw_set_color(c_white);
}

// ------------------------------------------------------------------ the fade
if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
}
draw_set_color(c_white);
