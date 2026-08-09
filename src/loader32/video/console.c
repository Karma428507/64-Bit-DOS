#include <video.h>

#include <stdarg.h>
#include <stdlib.h>

void printk(const char *fmt, ...) {
    char buf[100];
    va_list ap;
    int num;

    va_start(ap, fmt);

    for (int i = 0; fmt[i] != '\0'; i++) {
        if (fmt[i] == '%') {
            // throw an error later
            if (fmt[++i] == '\0')
                return;

            // see what options should be used
            switch (fmt[i]) {
                case '%':
                    vga_put_char('%');
                    break;
                case 'c':
                    char c = (char)va_arg(ap, int);
                    vga_put_char(c);
                    break;
                case 's':
                    const char *msg = (const char *)va_arg(ap, int);
                    put_string(msg);
                    break;
                case 'd':
                    num = va_arg(ap, int);
                    itoa(num, buf, 10);
                    put_string(buf);
                    break;
                case 'x':
                    num = va_arg(ap, int);
                    itoa(num, buf, 16);
                    put_string(buf);
                    break;
                default:
                    // throw an error
                    break;
            }
        } else {
            vga_put_char(fmt[i]);
        }
    }

    va_end(ap);
}

void put_string(const char *msg) {
    for (int i = 0; msg[i] != '\0'; i++)
        vga_put_char(msg[i]);
}