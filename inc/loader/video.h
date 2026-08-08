#ifndef LOADER_VIDEO_H
#define LOADER_VIDEO_H

#include <stdtype.h>

typedef enum {
    VGA_COLOR_L_BLACK = 0,
    VGA_COLOR_L_BLUE,
    VGA_COLOR_L_GREEN,
    VGA_COLOR_L_CYAN,
    VGA_COLOR_L_RED,
    VGA_COLOR_L_MAGENTA,
    VGA_COLOR_L_YELLOW,
    VGA_COLOR_L_WHITE,
    VGA_COLOR_H_BLACK,
    VGA_COLOR_H_BLUE,
    VGA_COLOR_H_GREEN,
    VGA_COLOR_H_CYAN,
    VGA_COLOR_H_RED,
    VGA_COLOR_H_MAGENTA,
    VGA_COLOR_H_YELLOW,
    VGA_COLOR_H_WHITE,
} VGA_COLORS;

// VGA functions
void init_vga(void);
short vga_add_entry(int index, uint8_t character, VGA_COLORS fore, VGA_COLORS back);
void vga_put_char(uint8_t character);

#endif
