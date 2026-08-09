#include <stdbool.h>
#include <stdtype.h>

#include <stdlib.h>

// A function I copied
void reverse(char str[], int length)
{
    int start = 0;
    int end = length - 1;
    while (start < end) {
        char temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        end--;
        start++;
    }
}

char *itoa(int num, char* str, int base) {
    int i = 0;
    bool negative = (base == 10) & ((num & 0x80000000) >> 31); // funny way to check if it's negative

    // Exit if 0
    if (num == 0) {
        str[i++] = '0';
        str[i] = '\0';
        return str;
    }

    // Make the number positive if negative
    if (negative)
        num = -num;

    // Process the number and put it into the string
    while (num != 0) {
        // must cast as unsigned or it'll break
        uint32_t rem = (uint32_t)(num) % base;
        str[i++] = (rem > 9) ? (rem - 10) + 'a' : rem + '0';
        num = (uint32_t)(num) / base;
    }

    // Add the negative sign
    if (negative)
        str[i++] = '-';

    // Null the end
    str[i] = '\0';

    // Reverse the string and end it
    reverse(str, i);
    return str;
}