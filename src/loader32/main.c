#include <video.h>

#ifdef __x86_64__
#error "Loader must be compiled in i386"
#endif

#ifdef __kernel__
#error "Loader must have -Dk enabled in the script compile settings"
#endif

void main(void) {
    init_vga();

    vga_put_char('t');
    vga_put_char('e');
    vga_put_char('s');
    vga_put_char('t');
}