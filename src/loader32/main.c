// "standard" libraries
#include <stdlib.h>
#include <stdtype.h>

// loader libaries
#include <video.h>
#include <multiboot.h>

#ifdef __x86_64__
#error "Loader must be compiled in 32-Bit mode with the -32 option"
#endif

#if __ring__ != 0
#error "Loader must be compiled with the -R0 flag enabled"
#endif

void main(uint32_t magic, uint32_t multiboot) {
    MULTIBOOT_INFO *header = (MULTIBOOT_INFO *)multiboot;
    
    // Make this check if the OS has been loaded before or if there's an issue with the bootloader.
    if (magic != 0x2BADB002) {
        init_vga();
        printk("Error, cannot load the OS, make sure you are using a bootloader like GRUB.\nPress any key to restart");
        // LIES
        return;
    }

    init_vga();
    printk("Multiboot flags %b\n", header->flags);
    printk("Modules %d\n", header->mods_count);
    printk("Bootloader name %s\n", header->boot_loader_name);
}