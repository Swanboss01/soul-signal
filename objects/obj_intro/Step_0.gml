// the fade: every new screen starts from black
if (state != prev_state) { fade = 1; prev_state = state; }
fade = max(0, fade - 0.06);

var _ok = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"));
var _back = keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift);
var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));

switch (state) {
    case 0: // how to play
        chars = min(string_length(howto), chars + 1.2);
        if (_ok) {
            if (chars < string_length(howto)) chars = string_length(howto);
            else { state = 1; chars = 0; dline = 0; }
        }
        break;

    case 1: // the dark lines
        chars = min(string_length(dlines[dline]), chars + 0.5);
        if (dline == 2 && !motif_played) { motif_played = true; play_sound_safe("snd_leitmotif", false); }
        if (_ok) {
            if (chars < string_length(dlines[dline])) chars = string_length(dlines[dline]);
            else if (dline < array_length(dlines) - 1) { dline++; chars = 0; }
            else { state = 2; sel = 0; }
        }
        break;

    case 2: // head, torso, legs: three choices each
    case 3:
    case 4:
        if (_left) sel = (sel + 2) mod 3;
        if (_right) sel = (sel + 1) mod 3;
        if (_back && state > 2) { state--; sel = 0; }
        if (_ok) {
            if (state == 2) head = sel;
            if (state == 3) torso = sel;
            if (state == 4) legs = sel;
            state++; sel = 0; cursor = 0;
        }
        break;

    case 5: // the name, on a grid of letters
        if (_right) cursor = (cursor + 1) mod 28;
        if (_left) cursor = (cursor + 27) mod 28;
        if (_down) cursor = min(27, cursor + 9);
        if (_up) cursor = max(0, cursor - 9);
        if (_back && string_length(pname) > 0) pname = string_delete(pname, string_length(pname), 1);
        if (_ok) {
            if (cursor < 26) {
                if (string_length(pname) < maxname) pname += string_char_at(letters, cursor + 1);
            } else if (cursor == 26) {
                if (string_length(pname) > 0) pname = string_delete(pname, string_length(pname), 1);
            } else if (string_length(pname) > 0) {
                state = 6; yesno = 0;
            }
        }
        break;

    case 6: // is this name correct?
        if (_left || _right) yesno = 1 - yesno;
        if (_ok) {
            if (yesno == 0 && pname == "NULL") { state = 9; secret_t = 0; chars = 0; play_sound_safe("snd_secret", false); }
            else if (yesno == 0) { state = 7; qi = 0; sel = 0; }
            else state = 5;
        }
        break;

    case 7: // the questions
        var _n = array_length(qs[qi].o);
        if (_up) sel = (sel + _n - 1) mod _n;
        if (_down) sel = (sel + 1) mod _n;
        if (_ok) {
            answers[qi] = sel;
            qi++; sel = 0;
            if (qi >= array_length(qs)) {
                finpages = [
                    "THANK YOU, " + pname + ".\n\nYOUR VESSEL IS READY.",
                    "NOBODY CAN CHOOSE\nWHO THEY ARE IN THIS WORLD.\n\nNOT THE VESSEL.\nNOT YOU.",
                    "YOUR VESSEL WAS NEVER\nYOURS TO NAME.\n\nITS NAME IS ELI HART.",
                    "ELI HART, 16 YEARS OLD.\nSLIM, 170 CM, MESSY BROWN HAIR,\nGREEN EYES, COLD HANDS.\nBLOOD TYPE E, THE RAREST OF THE SIX.\n\nHE LIKES PIXEL ART GAMES, RAINY DAYS,\nHOT CHOCOLATE, OLD RADIOS AND DRAWING.",
                    "YOU OPEN YOUR EYES...\n\nAND YOU ARE IN ELI'S BODY."
                ];
                global.pname = pname; global.vhead = head; global.vtorso = torso; global.vlegs = legs; global.answers = answers;
                state = 8; fin = 0; chars = 0;
            }
        }
        break;

    case 9: // the secret: a signal from another universe
        secret_t++;
        chars = min(string_length(secret_lines[0]) + 200, chars + 0.4);
        if (_ok && secret_t > 240) {
            secret_stop();
            pname = "";
            cursor = 0;
            state = 5;
        }
        break;

    case 8: // the end
        chars = min(string_length(finpages[fin]), chars + 0.6);
        if (_ok) {
            if (chars < string_length(finpages[fin])) chars = string_length(finpages[fin]);
            else if (fin < array_length(finpages) - 1) { fin++; chars = 0; }
            else room_goto_next();
        }
        break;
}
