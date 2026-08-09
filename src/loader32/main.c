#include <video.h>

// "standard" libraries
#include <stdlib.h>
#include <stdtype.h>

#ifdef __x86_64__
#error "Loader must be compiled in 32-Bit mode with the -32 option"
#endif

#if __ring__ != 0
#error "Loader must be compiled with the -R0 flag enabled"
#endif

void main(uint32_t magic, uint32_t multiboot) {
    char test[100];
    
    init_vga();

    itoa(magic, test, 16);

    for (int i = 0; test[i] != '\0'; i++)
        vga_put_char(test[i]);
    
    vga_put_char(' ');
    vga_put_char('t');
    vga_put_char('e');
    vga_put_char('s');
    vga_put_char('t');
}