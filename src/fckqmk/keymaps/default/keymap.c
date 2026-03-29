#include QMK_KEYBOARD_H
#include "vim.h"

enum layers {
    BASE,
    NUMBERS,
    VIM_COMPATIBILITY,
    SOUNDS,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [BASE] = LAYOUT(
        KC_Q, KC_W, KC_E, KC_R, KC_T, KC_SPACE, KC_DELETE, KC_Y, KC_U, KC_I, KC_O,
        KC_P, MT(MOD_LALT, KC_A), MT(MOD_LGUI, KC_S), MT(MOD_LCTL, KC_D),
        MT(MOD_LSFT, KC_F), KC_G, TG(VIM_COMPATIBILITY), LT(NUMBERS, KC_ESCAPE),
        MT(MOD_RSFT, KC_H), MT(MOD_RCTL, KC_J), MT(MOD_RGUI, KC_K),
        MT(MOD_RALT, KC_L), KC_SLASH, KC_Z, KC_X, KC_C, KC_V, KC_B, KC_ENTER,
        KC_BACKSPACE, KC_N, KC_M, KC_SEMICOLON, KC_DOT, KC_COMMA),

    [NUMBERS] =
        LAYOUT(KC_1, KC_2, KC_3, KC_4, KC_5, _______, _______, KC_6, KC_7, KC_8,
               KC_9, KC_0, _______, _______, _______, _______, _______,
               OSL(SOUNDS), _______, _______, _______, _______, _______, _______,
               _______, _______, _______, _______, _______, _______, _______,
               _______, _______, _______, _______, _______),

    [VIM_COMPATIBILITY] = LAYOUT(
        _______, NEXT_WORD, _______, REDO, _______, _______, _______, COPY_SELECT,
        UNDO, _______, _______, PASTE, _______, _______, _______, _______,
        START_END, TG(VIM_COMPATIBILITY), _______, MOVE_CURSOR_LEFT,
        MOVE_CURSOR_DOWN, MOVE_CURSOR_UP, MOVE_CURSOR_RIGHT, _______, _______,
        CUT, _______, VISUAL_TOGGLE, PREVIOUS_WORD, _______, _______, SELECT_NEXT,
        _______, _______, _______, _______),

    [SOUNDS] =
        LAYOUT(KC_F1, KC_F2, KC_F3, KC_F4, KC_F5, _______, _______, _______,
               _______, _______, _______, _______, KC_F6, KC_F7, KC_F8, KC_F9,
               KC_F10, _______, _______, _______, _______, _______, _______,
               _______, KC_F11, KC_F12, KC_F13, KC_F14, KC_F15, _______, _______,
               _______, _______, _______, _______, _______),
};
