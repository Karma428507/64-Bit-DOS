#include <video.h>

uint16_t *pointer;
VGA_COLORS foreground, background;
int cursor;

// Add more arguements later for the framebuffer.
void init_vga(void) {
    pointer = (uint16_t *)0xB8000;
    foreground = VGA_COLOR_H_WHITE;
    background = VGA_COLOR_L_BLACK;
    cursor = 0;

    for (int i = 0; i < 80 * 25; i++)
        vga_add_entry(i, 0x00, foreground, background);
}

short vga_add_entry(int index, uint8_t character, VGA_COLORS fore, VGA_COLORS back) {
    short entry = (back & 0x0F) << 4;
    entry |= (fore & 0x0F);
    entry <<= 8;
    entry |= (character & 0xFF);

    pointer[index] = entry;
    return entry;
}

void vga_put_char(uint8_t character) {
    switch (character) {
        case '\n':
            cursor = ((cursor / 80) + 1) * 80;
            return;
        case '\t':
            cursor = ((cursor / 4) + 1) * 80;
            return;
    }

    // make it shift up after line 22
    if (cursor / 25 > 22) {

    }

    vga_add_entry(cursor++, character, foreground, background);
}