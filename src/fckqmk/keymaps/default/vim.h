#pragma once
#include <fprint.h>

#define MAP_KEY(mod, key, result)                                              \
  case key:                                                                    \
    if (record->event.pressed) {                                               \
      tap_code16(result);                                                      \
    }                                                                          \
    return false;

#define VISUAL_OVERRIDE(key, result)                                           \
  case key:                                                                    \
    if (record->event.pressed) {                                               \
      if (visual_mode) {                                                       \
        tap_code16(LSFT(result));                                              \
      } else {                                                                 \
        tap_code16(result);                                                    \
      }                                                                        \
    }                                                                          \
    return false;

#define MOD_MAP_KEY(mod, key, result, modded_result)                           \
  case key:                                                                    \
    if (record->event.pressed) {                                               \
      if (get_mods() == MOD_BIT(mod)) {                                        \
        tap_code16(modded_result);                                             \
      } else {                                                                 \
        tap_code16(result);                                                    \
      }                                                                        \
    }                                                                          \
    return false;

#define CUT C(KC_X)
#define PASTE C(KC_V)
#define UNDO C(KC_Z)

enum vim_compatability_keys {
  MOVE_CURSOR_RIGHT = SAFE_RANGE,
  MOVE_CURSOR_LEFT,
  MOVE_CURSOR_UP,
  MOVE_CURSOR_DOWN,
  NEXT_WORD,
  PREVIOUS_WORD,
  SELECT_NEXT,
  SELECT_PREVIOUS,
  SELECT_ENTER,
  PAGE_UP,
  PAGE_DOWN,
  VISUAL_TOGGLE,
  REDO,
  START_END,
  COPY_SELECT,
};

bool visual_mode = false;

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    VISUAL_OVERRIDE(MOVE_CURSOR_RIGHT, KC_RIGHT)
    VISUAL_OVERRIDE(MOVE_CURSOR_LEFT, KC_LEFT)
    VISUAL_OVERRIDE(MOVE_CURSOR_UP, KC_UP)
    VISUAL_OVERRIDE(MOVE_CURSOR_DOWN, KC_DOWN)

    VISUAL_OVERRIDE(NEXT_WORD, C(KC_RIGHT))
    VISUAL_OVERRIDE(PREVIOUS_WORD, C(KC_LEFT))

    MAP_KEY(MOD_MASK_CTRL, SELECT_NEXT, KC_TAB)
    MAP_KEY(MOD_MASK_CTRL, SELECT_PREVIOUS, S(KC_TAB))
    MOD_MAP_KEY(MOD_MASK_CTRL, COPY_SELECT, C(KC_C), KC_ENTER)

    MAP_KEY(MOD_MASK_CTRL, PAGE_UP, KC_PAGE_UP)
    MAP_KEY(MOD_MASK_CTRL, PAGE_DOWN, KC_PAGE_DOWN)

    MAP_KEY(MOD_MASK_CTRL, REDO, C(KC_Y))

    MOD_MAP_KEY(MOD_MASK_SHIFT, START_END, KC_HOME, KC_END)

  case VISUAL_TOGGLE:
    visual_mode = !visual_mode;
    return false;
  }
  return true;
}
